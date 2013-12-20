USE [msdb]
GO

/****** Object:  Job [ASPnet_SYNC]    Script Date: 12/11/2013 16:52:30 ******/
IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'ASPnet_SYNC')
EXEC msdb.dbo.sp_delete_job @job_id=N'2ea1b86a-c2e3-41f6-b5b9-311b5e67c6df', @delete_unused_schedule=1
GO

USE [msdb]
GO

/****** Object:  Job [ASPnet_SYNC]    Script Date: 12/11/2013 16:52:30 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]]    Script Date: 12/11/2013 16:52:30 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'ASPnet_SYNC', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Synchronisation]    Script Date: 12/11/2013 16:52:30 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Synchronisation', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=3, 
		@on_fail_action=4, 
		@on_fail_step_id=2, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'use APT2012
go

exec dbo.Synch_ASPnet
go

exec dbo.UPDATE_RESET_PASSWORD_LOCAL_FROM_H365 ''[RAVEN]'',''[10.192.23.10]''
go
', 
		@database_name=N'master', 
		@output_file_name=N'E:\SQLData\Synch_ASPnet\TomR_Synch.log', 
		@flags=4
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [EMAIL FAILURE]    Script Date: 12/11/2013 16:52:30 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'EMAIL FAILURE', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=2, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE msdb 
GO 
EXEC sp_send_dbmail @profile_name=''RavenSQLMail'', 
@recipients=''trichardson@alliedpensions.com'', @subject=''FAILED** RAVEN Synch_ASPnet FAILED!'',
@body=''FAILED** RAVEN Synch_ASPnet FAILED!.''', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [EMAIL OK]    Script Date: 12/11/2013 16:52:30 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'EMAIL OK', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE msdb 
GO 

EXEC sp_send_dbmail @profile_name=''RavenSQLMail'', 
@recipients=''trichardson@alliedpensions.com'', 
@subject=''SUCCESS - Synch_ASPnet ON RAVEN'' ,
@body=''SUCCESS - Synch_ASPnet ON RAVEN was fine (well it didn''''t fail anyway!)''', 
		@database_name=N'master', 
		@flags=4
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'APT2012-SYNC-SCHEDULE', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=30, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20120608, 
		@active_end_date=99991231, 
		@active_start_time=82000, 
		@active_end_time=12000, 
		@schedule_uid=N'937d8f8b-8f99-4b3c-8d6d-1d0121dbe0c4'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO


