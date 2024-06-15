@echo off
schtasks /create /tn "DBFullBackup" /tr "%~dp0FullBackupTask.bat" /sc minute /mo 5 /st %TIME:~0,2%:%TIME:~3,2% /f

schtasks /create /tn "DBDifferentialBackup" /tr "%~dp0DifferentialBackupTask.bat" /sc minute /mo 3 /st %TIME:~0,2%:%TIME:~3,2% /f

schtasks /create /tn "DBLogBackup" /tr "%~dp0LogBackupTask.bat" /sc minute /mo 1 /st %TIME:~0,2%:%TIME:~3,2% /f

pause

