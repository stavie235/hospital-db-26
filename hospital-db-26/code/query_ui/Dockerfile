FROM python:3.12-alpine

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

RUN apk add --no-cache mariadb-client

WORKDIR /app

COPY code/query_ui/ ./

EXPOSE 8765

CMD ["python3", "server.py"]
