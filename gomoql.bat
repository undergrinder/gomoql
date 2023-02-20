@echo off

REM set PGPASSWORD=[secret password]
REM set PGOPTIONS=--search_path=gomoql
REM psql -U [your user] -h [your host] -p [your port, usually 5432] -d [your database] --variable=SEARCH_PATH=gomoql

REM EXAMPLE
set PGPASSWORD=secret
set PGOPTIONS=--search_path=gomoql
psql -U postgres -h localhost -p 5432 -d test --variable=SEARCH_PATH=gomoql

pause
