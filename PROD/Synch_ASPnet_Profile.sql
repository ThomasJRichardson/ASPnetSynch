USE [APT2012]
GO

/* Environments:
	PReProd	[10.192.23.11]
	PROD	[10.192.23.10]
*/

/****** Object:  StoredProcedure [dbo].[Synch_ASPnet_Profile]    Script Date: 11/19/2013 09:32:42 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Synch_ASPnet_Profile]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Synch_ASPnet_Profile]
GO

USE [APT2012]
GO

/****** Object:  StoredProcedure [dbo].[Synch_ASPnet_Profile]    Script Date: 11/19/2013 09:32:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Synch_ASPnet_Profile]
AS
set nocount on;

DECLARE	@ErrorMessage NVARCHAR(4000),
	@ErrorSeverity INT,
	@ErrorState INT;

--START OF: Apply ASPnet Profile updates to ASPnet

Begin Try
	--add in updates from web where not already in local

	insert into ASP_PROFILE_UPDATE_LOG (
		[UserId],

		[FirstName],
		[LastName],

		[MemberId],
		[SchemeId],

		[Address1],
		[Address2],
		[Address3],
		[Address4],

		[PhoneHome],
		[PhoneMobile],
		[PhoneOffice],
		[Fax],

		[Email],

		_CreatedWhen,
		_CreatedBy,
		_CreatedOn,
		_CreatedIn,

		ID
	)
	select	[UserId],

		[FirstName],
		[LastName],

		[MemberId],
		[SchemeId],

		[Address1],
		[Address2],
		[Address3],
		[Address4],

		[PhoneHome],
		[PhoneMobile],
		[PhoneOffice],
		[Fax],

		[Email],

		_CreatedWhen,
		_CreatedBy,
		_CreatedOn,
		_CreatedIn,

		ID

	from	ASP_PROFILE_UPDATE_WEB

	EXCEPT

	select	[UserId],

		[FirstName],
		[LastName],

		[MemberId],
		[SchemeId],

		[Address1],
		[Address2],
		[Address3],
		[Address4],

		[PhoneHome],
		[PhoneMobile],
		[PhoneOffice],
		[Fax],

		[Email],

		_CreatedWhen,
		_CreatedBy,
		_CreatedOn,
		_CreatedIn,

		ID

	from	ASP_PROFILE_UPDATE_LOG;

		select convert(varchar,@@ROWCOUNT) + ' added from Web to ASP_PROFILE_UPDATE_LOG by Synch_ASPnet_Profile';

	--add in Profund amendments

	exec Synch_ASPnet_PROFUND;

	--Update Profile - Local & Sungard

	update AP
	set	AP.Address1 = APU.Address1,
		AP.Address2 = APU.Address2,
		AP.Address3 = APU.Address3,
		AP.Address4 = APU.Address4,
		AP.PhoneHome = case when isnull(APU.PHoneHome,'') = '' then AP.PhoneHome else APU.PHoneHome end,
		AP.Fax = APU.Fax,
		AP.PhoneMobile = case when isnull(APU.PHoneMobile,'') = '' then AP.PhoneMobile else APU.PHoneMobile end
	from		ASP_PROFILE_UPDATE_LOG APU
	inner join	(select Z.UserId,Z._CreatedWhen,Z.maxID from
			(select UserId,_CreatedWhen,max(ID) as maxID from ASP_PROFILE_UPDATE_LOG group by UserId,_CreatedWhen) Z
	inner join	(select UserId, max(_CreatedWhen) as maxCreatedWhen from ASP_PROFILE_UPDATE_LOG group by UserId) MCW
		on Z.UserId=MCW.UserId and Z._CreatedWhen=MCW.maxCreatedWhen) X
		on APU.ID = X.maxID	
	inner join	aspnet_Profile AP on AP.UserId = APU.UserId
	where	isnull(APU.Address1,'') <> ''
	and (	isnull(AP.Address1,'') <> isnull(APU.Address1,'')
	or	isnull(AP.Address2,'') <> isnull(APU.Address2,'')
	or	isnull(AP.Address3,'') <> isnull(APU.Address3,'')
	or	isnull(AP.Address4,'') <> isnull(APU.Address4,'')
	or	isnull(AP.PhoneHome,'') <> isnull(APU.PhoneHome,'')
	or	isnull(AP.Fax,'') <> isnull(APU.Fax,'')
	or	isnull(AP.PhoneMobile,'') <> isnull(APU.PhoneMobile,'')
	);

		select convert(varchar,@@ROWCOUNT) + ' updates to LCL.aspnet_Profile by Synch_ASPnet_Profile';
/*
	update AP
	set	AP.Address1 = APU.Address1,
		AP.Address2 = APU.Address2,
		AP.Address3 = APU.Address3,
		AP.Address4 = APU.Address4,
		AP.PhoneHome = case when isnull(APU.PHoneHome,'') = '' then AP.PhoneHome else APU.PHoneHome end,
		AP.Fax = APU.Fax,
		AP.PhoneMobile = case when isnull(APU.PHoneMobile,'') = '' then AP.PhoneMobile else APU.PHoneMobile end
	from		ASP_PROFILE_UPDATE_LOG APU
	inner join	(select Z.UserId,Z._CreatedWhen,Z.maxID from
			(select UserId,_CreatedWhen,max(ID) as maxID from ASP_PROFILE_UPDATE_LOG group by UserId,_CreatedWhen) Z
	inner join	(select UserId, max(_CreatedWhen) as maxCreatedWhen from ASP_PROFILE_UPDATE_LOG group by UserId) MCW
		on Z.UserId=MCW.UserId and Z._CreatedWhen=MCW.maxCreatedWhen) X
		on APU.ID = X.maxID	
	inner join	[10.192.23.10].[APT2012].[dbo].aspnet_Profile AP on AP.UserId = APU.UserId
	where	isnull(APU.Address1,'') <> ''
	and (	isnull(AP.Address1,'') <> isnull(APU.Address1,'')
	or	isnull(AP.Address2,'') <> isnull(APU.Address2,'')
	or	isnull(AP.Address3,'') <> isnull(APU.Address3,'')
	or	isnull(AP.Address4,'') <> isnull(APU.Address4,'')
	or	isnull(AP.PhoneHome,'') <> isnull(APU.PhoneHome,'')
	or	isnull(AP.Fax,'') <> isnull(APU.Fax,'')
	or	isnull(AP.PhoneMobile,'') <> isnull(APU.PhoneMobile,'')
	);

		select convert(varchar,@@ROWCOUNT) + ' updates to WEB.aspnet_Profile by Synch_ASPnet_Profile';
*/
	--Update Membership - Local & Sungard

	update AM
	set	AM.Email = APU.Email,
		AM.LoweredEmail = lower(APU.Email)
	from		ASP_PROFILE_UPDATE_LOG APU
	inner join	(select Z.UserId,Z._CreatedWhen,Z.maxID from
			(select UserId,_CreatedWhen,max(ID) as maxID from ASP_PROFILE_UPDATE_LOG group by UserId,_CreatedWhen) Z
	inner join	(select UserId, max(_CreatedWhen) as maxCreatedWhen from ASP_PROFILE_UPDATE_LOG group by UserId) MCW
		on Z.UserId=MCW.UserId and Z._CreatedWhen=MCW.maxCreatedWhen) X
		on APU.ID = X.maxID	
	inner join	aspnet_Membership AM on AM.UserId = APU.UserId
	where	isnull(APU.Email,'') <> ''
	and	isnull(AM.Email,'') <> isnull(APU.Email,'');

		select convert(varchar,@@ROWCOUNT) + ' updates to LCL.aspnet_Membership by Synch_ASPnet_Profile';
/*
	update AM
	set	AM.Email = APU.Email,
		AM.LoweredEmail = lower(APU.Email)
	from		ASP_PROFILE_UPDATE_LOG APU
	inner join	(select Z.UserId,Z._CreatedWhen,Z.maxID from
			(select UserId,_CreatedWhen,max(ID) as maxID from ASP_PROFILE_UPDATE_LOG group by UserId,_CreatedWhen) Z
	inner join	(select UserId, max(_CreatedWhen) as maxCreatedWhen from ASP_PROFILE_UPDATE_LOG group by UserId) MCW
		on Z.UserId=MCW.UserId and Z._CreatedWhen=MCW.maxCreatedWhen) X
		on APU.ID = X.maxID	
	inner join	[10.192.23.10].[APT2012].[dbo].aspnet_Membership AM on AM.UserId = APU.UserId
	where	isnull(APU.Email,'') <> ''
	and	isnull(AM.Email,'') <> isnull(APU.Email,'');

		select convert(varchar,@@ROWCOUNT) + ' updates to WEB.aspnet_Membership by Synch_ASPnet_Profile';
*/
	--Archive update log

	insert into ASP_PROFILE_HIST (
		[UserId],

		[FirstName],
		[LastName],

		[MemberId],
		[SchemeId],

		[Address1],
		[Address2],
		[Address3],
		[Address4],

		[PhoneHome],
		[PhoneMobile],
		[PhoneOffice],
		[Fax],

		[Email],

		_CreatedWhen,
		_CreatedBy,
		_CreatedOn,
		_CreatedIn,

		_ProcessedWhen,
		ID
	)
	select	[UserId],

		[FirstName],
		[LastName],

		[MemberId],
		[SchemeId],

		[Address1],
		[Address2],
		[Address3],
		[Address4],

		[PhoneHome],
		[PhoneMobile],
		[PhoneOffice],
		[Fax],

		[Email],

		_CreatedWhen,
		_CreatedBy,
		_CreatedOn,
		_CreatedIn,

		getdate(),
		ID

	from	ASP_PROFILE_UPDATE_LOG;

		select convert(varchar,@@ROWCOUNT) + ' history archivals by Synch_ASPnet_Profile';
END TRY

BEGIN CATCH
	SELECT	@ErrorMessage = 'Error in procedure Synch_ASPnet_Profile: ' + ERROR_MESSAGE(),
		@ErrorSeverity = ERROR_SEVERITY(),
		@ErrorState = ERROR_STATE();

	RAISERROR (	@ErrorMessage,
			@ErrorSeverity,
			@ErrorState	);

	if @@TRANCOUNT > 0
		rollback transaction;
END CATCH

--END OF: Apply ASPnet Profile updates to ASPnet

GO