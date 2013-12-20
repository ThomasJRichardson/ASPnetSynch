USE [APT2012]
GO

/*
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aspnet_Users_WEB]') AND type in (N'U'))
DROP TABLE [dbo].[aspnet_Users_WEB]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aspnet_UsersScheme_WEB]') AND type in (N'U'))
DROP TABLE [dbo].[aspnet_UsersScheme_WEB]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aspnet_UsersInRoles_WEB]') AND type in (N'U'))
DROP TABLE [dbo].[aspnet_UsersInRoles_WEB]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aspnet_Membership_WEB]') AND type in (N'U'))
DROP TABLE [dbo].[aspnet_Membership_WEB]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aspnet_Profile_WEB]') AND type in (N'U'))
DROP TABLE [dbo].[aspnet_Profile_WEB]
GO

CREATE TABLE [dbo].[aspnet_Users_WEB] (
	[ApplicationId]		[varchar](256)	NOT NULL,
	[UserId]		[varchar](256)	NOT NULL,
	[UserName]		[nvarchar](256) NOT NULL,
	[LoweredUserName]	[nvarchar](256) NOT NULL,
	[MobileAlias]		[nvarchar](16)	NULL,
	[IsAnonymous]		[bit]		NOT NULL,
	[LastActivityDate]	[datetime]	NOT NULL
)
go

CREATE TABLE [dbo].[aspnet_UsersScheme_WEB] (
	[SchemeId]		[int]		NOT NULL,
	[UserId]		[nvarchar](256) NOT NULL
)
go

CREATE TABLE [dbo].[aspnet_UsersInRoles_WEB] (
	[UserId]		[nvarchar](256) NOT NULL,
	[RoleId]		[nvarchar](256) NOT NULL
)
go

CREATE TABLE [dbo].[aspnet_Membership_WEB] (
	[ApplicationId]		[nvarchar](256)	NOT NULL,
	[UserId]		[nvarchar](256) NOT NULL,
	[Password]		[nvarchar](128) NOT NULL,
	[PasswordFormat]	[int]		NOT NULL,
	[PasswordSalt]		[nvarchar](128)	NOT NULL,
	[MobilePIN]		[nvarchar](16)	NULL,
	[Email]			[nvarchar](256) NULL,
	[LoweredEmail]		[nvarchar](256) NULL,
	[PasswordQuestion]	[nvarchar](256) NULL,
	[PasswordAnswer]	[nvarchar](128) NULL,
	[IsApproved]		[bit]		NOT NULL,
	[IsLockedOut]		[bit]		NOT NULL,
	[CreateDate]		[datetime]	NOT NULL,
	[LastLoginDate]					[datetime]	NOT NULL,
	[LastPasswordChangedDate] 			[datetime]	NOT NULL,
	[LastLockoutDate]				[datetime]	NOT NULL,
	[FailedPasswordAttemptCount]			[int]		NOT NULL,
	[FailedPasswordAttemptWindowStart]		[datetime]	NOT NULL,
	[FailedPasswordAnswerAttemptCount]		[int]		NOT NULL,
	[FailedPasswordAnswerAttemptWindowStart]	[datetime]	NOT NULL,
	[Comment]					[ntext]		NULL,
	[IsPasswordReset]				[bit]		NULL
)
go

CREATE TABLE [dbo].[aspnet_Profile_WEB](
	[UserId]		[nvarchar](256)	NOT NULL,
	[FirstName]		[nvarchar](255) NULL,
	[LastName]		[nvarchar](255) NULL,
	[MemberId]		[int]		NULL,
	[SchemeId]		[int]		NULL,
	[Address1]		[nvarchar](255) NULL,
	[Address2]		[nvarchar](255) NULL,
	[Address3]		[nvarchar](255) NULL,
	[Address4]		[nvarchar](255) NULL,
	[PhoneHome]		[nvarchar](255) NULL,
	[PhoneMobile]		[nvarchar](255) NULL,
	[PhoneOffice]		[nvarchar](255) NULL,
	[Fax]			[nvarchar](255) NULL,
	[ContactMethod]		[nvarchar](255) NULL,
	[LastUpdatedDate]	[datetime]	NOT NULL,
	[LastLogonDate]		[datetime]	NULL,
	[County]		[varchar](256)	NULL,
	[Country]		[varchar](256)	NULL,
	[UseCompanyAddress]	[bit]		NULL
)
go
*/

--PF_ADDRESS_ARC
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PF_ADDRESS_ARC]') AND type in (N'U'))
DROP TABLE [dbo].[PF_ADDRESS_ARC]
GO

CREATE TABLE [dbo].[PF_ADDRESS_ARC](
	[ParentUID]		[int]		NOT NULL,
	[Line1]			[varchar](100)	NULL,
	[Line2]			[varchar](100)	NULL,
	[Line3]			[varchar](100)	NULL,
	[Line4]			[varchar](100)	NULL,
	[TelephoneNumber]	[varchar](50)	NULL,
	[FaxNumber]		[varchar](50)	NULL,
	[MobileNumber]		[varchar](50)	NULL,
	[EMail]			[varchar](50)	NULL
)
GO

--PF_ADDRESS_NOW
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PF_ADDRESS_NOW]') AND type in (N'U'))
DROP TABLE [dbo].[PF_ADDRESS_NOW]
GO

CREATE TABLE [dbo].[PF_ADDRESS_NOW](
	[ParentUID]		[int]		NOT NULL,
	[Line1]			[varchar](100)	NULL,
	[Line2]			[varchar](100)	NULL,
	[Line3]			[varchar](100)	NULL,
	[Line4]			[varchar](100)	NULL,
	[TelephoneNumber]	[varchar](50)	NULL,
	[FaxNumber]		[varchar](50)	NULL,
	[MobileNumber]		[varchar](50)	NULL,
	[EMail]			[varchar](50)	NULL
)
GO

create index PF_ADDRESS_NOW_IX1 on PF_ADDRESS_NOW(ParentUID)
go

--PF_ADDRESS_DIFF
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PF_ADDRESS_DIFF]') AND type in (N'U'))
DROP TABLE [dbo].[PF_ADDRESS_DIFF]
GO

CREATE TABLE [dbo].[PF_ADDRESS_DIFF](
	[ParentUID]		[int]		NOT NULL,
	[Line1]			[varchar](100)	NULL,
	[Line2]			[varchar](100)	NULL,
	[Line3]			[varchar](100)	NULL,
	[Line4]			[varchar](100)	NULL,
	[TelephoneNumber]	[varchar](50)	NULL,
	[FaxNumber]		[varchar](50)	NULL,
	[MobileNumber]		[varchar](50)	NULL,
	[EMail]			[varchar](50)	NULL
)
GO

create index PF_ADDRESS_DIFF_IX1 on PF_ADDRESS_DIFF(ParentUID)
go

--PF_ADDRESS_HIST
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PF_ADDRESS_HIST]') AND type in (N'U'))
DROP TABLE [dbo].[PF_ADDRESS_HIST]
GO

CREATE TABLE [dbo].[PF_ADDRESS_HIST](
	[ParentUID]		[int]		NOT NULL,
	[Line1]			[varchar](100)	NULL,
	[Line2]			[varchar](100)	NULL,
	[Line3]			[varchar](100)	NULL,
	[Line4]			[varchar](100)	NULL,
	[TelephoneNumber]	[varchar](50)	NULL,
	[FaxNumber]		[varchar](50)	NULL,
	[MobileNumber]		[varchar](50)	NULL,
	[EMail]			[varchar](50)	NULL,
	_ProcessedWhen		datetime	NOT NULL
)
GO

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
and	a.EndDate is null
go

create index PF_ADDRESS_ARC_IX1 on PF_ADDRESS_ARC(ParentUID)
go


--ASP_PROFILE_UPDATES
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ASP_PROFILE_UPDATES]') AND type in (N'U'))
DROP TABLE [dbo].[ASP_PROFILE_UPDATES]
GO

CREATE TABLE [dbo].[ASP_PROFILE_UPDATES](
	[UserId]	[varchar](256) 	NOT NULL,
	[FirstName]	[nvarchar](255) NULL,
	[LastName]	[nvarchar](255) NULL,
	[MemberId]	[int] 		NULL,
	[SchemeId]	[int] 		NULL,
	[Address1]	[nvarchar](255) NULL,
	[Address2]	[nvarchar](255) NULL,
	[Address3]	[nvarchar](255) NULL,
	[Address4]	[nvarchar](255) NULL,
	[PhoneHome]	[nvarchar](255) NULL,
	[PhoneMobile]	[nvarchar](255) NULL,
	[PhoneOffice]	[nvarchar](255) NULL,
	[Fax]		[nvarchar](255) NULL,
	[Email]		[nvarchar](256) NULL,
	_CreatedWhen	datetime	not null,
	_CreatedBy	varchar(50)	not null,
	_CreatedOn	varchar(50)	not null,
	_CreatedIn	varchar(50)	not null,

	ID		int		identity(1,1)
)
GO

--ASP_PROFILE_UPDATE_LOG
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ASP_PROFILE_UPDATE_LOG]') AND type in (N'U'))
DROP TABLE [dbo].[ASP_PROFILE_UPDATE_LOG]
GO

CREATE TABLE [dbo].[ASP_PROFILE_UPDATE_LOG](
	[UserId]	[varchar](256) 	NOT NULL,
	[FirstName]	[nvarchar](255) NULL,
	[LastName]	[nvarchar](255) NULL,
	[MemberId]	[int] 		NULL,
	[SchemeId]	[int] 		NULL,
	[Address1]	[nvarchar](255) NULL,
	[Address2]	[nvarchar](255) NULL,
	[Address3]	[nvarchar](255) NULL,
	[Address4]	[nvarchar](255) NULL,
	[PhoneHome]	[nvarchar](255) NULL,
	[PhoneMobile]	[nvarchar](255) NULL,
	[PhoneOffice]	[nvarchar](255) NULL,
	[Fax]		[nvarchar](255) NULL,
	[Email]		[nvarchar](256) NULL,
	_CreatedWhen	datetime	not null,
	_CreatedBy	varchar(50)	not null,
	_CreatedOn	varchar(50)	not null,
	_CreatedIn	varchar(50)	not null,

	ID		int		not null
)
GO

--ASP_PROFILE_UPDATE_WEB
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ASP_PROFILE_UPDATE_WEB]') AND type in (N'U'))
DROP TABLE [dbo].[ASP_PROFILE_UPDATE_WEB]
GO

CREATE TABLE [dbo].[ASP_PROFILE_UPDATE_WEB](
	[UserId]	[varchar](256) 	NOT NULL,
	[FirstName]	[nvarchar](255) NULL,
	[LastName]	[nvarchar](255) NULL,
	[MemberId]	[int] 		NULL,
	[SchemeId]	[int] 		NULL,
	[Address1]	[nvarchar](255) NULL,
	[Address2]	[nvarchar](255) NULL,
	[Address3]	[nvarchar](255) NULL,
	[Address4]	[nvarchar](255) NULL,
	[PhoneHome]	[nvarchar](255) NULL,
	[PhoneMobile]	[nvarchar](255) NULL,
	[PhoneOffice]	[nvarchar](255) NULL,
	[Fax]		[nvarchar](255) NULL,
	[Email]		[nvarchar](256) NULL,
	_CreatedWhen	datetime	not null,
	_CreatedBy	varchar(50)	not null,
	_CreatedOn	varchar(50)	not null,
	_CreatedIn	varchar(50)	not null,

	ID		int		not null
)
GO

--ASP_PROFILE_HIST
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ASP_PROFILE_HIST]') AND type in (N'U'))
DROP TABLE [dbo].[ASP_PROFILE_HIST]
GO

CREATE TABLE [dbo].[ASP_PROFILE_HIST](
	[UserId]	[varchar](256) 	NOT NULL,
	[FirstName]	[nvarchar](255) NULL,
	[LastName]	[nvarchar](255) NULL,
	[MemberId]	[int] 		NULL,
	[SchemeId]	[int] 		NULL,
	[Address1]	[nvarchar](255) NULL,
	[Address2]	[nvarchar](255) NULL,
	[Address3]	[nvarchar](255) NULL,
	[Address4]	[nvarchar](255) NULL,
	[PhoneHome]	[nvarchar](255) NULL,
	[PhoneMobile]	[nvarchar](255) NULL,
	[PhoneOffice]	[nvarchar](255) NULL,
	[Fax]		[nvarchar](255) NULL,
	[Email]		[nvarchar](256) NULL,
	_CreatedWhen	datetime	not null,
	_CreatedBy	varchar(50)	not null,
	_CreatedOn	varchar(50)	not null,
	_CreatedIn	varchar(50)	not null,
	_ProcessedWhen	datetime	NOT NULL,

	ID		int		not null
)
GO

--ASP_PASSWORD_UPDATES
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ASP_PASSWORD_UPDATES]') AND type in (N'U'))
DROP TABLE [dbo].[ASP_PASSWORD_UPDATES]
GO

CREATE TABLE [dbo].[ASP_PASSWORD_UPDATES](
	[UserId]		[varchar](256) 	NOT NULL,
	[UserName]		[nvarchar](256) NOT NULL,
	[Password]		[nvarchar](128) NOT NULL,
	[PasswordFormat]	[int] 		NOT NULL,
	[PasswordSalt]		[nvarchar](128) NOT NULL,
	[MobilePIN]		[nvarchar](16) 	NULL,
	[MobileAlias]		[nvarchar](16) 	NULL,
	[IsAnonymous]		[bit]	 	NOT NULL,
	_CreatedWhen		datetime	not null,
	_CreatedBy		varchar(50)	not null,
	_CreatedOn		varchar(50)	not null,
	_CreatedIn		varchar(50)	not null,

	ID			int		identity(1,1)
)
GO

--ASP_PASSWORD_UPDATE_LOG
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ASP_PASSWORD_UPDATE_LOG]') AND type in (N'U'))
DROP TABLE [dbo].[ASP_PASSWORD_UPDATE_LOG]
GO

CREATE TABLE [dbo].[ASP_PASSWORD_UPDATE_LOG](
	[UserId]		[varchar](256) 	NOT NULL,
	[UserName]		[nvarchar](256) NOT NULL,
	[Password]		[nvarchar](128) NOT NULL,
	[PasswordFormat]	[int] 		NOT NULL,
	[PasswordSalt]		[nvarchar](128) NOT NULL,
	[MobilePIN]		[nvarchar](16) 	NULL,
	[MobileAlias]		[nvarchar](16) 	NULL,
	[IsAnonymous]		[bit]	 	NOT NULL,
	_CreatedWhen		datetime	not null,
	_CreatedBy		varchar(50)	not null,
	_CreatedOn		varchar(50)	not null,
	_CreatedIn		varchar(50)	not null,

	ID			int		not null
)
GO

--ASP_PASSWORD_UPDATE_WEB
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ASP_PASSWORD_UPDATE_WEB]') AND type in (N'U'))
DROP TABLE [dbo].[ASP_PASSWORD_UPDATE_WEB]
GO

CREATE TABLE [dbo].[ASP_PASSWORD_UPDATE_WEB](
	[UserId]		[varchar](256) 	NOT NULL,
	[UserName]		[nvarchar](256) NOT NULL,
	[Password]		[nvarchar](128) NOT NULL,
	[PasswordFormat]	[int] 		NOT NULL,
	[PasswordSalt]		[nvarchar](128) NOT NULL,
	[MobilePIN]		[nvarchar](16) 	NULL,
	[MobileAlias]		[nvarchar](16) 	NULL,
	[IsAnonymous]		[bit]	 	NOT NULL,
	_CreatedWhen		datetime	not null,
	_CreatedBy		varchar(50)	not null,
	_CreatedOn		varchar(50)	not null,
	_CreatedIn		varchar(50)	not null,

	ID			int		not null
)
GO

--ASP_PASSWORD_HIST
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ASP_PASSWORD_HIST]') AND type in (N'U'))
DROP TABLE [dbo].[ASP_PASSWORD_HIST]
GO

CREATE TABLE [dbo].[ASP_PASSWORD_HIST](
	[UserId]		[varchar](256) 	NOT NULL,
	[UserName]		[nvarchar](256) NOT NULL,
	[Password]		[nvarchar](128) NOT NULL,
	[PasswordFormat]	[int] 		NOT NULL,
	[PasswordSalt]		[nvarchar](128) NOT NULL,
	[MobilePIN]		[nvarchar](16) 	NULL,
	[MobileAlias]		[nvarchar](16) 	NULL,
	[IsAnonymous]		[bit]	 	NOT NULL,
	_CreatedWhen		datetime	not null,
	_CreatedBy		varchar(50)	not null,
	_CreatedOn		varchar(50)	not null,
	_CreatedIn		varchar(50)	not null,
	_ProcessedWhen		datetime	NOT NULL,

	ID			int		not null
)
GO
