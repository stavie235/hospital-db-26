FROM alpine:3.21 AS assets

WORKDIR /build

COPY sql/install.sql sql/load.sql ./sql/
COPY docs/*.csv ./docs/

RUN sha256sum sql/install.sql sql/load.sql > sql.sha256

FROM mariadb:10.6

COPY --from=assets /build/sql /opt/hospital-db/sql
COPY --from=assets /build/docs /tmp/docs
COPY --from=assets /build/sql.sha256 /opt/hospital-db/sql.sha256

COPY --chmod=755 code/init/01_hospital_init.sh /docker-entrypoint-initdb.d/01_hospital_init.sh
COPY --chmod=755 code/init/docker-entrypoint-wrapper.sh /usr/local/bin/hospital-db-entrypoint.sh
COPY --chmod=755 code/init/hospital-db-healthcheck.sh /usr/local/bin/hospital-db-healthcheck.sh

ENTRYPOINT ["hospital-db-entrypoint.sh"]
CMD ["mariadbd", "--local-infile=1", "--secure-file-priv=", "--character-set-server=utf8mb4", "--collation-server=utf8mb4_unicode_ci", "--max_allowed_packet=256M"]
