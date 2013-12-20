USE [APT2012]
GO


/* Environments:
	PReProd	[10.192.23.11]
	PROD	[10.192.23.10]
*/

/****** Object:  StoredProcedure [dbo].[Synch_ASPnet_Password]    Script Date: 11/19/2013 09:32:42 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Synch_ASPnet_Password]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Synch_ASPnet_Password]
GO

USE [APT2012]
GO

/****** Object:  StoredProcedure [dbo].[Synch_ASPnet_Password]    Script Date: 11/19/2013 09:32:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Synch_ASPnet_Password]
AS

DECLARE	@ErrorMessage NVARCHAR(4000),
	@ErrorSeverity INT,
	@ErrorState INT;

--START OF: Apply ASPnet Password updates to ASPnet

Begin Try
	--add in updates from web

	insert into [dbo].[ASP_PASSWORD_UPDATE_LOG](
		[UserId],

		[UserName],
		[Password],
		[PasswordFormat],
		[PasswordSalt],
		[MobilePIN],
		[MobileAlias],
		[IsAnonymous],

		_CreatedWhen,
		_CreatedBy,
		_CreatedOn,
		_CreatedIn,

		ID
	)
	select	[UserId],

		[UserName],
		[Password],
		[PasswordFormat],
		[PasswordSalt],
		[MobilePIN],
		[MobileAlias],
		[IsAnonymous],

		_CreatedWhen,
		_CreatedBy,
		_CreatedOn,
		_CreatedIn,

		ID

	from	ASP_PASSWORD_UPDATE_WEB
/*
	EXCEPT

	select	[UserId],

		[UserName],
		[Password],
		[PasswordFormat],
		[PasswordSalt],
		[MobilePIN],
		[MobileAlias],
		[IsAnonymous],

		_CreatedWhen,
		_CreatedBy,
		_CreatedOn,
		_CreatedIn,

		ID

	from	ASP_PASSWORD_UPDATE_LOG;
*/

		select convert(varchar,@@ROWCOUNT) + ' added from Web to ASP_PASSWORD_UPDATE_LOG by Synch_ASPnet_Password';

/*
	--Update Passwords - Local & Sungard

	update AU
	set	AU.UserName = APU.UserName,
		AU.LoweredUserName = lower(APU.UserName),
		AU.MobileAlias = isnull(APU.MobileAlias,''),
		AU.IsAnonymous = APU.IsAnonymous
	from		ASP_PASSWORD_UPDATE_LOG APU
	inner join	(select Z.UserId,Z._CreatedWhen,Z.maxID from
			(select UserId,_CreatedWhen,max(ID) as maxID from ASP_PASSWORD_UPDATE_LOG group by UserId,_CreatedWhen) Z
	inner join	(select UserId, max(_CreatedWhen) as maxCreatedWhen from ASP_PASSWORD_UPDATE_LOG group by UserId) MCW
		on Z.UserId=MCW.UserId and Z._CreatedWhen=MCW.maxCreatedWhen) X
		on APU.ID = X.maxID	
	inner join	aspnet_Users AU on AU.UserId = APU.UserId
	where	AU.UserName <> APU.UserName
	or	isnull(AU.MobileAlias,'') <> isnull(APU.MobileAlias,'')
	or	AU.IsAnonymous <> AU.IsAnonymous;

		select convert(varchar,@@ROWCOUNT) + ' updates to LCL.aspnet_Users by Synch_ASPnet_Password';

	update AU
	set	AU.UserName = APU.UserName,
		AU.LoweredUserName = lower(APU.UserName),
		AU.MobileAlias = isnull(APU.MobileAlias,''),
		AU.IsAnonymous = APU.IsAnonymous
	from		ASP_PASSWORD_UPDATE_LOG APU
	inner join	(select Z.UserId,Z._CreatedWhen,Z.maxID from
			(select UserId,_CreatedWhen,max(ID) as maxID from ASP_PASSWORD_UPDATE_LOG group by UserId,_CreatedWhen) Z
	inner join	(select UserId, max(_CreatedWhen) as maxCreatedWhen from ASP_PASSWORD_UPDATE_LOG group by UserId) MCW
		on Z.UserId=MCW.UserId and Z._CreatedWhen=MCW.maxCreatedWhen) X
		on APU.ID = X.maxID	
	inner join	[10.192.23.11].[APT2012].[dbo].aspnet_Users AU on AU.UserId = APU.UserId
	where	AU.UserName <> APU.UserName
	or	isnull(AU.MobileAlias,'') <> isnull(APU.MobileAlias,'')
	or	AU.IsAnonymous <> AU.IsAnonymous;

		select convert(varchar,@@ROWCOUNT) + ' updates to WEB.aspnet_Users by Synch_ASPnet_Password';
*/
	--Update Membership - Local & Sungard

	update AM
	set	AM.Password = APU.Password,
		AM.PasswordFormat = APU.PasswordFormat,
		AM.PasswordSalt = APU.PasswordSalt,
		AM.MobilePIN = isnull(APU.MobilePIN,'')
	from		ASP_PASSWORD_UPDATE_LOG APU
	inner join	(select Z.UserId,Z._CreatedWhen,Z.maxID from
			(select UserId,_CreatedWhen,max(ID) as maxID from ASP_PASSWORD_UPDATE_LOG group by UserId,_CreatedWhen) Z
	inner join	(select UserId, max(_CreatedWhen) as maxCreatedWhen from ASP_PASSWORD_UPDATE_LOG group by UserId) MCW
		on Z.UserId=MCW.UserId and Z._CreatedWhen=MCW.maxCreatedWhen) X
		on APU.ID = X.maxID	
	inner join	aspnet_Membership AM on AM.UserId = APU.UserId
	where	AM.Password <> APU.PAssword
	or	AM.PasswordFormat <> APU.PasswordFormat
	or	AM.PasswordSalt <> APU.PasswordSalt
	or	AM.MobilePIN <> isnull(APU.MobilePIN,'');

		select convert(varchar,@@ROWCOUNT) + ' updates to LCL.aspnet_Membership by Synch_ASPnet_Password';
/*
	update AM
	set	AM.Password = APU.Password,
		AM.PasswordFormat = APU.PasswordFormat,
		AM.PasswordSalt = APU.PasswordSalt,
		AM.MobilePIN = isnull(APU.MobilePIN,'')
	from		ASP_PASSWORD_UPDATE_LOG APU
	inner join	(select Z.UserId,Z._CreatedWhen,Z.maxID from
			(select UserId,_CreatedWhen,max(ID) as maxID from ASP_PASSWORD_UPDATE_LOG group by UserId,_CreatedWhen) Z
	inner join	(select UserId, max(_CreatedWhen) as maxCreatedWhen from ASP_PASSWORD_UPDATE_LOG group by UserId) MCW
		on Z.UserId=MCW.UserId and Z._CreatedWhen=MCW.maxCreatedWhen) X
		on APU.ID = X.maxID	
	inner join	[10.192.23.11].[APT2012].[dbo].aspnet_Membership AM on AM.UserId = APU.UserId
	where	AM.Password <> APU.PAssword
	or	AM.PasswordFormat <> APU.PasswordFormat
	or	AM.PasswordSalt <> APU.PasswordSalt
	or	AM.MobilePIN <> isnull(APU.MobilePIN,'');

		select convert(varchar,@@ROWCOUNT) + ' updates to WEB.aspnet_Membership by Synch_ASPnet_Password';
*/
	--Archive update log

	insert into ASP_PASSWORD_HIST (
		[UserId],

		[UserName],
		[Password],
		[PasswordFormat],
		[PasswordSalt],
		[MobilePIN],
		[MobileAlias],
		[IsAnonymous],

		_CreatedWhen,
		_CreatedBy,
		_CreatedOn,
		_CreatedIn,

		_ProcessedWhen,
		ID
	)
	select	[UserId],

		[UserName],
		[Password],
		[PasswordFormat],
		[PasswordSalt],
		[MobilePIN],
		[MobileAlias],
		[IsAnonymous],

		_CreatedWhen,
		_CreatedBy,
		_CreatedOn,
		_CreatedIn,

		getdate(),
		ID

	from	ASP_PASSWORD_UPDATE_LOG;

		select convert(varchar,@@ROWCOUNT) + ' history archivals by Synch_ASPnet_Password';
END TRY

BEGIN CATCH
	SELECT	@ErrorMessage = 'Error in procedure Synch_ASPnet_Password: ' + ERROR_MESSAGE(),
		@ErrorSeverity = ERROR_SEVERITY(),
		@ErrorState = ERROR_STATE();

	RAISERROR (	@ErrorMessage,
			@ErrorSeverity,
			@ErrorState	);

	if @@TRANCOUNT > 0
		rollback transaction;
END CATCH

--END OF: Apply ASPnet PAssword updates to ASPnet

GO