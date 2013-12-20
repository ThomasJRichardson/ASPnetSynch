USE [APT2012]
GO

/* Environments:
	PReProd	[10.192.23.11]
	PROD	[10.192.23.10]
*/

/****** Object:  StoredProcedure [dbo].[Synch_ASPnet_PREP]    Script Date: 11/19/2013 09:32:42 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Synch_ASPnet_PREP]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Synch_ASPnet_PREP]
GO

USE [APT2012]
GO

/****** Object:  StoredProcedure [dbo].[Synch_ASPnet_PREP]    Script Date: 11/19/2013 09:32:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Synch_ASPnet_PREP]
AS
set nocount on;

DECLARE	@ErrorMessage NVARCHAR(4000),
	@ErrorSeverity INT,
	@ErrorState INT;

BEGIN TRY
/*
	delete from aspnet_Users_WEB;
	delete from aspnet_UsersScheme_WEB;
	delete from aspnet_UsersInRoles_WEB;
	delete from aspnet_Membership_WEB;
	delete from aspnet_Profile_WEB;
*/

	delete from ASP_PASSWORD_UPDATE_WEB;
	delete from ASP_PROFILE_UPDATE_WEB;
	delete from ASP_PASSWORD_UPDATE_LOG;
	delete from ASP_PROFILE_UPDATE_LOG;
	delete from [10.192.23.10].APT2012.dbo.ASP_PASSWORD_UPDATE_LOG;
	delete from [10.192.23.10].APT2012.dbo.ASP_PROFILE_UPDATE_LOG;

	delete from ASP_PASSWORD_UPDATE_LOG;
	delete from ASP_PROFILE_UPDATE_LOG;

	delete from ASP_PASSWORD_UPDATES;				-- DEL trigger populates ASP_PASSWORD_UPDATE_LOG
	delete from ASP_PROFILE_UPDATES;				-- DEL trigger populates ASP_PROFILE_UPDATE_LOG

	delete from [10.192.23.10].APT2012.dbo.ASP_PASSWORD_UPDATES;	-- DEL trigger populates ASP_PASSWORD_UPDATE_LOG
	delete from [10.192.23.10].APT2012.dbo.ASP_PROFILE_UPDATES;	-- DEL trigger populates ASP_PROFILE_UPDATE_LOG

	insert into ASP_PASSWORD_UPDATE_WEB select * from [10.192.23.10].APT2012.dbo.ASP_PASSWORD_UPDATE_LOG;
	insert into ASP_PROFILE_UPDATE_WEB select * from [10.192.23.10].APT2012.dbo.ASP_PROFILE_UPDATE_LOG;

/*
	insert into aspnet_Users_WEB		select * from [10.192.23.10].APT2012.dbo.aspnet_Users;
	insert into aspnet_UsersScheme_WEB	select * from [10.192.23.10].APT2012.dbo.aspnet_UsersScheme;
	insert into aspnet_UsersInRoles_WEB	select * from [10.192.23.10].APT2012.dbo.aspnet_UsersInRoles;
	insert into aspnet_Membership_WEB	select * from [10.192.23.10].APT2012.dbo.aspnet_Membership;
	insert into aspnet_Profile_WEB		select * from [10.192.23.10].APT2012.dbo.aspnet_Profile;
*/

	delete from PF_ADDRESS_NOW;
	delete from PF_ADDRESS_DIFF;
END TRY

BEGIN CATCH
	SELECT	@ErrorMessage = 'Error in procedure Synch_ASPnet_PREP: ' + ERROR_MESSAGE(),
		@ErrorSeverity = ERROR_SEVERITY(),
		@ErrorState = ERROR_STATE();

	RAISERROR (	@ErrorMessage,
			@ErrorSeverity,
			@ErrorState	);

	if @@TRANCOUNT > 0
		rollback transaction;
END CATCH
GO
