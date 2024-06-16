@echo off

schtasks /create /tn "DBFullBackup" /tr "%~dp0FullBackupTask.bat" /sc monthly /mo FIRST /d MON /st 02:00 /f

schtasks /create /tn "DBDifferentialBackup" /tr "%~dp0DifferentialBackupTask.bat" /sc weekly /d WED /st 02:30 /f

schtasks /create /tn "DBLogBackup" /tr "%~dp0LogBackupTask.bat" /sc weekly /d MON,TUE,THU,FRI /st 03:30 /f

pause