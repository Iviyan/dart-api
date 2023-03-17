FROM postgres:15.2
COPY ["init db.sql", "/docker-entrypoint-initdb.d/"]