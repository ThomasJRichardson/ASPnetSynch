USE [APT2012]
GO

/****** Object:  StoredProcedure [dbo].[Synch_ASPnet_PROFUND]    Script Date: 11/19/2013 09:32:42 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Synch_ASPnet_PROFUND]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Synch_ASPnet_PROFUND]
GO

USE [APT2012]
GO

/****** Object:  StoredProcedure [dbo].[Synch_ASPnet_PROFUND]    Script Date: 11/19/2013 09:32:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Synch_ASPnet_PROFUND]
AS

DECLARE	@ErrorMessage NVARCHAR(4000),
	@ErrorSeverity INT,
	@ErrorState INT;

BEGIN TRY
	--get current Profund data

	insert into PF_ADDRESS_NOW (
		ParentUID,
		Line1,
		Line2,
		Line3,
		Line4,
		TelephoneNumber,
		FaxNumber,
		MobileNumber,
		Email
	)
	select	a.ParentUID,
		a.Line1,
		a.Line2,
		a.Line3,
		a.Line4,
		a.TelephoneNumber,
		a.FaxNumber,
		m.Value,
		isnull(e.Value, a.Email)
	from		APTLIVE.dbo.Address a
	left outer join	APTLIVE.dbo.Communications m on m.ParentUID = a.ParentUID and m.CatID = 800 and m.Enddate is null
	left outer join	APTLIVE.dbo.Communications e on e.ParentUID = a.ParentUID and e.CatID = 802 and e.Enddate is null
	where	a.CatID = 1
	and	a.EndDate is null;

		select convert(varchar,@@ROWCOUNT) + ' "now" inserts by Synch_ASPnet_PROFUND';

	--put inserts and changes (not deletions) into DIFF

	insert into PF_ADDRESS_DIFF (
		ParentUID,
		Line1,
		Line2,
		Line3,
		Line4,
		TelephoneNumber,
		FaxNumber,
		MobileNumber,
		Email
	)
	select	ParentUID,
		isnull(Line1,'') as Line1,
		isnull(Line2,'') as Line2,
		isnull(Line3,'') as Line3,
		isnull(Line4,'') as Line4,
		isnull(TelephoneNumber,'') as TelephoneNumber,
		isnull(FaxNumber,'') as FaxNumber,
		isnull(MobileNumber,'') as MobileNumber,
		isnull(Email,'') as Email
	from PF_ADDRESS_NOW
	EXCEPT
	select	ParentUID,
		isnull(Line1,'') as Line1,
		isnull(Line2,'') as Line2,
		isnull(Line3,'') as Line3,
		isnull(Line4,'') as Line4,
		isnull(TelephoneNumber,'') as TelephoneNumber,
		isnull(FaxNumber,'') as FaxNumber,
		isnull(MobileNumber,'') as MobileNumber,
		isnull(Email,'') as Email
	from PF_ADDRESS_ARC;

		select convert(varchar,@@ROWCOUNT) + ' "diff" inserts by Synch_ASPnet_PROFUND';

	--Write existing profile updates into Profund

	update A
	set	A.Enddate = dateadd(dd, -1, getdate())
	from		ASP_PROFILE_UPDATE_LOG P
	inner join	(select Z.UserId,Z._CreatedWhen,Z.maxID from
			(select UserId,_CreatedWhen,max(ID) as maxID from ASP_PROFILE_UPDATE_LOG group by UserId,_CreatedWhen) Z
	inner join	(select UserId, max(_CreatedWhen) as maxCreatedWhen from ASP_PROFILE_UPDATE_LOG group by UserId) MCW
		on Z.UserId=MCW.UserId and Z._CreatedWhen=MCW.maxCreatedWhen) X
		on P.ID = X.maxID	
	inner join	Member M on M.ID = P.MemberID
	inner join	APTLIVE.dbo.Person PFP on PFP.PersonUID = M.PersonUID
	inner join	APTLIVE.dbo.Address A on A.ParentUID = M.PersonUID and A.CatID = 1 and A.Enddate is null
			and A.Line1 <> case when isnull(P.Address1,'') = '' then A.Line1 else P.Address1 end

		select convert(varchar,@@ROWCOUNT) + ' Profund Address closures by Synch_ASPnet_PROFUND';

	insert into APTLIVE.dbo.Address (
		ParentUID,
		CatID,
		EffDate,
		Line1,
		Line2,
		Line3,
		Line4,
		TelephoneNumber,
		FaxNumber,
		CreationStamp, WFCreatorID, CreatorStepID, WFOwnerID, OWnerStepID
	)
	select	M.PersonUID,
		1,
		getdate(),
		P.Address1,
		P.Address2,
		P.Address3,
		P.Address4,
		P.PhoneHome,
		P.Fax,
		getdate(), 1, 1, 1, 1
	from		ASP_PROFILE_UPDATE_LOG P
	inner join	(select Z.UserId,Z._CreatedWhen,Z.maxID from
			(select UserId,_CreatedWhen,max(ID) as maxID from ASP_PROFILE_UPDATE_LOG group by UserId,_CreatedWhen) Z
	inner join	(select UserId, max(_CreatedWhen) as maxCreatedWhen from ASP_PROFILE_UPDATE_LOG group by UserId) MCW
		on Z.UserId=MCW.UserId and Z._CreatedWhen=MCW.maxCreatedWhen) X
		on P.ID = X.maxID	
	inner join	Member M on M.ID = P.MemberID
	inner join	APTLIVE.dbo.Person PFP on PFP.PersonUID = M.PersonUID
	and not exists (select 1 from APTLIVE.dbo.Address A where A.ParentUID = M.PersonUID and A.CatID = 1 and A.Enddate is null
			and A.Line1 = case when isnull(P.Address1,'') = '' then A.Line1 else P.Address1 end)

		select convert(varchar,@@ROWCOUNT) + ' Profund Address inserts by Synch_ASPnet_PROFUND';

	insert into APTLIVE.dbo.Communications (
		ParentUID,
		CatID,
		EffDate,
		Value,
		CreationStamp, WFCreatorID, CreatorStepID, WFOwnerID, OWnerStepID
	)
	select	M.PersonUID,
		802,
		getdate(),
		P.Email,
		getdate(), 1, 1, 1, 1
	from		ASP_PROFILE_UPDATE_LOG P
	inner join	(select Z.UserId,Z._CreatedWhen,Z.maxID from
			(select UserId,_CreatedWhen,max(ID) as maxID from ASP_PROFILE_UPDATE_LOG group by UserId,_CreatedWhen) Z
	inner join	(select UserId, max(_CreatedWhen) as maxCreatedWhen from ASP_PROFILE_UPDATE_LOG group by UserId) MCW
		on Z.UserId=MCW.UserId and Z._CreatedWhen=MCW.maxCreatedWhen) X
		on P.ID = X.maxID	
	inner join	Member M on M.ID = P.MemberID
	inner join	APTLIVE.dbo.Person PFP on PFP.PersonUID = M.PersonUID
	where not exists (select 1 from APTLIVE.dbo.Communications where ParentUID = M.PersonUID and CatID = 802)

		select convert(varchar,@@ROWCOUNT) + ' Profund Email inserts by Synch_ASPnet_PROFUND';

	update c
	set	c.EffDate = getdate(),
		c.Value = P.Email
	from		ASP_PROFILE_UPDATE_LOG P
	inner join	(select Z.UserId,Z._CreatedWhen,Z.maxID from
			(select UserId,_CreatedWhen,max(ID) as maxID from ASP_PROFILE_UPDATE_LOG group by UserId,_CreatedWhen) Z
	inner join	(select UserId, max(_CreatedWhen) as maxCreatedWhen from ASP_PROFILE_UPDATE_LOG group by UserId) MCW
		on Z.UserId=MCW.UserId and Z._CreatedWhen=MCW.maxCreatedWhen) X
		on P.ID = X.maxID	
	inner join	Member M on M.ID = P.MemberID
	inner join	APTLIVE.dbo.Person PFP on PFP.PersonUID = M.PersonUID
	inner join	APTLIVE.dbo.Communications c on c.ParentUID = M.PersonUID and c.CatID = 802
	where	isnull(P.Email,'') <> ''
	and	isnull(c.Value,'') <> isnull(P.Email,'')

		select convert(varchar,@@ROWCOUNT) + ' Profund Email updates by Synch_ASPnet_PROFUND';

	insert into APTLIVE.dbo.Communications (
		ParentUID,
		CatID,
		EffDate,
		Value,
		CreationStamp, WFCreatorID, CreatorStepID, WFOwnerID, OWnerStepID
	)
	select	M.PersonUID,
		800,
		getdate(),
		P.PHoneMobile,
		getdate(), 1, 1, 1, 1
	from		ASP_PROFILE_UPDATE_LOG P
	inner join	(select Z.UserId,Z._CreatedWhen,Z.maxID from
			(select UserId,_CreatedWhen,max(ID) as maxID from ASP_PROFILE_UPDATE_LOG group by UserId,_CreatedWhen) Z
	inner join	(select UserId, max(_CreatedWhen) as maxCreatedWhen from ASP_PROFILE_UPDATE_LOG group by UserId) MCW
		on Z.UserId=MCW.UserId and Z._CreatedWhen=MCW.maxCreatedWhen) X
		on P.ID = X.maxID	
	inner join	Member M on M.ID = P.MemberID
	inner join	APTLIVE.dbo.Person PFP on PFP.PersonUID = M.PersonUID
	where not exists (select 1 from APTLIVE.dbo.Communications where ParentUID = M.PersonUID and CatID = 800)

		select convert(varchar,@@ROWCOUNT) + ' Profund Mobile inserts by Synch_ASPnet_PROFUND';

	update c
	set	c.EffDate = getdate(),
		c.Value = P.PhoneMobile
	from		ASP_PROFILE_UPDATE_LOG P
	inner join	(select Z.UserId,Z._CreatedWhen,Z.maxID from
			(select UserId,_CreatedWhen,max(ID) as maxID from ASP_PROFILE_UPDATE_LOG group by UserId,_CreatedWhen) Z
	inner join	(select UserId, max(_CreatedWhen) as maxCreatedWhen from ASP_PROFILE_UPDATE_LOG group by UserId) MCW
		on Z.UserId=MCW.UserId and Z._CreatedWhen=MCW.maxCreatedWhen) X
		on P.ID = X.maxID	
	inner join	Member M on M.ID = P.MemberID
	inner join	APTLIVE.dbo.Person PFP on PFP.PersonUID = M.PersonUID
	inner join	APTLIVE.dbo.Communications c on c.ParentUID = M.PersonUID and c.CatID = 800
	where	isnull(P.PhoneMobile,'') <> ''
	and	isnull(c.Value,'') <> isnull(P.PhoneMobile,'')

		select convert(varchar,@@ROWCOUNT) + ' Profund Mobile updates by Synch_ASPnet_PROFUND';

	--Profund DIFFs => Profile updates for ASPnet

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
	select	AP.UserId,
		AP.FirstName,
		AP.LastName,
		AP.MemberId,
		AP.SchemeId,

		D.Line1,
		D.Line2,
		D.Line3,
		D.Line4,
		D.TelephoneNumber,
		D.MobileNumber,
		null,
		D.FaxNumber,
		D.Email,

		getdate(),
		'Profund',
		@@SERVERNAME,
		db_name(),
		1

	from		PF_ADDRESS_DIFF D
	inner join	APTLIVE.dbo.Person P on P.PersonUID = D.ParentUID
	inner join	APT2012.dbo.Member M on M.PersonUID = P.PersonUID and M.PPSN = P.NationalIDNumber
	inner join	aspnet_Profile AP on AP.MemberId = M.ID
	inner join	aspnet_Membership AM on AM.UserID = AP.UserId
	where not exists (select 1 from ASP_PROFILE_UPDATE_LOG where UserId = AP.UserId);

		select convert(varchar,@@ROWCOUNT) + ' "log" inserts by Synch_ASPnet_PROFUND';

	--Archive Profund updates

	insert into PF_ADDRESS_HIST (
		ParentUID,
		Line1,
		Line2,
		Line3,
		Line4,
		TelephoneNumber,
		FaxNumber,
		MobileNumber,
		Email,
		_ProcessedWhen
	)
	select	ParentUID,
		Line1,
		Line2,
		Line3,
		Line4,
		TelephoneNumber,
		FaxNumber,
		MobileNumber,
		Email,
		getdate()
	from PF_ADDRESS_DIFF;

		select convert(varchar,@@ROWCOUNT) + ' history archivals by Synch_ASPnet_PROFUND';

	--Replace local Profund archive with current local

	delete from PF_ADDRESS_ARC;

	insert into PF_ADDRESS_ARC (
		ParentUID,
		Line1,
		Line2,
		Line3,
		Line4,
		TelephoneNumber,
		FaxNumber,
		MobileNumber,
		Email
	)
	select	a.ParentUID,
		a.Line1,
		a.Line2,
		a.Line3,
		a.Line4,
		a.TelephoneNumber,
		a.FaxNumber,
		m.Value,
		isnull(e.Value, a.Email)
	from		APTLIVE.dbo.Address a
	left outer join	APTLIVE.dbo.Communications m on m.ParentUID = a.ParentUID and m.CatID = 800 and m.Enddate is null
	left outer join	APTLIVE.dbo.Communications e on e.ParentUID = a.ParentUID and e.CatID = 802 and e.Enddate is null
	where	a.CatID = 1
	and	a.EndDate is null;

		select convert(varchar,@@ROWCOUNT) + ' "arc" refreshings by Synch_ASPnet_PROFUND';
END TRY

BEGIN CATCH
	SELECT	@ErrorMessage = 'Error in procedure Synch_ASPnet_PROFUND: ' + ERROR_MESSAGE(),
		@ErrorSeverity = ERROR_SEVERITY(),
		@ErrorState = ERROR_STATE();

	RAISERROR (	@ErrorMessage,
			@ErrorSeverity,
			@ErrorState	);

	if @@TRANCOUNT > 0
		rollback transaction;
END CATCH
GO