@echo off
sqlcmd -S KEROSWIFT\MSSQLSERVER2016 -d BUS_STATION -i "%~dp0..\ArchiveScripts\DifferentialBackup.sql"