--delete the job if it already exists
IF EXISTS(SELECT 1 FROM msdb.dbo.sysjobs WHERE name = 'TestJob - Unreachable Step')
	EXEC msdb.dbo.sp_delete_job @job_name = 'TestJob - Unreachable Step'

--Create the job
DECLARE @JobId BINARY(16)
EXEC msdb.dbo.sp_add_job @job_name = 'TestJob - Unreachable Step'
	, @enabled = 1
	, @job_id = @JobId OUTPUT

--add 6 steps with differing on success/on fail flows
EXEC msdb.dbo.sp_add_jobstep @job_id=@jobId
	, @step_name=N'Clear Table Step 1'
	, @subsystem=N'TSQL'
	, @on_success_action=3
	, @command=N'DELETE FROM TestJobTable'
	, @database_name=N'tempdb'

EXEC msdb.dbo.sp_add_jobstep @job_id=@jobId
	, @step_name=N'Insert Step 2'
	, @subsystem=N'TSQL'
	, @on_success_action=3
	, @on_fail_action = 4
	, @on_fail_step_id = 4
	, @command=N'INSERT INTO TestJobTable VALUES (1, ''Insert 1'')'
	, @database_name=N'tempdb'

EXEC msdb.dbo.sp_add_jobstep @job_id=@jobId
	, @step_name=N'Insert Step 3'
	, @subsystem=N'TSQL'
	, @on_success_action=1
	, @command=N'INSERT INTO TestJobTable VALUES (2, ''Insert 2'')'
	, @database_name=N'tempdb'

EXEC msdb.dbo.sp_add_jobstep @job_id=@jobId
	, @step_name=N'Insert Step 4'
	, @subsystem=N'TSQL'
	, @on_success_action=1
	, @command=N'INSERT INTO TestJobTable VALUES (3, ''Insert 3'')'
	, @database_name=N'tempdb'

EXEC msdb.dbo.sp_add_jobstep @job_id=@jobId
	, @step_name=N'Insert Step 5'
	, @subsystem=N'TSQL'
	, @on_success_action=1
	, @on_fail_step_id = 5
	, @command=N'INSERT INTO TestJobTable VALUES (4, ''Insert 4'')'
	, @database_name=N'tempdb'
	
EXEC msdb.dbo.sp_add_jobstep @job_id=@jobId
	, @step_name=N'Insert Step 6'
	, @subsystem=N'TSQL'
	, @on_success_action=4
	, @on_success_step_id = 5
	, @on_fail_action = 1
	, @command=N'INSERT INTO TestJobTable VALUES (5, ''Insert 5'')'
	, @database_name=N'tempdb'

--set job server to local
EXEC msdb.dbo.sp_add_jobserver @job_id = @jobId
	, @server_name = N'(local)'

--set the job to start at step number 2
EXEC msdb.dbo.sp_update_job @job_id = @JobId, @start_step_id = 2
GO


--detect any unreachable steps in any of our jobs
USE msdb
GO

SELECT sj.name AS 'Job Name'
	, sjs1.step_id AS 'Step Number'
	, sjs1.step_name AS 'Step Name'
FROM sysjobsteps sjs1
INNER JOIN sysjobs sj on sj.job_id = sjs1.job_id
LEFT JOIN sysjobsteps sjs2 ON sjs2.job_id = sjs1.job_id AND sjs2.step_id <> sjs1.step_id AND
	(
		(sjs1.step_id = sjs2.on_success_step_id AND sjs2.on_success_action = 4) OR 
		(sjs1.step_id = sjs2.on_fail_step_id AND sjs2.on_fail_action = 4) OR
		(sjs1.step_id = sjs2.step_id + 1 AND sjs2.on_success_action = 3) OR
		(sjs1.step_id = sjs2.step_id + 1 AND sjs2.on_fail_action = 3) OR
		(sjs1.step_id = sj.start_step_id)
	)
WHERE sjs2.step_id IS NULL
ORDER BY sj.name, sjs1.step_id

