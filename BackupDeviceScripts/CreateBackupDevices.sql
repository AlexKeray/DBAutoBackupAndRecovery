USE MASTER
GO

sp_addumpdevice disk, bus_station_recovery_full, 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER2016\MSSQL\Backup\bus_station_recovery_full.bak'
GO
sp_addumpdevice disk, bus_station_recovery_differential, 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER2016\MSSQL\Backup\bus_station_recovery_differential.bak'
GO
sp_addumpdevice disk, bus_station_recovery_log, 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER2016\MSSQL\Backup\bus_station_recovery_log.bak'
GO