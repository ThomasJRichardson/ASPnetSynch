USE [APT2012]
GO

/* Environments:
	PReProd	[10.192.23.11]
	PROD	[10.192.23.10]
*/

/****** Object:  StoredProcedure [dbo].[Synch_ASPnet_Zap]    Script Date: 11/19/2013 09:32:42 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Synch_ASPnet_Zap]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Synch_ASPnet_Zap]
GO

USE [APT2012]
GO

/****** Object:  StoredProcedure [dbo].[Synch_ASPnet_Zap]    Script Date: 11/19/2013 09:32:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Synch_ASPnet_Zap]
AS

DECLARE	@ErrorMessage NVARCHAR(4000),
	@ErrorSeverity INT,
	@ErrorState INT;

BEGIN TRY
--delete removed records

	--Users
	delete d
	from	[10.192.23.10].[APT2012].[dbo].aspnet_Users d
	inner join (select ApplicationId,LoweredUsername from aspnet_Users_WEB EXCEPT select ApplicationId,LoweredUsername from aspnet_Users) o
		on d.ApplicationId = o.ApplicationId and d.LoweredUsername = o.LoweredUsername
END TRY

BEGIN CATCH
	SELECT	@ErrorMessage = 'Error in procedure Synch_ASPnet_Zap: ' + ERROR_MESSAGE(),
		@ErrorSeverity = ERROR_SEVERITY(),
		@ErrorState = ERROR_STATE();

	RAISERROR (	@ErrorMessage,
			@ErrorSeverity,
			@ErrorState	);

	if @@TRANCOUNT > 0
		rollback transaction;
END CATCH
GO
