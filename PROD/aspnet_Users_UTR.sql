USE [APT2012]
GO

/****** Object:  Trigger [aspnet_Users_UTR]    Script Date: 11/13/2013 09:24:52 ******/
IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[aspnet_Users_UTR]'))
DROP TRIGGER [dbo].[aspnet_Users_UTR]
GO

USE [APT2012]
GO

/****** Object:  Trigger [dbo].[aspnet_Users_UTR]    Script Date: 11/13/2013 09:24:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create trigger [dbo].[aspnet_Users_UTR]
on [dbo].[aspnet_Users]
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
		I.[UserName],

		M.[Password],
		M.[PasswordFormat],
		M.[PasswordSalt],
		isnull(M.[MobilePIN],''),

		isnull(I.[MobileAlias],''),
		I.[IsAnonymous],

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
		D.[UserName],

		M.[Password],
		M.[PasswordFormat],
		M.[PasswordSalt],
		isnull(M.[MobilePIN],''),

		isnull(D.[MobileAlias],''),
		D.[IsAnonymous],

		getdate(),
		suser_name(),
		@@Servername,
		db_name()
	from		deleted D
	inner join	aspnet_Membership M on M.UserId = D.UserId

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
	SELECT	@ErrorMessage = 'Error in aspnet_Users_UTR: ' + ERROR_MESSAGE(),
		@ErrorSeverity = ERROR_SEVERITY(),
		@ErrorState = ERROR_STATE();

	RAISERROR (	@ErrorMessage,
			@ErrorSeverity,
			@ErrorState	);

	if @@TRANCOUNT > 0
		rollback transaction;
END CATCH
GO