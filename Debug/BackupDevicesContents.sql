USE master
GO

BEGIN TRY
    -- Attempt to display header information from the backup device
    RESTORE HEADERONLY 
    FROM DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER2016\MSSQL\Backup\bus_station_recovery_full.bak';
END TRY
BEGIN CATCH
    -- Error handling code
    SELECT 
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_SEVERITY() AS ErrorSeverity,
        ERROR_STATE() AS ErrorState,
        ERROR_PROCEDURE() AS ErrorProcedure,
        ERROR_LINE() AS ErrorLine,
        ERROR_MESSAGE() AS ErrorMessage;
END CATCH

BEGIN TRY
    -- Attempt to display header information from the backup device
    RESTORE HEADERONLY 
    FROM DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER2016\MSSQL\Backup\bus_station_recovery_differential.bak';
END TRY
BEGIN CATCH
    -- Error handling code
    SELECT 
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_SEVERITY() AS ErrorSeverity,
        ERROR_STATE() AS ErrorState,
        ERROR_PROCEDURE() AS ErrorProcedure,
        ERROR_LINE() AS ErrorLine,
        ERROR_MESSAGE() AS ErrorMessage;
END CATCH

BEGIN TRY
    -- Attempt to display header information from the backup device
    RESTORE HEADERONLY 
    FROM DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER2016\MSSQL\Backup\bus_station_recovery_log.bak';
END TRY
BEGIN CATCH
    -- Error handling code
    SELECT 
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_SEVERITY() AS ErrorSeverity,
        ERROR_STATE() AS ErrorState,
        ERROR_PROCEDURE() AS ErrorProcedure,
        ERROR_LINE() AS ErrorLine,
        ERROR_MESSAGE() AS ErrorMessage;
END CATCH