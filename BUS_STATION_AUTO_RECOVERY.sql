USE MASTER
GO

-- ##ProcedureMessages is used to return information to the user about which backups are used in the recovery.
-- Also it provides information about errors, if any occur.
-- Every time the script is runned, it guarantees that there is a new ##ProcedureMessages table every time.
IF OBJECT_ID('tempdb..##ProcedureMessages') IS NOT NULL
BEGIN
    DROP TABLE ##ProcedureMessages;
END;

CREATE TABLE ##ProcedureMessages (Message NVARCHAR(MAX));

USE MSDB
GO

-- Stored procedure is used to be able to extend the life of the variables beyond the first batch.
-- Variables are used for easier configuration.
-- Alter is added in case that the script is run more than once per session.
CREATE or ALTER PROCEDURE dbo.RestoreBUS_STATION
AS
BEGIN
	DECLARE @fullBackupDeviceName NVARCHAR(255) = 'bus_station_recovery_full';
	DECLARE @fullBackupDevicePath NVARCHAR(255) = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER2016\MSSQL\Backup\bus_station_recovery_full.bak';
	DECLARE @differentialBackupDeviceName NVARCHAR(255) = 'bus_station_recovery_differential';
	DECLARE @differentialBackupDevicePath NVARCHAR(255) = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER2016\MSSQL\Backup\bus_station_recovery_differential.bak';
	DECLARE @logBackupDeviceName NVARCHAR(255) = 'bus_station_recovery_log';
	DECLARE @logBackupDevicePath NVARCHAR(255) = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER2016\MSSQL\Backup\bus_station_recovery_log.bak';
	DECLARE @databaseName NVARCHAR(255) = 'BUS_STATION';
	DECLARE @lastFullBackupId INT = NULL
	DECLARE @lastFullBackupPosition INT = NULL
	DECLARE @lastDiffBackupId INT = NULL
	DECLARE @lastDiffBackupPosition INT = NULL
	DECLARE @lastBackupId INT = NULL
	DECLARE @lastUsefullLogBackupPosition INT = NULL
	DECLARE @firstUsefullLogBackupPosition INT = NULL
	DECLARE @fileExists INT

-- Check if the fullBackupDevice doesnt exsist or is empty. In that case the script ends unsuccessfully.
	EXEC xp_fileexist @fullBackupDevicePath, @fileExists OUTPUT
	IF @fileExists = 0
	BEGIN

		INSERT INTO ##ProcedureMessages VALUES (@fullBackupDeviceName + ' not found.');
		INSERT INTO ##ProcedureMessages VALUES ('Recovery failed.');

		RETURN
	END

-- Check if the logBackupDevice doesnt exsist or is empty. If so, the latest changes to the database might be lost. Recovery continues.
	EXEC xp_fileexist @logBackupDevicePath, @fileExists OUTPUT
	IF @fileExists = 0
		BEGIN
			INSERT INTO ##ProcedureMessages VALUES ('Can not create tail log. ' + @logBackupDeviceName + ' not found.');
		END
	ELSE
	-- If the logBackupDevice exists, the script creates a tail log backup.
		BEGIN
			BACKUP LOG BUS_STATION
			TO @logBackupDeviceName
			WITH NO_TRUNCATE, NORECOVERY

			INSERT INTO ##ProcedureMessages VALUES ('BACKUP LOG BUS_STATION   TO ' + @logBackupDeviceName + '   WITH NO_TRUNCATE, NORECOVERY');
		END

-- Selects the latest fullBackup and starts the restoring sequence.
	SELECT top 1
		@lastFullBackupId = bs.backup_set_id, @lastFullBackupPosition = position
	FROM
	-- backupset and backupmediafamily are system tables from the msdb database
	-- that gives us information about the backup history on the server
		backupset bs
	JOIN
		backupmediafamily bmf ON bs.media_set_id = bmf.media_set_id
	WHERE
		bmf.physical_device_name LIKE CONCAT('%', @fullBackupDeviceName,'%')
		AND bs.database_name LIKE CONCAT('%', @databaseName,'%')
	ORDER BY  backup_set_id desc

	RESTORE DATABASE BUS_STATION
	FROM @fullBackupDeviceName
	WITH FILE = @lastFullBackupPosition, NORECOVERY, REPLACE

	INSERT INTO ##ProcedureMessages VALUES ('RESTORE DATABASE BUS_STATION   FROM ' + @fullBackupDeviceName + '   WITH FILE = ' + CAST(@lastFullBackupPosition AS NVARCHAR) + ', NORECOVERY, REPLACE');

	-- lastBackupId is used to the differential and log backus that were created after the full backup.
	SET @lastBackupId = @lastFullBackupId

-- Check if the differentialBackupDevice doesnt exsist or is empty. If so, the script searches for every log backupfile
-- after the full backup. Recovery continues. If the differentialBackupDevice exists, then the script searches for the latest
-- differential backup and the log backups after this differential backup.
	EXEC xp_fileexist @differentialBackupDevicePath, @fileExists OUTPUT
	-- fileExists is the output of the xp_fileexist procedure. 1 says that the device exists, 0 says that it doesn't.
	IF @fileExists = 0
		BEGIN
			SET @lastBackupId = @lastFullBackupId
			INSERT INTO ##ProcedureMessages VALUES (@differentialBackupDeviceName + ' not found.');
		END
	ELSE
		BEGIN
			SELECT top 1
				@lastDiffBackupId = bs.backup_set_id,
				@lastDiffBackupPosition = bs.position
			FROM
				backupset bs
			JOIN
				backupmediafamily bmf ON bs.media_set_id = bmf.media_set_id
			WHERE
				bmf.physical_device_name LIKE CONCAT('%', @differentialBackupDeviceName,'%')
				AND bs.database_name LIKE CONCAT('%', @databaseName,'%')
				AND bs.backup_set_id > @lastFullBackupId
			ORDER BY  backup_set_id desc

			IF @lastDiffBackupId IS NULL
				BEGIN
					SET @lastBackupId = @lastFullBackupId
					INSERT INTO ##ProcedureMessages VALUES ('No Differential backups found.');

					SET @lastDiffBackupPosition = NULL
				END
			ELSE
				BEGIN
					SET @lastBackupId = @lastDiffBackupId

					RESTORE DATABASE BUS_STATION
					FROM @differentialBackupDeviceName
					WITH FILE = @lastDiffBackupPosition, NORECOVERY

					INSERT INTO ##ProcedureMessages VALUES('RESTORE DATABASE BUS_STATION   FROM ' + @differentialBackupDeviceName + '   WITH FILE = ' + CAST(@lastDiffBackupPosition AS NVARCHAR(10)) + ', NORECOVERY');

				END
		END
-- Searches for logBackupDevice. If such a device doesn't exist, the script doesnt use log backups at all 
-- and continues with the recovery process.
	EXEC xp_fileexist @logBackupDevicePath, @fileExists OUTPUT
	IF @fileExists = 0
		BEGIN
			INSERT INTO ##ProcedureMessages VALUES(@logBackupDeviceName + ' not found.');
			RETURN
		END
	ELSE
		BEGIN
		-- First the script searches for the earliest valid logBackupFile (the first log after the last full or differential).
			SELECT top 1
				@firstUsefullLogBackupPosition = bs.position
			FROM
				backupset bs
			JOIN
				backupmediafamily bmf ON bs.media_set_id = bmf.media_set_id
			WHERE
				bmf.physical_device_name LIKE CONCAT('%', @logBackupDeviceName,'%')

				AND bs.database_name LIKE CONCAT('%', @databaseName,'%')
				AND bs.backup_set_id > @lastBackupId
			ORDER BY  backup_set_id asc
		-- Then it searches for the last valid logBackup.
			SELECT top 1
				@lastUsefullLogBackupPosition = bs.position
			FROM
				backupset bs
			JOIN
				backupmediafamily bmf ON bs.media_set_id = bmf.media_set_id
			WHERE
				bmf.physical_device_name LIKE CONCAT('%', @logBackupDeviceName,'%')
				AND bs.database_name LIKE CONCAT('%', @databaseName,'%')
				AND bs.backup_set_id > @lastBackupId
			ORDER BY  backup_set_id desc

			-- Then it iterates trough all the log bakcups, except for the last one, and restores them.
			DECLARE @i INT = @firstUsefullLogBackupPosition

			WHILE @i < @lastUsefullLogBackupPosition
				BEGIN
					RESTORE DATABASE BUS_STATION
					FROM @logBackupDeviceName
					WITH FILE=@i, NORECOVERY

					INSERT INTO ##ProcedureMessages VALUES('RESTORE DATABASE BUS_STATION   FROM ' + @logBackupDeviceName + '   WITH FILE = ' + CAST(@i AS NVARCHAR(10)) + ', NORECOVERY');

					SET @i = @i + 1
				END
			
			-- Restores the tail log if such exists.
			RESTORE DATABASE BUS_STATION
					FROM @logBackupDeviceName
					WITH FILE=@i, RECOVERY

					INSERT INTO ##ProcedureMessages VALUES('RESTORE DATABASE BUS_STATION   FROM ' + @logBackupDeviceName + '   WITH FILE = ' + CAST(@i AS NVARCHAR(10)) + ', RECOVERY');
		END

		INSERT INTO ##ProcedureMessages VALUES('Recovery is successfull.');
END;
GO

USE MASTER
GO

-- Executes the stored procedure.
EXEC msdb.dbo.RestoreBUS_STATION;

-- Selects the result stored in the global temporary table created before the procedure.
SELECT Message FROM ##ProcedureMessages;

-- Drops the temporary table in case that the script is run more than once in the scope of the session.
DROP TABLE ##ProcedureMessages;

