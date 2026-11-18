# Baseline Postgres image for local QuickTeams development.
# Creates the development and test databases on first boot.
FROM postgres:16-alpine

ENV POSTGRES_USER=postgres \
    POSTGRES_PASSWORD=postgres

COPY init/ /docker-entrypoint-initdb.d/
