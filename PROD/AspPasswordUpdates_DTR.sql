USE [APT2012]
GO

/****** Object:  Trigger [AspPasswordUpdates_DTR]    Script Date: 11/13/2013 09:24:52 ******/
IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[AspPasswordUpdates_DTR]'))
DROP TRIGGER [dbo].[AspPasswordUpdates_DTR]
GO

USE [APT2012]
GO

/****** Object:  Trigger [dbo].[AspPasswordUpdates_DTR]    Script Date: 11/13/2013 09:24:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create trigger [dbo].[AspPasswordUpdates_DTR]
on [dbo].[ASP_PASSWORD_UPDATES]
for delete
AS

if (select count(1) from inserted) = 0
and (select count(1) from deleted) = 0
	return

insert into ASP_PASSWORD_UPDATE_LOG
select * from deleted
GO