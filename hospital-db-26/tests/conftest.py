"""
Shared fixtures for hospital-db integration tests.

Requires a live MariaDB instance.  Connection parameters are read from env vars
(same defaults as server.py so you can reuse the same environment):

    HOSPITAL_DB_HOST      (default: 127.0.0.1)
    HOSPITAL_DB_PORT      (default: 3307 — the docker-compose external port)
    HOSPITAL_DB_USER      (default: root)
    HOSPITAL_DB_PASSWORD  (default: root)
    HOSPITAL_DB_NAME      (default: hospital)

Start the database before running:
    docker compose up -d
    pytest tests/
"""

from __future__ import annotations

import os
import uuid

import pytest

try:
    import mysql.connector as _mc
    _DRIVER = "mysql"
except ImportError:  # pragma: no cover
    import mariadb as _mc  # type: ignore[no-redef]
    _DRIVER = "mariadb"


DB_HOST = os.environ.get("HOSPITAL_DB_HOST", "127.0.0.1")
DB_PORT = int(os.environ.get("HOSPITAL_DB_PORT", "3307"))
DB_USER = os.environ.get("HOSPITAL_DB_USER", "root")
DB_PASSWORD = os.environ.get("HOSPITAL_DB_PASSWORD", "root")
DB_NAME = os.environ.get("HOSPITAL_DB_NAME", "hospital")


@pytest.fixture(scope="session")
def db():
    """Session-scoped raw connection — tests must manage their own transactions."""
    if _DRIVER == "mysql":
        conn = _mc.connect(
            host=DB_HOST,
            port=DB_PORT,
            user=DB_USER,
            password=DB_PASSWORD,
            database=DB_NAME,
            autocommit=False,
        )
    else:
        conn = _mc.connect(
            host=DB_HOST,
            port=DB_PORT,
            user=DB_USER,
            password=DB_PASSWORD,
            database=DB_NAME,
            autocommit=False,
        )
    yield conn
    conn.close()


@pytest.fixture()
def cur(db):
    """Per-test cursor that rolls back after the test — DB stays clean."""
    cursor = db.cursor()
    yield cursor
    db.rollback()
    cursor.close()


def unique_amka() -> str:
    """Generate a unique 11-digit AMKA string for test patients."""
    return str(uuid.uuid4().int)[:11]


def execute(cursor, sql: str, params=None):
    cursor.execute(sql, params or ())
    return cursor


def raises_signal(cursor, sql: str, params=None) -> str:
    """Execute SQL and assert it raises a MariaDB/MySQL SIGNAL (SQLSTATE 45000).
    Returns the error message text for further assertions."""
    import mysql.connector.errors as _err  # works for both connectors
    with pytest.raises(Exception) as exc_info:
        cursor.execute(sql, params or ())
    msg = str(exc_info.value)
    assert "45000" in msg or exc_info.value.errno in (1644, 1452, 1062), (
        f"Expected SIGNAL 45000 but got: {msg}"
    )
    return msg
