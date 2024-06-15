USE MSDB
GO
SELECT
	backup_set_id, position, [type], backup_start_date, backup_finish_date, logical_device_name, physical_device_name
	FROM
		backupset bs
	JOIN
		backupmediafamily bmf ON bs.media_set_id = bmf.media_set_id
	ORDER BY  backup_set_id desc