USE MASTER
GO

-- Test 4 weeks
--1
BACKUP DATABASE BUS_STATION
TO bus_station_recovery_full
WITH INIT

BACKUP DATABASE BUS_STATION
TO bus_station_recovery_differential
WITH DIFFERENTIAL, INIT

BACKUP log BUS_STATION
TO bus_station_recovery_log
WITH INIT

BACKUP log BUS_STATION
TO bus_station_recovery_log

BACKUP DATABASE BUS_STATION
TO bus_station_recovery_differential
WITH DIFFERENTIAL

BACKUP log BUS_STATION
TO bus_station_recovery_log

BACKUP log BUS_STATION
TO bus_station_recovery_log

-- 2
BACKUP log BUS_STATION
TO bus_station_recovery_log

BACKUP DATABASE BUS_STATION
TO bus_station_recovery_differential
WITH DIFFERENTIAL

BACKUP log BUS_STATION
TO bus_station_recovery_log

BACKUP log BUS_STATION
TO bus_station_recovery_log

BACKUP DATABASE BUS_STATION
TO bus_station_recovery_differential
WITH DIFFERENTIAL

BACKUP log BUS_STATION
TO bus_station_recovery_log

BACKUP log BUS_STATION
TO bus_station_recovery_log

-- 3
BACKUP log BUS_STATION
TO bus_station_recovery_log

BACKUP DATABASE BUS_STATION
TO bus_station_recovery_differential
WITH DIFFERENTIAL

BACKUP log BUS_STATION
TO bus_station_recovery_log

BACKUP log BUS_STATION
TO bus_station_recovery_log

BACKUP DATABASE BUS_STATION
TO bus_station_recovery_differential
WITH DIFFERENTIAL

BACKUP log BUS_STATION
TO bus_station_recovery_log

BACKUP log BUS_STATION
TO bus_station_recovery_log

-- 4
BACKUP log BUS_STATION
TO bus_station_recovery_log

BACKUP DATABASE BUS_STATION
TO bus_station_recovery_differential
WITH DIFFERENTIAL

BACKUP log BUS_STATION
TO bus_station_recovery_log

BACKUP log BUS_STATION
TO bus_station_recovery_log

BACKUP DATABASE BUS_STATION
TO bus_station_recovery_differential
WITH DIFFERENTIAL

BACKUP log BUS_STATION
TO bus_station_recovery_log

BACKUP log BUS_STATION
TO bus_station_recovery_log