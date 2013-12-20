USE [APT2012]
GO

/****** Object:  Trigger [aspnet_Membership_UTR]    Script Date: 11/13/2013 09:24:52 ******/
IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[aspnet_Membership_UTR]'))
DROP TRIGGER [dbo].[aspnet_Membership_UTR]
GO

USE [APT2012]
GO

/****** Object:  Trigger [dbo].[aspnet_Membership_UTR]    Script Date: 11/13/2013 09:24:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create trigger [dbo].[aspnet_Membership_UTR]
on [dbo].[aspnet_Membership]
for update
AS

if (select count(1) from inserted) = 0
and (select count(1) from deleted) = 0
	return;

DECLARE	@ErrorMessage NVARCHAR(4000),
	@ErrorSeverity INT,
	@ErrorState INT;

--insert into PRofile log where ((inserted <> deleted) <> current log)

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

		isnull(P.[FirstName],''),
		isnull(P.[LastName],''),

		isnull(P.[MemberId],''),
		isnull(P.[SchemeId],''),

		isnull(P.[Address1],''),
		isnull(P.[Address2],''),
		isnull(P.[Address3],''),
		isnull(P.[Address4],''),

		isnull(P.[PhoneHome],''),
		isnull(P.[PhoneMobile],''),
		isnull(P.[PhoneOffice],''),
		isnull(P.[Fax],''),

		isnull(I.[Email],''),

		getdate(),
		suser_name(),
		@@Servername,
		db_name()
	from		inserted I
	inner join	deleted D on D.UserId = I.UserId
	inner join	aspnet_Profile P on P.UserId = I.UserId

	EXCEPT

	select
		D.[UserId],

		isnull(P.[FirstName],''),
		isnull(P.[LastName],''),

		isnull(P.[MemberId],''),
		isnull(P.[SchemeId],''),

		isnull(P.[Address1],''),
		isnull(P.[Address2],''),
		isnull(P.[Address3],''),
		isnull(P.[Address4],''),

		isnull(P.[PhoneHome],''),
		isnull(P.[PhoneMobile],''),
		isnull(P.[PhoneOffice],''),
		isnull(P.[Fax],''),

		isnull(D.[Email],''),

		getdate(),
		suser_name(),
		@@Servername,
		db_name()
	from		deleted D
	inner join	aspnet_Profile P on P.UserId = D.UserId

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

	insert into [dbo].[ASP_PASSWORD_UPDATES](
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
		_CreatedIn
	)

	select
		I.[UserId],

		U.[UserName],
		I.[Password],
		I.[PasswordFormat],
		I.[PasswordSalt],
		isnull(I.[MobilePIN],''),
		isnull(U.[MobileAlias],''),
		U.[IsAnonymous],

		getdate(),
		suser_name(),
		@@Servername,
		db_name()
	from		inserted I
	inner join	deleted D on D.UserId = I.UserId
	inner join	aspnet_Users U on U.UserId = I.UserId

	EXCEPT

	select
		D.[UserId],

		U.[UserName],

		D.[Password],
		D.[PasswordFormat],
		D.[PasswordSalt],
		isnull(D.[MobilePIN],''),

		isnull(U.[MobileAlias],''),
		U.[IsAnonymous],

		getdate(),
		suser_name(),
		@@Servername,
		db_name()
	from		deleted D
	inner join	aspnet_Users U on U.UserId = D.UserId

	EXCEPT

	select
		ASP.[UserId],

		ASP.[UserName],
		ASP.[Password],
		ASP.[PasswordFormat],
		ASP.[PasswordSalt],
		isnull(ASP.[MobilePIN],''),
		isnull(ASP.[MobileAlias],''),
		ASP.[IsAnonymous],


		getdate(),
		suser_name(),
		@@Servername,
		db_name()
	from		[dbo].[ASP_PASSWORD_UPDATES] ASP;
END TRY

BEGIN CATCH
	SELECT	@ErrorMessage = 'Error in aspnet_Membership_UTR: ' + ERROR_MESSAGE(),
		@ErrorSeverity = ERROR_SEVERITY(),
		@ErrorState = ERROR_STATE();

	RAISERROR (	@ErrorMessage,
			@ErrorSeverity,
			@ErrorState	);

	if @@TRANCOUNT > 0
		rollback transaction;
END CATCH
GO