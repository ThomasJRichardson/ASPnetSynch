USE [APT2012]
GO

/****** Object:  StoredProcedure [dbo].[Synch_ASPnet]    Script Date: 11/19/2013 09:32:42 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Synch_ASPnet]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Synch_ASPnet]
GO

USE [APT2012]
GO

/****** Object:  StoredProcedure [dbo].[Synch_ASPnet]    Script Date: 11/19/2013 09:32:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Synch_ASPnet]
AS

DECLARE	@ErrorMessage NVARCHAR(4000),
	@ErrorSeverity INT,
	@ErrorState INT;

BEGIN TRY
	exec Synch_ASPnet_PREP;		--Prepare tables
	exec Synch_ASPnet_Profile;	--Local, Web and Profund profile changes
	exec Synch_ASPnet_Password;	--Passwords
	--exec Synch_ASPnet_Add;		--new ASP net records
	--exec Synch_ASPnet_ZAP;		--removed ASP net records
END TRY

BEGIN CATCH
	SELECT	@ErrorMessage = 'Error in procedure Synch_ASPnet: ' + ERROR_MESSAGE(),
		@ErrorSeverity = ERROR_SEVERITY(),
		@ErrorState = ERROR_STATE();

	RAISERROR (	@ErrorMessage,
			@ErrorSeverity,
			@ErrorState	);

	if @@TRANCOUNT > 0
		rollback transaction;
END CATCH
GO
