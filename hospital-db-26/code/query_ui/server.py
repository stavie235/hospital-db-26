#!/usr/bin/env python3
from __future__ import annotations

import json
import mimetypes
import os
import re
import subprocess
import time
from http import HTTPStatus
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import urlparse

from saved_queries import DEFAULT_QUERY_ID, SAVED_QUERIES, get_all_queries, load_custom_queries, save_custom_queries


BASE_DIR = Path(__file__).resolve().parent
STATIC_DIR = BASE_DIR / "static"
CODE_DIR = BASE_DIR.parent
COMPOSE_FILE = Path(
    os.environ.get("HOSPITAL_DB_COMPOSE_FILE", CODE_DIR / "docker-compose.yml")
).resolve()
DB_SERVICE = os.environ.get("HOSPITAL_DB_SERVICE", "mariadb")
DB_HOST = os.environ.get("HOSPITAL_DB_HOST")
DB_PORT = os.environ.get("HOSPITAL_DB_PORT", "3306")
DB_USER = os.environ.get("HOSPITAL_DB_USER", "root")
DB_PASSWORD = os.environ.get("HOSPITAL_DB_PASSWORD", "root")
DB_NAME = os.environ.get("HOSPITAL_DB_NAME", "hospital")
QUERY_TIMEOUT_SECONDS = 45
MAX_PREVIEW_ROWS = 1000

QUERY_ID_PATTERN = re.compile(r"^/api/queries/([a-zA-Z0-9_-]+)$")
READ_ONLY_PATTERN = re.compile(r"^\s*(WITH|SELECT|SHOW|DESCRIBE|DESC|EXPLAIN)\b", re.IGNORECASE)
BLOCKED_PATTERN = re.compile(
    r"\b(INSERT|UPDATE|DELETE|DROP|TRUNCATE|ALTER|CREATE|REPLACE|GRANT|REVOKE|SET|CALL|LOAD|SOURCE|USE)\b",
    re.IGNORECASE,
)


def normalize_query(sql: str) -> str:
    query = sql.strip()
    if not query:
        raise ValueError("Query is empty.")

    if query.endswith(";"):
        query = query[:-1].strip()

    if ";" in query:
        raise ValueError("Only one statement at a time is allowed.")

    if not READ_ONLY_PATTERN.match(query):
        raise ValueError("Only read-only SELECT, WITH, SHOW, DESCRIBE, or EXPLAIN queries are allowed.")

    if BLOCKED_PATTERN.search(query) and not query.lstrip().upper().startswith(("SHOW", "DESCRIBE", "DESC", "EXPLAIN")):
        blocked = BLOCKED_PATTERN.search(query)
        if blocked and blocked.group(1).upper() not in {"SELECT", "WITH"}:
            raise ValueError(f"Blocked keyword detected: {blocked.group(1).upper()}")

    return query


def docker_compose_command(*extra: str) -> list[str]:
    return ["docker", "compose", "-f", str(COMPOSE_FILE), *extra]


def using_direct_database_connection() -> bool:
    return bool(DB_HOST)


def mariadb_query_command(query: str) -> list[str]:
    common_args = [
        f"-u{DB_USER}",
        f"-p{DB_PASSWORD}",
        "--database",
        DB_NAME,
        "--batch",
        "--raw",
        "--default-character-set=utf8mb4",
        "--max-allowed-packet=256M",
        "-e",
        query,
    ]

    if using_direct_database_connection():
        return [
            "mariadb",
            f"-h{DB_HOST}",
            f"-P{DB_PORT}",
            "--ssl=0",
            *common_args,
        ]

    return docker_compose_command("exec", "-T", DB_SERVICE, "mariadb", *common_args)


def run_subprocess(command: list[str], *, timeout: int = QUERY_TIMEOUT_SECONDS) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        command,
        cwd=str(CODE_DIR),
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
        timeout=timeout,
        check=False,
    )


def ensure_database_ready() -> None:
    if using_direct_database_connection():
        command = [
            "mariadb-admin",
            f"-h{DB_HOST}",
            f"-P{DB_PORT}",
            "--ssl=0",
            f"-u{DB_USER}",
            f"-p{DB_PASSWORD}",
            "ping",
            "--silent",
        ]
        result = run_subprocess(command, timeout=10)
        if result.returncode != 0:
            raise RuntimeError(
                f"MariaDB host '{DB_HOST}:{DB_PORT}' is not ready. "
                "Check the database container health and credentials."
            )
        return

    command = docker_compose_command("ps", "-q", DB_SERVICE)
    result = run_subprocess(command, timeout=10)
    if result.returncode != 0 or not result.stdout.strip():
        raise RuntimeError(
            f"MariaDB service '{DB_SERVICE}' is not running. Start it first with 'docker compose up -d'."
        )


def parse_tsv(tsv: str) -> tuple[list[str], list[dict[str, str]]]:
    lines = [line for line in tsv.splitlines() if line.strip()]
    if not lines:
        return [], []

    columns = lines[0].split("\t")
    rows: list[dict[str, str]] = []
    for line in lines[1:]:
        values = line.split("\t")
        if len(values) < len(columns):
            values.extend([""] * (len(columns) - len(values)))
        elif len(values) > len(columns):
            values = values[: len(columns)]
        rows.append(dict(zip(columns, values)))
    return columns, rows


def execute_query(sql: str) -> dict[str, object]:
    query = normalize_query(sql)
    ensure_database_ready()

    command = mariadb_query_command(query)

    started = time.perf_counter()
    result = run_subprocess(command)
    duration_ms = round((time.perf_counter() - started) * 1000, 1)

    if result.returncode != 0:
        raise RuntimeError(result.stderr.strip() or "MariaDB returned a non-zero exit code.")

    columns, rows = parse_tsv(result.stdout)
    limited_rows = rows[:MAX_PREVIEW_ROWS]

    return {
        "query": query,
        "columns": columns,
        "rows": limited_rows,
        "rowCount": len(rows),
        "truncated": len(rows) > MAX_PREVIEW_ROWS,
        "durationMs": duration_ms,
    }


def fetch_schema() -> dict[str, object]:
    schema_query = """
SELECT c.table_name,
       c.column_name,
       c.data_type
FROM information_schema.columns c
WHERE c.table_schema = 'hospital'
ORDER BY c.table_name, c.ordinal_position;
""".strip()

    result = execute_query(schema_query)
    grouped: dict[str, list[dict[str, str]]] = {}
    for row in result["rows"]:
        grouped.setdefault(row["table_name"], []).append(
            {"name": row["column_name"], "type": row["data_type"]}
        )

    tables = [{"name": table, "columns": columns} for table, columns in grouped.items()]
    return {"tables": tables}


class QueryUIHandler(BaseHTTPRequestHandler):
    server_version = "HospitalQueryUI/1.0"

    def log_message(self, fmt: str, *args: object) -> None:
        return

    def do_GET(self) -> None:
        parsed = urlparse(self.path)
        if parsed.path == "/api/health":
            self.send_json({"status": "ok"})
            return
        if parsed.path == "/api/queries":
            self.send_json({"defaultQueryId": DEFAULT_QUERY_ID, "queries": get_all_queries()})
            return
        if parsed.path == "/api/schema":
            self.handle_schema()
            return
        if parsed.path == "/" or parsed.path == "":
            self.serve_static("index.html")
            return
        self.serve_static(parsed.path.lstrip("/"))

    def do_POST(self) -> None:
        parsed = urlparse(self.path)
        if parsed.path == "/api/query":
            self.handle_query()
            return
        if parsed.path == "/api/queries":
            self.handle_create_query()
            return
        self.send_error(HTTPStatus.NOT_FOUND, "Unknown endpoint.")

    def do_PUT(self) -> None:
        parsed = urlparse(self.path)
        match = QUERY_ID_PATTERN.match(parsed.path)
        if match:
            self.handle_update_query(match.group(1))
            return
        self.send_error(HTTPStatus.NOT_FOUND, "Unknown endpoint.")

    def do_DELETE(self) -> None:
        parsed = urlparse(self.path)
        match = QUERY_ID_PATTERN.match(parsed.path)
        if match:
            self.handle_delete_query(match.group(1))
            return
        self.send_error(HTTPStatus.NOT_FOUND, "Unknown endpoint.")

    def read_json_body(self) -> dict[str, object]:
        content_length = int(self.headers.get("Content-Length", "0"))
        payload = self.rfile.read(content_length).decode("utf-8")
        return json.loads(payload or "{}")

    def handle_query(self) -> None:
        try:
            body = self.read_json_body()
            sql = str(body.get("sql", ""))
            query_id = body.get("queryId")
            result = execute_query(sql)
            result["queryId"] = query_id
            self.send_json(result)
        except subprocess.TimeoutExpired:
            self.send_json({"error": "Query timed out."}, status=HTTPStatus.GATEWAY_TIMEOUT)
        except (ValueError, RuntimeError) as exc:
            self.send_json({"error": str(exc)}, status=HTTPStatus.BAD_REQUEST)
        except Exception as exc:  # pragma: no cover - defensive path
            self.send_json({"error": f"Unexpected error: {exc}"}, status=HTTPStatus.INTERNAL_SERVER_ERROR)

    def handle_schema(self) -> None:
        try:
            self.send_json(fetch_schema())
        except Exception as exc:
            self.send_json({"error": str(exc)}, status=HTTPStatus.BAD_REQUEST)

    def handle_create_query(self) -> None:
        try:
            body = self.read_json_body()
            title = str(body.get("title", "")).strip()
            category = str(body.get("category", "")).strip()
            description = str(body.get("description", "")).strip()
            sql = str(body.get("sql", "")).strip()
            visualization = body.get("visualization")

            if not title:
                raise ValueError("Title is required.")
            if not sql:
                raise ValueError("SQL is required.")

            custom_id = f"custom-{int(time.time() * 1000)}"
            new_query = {
                "id": custom_id,
                "title": title,
                "category": category or "Custom",
                "description": description,
                "sql": sql,
            }
            if isinstance(visualization, dict):
                new_query["visualization"] = visualization

            queries = load_custom_queries()
            queries.append(new_query)
            save_custom_queries(queries)

            self.send_json(new_query, status=HTTPStatus.CREATED)
        except (ValueError, RuntimeError) as exc:
            self.send_json({"error": str(exc)}, status=HTTPStatus.BAD_REQUEST)
        except Exception as exc:
            self.send_json({"error": str(exc)}, status=HTTPStatus.INTERNAL_SERVER_ERROR)

    def handle_update_query(self, query_id: str) -> None:
        try:
            if not query_id.startswith("custom-"):
                raise ValueError("Built-in queries cannot be modified.")

            body = self.read_json_body()
            queries = load_custom_queries()

            index = next((i for i, q in enumerate(queries) if q["id"] == query_id), None)
            if index is None:
                self.send_json({"error": "Query not found."}, status=HTTPStatus.NOT_FOUND)
                return

            existing = queries[index]
            title = str(body.get("title", "")).strip()
            if title:
                existing["title"] = title
            if "category" in body:
                existing["category"] = str(body["category"]).strip() or existing["category"]
            if "description" in body:
                existing["description"] = str(body["description"]).strip()
            if "sql" in body:
                sql = str(body["sql"]).strip()
                if sql:
                    existing["sql"] = sql
            if "visualization" in body:
                visualization = body["visualization"]
                if isinstance(visualization, dict):
                    existing["visualization"] = visualization
                elif visualization is None:
                    existing.pop("visualization", None)

            queries[index] = existing
            save_custom_queries(queries)
            self.send_json(existing)
        except (ValueError, RuntimeError) as exc:
            self.send_json({"error": str(exc)}, status=HTTPStatus.BAD_REQUEST)
        except Exception as exc:
            self.send_json({"error": str(exc)}, status=HTTPStatus.INTERNAL_SERVER_ERROR)

    def handle_delete_query(self, query_id: str) -> None:
        try:
            if not query_id.startswith("custom-"):
                raise ValueError("Built-in queries cannot be deleted.")

            queries = load_custom_queries()
            filtered = [q for q in queries if q["id"] != query_id]

            if len(filtered) == len(queries):
                self.send_json({"error": "Query not found."}, status=HTTPStatus.NOT_FOUND)
                return

            save_custom_queries(filtered)
            self.send_json({"deleted": query_id})
        except (ValueError, RuntimeError) as exc:
            self.send_json({"error": str(exc)}, status=HTTPStatus.BAD_REQUEST)
        except Exception as exc:
            self.send_json({"error": str(exc)}, status=HTTPStatus.INTERNAL_SERVER_ERROR)

    def serve_static(self, relative_path: str) -> None:
        target = (STATIC_DIR / relative_path).resolve()
        if not str(target).startswith(str(STATIC_DIR.resolve())) or not target.exists() or not target.is_file():
            self.send_error(HTTPStatus.NOT_FOUND, "File not found.")
            return

        content_type, _ = mimetypes.guess_type(target.name)
        self.send_response(HTTPStatus.OK)
        self.send_header("Content-Type", content_type or "application/octet-stream")
        self.send_header("Cache-Control", "no-cache")
        self.end_headers()
        self.wfile.write(target.read_bytes())

    def send_json(self, payload: dict[str, object], *, status: HTTPStatus = HTTPStatus.OK) -> None:
        encoded = json.dumps(payload).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(encoded)))
        self.end_headers()
        self.wfile.write(encoded)


def main() -> None:
    host = os.environ.get("HOSPITAL_QUERY_UI_HOST", "127.0.0.1")
    port = int(os.environ.get("HOSPITAL_QUERY_UI_PORT", "8765"))
    server = ThreadingHTTPServer((host, port), QueryUIHandler)
    print(f"Hospital query UI running on http://{host}:{port}")
    if using_direct_database_connection():
        print(f"Using MariaDB host: {DB_HOST}:{DB_PORT}")
    else:
        print(f"Using compose file: {COMPOSE_FILE}")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()


if __name__ == "__main__":
    main()
