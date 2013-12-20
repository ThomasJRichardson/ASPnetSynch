USE [APT2012]
GO

/****** Object:  Trigger [aspnet_Profile_UTR]    Script Date: 11/13/2013 09:24:52 ******/
IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[aspnet_Profile_UTR]'))
DROP TRIGGER [dbo].[aspnet_Profile_UTR]
GO

USE [APT2012]
GO

/****** Object:  Trigger [dbo].[aspnet_Profile_UTR]    Script Date: 11/13/2013 09:24:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create trigger [dbo].[aspnet_Profile_UTR]
on [dbo].[aspnet_Profile]
for update
AS

if (select count(1) from inserted) = 0
and (select count(1) from deleted) = 0
	return;

DECLARE	@ErrorMessage NVARCHAR(4000),
	@ErrorSeverity INT,
	@ErrorState INT;

--insert into Password log where ((inserted <> deleted) <> current log)

BEGIN TRY
	insert into [dbo].[ASP_PROFILE_UPDATES](
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
		_CreatedIn
	)

	select
		I.[UserId],
		isnull(I.[FirstName],''),
		isnull(I.[LastName],''),
		isnull(I.[MemberId],''),
		isnull(I.[SchemeId],''),
		isnull(I.[Address1],''),
		isnull(I.[Address2],''),
		isnull(I.[Address3],''),
		isnull(I.[Address4],''),
		isnull(I.[PhoneHome],''),
		isnull(I.[PhoneMobile],''),
		isnull(I.[PhoneOffice],''),
		isnull(I.[Fax],''),
		isnull(M.[Email],''),

		getdate(),
		suser_name(),
		@@Servername,
		db_name()
	from		inserted I
	inner join	deleted D on D.UserId = I.UserId
	inner join	aspnet_Membership M on M.UserId = I.UserId

	EXCEPT

	select
		D.[UserId],
		isnull(D.[FirstName],''),
		isnull(D.[LastName],''),
		isnull(D.[MemberId],''),
		isnull(D.[SchemeId],''),
		isnull(D.[Address1],''),
		isnull(D.[Address2],''),
		isnull(D.[Address3],''),
		isnull(D.[Address4],''),
		isnull(D.[PhoneHome],''),
		isnull(D.[PhoneMobile],''),
		isnull(D.[PhoneOffice],''),
		isnull(D.[Fax],''),
		isnull(M.[Email],''),

		getdate(),
		suser_name(),
		@@Servername,
		db_name()
	from		deleted D
	inner join	aspnet_Membership M on M.UserId = D.UserId

	EXCEPT

	select
		ASP.[UserId],
		isnull(ASP.[FirstName],''),
		isnull(ASP.[LastName],''),
		isnull(ASP.[MemberId],''),
		isnull(ASP.[SchemeId],''),
		isnull(ASP.[Address1],''),
		isnull(ASP.[Address2],''),
		isnull(ASP.[Address3],''),
		isnull(ASP.[Address4],''),
		isnull(ASP.[PhoneHome],''),
		isnull(ASP.[PhoneMobile],''),
		isnull(ASP.[PhoneOffice],''),
		isnull(ASP.[Fax],''),
		isnull(ASP.[Email],''),

		getdate(),
		suser_name(),
		@@Servername,
		db_name()
	from		[dbo].[ASP_PROFILE_UPDATES] ASP;
END TRY

BEGIN CATCH
	SELECT	@ErrorMessage = 'Error in aspnet_Profile_UTR: ' + ERROR_MESSAGE(),
		@ErrorSeverity = ERROR_SEVERITY(),
		@ErrorState = ERROR_STATE();

	RAISERROR (	@ErrorMessage,
			@ErrorSeverity,
			@ErrorState	);

	if @@TRANCOUNT > 0
		rollback transaction;
END CATCH
GO


