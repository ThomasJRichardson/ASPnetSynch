USE [APT2012]
GO

/* Environments:
	PReProd	[10.192.23.11]
	PROD	[10.192.23.10]
*/

/****** Object:  StoredProcedure [dbo].[Synch_ASPnet_Add]    Script Date: 11/19/2013 09:32:42 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Synch_ASPnet_Add]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Synch_ASPnet_Add]
GO

USE [APT2012]
GO

/****** Object:  StoredProcedure [dbo].[Synch_ASPnet_Add]    Script Date: 11/19/2013 09:32:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Synch_ASPnet_Add]
AS

DECLARE	@ErrorMessage NVARCHAR(4000),
	@ErrorSeverity INT,
	@ErrorState INT;

BEGIN TRY
--add new records

	--Users
	insert into [10.192.23.11].[APT2012].[dbo].aspnet_Users (
		ApplicationId,
		--UserId,
		UserName,
		LoweredUserName,
		MobileAlias,
		IsAnonymous,
		LastActivityDate
	)
	select	i.ApplicationId,
		--i.UserId,
		i.UserName,
		i.LoweredUserName,
		i.MobileAlias,
		i.IsAnonymous,
		i.LastActivityDate
	from	aspnet_Users i
	inner join (select ApplicationId,LoweredUsername from aspnet_Users EXCEPT select ApplicationId,LoweredUsername from aspnet_Users_WEB) n
		on i.ApplicationId = n.ApplicationId and i.LoweredUsername = n.LoweredUsername

/*
	--UsersScheme
	insert into [10.192.23.11].[APT2012].[dbo].aspnet_UsersScheme (
		SchemeId,
		UserId
	)
	select	u.SchemeId,
		nu.UserId
	from	aspnet_Users i
	inner join (select ApplicationId,LoweredUsername from aspnet_Users EXCEPT select ApplicationId,LoweredUsername from aspnet_Users_WEB) n
		on i.ApplicationId = n.ApplicationId and i.LoweredUsername = n.LoweredUsername
	inner join aspnet_UsersScheme u
		on u.UserId = i.UserId
	inner join [10.192.23.11].[APT2012].[dbo].aspnet_Users nu
		on i.ApplicationId = nu.ApplicationId and i.LoweredUsername = nu.LoweredUsername
*/

	--UsersInRoles
	insert into [10.192.23.11].[APT2012].[dbo].aspnet_UsersInRoles (
		UserId,
		RoleId
	)
	select	nu.UserId,
		r.RoleId
	from	aspnet_Users i
	inner join (select ApplicationId,LoweredUsername from aspnet_Users EXCEPT select ApplicationId,LoweredUsername from aspnet_Users_WEB) n
		on i.ApplicationId = n.ApplicationId and i.LoweredUsername = n.LoweredUsername
	inner join aspnet_UsersInRoles r
		on r.UserId = i.UserId
	inner join [10.192.23.11].[APT2012].[dbo].aspnet_Users nu
		on i.ApplicationId = nu.ApplicationId and i.LoweredUsername = nu.LoweredUsername

	--Membership
	insert into [10.192.23.11].[APT2012].[dbo].aspnet_Membership (
		ApplicationId,
		UserId,
		Password,
		PasswordFormat,
		PasswordSalt,
		MobilePIN,
		Email,
		LoweredEmail,
		PasswordQuestion,
		PasswordAnswer,
		IsApproved,
		IsLockedOut,
		CreateDate,
		LastLoginDate,
		LastPasswordChangedDate,
		LastLockoutDate,
		FailedPasswordAttemptCount,
		FailedPasswordAttemptWindowStart,
		FailedPasswordAnswerAttemptCount,
		FailedPasswordAnswerAttemptWindowStart,
		Comment,
		IsPasswordReset
	)
	select	m.ApplicationId,
		nu.UserId,
		m.Password,
		m.PasswordFormat,
		m.PasswordSalt,
		m.MobilePIN,
		m.Email,
		m.LoweredEmail,
		m.PasswordQuestion,
		m.PasswordAnswer,
		m.IsApproved,
		m.IsLockedOut,
		m.CreateDate,
		m.LastLoginDate,
		m.LastPasswordChangedDate,
		m.LastLockoutDate,
		m.FailedPasswordAttemptCount,
		m.FailedPasswordAttemptWindowStart,
		m.FailedPasswordAnswerAttemptCount,
		m.FailedPasswordAnswerAttemptWindowStart,
		m.Comment,
		m.IsPasswordReset
	from	aspnet_Users i
	inner join (select ApplicationId,LoweredUsername from aspnet_Users EXCEPT select ApplicationId,LoweredUsername from aspnet_Users_WEB) n
		on i.ApplicationId = n.ApplicationId and i.LoweredUsername = n.LoweredUsername
	inner join aspnet_Membership m
		on m.UserId = i.UserId
	inner join [10.192.23.11].[APT2012].[dbo].aspnet_Users nu
		on i.ApplicationId = nu.ApplicationId and i.LoweredUsername = nu.LoweredUsername

	--Profile
	insert into [10.192.23.11].[APT2012].[dbo].aspnet_Profile (
		UserId,
		FirstName,
		LastName,
		MemberId,
		SchemeId,
		Address1,
		Address2,
		Address3,
		Address4,
		PhoneHome,
		PhoneMobile,
		PhoneOffice,
		Fax,
		ContactMethod,
		LastUpdatedDate,
		LastLogonDate,
		County,
		Country,
		UseCompanyAddress
	)
	select	nu.UserId,
		p.FirstName,
		p.LastName,
		p.MemberId,
		p.SchemeId,
		p.Address1,
		p.Address2,
		p.Address3,
		p.Address4,
		p.PhoneHome,
		p.PhoneMobile,
		p.PhoneOffice,
		p.Fax,
		p.ContactMethod,
		p.LastUpdatedDate,
		p.LastLogonDate,
		p.County,
		p.Country,
		p.UseCompanyAddress
	from	aspnet_Users i
	inner join (select ApplicationId,LoweredUsername from aspnet_Users EXCEPT select ApplicationId,LoweredUsername from aspnet_Users_WEB) n
		on i.ApplicationId = n.ApplicationId and i.LoweredUsername = n.LoweredUsername
	inner join aspnet_Profile p
		on p.UserId = i.UserId
	inner join [10.192.23.11].[APT2012].[dbo].aspnet_Users nu
		on i.ApplicationId = nu.ApplicationId and i.LoweredUsername = nu.LoweredUsername

END TRY

BEGIN CATCH
	SELECT	@ErrorMessage = 'Error in procedure Synch_ASPnet_Add: ' + ERROR_MESSAGE(),
		@ErrorSeverity = ERROR_SEVERITY(),
		@ErrorState = ERROR_STATE();

	RAISERROR (	@ErrorMessage,
			@ErrorSeverity,
			@ErrorState	);

	if @@TRANCOUNT > 0
		rollback transaction;
END CATCH
GO
