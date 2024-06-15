schtasks /delete /tn "DBFullBackup" /f
schtasks /delete /tn "DBDifferentialBackup" /f
schtasks /delete /tn "DBLogBackup" /f