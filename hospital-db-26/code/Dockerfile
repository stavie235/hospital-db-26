FROM mariadb:10.6

# Bake in the init script with execute permission.
# (COPY --chmod avoids permission issues when building on Windows.)
COPY --chmod=755 init/01_hospital_init.sh /docker-entrypoint-initdb.d/
