USE MASTER
GO

BACKUP DATABASE BUS_STATION
TO bus_station_recovery_differential
WITH DIFFERENTIAL