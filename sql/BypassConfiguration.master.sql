USE master
GO
if not exists(select* from sysdatabases where name = 'BypassConfiguration')
begin
print 'Creating BypassConfiguration database.'
declare @cmdShellActive as integer
declare @showAdvancedActive as integer
declare @cmd as varchar(128)
set @showAdvancedActive = (select cast(value_in_use as integer) from sys.configurations where name = 'show advanced options')
set @cmdShellActive = (select cast(value_in_use as integer) from sys.configurations where name = 'xp_cmdshell')
if (@cmdShellActive = 0)
begin
 if (@showAdvancedActive = 0)
 begin
        execute sp_configure 'show advanced options', 1
  RECONFIGURE
    end
    execute sp_configure 'xp_cmdshell', 1
    RECONFIGURE
end
execute xp_cmdshell 'mkdir e:\databases\BypassConfiguration'
CREATE DATABASE BypassConfiguration
ON
(NAME = 'BypassConfiguration_Data1',
  FILENAME = 'e:\databases\BypassConfiguration\BypassConfiguration_Data1.MDF',
  SIZE = 20GB,
  FILEGROWTH = 10GB )
LOG ON
(NAME = 'BypassConfiguration_Log',
  FILENAME = 'e:\databases\BypassConfiguration\BypassConfiguration_Log.LDF',
  SIZE = 1GB,
  FILEGROWTH = 500MB )
if CONVERT(VARCHAR(128), SERVERPROPERTY('productversion')) like '8%'
   or CONVERT(VARCHAR(128), SERVERPROPERTY('productversion')) like '9%'
   or CONVERT(VARCHAR(128), SERVERPROPERTY('productversion')) like '10.0%'
   or CONVERT(VARCHAR(128), SERVERPROPERTY('productversion')) like '10.5%'
begin
   execute sp_dboption 'BypassConfiguration', 'select into/bulkcopy', 'FALSE'
   execute sp_dboption 'BypassConfiguration', 'trunc. log on chkpt.', 'TRUE'
end
alter database BypassConfiguration
set recovery full
end else begin
print 'BypassConfiguration database exists'
end
GO
USE BypassConfiguration
GO
/* Bypass schema and tables */
if not exists (select * from sys.schemas where name = N'bypass')
begin
   print 'Creating schema bypass'
   execute('create schema [bypass] authorization [dbo]')
end
else
begin
   print 'bypass schema already exists'
end
GO
if not exists (select * from sys.schemas where name = N'bypass_static')
begin
   print 'Creating schema bypass_static'
   execute('create schema [bypass_static] authorization [dbo]')
end
else
begin
   print 'bypass_static schema already exists'
end
GO
/* drop table [bypass].[applications] */
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
-- TABLE CREATION --
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
if not exists(select * from sys.tables where name = 'applications' and schema_id = (select schema_id from sys.schemas where name = 'bypass'))
begin
   print 'Creating applications table'
   create table [bypass].[applications] (
      [applicationId] int not null identity (1,1),
      [application] varchar(32) not null,
      [dateAdded] datetime not null constraint [applicationsDateAddedDefault] default (getdate()),
      [userIdAdd] int not null,
   ) on [PRIMARY]
end
else
begin
   print 'applications table already exists'
end
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
-- NULL CONSTRAINTS --
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
if exists (select * from sys.columns where object_id = object_id('[bypass].[applications]') and name = 'applicationId' and is_nullable=1)
begin
   print 'Converting column applicationId in applications to disallow nulls'
   alter table [bypass].[applications] alter column [applicationId] int not null
end
else
begin
   print '	Column applicationId already in applications already disallows nulls'
end
if exists (select * from sys.columns where object_id = object_id('[bypass].[applications]') and name = 'application' and is_nullable=1)
begin
   print 'Converting column application in applications to disallow nulls'
   alter table [bypass].[applications] alter column [application] varchar(32) not null
end
else
begin
   print '	Column application already in applications already disallows nulls'
end
if exists (select * from sys.columns where object_id = object_id('[bypass].[applications]') and name = 'dateAdded' and is_nullable=1)
begin
   print 'Converting column dateAdded in applications to disallow nulls'
   alter table [bypass].[applications] alter column [dateAdded] datetime not null
end
else
begin
   print '	Column dateAdded already in applications already disallows nulls'
end
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
-- DEFAULT CONSTRAINTS --
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
if exists (select * from sys.columns where object_id = object_id('[bypass].[applications]') and name = 'dateAdded' and [default_object_id]=0)
begin
   print 'Creating default constraint on applications.dateAdded'
   alter table [bypass].[applications] add constraint [applicationsDateAddedDefault] default (getdate()) for [dateAdded]
end
else
begin
   print 'Default constraint already exists for applications.dateAdded'
end
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
-- CHECK CONSTRAINTS --
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
-- PRIMARY KEY / UNIQUE KEY CONSTRAINTS / INDEXES --
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
declare @idxExists bit = 0,
@idxIsUnique bit = 0,
@idxIsUniqueConstraint bit = 0,
@idxIsPKConstraint bit = 0,
@idxType tinyInt = NULL,
@idxIsClustered bit = 0,
@idxShouldBeUnique bit = 0,
@idxShouldBeUniqueConstraint bit = 0,
@idxShouldBePKConstraint bit = 0,
@idxShouldBeClustered bit = 0,
--the following are used for FKS when the object to be dropped is a PK or a unique constraint
@dropComm as varchar (max),
@addComm as varchar (max),
@addComm2 as varchar (max)
select @idxIsUnique=is_unique, @idxIsUniqueConstraint=is_unique_constraint, @idxIsPKConstraint=is_primary_key, @idxType=type from sys.indexes where object_id = object_id('[bypass].[applications]') and name = 'applicationsPrimaryKey'
set @idxExists = case when @idxType is null then 0 else 1 end
set @idxIsClustered = case when @idxType = 1 then 1 else 0 end
set @idxIsUnique = isnull(@idxIsUnique, 0)
set @idxIsUniqueConstraint = isnull(@idxIsUniqueConstraint, 0)
set @idxIsPKConstraint = isnull(@idxIsPKConstraint, 0)
set @idxShouldBeUnique = 1
set @idxShouldBeUniqueConstraint = 0
set @idxShouldBePKConstraint = 1
set @idxShouldBeClustered = 1
if (@idxExists = 0)
begin
   print 'Creating PK constraint applicationsPrimaryKey on applications'
   alter table [bypass].[applications] add constraint [applicationsPrimaryKey] primary key clustered (
      [applicationId] ASC
   )
   with ( PAD_INDEX = OFF, ALLOW_PAGE_LOCKS = ON, ALLOW_ROW_LOCKS = ON, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, SORT_IN_TEMPDB = OFF ) on [PRIMARY]
end
else if ((@idxIsPKConstraint <> @idxShouldBePKConstraint) or
         (@idxIsUnique <> @idxShouldBeUnique) or
         (@idxIsUniqueConstraint <> @idxShouldBeUniqueConstraint) or
         (@idxIsClustered <> @idxShouldBeClustered))
begin
   print 'Recreating PK constraint applicationsPrimaryKey on applications'
   if (@idxIsPKConstraint = 1 or @idxIsUniqueConstraint = 1)
   begin
      exec DropAddForeignKeys @tableName = 'applications', @dropCommands = @dropComm OUTPUT, @addCommands = @addComm OUTPUT, @addCommands2 = @addComm2 OUTPUT
      exec(@dropComm)
   end
   alter table [bypass].[applications] drop constraint [applicationsPrimaryKey]
   alter table [bypass].[applications] add constraint [applicationsPrimaryKey] primary key clustered (
      [applicationId] ASC
   )
   with ( PAD_INDEX = OFF, ALLOW_PAGE_LOCKS = ON, ALLOW_ROW_LOCKS = ON, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, SORT_IN_TEMPDB = OFF ) on [PRIMARY]
   if ((@idxIsPKConstraint = 1 or @idxIsUniqueConstraint = 1) and (@idxShouldBePKConstraint = 1 or @idxShouldBeUniqueConstraint = 1) )
   begin
      exec(@addComm)
      exec(@addComm2)
   end
end
else
begin
   print '	PK constraint applicationsPrimaryKey already exists on applications'
end
select @idxIsUnique=is_unique, @idxIsUniqueConstraint=is_unique_constraint, @idxIsPKConstraint=is_primary_key, @idxType=type from sys.indexes where object_id = object_id('[bypass].[applications]') and name = 'applicationIndex'
set @idxExists = case when @idxType is null then 0 else 1 end
set @idxIsClustered = case when @idxType = 1 then 1 else 0 end
set @idxIsUnique = isnull(@idxIsUnique, 0)
set @idxIsUniqueConstraint = isnull(@idxIsUniqueConstraint, 0)
set @idxIsPKConstraint = isnull(@idxIsPKConstraint, 0)
set @idxShouldBeUnique = 1
set @idxShouldBeUniqueConstraint = 0
set @idxShouldBePKConstraint = 0
set @idxShouldBeClustered = 0
if (@idxExists = 0)
begin
   print 'Creating index applicationIndex on applications'
   create unique nonclustered index [applicationIndex] on [bypass].[applications] (
      [application] ASC
   )
   with ( PAD_INDEX = OFF, ALLOW_PAGE_LOCKS = ON, ALLOW_ROW_LOCKS = ON, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, SORT_IN_TEMPDB = OFF, FILLFACTOR = 70 ) on [PRIMARY]
end
else if ((@idxIsPKConstraint <> @idxShouldBePKConstraint) or
         (@idxIsUnique <> @idxShouldBeUnique) or
         (@idxIsUniqueConstraint <> @idxShouldBeUniqueConstraint) or
         (@idxIsClustered <> @idxShouldBeClustered))
begin
   print 'Recreating index applicationIndex on applications'
   if (@idxIsPKConstraint = 1 or @idxIsUniqueConstraint = 1)
   begin
      exec DropAddForeignKeys @tableName = 'applications', @dropCommands = @dropComm OUTPUT, @addCommands = @addComm OUTPUT, @addCommands2 = @addComm2 OUTPUT
      exec(@dropComm)
   end
   alter table [bypass].[applications] drop constraint [applicationIndex]
   create unique nonclustered index [applicationIndex] on [bypass].[applications] (
      [application] ASC
   )
   with ( PAD_INDEX = OFF, ALLOW_PAGE_LOCKS = ON, ALLOW_ROW_LOCKS = ON, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, SORT_IN_TEMPDB = OFF, FILLFACTOR = 70 ) on [PRIMARY]
   if ((@idxIsPKConstraint = 1 or @idxIsUniqueConstraint = 1) and (@idxShouldBePKConstraint = 1 or @idxShouldBeUniqueConstraint = 1) )
   begin
      exec(@addComm)
      exec(@addComm2)
   end
end
else
begin
   print '	Index applicationIndex already exists on applications'
end
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
-- FOREIGN KEYS - applications --
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
-- TRIGGERS --
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
GO
/* drop table [bypass].[languages] */
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
-- TABLE CREATION --
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
if not exists(select * from sys.tables where name = 'languages' and schema_id = (select schema_id from sys.schemas where name = 'bypass'))
begin
   print 'Creating languages table'
   create table [bypass].[languages] (
      [languageId] int not null identity (1,1),
      [language] varchar(32) not null,
   ) on [PRIMARY]
end
else
begin
   print 'languages table already exists'
end
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
-- NULL CONSTRAINTS --
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
if exists (select * from sys.columns where object_id = object_id('[bypass].[languages]') and name = 'languageId' and is_nullable=1)
begin
   print 'Converting column languageId in languages to disallow nulls'
   alter table [bypass].[languages] alter column [languageId] int not null
end
else
begin
   print '	Column languageId already in languages already disallows nulls'
end
if exists (select * from sys.columns where object_id = object_id('[bypass].[languages]') and name = 'language' and is_nullable=1)
begin
   print 'Converting column language in languages to disallow nulls'
   alter table [bypass].[languages] alter column [language] varchar(35) not null
end
else
begin
   print '	Column language already in languages already disallows nulls'
end
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
-- DEFAULT CONSTRAINTS --
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
-- CHECK CONSTRAINTS --
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
-- PRIMARY KEY / UNIQUE KEY CONSTRAINTS / INDEXES --
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
declare @idxExists bit = 0,
@idxIsUnique bit = 0,
@idxIsUniqueConstraint bit = 0,
@idxIsPKConstraint bit = 0,
@idxType tinyInt = NULL,
@idxIsClustered bit = 0,
@idxShouldBeUnique bit = 0,
@idxShouldBeUniqueConstraint bit = 0,
@idxShouldBePKConstraint bit = 0,
@idxShouldBeClustered bit = 0,
--the following are used for FKS when the object to be dropped is a PK or a unique constraint
@dropComm as varchar (max),
@addComm as varchar (max),
@addComm2 as varchar (max)
select @idxIsUnique=is_unique, @idxIsUniqueConstraint=is_unique_constraint, @idxIsPKConstraint=is_primary_key, @idxType=type from sys.indexes where object_id = object_id('[bypass].[languages]') and name = 'languagesPrimaryKey'
set @idxExists = case when @idxType is null then 0 else 1 end
set @idxIsClustered = case when @idxType = 1 then 1 else 0 end
set @idxIsUnique = isnull(@idxIsUnique, 0)
set @idxIsUniqueConstraint = isnull(@idxIsUniqueConstraint, 0)
set @idxIsPKConstraint = isnull(@idxIsPKConstraint, 0)
set @idxShouldBeUnique = 1
set @idxShouldBeUniqueConstraint = 0
set @idxShouldBePKConstraint = 1
set @idxShouldBeClustered = 1
if (@idxExists = 0)
begin
   print 'Creating PK constraint languagesPrimaryKey on languages'
   alter table [bypass].[languages] add constraint [languagesPrimaryKey] primary key clustered (
      [languageId] ASC
   )
   with ( PAD_INDEX = OFF, ALLOW_PAGE_LOCKS = ON, ALLOW_ROW_LOCKS = ON, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, SORT_IN_TEMPDB = OFF ) on [PRIMARY]
end
else if ((@idxIsPKConstraint <> @idxShouldBePKConstraint) or
         (@idxIsUnique <> @idxShouldBeUnique) or
         (@idxIsUniqueConstraint <> @idxShouldBeUniqueConstraint) or
         (@idxIsClustered <> @idxShouldBeClustered))
begin
   print 'Recreating PK constraint languagesPrimaryKey on languages'
   if (@idxIsPKConstraint = 1 or @idxIsUniqueConstraint = 1)
   begin
      exec DropAddForeignKeys @tableName = 'languages', @dropCommands = @dropComm OUTPUT, @addCommands = @addComm OUTPUT, @addCommands2 = @addComm2 OUTPUT
      exec(@dropComm)
   end
   alter table [bypass].[languages] drop constraint [languagesPrimaryKey]
   alter table [bypass].[languages] add constraint [languagesPrimaryKey] primary key clustered (
      [languageId] ASC
   )
   with ( PAD_INDEX = OFF, ALLOW_PAGE_LOCKS = ON, ALLOW_ROW_LOCKS = ON, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, SORT_IN_TEMPDB = OFF ) on [PRIMARY]
   if ((@idxIsPKConstraint = 1 or @idxIsUniqueConstraint = 1) and (@idxShouldBePKConstraint = 1 or @idxShouldBeUniqueConstraint = 1) )
   begin
      exec(@addComm)
      exec(@addComm2)
   end
end
else
begin
   print '	PK constraint languagesPrimaryKey already exists on languages'
end
select @idxIsUnique=is_unique, @idxIsUniqueConstraint=is_unique_constraint, @idxIsPKConstraint=is_primary_key, @idxType=type from sys.indexes where object_id = object_id('[bypass].[languages]') and name = 'languageIndex'
set @idxExists = case when @idxType is null then 0 else 1 end
set @idxIsClustered = case when @idxType = 1 then 1 else 0 end
set @idxIsUnique = isnull(@idxIsUnique, 0)
set @idxIsUniqueConstraint = isnull(@idxIsUniqueConstraint, 0)
set @idxIsPKConstraint = isnull(@idxIsPKConstraint, 0)
set @idxShouldBeUnique = 1
set @idxShouldBeUniqueConstraint = 0
set @idxShouldBePKConstraint = 0
set @idxShouldBeClustered = 0
if (@idxExists = 0)
begin
   print 'Creating index languageIndex on languages'
   create unique nonclustered index [languageIndex] on [bypass].[languages] (
      [language] ASC
   )
   with ( PAD_INDEX = OFF, ALLOW_PAGE_LOCKS = ON, ALLOW_ROW_LOCKS = ON, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, SORT_IN_TEMPDB = OFF, FILLFACTOR = 70 ) on [PRIMARY]
end
else if ((@idxIsPKConstraint <> @idxShouldBePKConstraint) or
         (@idxIsUnique <> @idxShouldBeUnique) or
         (@idxIsUniqueConstraint <> @idxShouldBeUniqueConstraint) or
         (@idxIsClustered <> @idxShouldBeClustered))
begin
   print 'Recreating index languageIndex on languages'
   if (@idxIsPKConstraint = 1 or @idxIsUniqueConstraint = 1)
   begin
      exec DropAddForeignKeys @tableName = 'languages', @dropCommands = @dropComm OUTPUT, @addCommands = @addComm OUTPUT, @addCommands2 = @addComm2 OUTPUT
      exec(@dropComm)
   end
   alter table [bypass].[languages] drop constraint [languageIndex]
   create unique nonclustered index [languageIndex] on [bypass].[languages] (
      [language] ASC
   )
   with ( PAD_INDEX = OFF, ALLOW_PAGE_LOCKS = ON, ALLOW_ROW_LOCKS = ON, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, SORT_IN_TEMPDB = OFF, FILLFACTOR = 70 ) on [PRIMARY]
   if ((@idxIsPKConstraint = 1 or @idxIsUniqueConstraint = 1) and (@idxShouldBePKConstraint = 1 or @idxShouldBeUniqueConstraint = 1) )
   begin
      exec(@addComm)
      exec(@addComm2)
   end
end
else
begin
   print '	Index languageIndex already exists on languages'
end
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
-- FOREIGN KEYS - languages --
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
-- TRIGGERS --
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
GO
/* drop table [bypass].[configurations] */
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
-- TABLE CREATION --
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
IF NOT EXISTS (
  SELECT *
  FROM sys.tables
  WHERE name = 'configurations'
   AND schema_id = (
    SELECT schema_id
    FROM sys.schemas
    WHERE name = 'bypass'
    )
  )
BEGIN
 PRINT 'Creating configurations table'
 CREATE TABLE [bypass].[configurations] (
  [bypassConfigurationId] INT NOT NULL identity(1, 1)
  ,[order] INT NOT NULL
  ,[applicationId] INT NOT NULL
  ,[languageId] INT
  ,[dnis] VARCHAR(32)
  ,[destination] VARCHAR(32)
  ,[rank] VARCHAR(6)
  ,[offerId] VARCHAR(8)
  ,[offerType] VARCHAR(128)
  ,[peg] VARCHAR(128)
  ,[skillId] VARCHAR(16)
  ,[skillName] VARCHAR(64)
  ,[agentsAvailable] INT
  ,[med] INT
  ,[overflowSkillId] VARCHAR(16)
  ,[overflowSkillName] VARCHAR(64)
  ,[overflowAgentsAvailable] INT
  ,[overflowMed] INT
  ,[lastModifiedUserId] INT NOT NULL
  ,[lastModifiedDateTime] DATETIME NOT NULL
  ) ON [PRIMARY]
END
ELSE
BEGIN
 PRINT 'configurations table already exists'
END
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
-- NULL CONSTRAINTS --
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
IF EXISTS (
  SELECT *
  FROM sys.columns
  WHERE object_id = object_id('[bypass].[configurations]')
   AND name = 'bypassConfigurationId'
   AND is_nullable = 1
  )
BEGIN
 PRINT 'Converting column bypassConfigurationId in configurations to disallow nulls'
 ALTER TABLE [bypass].[configurations]
 ALTER COLUMN [bypassConfigurationId] INT NOT NULL
END
ELSE
BEGIN
 PRINT '	Column bypassConfigurationId already in configurations already disallows nulls'
END
IF EXISTS (
  SELECT *
  FROM sys.columns
  WHERE object_id = object_id('[bypass].[configurations]')
   AND name = 'order'
   AND is_nullable = 1
  )
BEGIN
 PRINT 'Converting column order in configurations to disallow nulls'
 ALTER TABLE [bypass].[configurations]
 ALTER COLUMN [order] INT NOT NULL
END
ELSE
BEGIN
 PRINT '	Column order already in configurations already disallows nulls'
END
IF EXISTS (
  SELECT *
  FROM sys.columns
  WHERE object_id = object_id('[bypass].[configurations]')
   AND name = 'applicationId'
   AND is_nullable = 1
  )
BEGIN
 PRINT 'Converting column applicationId in configurations to disallow nulls'
 ALTER TABLE [bypass].[configurations]
 ALTER COLUMN [applicationId] INT NOT NULL
END
ELSE
BEGIN
 PRINT '	Column applicationId already in configurations already disallows nulls'
END
IF EXISTS (
  SELECT *
  FROM sys.columns
  WHERE object_id = object_id('[bypass].[configurations]')
   AND name = 'languageId'
   AND is_nullable = 0
  )
BEGIN
 PRINT 'Converting column languageId in configurations to allow nulls'
 ALTER TABLE [bypass].[configurations]
 ALTER COLUMN [languageId] INT NULL
END
ELSE
BEGIN
 PRINT '	Column languageId already in configurations already allows nulls'
END
IF EXISTS (
  SELECT *
  FROM sys.columns
  WHERE object_id = object_id('[bypass].[configurations]')
   AND name = 'dnis'
   AND is_nullable = 0
  )
BEGIN
 PRINT 'Converting column dnis in configurations to allow nulls'
 ALTER TABLE [bypass].[configurations]
 ALTER COLUMN [dnis] VARCHAR(32) NULL
END
ELSE
BEGIN
 PRINT '	Column dnis already in configurations already allows nulls'
END
IF EXISTS (
  SELECT *
  FROM sys.columns
  WHERE object_id = object_id('[bypass].[configurations]')
   AND name = 'destination'
   AND is_nullable = 0
  )
BEGIN
 PRINT 'Converting column destination in configurations to allow nulls'
 ALTER TABLE [bypass].[configurations]
 ALTER COLUMN [destination] VARCHAR(32) NULL
END
ELSE
BEGIN
 PRINT '	Column destination already in configurations already allows nulls'
END
IF EXISTS (
  SELECT *
  FROM sys.columns
  WHERE object_id = object_id('[bypass].[configurations]')
   AND name = 'rank'
   AND is_nullable = 0
  )
BEGIN
 PRINT 'Converting column rank in configurations to allow nulls'
 ALTER TABLE [bypass].[configurations]
 ALTER COLUMN [rank] INT NULL
END
ELSE
BEGIN
 PRINT '	Column rank already in configurations already allows nulls'
END
IF EXISTS (
  SELECT *
  FROM sys.columns
  WHERE object_id = object_id('[bypass].[configurations]')
   AND name = 'offerId'
   AND is_nullable = 0
  )
BEGIN
 PRINT 'Converting column offerId in configurations to allow nulls'
 ALTER TABLE [bypass].[configurations]
 ALTER COLUMN [offerId] INT NULL
END
ELSE
BEGIN
 PRINT '	Column offerId already in configurations already allows nulls'
END
IF EXISTS (
  SELECT *
  FROM sys.columns
  WHERE object_id = object_id('[bypass].[configurations]')
   AND name = 'offerType'
   AND is_nullable = 0
  )
BEGIN
 PRINT 'Converting column offerType in configurations to allow nulls'
 ALTER TABLE [bypass].[configurations]
 ALTER COLUMN [offerType] INT NULL
END
ELSE
BEGIN
 PRINT '	Column offerType already in configurations already allows nulls'
END
IF EXISTS (
  SELECT *
  FROM sys.columns
  WHERE object_id = object_id('[bypass].[configurations]')
   AND name = 'skillId'
   AND is_nullable = 0
  )
BEGIN
 PRINT 'Converting column skillId in configurations to allow nulls'
 ALTER TABLE [bypass].[configurations]
 ALTER COLUMN [skillId] VARCHAR(16) NULL
END
ELSE
BEGIN
 PRINT '	Column skillId already in configurations already allows nulls'
END
IF EXISTS (
  SELECT *
  FROM sys.columns
  WHERE object_id = object_id('[bypass].[configurations]')
   AND name = 'skillName'
   AND is_nullable = 0
  )
BEGIN
 PRINT 'Converting column skillName in configurations to allow nulls'
 ALTER TABLE [bypass].[configurations]
 ALTER COLUMN [skillName] VARCHAR(64) NULL
END
ELSE
BEGIN
 PRINT '	Column skillName already in configurations already allows nulls'
END
IF EXISTS (
  SELECT *
  FROM sys.columns
  WHERE object_id = object_id('[bypass].[configurations]')
   AND name = 'agentsAvailable'
   AND is_nullable = 0
  )
BEGIN
 PRINT 'Converting column agentsAvailable in configurations to allow nulls'
 ALTER TABLE [bypass].[configurations]
 ALTER COLUMN [agentsAvailable] INT NULL
END
ELSE
BEGIN
 PRINT '	Column agentsAvailable already in configurations already allows nulls'
END
IF EXISTS (
  SELECT *
  FROM sys.columns
  WHERE object_id = object_id('[bypass].[configurations]')
   AND name = 'med'
   AND is_nullable = 0
  )
BEGIN
 PRINT 'Converting column med in configurations to allow nulls'
 ALTER TABLE [bypass].[configurations]
 ALTER COLUMN [med] INT NULL
END
ELSE
BEGIN
 PRINT '	Column med already in configurations already allows nulls'
END
IF EXISTS (
  SELECT *
  FROM sys.columns
  WHERE object_id = object_id('[bypass].[configurations]')
   AND name = 'overflowSkillId'
   AND is_nullable = 0
  )
BEGIN
 PRINT 'Converting column overflowSkillId in configurations to allow nulls'
 ALTER TABLE [bypass].[configurations]
 ALTER COLUMN [overflowSkillId] VARCHAR(64) NULL
END
ELSE
BEGIN
 PRINT '	Column overflowSkillId already in configurations already allows nulls'
END
IF EXISTS (
  SELECT *
  FROM sys.columns
  WHERE object_id = object_id('[bypass].[configurations]')
   AND name = 'overflowSkillName'
   AND is_nullable = 0
  )
BEGIN
 PRINT 'Converting column overflowSkillName in configurations to allow nulls'
 ALTER TABLE [bypass].[configurations]
 ALTER COLUMN [overflowSkillName] VARCHAR(64) NULL
END
ELSE
BEGIN
 PRINT '	Column overflowSkillName already in configurations already allows nulls'
END
IF EXISTS (
  SELECT *
  FROM sys.columns
  WHERE object_id = object_id('[bypass].[configurations]')
   AND name = 'overflowAgentsAvailable'
   AND is_nullable = 0
  )
BEGIN
 PRINT 'Converting column overflowAgentsAvailable in configurations to allow nulls'
 ALTER TABLE [bypass].[configurations]
 ALTER COLUMN [overflowAgentsAvailable] INT NULL
END
ELSE
BEGIN
 PRINT '	Column overflowAgentsAvailable already in configurations already allows nulls'
END
IF EXISTS (
  SELECT *
  FROM sys.columns
  WHERE object_id = object_id('[bypass].[configurations]')
   AND name = 'overflowMed'
   AND is_nullable = 0
  )
BEGIN
 PRINT 'Converting column overflowMed in configurations to allow nulls'
 ALTER TABLE [bypass].[configurations]
 ALTER COLUMN [overflowMed] INT NULL
END
ELSE
BEGIN
 PRINT '	Column overflowMed already in configurations already allows nulls'
END
IF EXISTS (
  SELECT *
  FROM sys.columns
  WHERE object_id = object_id('[bypass].[configurations]')
   AND name = 'lastModifiedUserId'
   AND is_nullable = 1
  )
BEGIN
 PRINT 'Converting column lastModifiedUserId in configurations to disallow nulls'
 ALTER TABLE [bypass].[configurations]
 ALTER COLUMN [lastModifiedUserId] INT NOT NULL
END
ELSE
BEGIN
 PRINT '	Column lastModifiedUserId already in configurations already disallows nulls'
END
IF EXISTS (
  SELECT *
  FROM sys.columns
  WHERE object_id = object_id('[bypass].[configurations]')
   AND name = 'lastModifiedDateTime'
   AND is_nullable = 1
  )
BEGIN
 PRINT 'Converting column lastModifiedDateTime in configurations to disallow nulls'
 ALTER TABLE [bypass].[configurations]
 ALTER COLUMN [lastModifiedDateTime] DATETIME NOT NULL
END
ELSE
BEGIN
 PRINT '	Column lastModifiedDateTime already in configurations already disallows nulls'
END
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
-- DEFAULT CONSTRAINTS --
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
IF EXISTS (
  SELECT *
  FROM sys.columns
  WHERE object_id = object_id('[bypass].[configurations]')
   AND name = 'lastModifiedDateTime'
   AND [default_object_id] = 0
  )
BEGIN
 PRINT 'Creating default constraint on configurations.lastModifiedDateTime'
 ALTER TABLE [bypass].[configurations] ADD CONSTRAINT [configurationsLastModifiedDateTimeDefault] DEFAULT(getdate())
 FOR [lastModifiedDateTime]
END
ELSE
BEGIN
 PRINT 'Default constraint already exists for configurations.lastModifiedDateTime'
END
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
-- CHECK CONSTRAINTS --
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
-- PRIMARY KEY / UNIQUE KEY CONSTRAINTS / INDEXES --
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
DECLARE @idxExists BIT = 0
 ,@idxIsUnique BIT = 0
 ,@idxIsUniqueConstraint BIT = 0
 ,@idxIsPKConstraint BIT = 0
 ,@idxType TINYINT = NULL
 ,@idxIsClustered BIT = 0
 ,@idxShouldBeUnique BIT = 0
 ,@idxShouldBeUniqueConstraint BIT = 0
 ,@idxShouldBePKConstraint BIT = 0
 ,@idxShouldBeClustered BIT = 0
 ,
 --the following are used for FKS when the object to be dropped is a PK or a unique constraint
 @dropComm AS VARCHAR(max)
 ,@addComm AS VARCHAR(max)
 ,@addComm2 AS VARCHAR(max)
--primary key
SET @idxType = NULL
SELECT @idxIsUnique = is_unique
 ,@idxIsUniqueConstraint = is_unique_constraint
 ,@idxIsPKConstraint = is_primary_key
 ,@idxType = type
FROM sys.indexes
WHERE object_id = object_id('[bypass].[configurations]')
 AND name = 'configurationsPrimaryKey'
SET @idxExists = CASE
  WHEN @idxType IS NULL
   THEN 0
  ELSE 1
  END
SET @idxIsClustered = CASE
  WHEN @idxType = 1
   THEN 1
  ELSE 0
  END
SET @idxIsUnique = isnull(@idxIsUnique, 0)
SET @idxIsUniqueConstraint = isnull(@idxIsUniqueConstraint, 0)
SET @idxIsPKConstraint = isnull(@idxIsPKConstraint, 0)
SET @idxShouldBeUnique = 1
SET @idxShouldBeUniqueConstraint = 0
SET @idxShouldBePKConstraint = 1
SET @idxShouldBeClustered = 1
IF (@idxExists = 0)
BEGIN
 PRINT 'Creating  PK constraint configurationsPrimaryKey on configurations'
 ALTER TABLE [bypass].[configurations] ADD CONSTRAINT [configurationsPrimaryKey] PRIMARY KEY CLUSTERED ([bypassConfigurationId] ASC)
  WITH (
    PAD_INDEX = OFF
    ,ALLOW_PAGE_LOCKS = ON
    ,ALLOW_ROW_LOCKS = ON
    ,STATISTICS_NORECOMPUTE = OFF
    ,IGNORE_DUP_KEY = OFF
    ,SORT_IN_TEMPDB = OFF
    ) ON [PRIMARY]
END
ELSE IF (
  (@idxIsPKConstraint <> @idxShouldBePKConstraint)
  OR (@idxIsUnique <> @idxShouldBeUnique)
  OR (@idxIsUniqueConstraint <> @idxShouldBeUniqueConstraint)
  OR (@idxIsClustered <> @idxShouldBeClustered)
  )
BEGIN
 PRINT 'Recreating PK constraint configurationsPrimaryKey on configurations'
 IF (
   @idxIsPKConstraint = 1
   OR @idxIsUniqueConstraint = 1
   )
 BEGIN
  EXEC DropAddForeignKeys @tableName = 'configurations'
   ,@dropCommands = @dropComm OUTPUT
   ,@addCommands = @addComm OUTPUT
   ,@addCommands2 = @addComm2 OUTPUT
  EXEC (@dropComm)
 END
 ALTER TABLE [bypass].[configurations]
 DROP CONSTRAINT [configurationsPrimaryKey]
 ALTER TABLE [bypass].[configurations] ADD CONSTRAINT [configurationsPrimaryKey] PRIMARY KEY CLUSTERED ([dnisId] ASC)
  WITH (
    PAD_INDEX = OFF
    ,ALLOW_PAGE_LOCKS = ON
    ,ALLOW_ROW_LOCKS = ON
    ,STATISTICS_NORECOMPUTE = OFF
    ,IGNORE_DUP_KEY = OFF
    ,SORT_IN_TEMPDB = OFF
    ) ON [PRIMARY]
 IF (
   (
    @idxIsPKConstraint = 1
    OR @idxIsUniqueConstraint = 1
    )
   AND (
    @idxShouldBePKConstraint = 1
    OR @idxShouldBeUniqueConstraint = 1
    )
   )
 BEGIN
  EXEC (@addComm)
  EXEC (@addComm2)
 END
END
ELSE
BEGIN
 PRINT '	PK constraint configurationsPrimaryKey already exists on configurations'
END
--unique constraint - [applicationId], [languageId], [dnis], [destination], [rank], [offerId]
SET @idxType = NULL
SELECT @idxIsUnique = is_unique
 ,@idxIsUniqueConstraint = is_unique_constraint
 ,@idxIsPKConstraint = is_primary_key
 ,@idxType = type
FROM sys.indexes
WHERE object_id = object_id('[bypass].[configurations]')
 AND name = 'configurationCombinedUniqueIndex'
SET @idxExists = CASE
  WHEN @idxType IS NULL
   THEN 0
  ELSE 1
  END
SET @idxIsClustered = CASE
  WHEN @idxType = 1
   THEN 1
  ELSE 0
  END
SET @idxIsUnique = isnull(@idxIsUnique, 0)
SET @idxIsUniqueConstraint = isnull(@idxIsUniqueConstraint, 0)
SET @idxIsPKConstraint = isnull(@idxIsPKConstraint, 0)
SET @idxShouldBeUnique = 1
SET @idxShouldBeUniqueConstraint = 0
SET @idxShouldBePKConstraint = 0
SET @idxShouldBeClustered = 0
IF (@idxExists = 0)
BEGIN
 PRINT 'Creating index configurationCombinedUniqueIndex on configurations'
 CREATE UNIQUE NONCLUSTERED INDEX [configurationCombinedUniqueIndex] ON [bypass].[configurations] (
  [applicationId]
  ,[languageId]
  ,[dnis]
  ,[destination]
  ,[rank]
  ,[offerId]
  )
  WITH (
    PAD_INDEX = OFF
    ,ALLOW_PAGE_LOCKS = ON
    ,ALLOW_ROW_LOCKS = ON
    ,STATISTICS_NORECOMPUTE = OFF
    ,IGNORE_DUP_KEY = OFF
    ,SORT_IN_TEMPDB = OFF
    ,FILLFACTOR = 70
    ) ON [PRIMARY]
END
ELSE IF (
  (@idxIsPKConstraint <> @idxShouldBePKConstraint)
  OR (@idxIsUnique <> @idxShouldBeUnique)
  OR (@idxIsUniqueConstraint <> @idxShouldBeUniqueConstraint)
  OR (@idxIsClustered <> @idxShouldBeClustered)
  )
BEGIN
 PRINT 'Recreating index configurationCombinedUniqueIndex on configurations'
 IF (
   @idxIsPKConstraint = 1
   OR @idxIsUniqueConstraint = 1
   )
 BEGIN
  EXEC DropAddForeignKeys @tableName = 'configurations'
   ,@dropCommands = @dropComm OUTPUT
   ,@addCommands = @addComm OUTPUT
   ,@addCommands2 = @addComm2 OUTPUT
  EXEC (@dropComm)
 END
 ALTER TABLE [bypass].[configurations]
 DROP CONSTRAINT [configurationCombinedUniqueIndex]
 CREATE UNIQUE NONCLUSTERED INDEX [configurationCombinedUniqueIndex] ON [bypass].[configurations] (
  [applicationId]
  ,[languageId]
  ,[dnis]
  ,[destination]
  ,[rank]
  ,[offerId]
  )
  WITH (
    PAD_INDEX = OFF
    ,ALLOW_PAGE_LOCKS = ON
    ,ALLOW_ROW_LOCKS = ON
    ,STATISTICS_NORECOMPUTE = OFF
    ,IGNORE_DUP_KEY = OFF
    ,SORT_IN_TEMPDB = OFF
    ,FILLFACTOR = 70
    ) ON [PRIMARY]
 IF (
   (
    @idxIsPKConstraint = 1
    OR @idxIsUniqueConstraint = 1
    )
   AND (
    @idxShouldBePKConstraint = 1
    OR @idxShouldBeUniqueConstraint = 1
    )
   )
 BEGIN
  EXEC (@addComm)
  EXEC (@addComm2)
 END
END
ELSE
BEGIN
 PRINT '	Index configurationCombinedUniqueIndex already exists on configurations'
END
--unique constraint - order
SET @idxType = NULL
SELECT @idxIsUnique = is_unique
 ,@idxIsUniqueConstraint = is_unique_constraint
 ,@idxIsPKConstraint = is_primary_key
 ,@idxType = type
FROM sys.indexes
WHERE object_id = object_id('[bypass].[configurations]')
 AND name = 'configurationOrderUniqueIndex'
SET @idxExists = CASE
  WHEN @idxType IS NULL
   THEN 0
  ELSE 1
  END
SET @idxIsClustered = CASE
  WHEN @idxType = 1
   THEN 1
  ELSE 0
  END
SET @idxIsUnique = isnull(@idxIsUnique, 0)
SET @idxIsUniqueConstraint = isnull(@idxIsUniqueConstraint, 0)
SET @idxIsPKConstraint = isnull(@idxIsPKConstraint, 0)
SET @idxShouldBeUnique = 1
SET @idxShouldBeUniqueConstraint = 0
SET @idxShouldBePKConstraint = 0
SET @idxShouldBeClustered = 0
IF (@idxExists = 0)
BEGIN
 PRINT 'Creating index configurationOrderUniqueIndex on configurations'
 CREATE UNIQUE NONCLUSTERED INDEX [configurationOrderUniqueIndex] ON [bypass].[configurations] (
  [applicationId]
  ,[order]
  )
  WITH (
    PAD_INDEX = OFF
    ,ALLOW_PAGE_LOCKS = ON
    ,ALLOW_ROW_LOCKS = ON
    ,STATISTICS_NORECOMPUTE = OFF
    ,IGNORE_DUP_KEY = OFF
    ,SORT_IN_TEMPDB = OFF
    ,FILLFACTOR = 70
    ) ON [PRIMARY]
END
ELSE IF (
  (@idxIsPKConstraint <> @idxShouldBePKConstraint)
  OR (@idxIsUnique <> @idxShouldBeUnique)
  OR (@idxIsUniqueConstraint <> @idxShouldBeUniqueConstraint)
  OR (@idxIsClustered <> @idxShouldBeClustered)
  )
BEGIN
 PRINT 'Recreating index configurationOrderUniqueIndex on configurations'
 IF (
   @idxIsPKConstraint = 1
   OR @idxIsUniqueConstraint = 1
   )
 BEGIN
  EXEC DropAddForeignKeys @tableName = 'configurations'
   ,@dropCommands = @dropComm OUTPUT
   ,@addCommands = @addComm OUTPUT
   ,@addCommands2 = @addComm2 OUTPUT
  EXEC (@dropComm)
 END
 ALTER TABLE [bypass].[configurations]
 DROP CONSTRAINT [configurationOrderUniqueIndex]
 CREATE UNIQUE NONCLUSTERED INDEX [configurationOrderUniqueIndex] ON [bypass].[configurations] (
  [applicationId]
  ,[order]
  )
  WITH (
    PAD_INDEX = OFF
    ,ALLOW_PAGE_LOCKS = ON
    ,ALLOW_ROW_LOCKS = ON
    ,STATISTICS_NORECOMPUTE = OFF
    ,IGNORE_DUP_KEY = OFF
    ,SORT_IN_TEMPDB = OFF
    ,FILLFACTOR = 70
    ) ON [PRIMARY]
 IF (
   (
    @idxIsPKConstraint = 1
    OR @idxIsUniqueConstraint = 1
    )
   AND (
    @idxShouldBePKConstraint = 1
    OR @idxShouldBeUniqueConstraint = 1
    )
   )
 BEGIN
  EXEC (@addComm)
  EXEC (@addComm2)
 END
END
ELSE
BEGIN
 PRINT '	Index configurationOrderUniqueIndex already exists on configurations'
END
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
-- FOREIGN KEYS - configurations --
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
IF NOT EXISTS (
  SELECT *
  FROM sys.foreign_keys
  WHERE name = 'configurationsApplicationsForeignKey'
   AND parent_object_id = object_id('[bypass].[configurations]')
  )
BEGIN
 PRINT 'Creating foreign key constraint configurationsApplicationsForeignKey for configurations'
 ALTER TABLE [bypass].[configurations]
  WITH CHECK ADD CONSTRAINT [configurationsApplicationsForeignKey] FOREIGN KEY ([applicationId]) REFERENCES [bypass].[applications]([applicationId])
 ALTER TABLE [bypass].[configurations] CHECK CONSTRAINT [configurationsApplicationsForeignKey]
END
ELSE
BEGIN
 PRINT 'Foreign key constraint configurationsApplicationsForeignKey already exists for configurations'
END
IF NOT EXISTS (
  SELECT *
  FROM sys.foreign_keys
  WHERE name = 'configurationsLanguagesForeignKey'
   AND parent_object_id = object_id('[bypass].[configurations]')
  )
BEGIN
 PRINT 'Creating foreign key constraint configurationsLanguagesForeignKey for configurations'
 ALTER TABLE [bypass].[configurations]
  WITH CHECK ADD CONSTRAINT [configurationsLanguagesForeignKey] FOREIGN KEY ([languageId]) REFERENCES [bypass].[languages]([languageId])
 ALTER TABLE [bypass].[configurations] CHECK CONSTRAINT [configurationsLanguagesForeignKey]
END
ELSE
BEGIN
 PRINT 'Foreign key constraint configurationsLanguagesForeignKey already exists for configurations'
END
  --$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
  -- TRIGGERS --
  --$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
GO
/* drop table [bypass].[roles] */
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
-- TABLE CREATION --
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
if not exists(select * from sys.tables where name = 'roles' and schema_id = (select schema_id from sys.schemas where name = 'bypass'))
begin
   print 'Creating roles table'
   create table [bypass].[roles] (
      [roleId] int not null identity (1,1),
      [name] varchar(100) null,
      [description] varchar(50) null,
      [dateAdded] datetime null,
   ) on [PRIMARY]
end
else
begin
   print 'roles table already exists'
end
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
-- NULL CONSTRAINTS --
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
if exists (select * from sys.columns where object_id = object_id('[bypass].[roles]') and name = 'roleId' and is_nullable=1)
begin
   print 'Converting column roleId in roles to disallow nulls'
   alter table [bypass].[roles] alter column [roleId] int not null
end
else
begin
   print '	Column roleId already in roles already disallows nulls'
end
if exists (select * from sys.columns where object_id = object_id('[bypass].[roles]') and name = 'name' and is_nullable=0)
begin
   print 'Converting column name in roles to allow nulls'
   alter table [bypass].[roles] alter column [name] varchar(100) null
end
else
begin
   print '	Column name already in roles already allows nulls'
end
if exists (select * from sys.columns where object_id = object_id('[bypass].[roles]') and name = 'description' and is_nullable=0)
begin
   print 'Converting column description in roles to allow nulls'
   alter table [bypass].[roles] alter column [description] varchar(50) null
end
else
begin
   print '	Column description already in roles already allows nulls'
end
if exists (select * from sys.columns where object_id = object_id('[bypass].[roles]') and name = 'dateAdded' and is_nullable=0)
begin
   print 'Converting column dateAdded in roles to allow nulls'
   alter table [bypass].[roles] alter column [dateAdded] datetime null
end
else
begin
   print '	Column dateAdded already in roles already allows nulls'
end
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
-- DEFAULT CONSTRAINTS --
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
-- CHECK CONSTRAINTS --
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
-- PRIMARY KEY / UNIQUE KEY CONSTRAINTS / INDEXES --
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
declare @idxExists bit = 0,
@idxIsUnique bit = 0,
@idxIsUniqueConstraint bit = 0,
@idxIsPKConstraint bit = 0,
@idxType tinyInt = NULL,
@idxIsClustered bit = 0,
@idxShouldBeUnique bit = 0,
@idxShouldBeUniqueConstraint bit = 0,
@idxShouldBePKConstraint bit = 0,
@idxShouldBeClustered bit = 0,
--the following are used for FKS when the object to be dropped is a PK or a unique constraint
@dropComm as varchar (max),
@addComm as varchar (max),
@addComm2 as varchar (max)
select @idxIsUnique=is_unique, @idxIsUniqueConstraint=is_unique_constraint, @idxIsPKConstraint=is_primary_key, @idxType=type from sys.indexes where object_id = object_id('[bypass].[roles]') and name = 'nameIndex'
set @idxExists = case when @idxType is null then 0 else 1 end
set @idxIsClustered = case when @idxType = 1 then 1 else 0 end
set @idxIsUnique = isnull(@idxIsUnique, 0)
set @idxIsUniqueConstraint = isnull(@idxIsUniqueConstraint, 0)
set @idxIsPKConstraint = isnull(@idxIsPKConstraint, 0)
set @idxShouldBeUnique = 1
set @idxShouldBeUniqueConstraint = 0
set @idxShouldBePKConstraint = 0
set @idxShouldBeClustered = 0
if (@idxExists = 0)
begin
   print 'Creating index nameIndex on roles'
   create unique nonclustered index [nameIndex] on [bypass].[roles] (
      [name] ASC
   )
   with ( PAD_INDEX = OFF, ALLOW_PAGE_LOCKS = ON, ALLOW_ROW_LOCKS = ON, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, SORT_IN_TEMPDB = OFF, FILLFACTOR = 70 ) on [PRIMARY]
end
else if ((@idxIsPKConstraint <> @idxShouldBePKConstraint) or
         (@idxIsUnique <> @idxShouldBeUnique) or
         (@idxIsUniqueConstraint <> @idxShouldBeUniqueConstraint) or
         (@idxIsClustered <> @idxShouldBeClustered))
begin
   print 'Recreating index nameIndex on roles'
   if (@idxIsPKConstraint = 1 or @idxIsUniqueConstraint = 1)
   begin
      exec DropAddForeignKeys @tableName = 'roles', @dropCommands = @dropComm OUTPUT, @addCommands = @addComm OUTPUT, @addCommands2 = @addComm2 OUTPUT
      exec(@dropComm)
   end
   alter table [bypass].[roles] drop constraint [nameIndex]
   create unique nonclustered index [nameIndex] on [bypass].[roles] (
      [name] ASC
   )
   with ( PAD_INDEX = OFF, ALLOW_PAGE_LOCKS = ON, ALLOW_ROW_LOCKS = ON, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, SORT_IN_TEMPDB = OFF, FILLFACTOR = 70 ) on [PRIMARY]
   if ((@idxIsPKConstraint = 1 or @idxIsUniqueConstraint = 1) and (@idxShouldBePKConstraint = 1 or @idxShouldBeUniqueConstraint = 1) )
   begin
      exec(@addComm)
      exec(@addComm2)
   end
end
else
begin
   print '	Index nameIndex already exists on roles'
end
select @idxIsUnique=is_unique, @idxIsUniqueConstraint=is_unique_constraint, @idxIsPKConstraint=is_primary_key, @idxType=type from sys.indexes where object_id = object_id('[bypass].[roles]') and name = 'rolesPrimaryKey'
set @idxExists = case when @idxType is null then 0 else 1 end
set @idxIsClustered = case when @idxType = 1 then 1 else 0 end
set @idxIsUnique = isnull(@idxIsUnique, 0)
set @idxIsUniqueConstraint = isnull(@idxIsUniqueConstraint, 0)
set @idxIsPKConstraint = isnull(@idxIsPKConstraint, 0)
set @idxShouldBeUnique = 1
set @idxShouldBeUniqueConstraint = 0
set @idxShouldBePKConstraint = 1
set @idxShouldBeClustered = 1
if (@idxExists = 0)
begin
   print 'Creating  PK constraint rolesPrimaryKey on roles'
   alter table [bypass].[roles] add constraint [rolesPrimaryKey] primary key clustered (
      [roleId] ASC
   )
   with ( PAD_INDEX = OFF, ALLOW_PAGE_LOCKS = ON, ALLOW_ROW_LOCKS = ON, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, SORT_IN_TEMPDB = OFF ) on [PRIMARY]
end
else if ((@idxIsPKConstraint <> @idxShouldBePKConstraint) or
         (@idxIsUnique <> @idxShouldBeUnique) or
         (@idxIsUniqueConstraint <> @idxShouldBeUniqueConstraint) or
         (@idxIsClustered <> @idxShouldBeClustered))
begin
   print 'Recreating PK constraint rolesPrimaryKey on roles'
   if (@idxIsPKConstraint = 1 or @idxIsUniqueConstraint = 1)
   begin
      exec DropAddForeignKeys @tableName = 'roles', @dropCommands = @dropComm OUTPUT, @addCommands = @addComm OUTPUT, @addCommands2 = @addComm2 OUTPUT
      exec(@dropComm)
   end
   alter table [bypass].[roles] drop constraint [rolesPrimaryKey]
   alter table [bypass].[roles] add constraint [rolesPrimaryKey] primary key clustered (
      [roleId] ASC
   )
   with ( PAD_INDEX = OFF, ALLOW_PAGE_LOCKS = ON, ALLOW_ROW_LOCKS = ON, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, SORT_IN_TEMPDB = OFF ) on [PRIMARY]
   if ((@idxIsPKConstraint = 1 or @idxIsUniqueConstraint = 1) and (@idxShouldBePKConstraint = 1 or @idxShouldBeUniqueConstraint = 1) )
   begin
      exec(@addComm)
      exec(@addComm2)
   end
end
else
begin
   print '	PK constraint rolesPrimaryKey already exists on roles'
end
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
-- FOREIGN KEYS - roles --
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
-- TRIGGERS --
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
GO
/* drop table [bypass].[users] */
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
-- TABLE CREATION --
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
if not exists(select * from sys.tables where name = 'users' and schema_id = (select schema_id from sys.schemas where name = 'bypass'))
begin
   print 'Creating users table'
   create table [bypass].[users] (
      [userId] int not null identity (1,1),
      [userName] varchar(100) not null,
      [deleted] bit not null constraint [usersDeletedDefault] default ((0)),
      [password] varchar(256) not null,
      [disabled] bit not null constraint [usersDisabledDefault] default ((0)),
      [isSuperAdmin] bit not null constraint [usersIsSuperAdminDefault] default ((0)),
      [isUsanUser] bit not null constraint [usersIsUsanUserDefault] default ((0)),
      [lastLoginDate] datetime null,
      [locked] bit not null constraint [usersLockedDefault] default ((0)),
      [failedLoginAttempts] smallint not null constraint [usersFailedLoginAttemptsDefault] default ((0)),
      [lastPasswordChangeDate] datetime null,
      [forceChangePassword] bit not null constraint [usersForceChangePasswordDefault] default ((0)),
      [dateAdded] datetime not null constraint [usersDateAddedDefault] default (getdate()),
   ) on [PRIMARY]
end
else
begin
   print 'users table already exists'
end
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
-- NULL CONSTRAINTS --
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
if exists (select * from sys.columns where object_id = object_id('[bypass].[users]') and name = 'userId' and is_nullable=1)
begin
   print 'Converting column userId in users to disallow nulls'
   alter table [bypass].[users] alter column [userId] int not null
end
else
begin
   print '	Column userId already in users already disallows nulls'
end
if exists (select * from sys.columns where object_id = object_id('[bypass].[users]') and name = 'userName' and is_nullable=1)
begin
   print 'Converting column userName in users to disallow nulls'
   alter table [bypass].[users] alter column [userName] varchar(100) not null
end
else
begin
   print '	Column userName already in users already disallows nulls'
end
if exists (select * from sys.columns where object_id = object_id('[bypass].[users]') and name = 'deleted' and is_nullable=1)
begin
   print 'Converting column deleted in users to disallow nulls'
   alter table [bypass].[users] alter column [deleted] bit not null
end
else
begin
   print '	Column deleted already in users already disallows nulls'
end
if exists (select * from sys.columns where object_id = object_id('[bypass].[users]') and name = 'password' and is_nullable=1)
begin
   print 'Converting column password in users to disallow nulls'
   alter table [bypass].[users] alter column [password] varchar(256) not null
end
else
begin
   print '	Column password already in users already disallows nulls'
end
if exists (select * from sys.columns where object_id = object_id('[bypass].[users]') and name = 'disabled' and is_nullable=1)
begin
   print 'Converting column disabled in users to disallow nulls'
   alter table [bypass].[users] alter column [disabled] bit not null
end
else
begin
   print '	Column disabled already in users already disallows nulls'
end
if exists (select * from sys.columns where object_id = object_id('[bypass].[users]') and name = 'isSuperAdmin' and is_nullable=1)
begin
   print 'Converting column isSuperAdmin in users to disallow nulls'
   alter table [bypass].[users] alter column [isSuperAdmin] bit not null
end
else
begin
   print '	Column isSuperAdmin already in users already disallows nulls'
end
if exists (select * from sys.columns where object_id = object_id('[bypass].[users]') and name = 'isUsanUser' and is_nullable=1)
begin
   print 'Converting column isUsanUser in users to disallow nulls'
   alter table [bypass].[users] alter column [isUsanUser] bit not null
end
else
begin
   print '	Column isUsanUser already in users already disallows nulls'
end
if exists (select * from sys.columns where object_id = object_id('[bypass].[users]') and name = 'lastLoginDate' and is_nullable=0)
begin
   print 'Converting column lastLoginDate in users to allow nulls'
   alter table [bypass].[users] alter column [lastLoginDate] datetime null
end
else
begin
   print '	Column lastLoginDate already in users already allows nulls'
end
if exists (select * from sys.columns where object_id = object_id('[bypass].[users]') and name = 'locked' and is_nullable=1)
begin
   print 'Converting column locked in users to disallow nulls'
   alter table [bypass].[users] alter column [locked] bit not null
end
else
begin
   print '	Column locked already in users already disallows nulls'
end
if exists (select * from sys.columns where object_id = object_id('[bypass].[users]') and name = 'failedLoginAttempts' and is_nullable=1)
begin
   print 'Converting column failedLoginAttempts in users to disallow nulls'
   alter table [bypass].[users] alter column [failedLoginAttempts] smallint not null
end
else
begin
   print '	Column failedLoginAttempts already in users already disallows nulls'
end
if exists (select * from sys.columns where object_id = object_id('[bypass].[users]') and name = 'lastPasswordChangeDate' and is_nullable=0)
begin
   print 'Converting column lastPasswordChangeDate in users to allow nulls'
   alter table [bypass].[users] alter column [lastPasswordChangeDate] datetime null
end
else
begin
   print '	Column lastPasswordChangeDate already in users already allows nulls'
end
if exists (select * from sys.columns where object_id = object_id('[bypass].[users]') and name = 'forceChangePassword' and is_nullable=1)
begin
   print 'Converting column forceChangePassword in users to disallow nulls'
   alter table [bypass].[users] alter column [forceChangePassword] bit not null
end
else
begin
   print '	Column forceChangePassword already in users already disallows nulls'
end
if exists (select * from sys.columns where object_id = object_id('[bypass].[users]') and name = 'dateAdded' and is_nullable=1)
begin
   print 'Converting column dateAdded in users to disallow nulls'
   alter table [bypass].[users] alter column [dateAdded] datetime not null
end
else
begin
   print '	Column dateAdded already in users already disallows nulls'
end
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
-- DEFAULT CONSTRAINTS --
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
if exists (select * from sys.columns where object_id = object_id('[bypass].[users]') and name = 'deleted' and [default_object_id]=0)
begin
   print 'Creating default constraint on users.deleted'
   alter table [bypass].[users] add constraint [usersDeletedDefault] default ((0)) for [deleted]
end
else
begin
   print 'Default constraint already exists for users.deleted'
end
if exists (select * from sys.columns where object_id = object_id('[bypass].[users]') and name = 'disabled' and [default_object_id]=0)
begin
   print 'Creating default constraint on users.disabled'
   alter table [bypass].[users] add constraint [usersDisabledDefault] default ((0)) for [disabled]
end
else
begin
   print 'Default constraint already exists for users.disabled'
end
if exists (select * from sys.columns where object_id = object_id('[bypass].[users]') and name = 'isSuperAdmin' and [default_object_id]=0)
begin
   print 'Creating default constraint on users.isSuperAdmin'
   alter table [bypass].[users] add constraint [usersIsSuperAdminDefault] default ((0)) for [isSuperAdmin]
end
else
begin
   print 'Default constraint already exists for users.isSuperAdmin'
end
if exists (select * from sys.columns where object_id = object_id('[bypass].[users]') and name = 'isUsanUser' and [default_object_id]=0)
begin
   print 'Creating default constraint on users.isUsanUser'
   alter table [bypass].[users] add constraint [usersIsUsanUserDefault] default ((0)) for [isUsanUser]
end
else
begin
   print 'Default constraint already exists for users.isUsanUser'
end
if exists (select * from sys.columns where object_id = object_id('[bypass].[users]') and name = 'locked' and [default_object_id]=0)
begin
   print 'Creating default constraint on users.locked'
   alter table [bypass].[users] add constraint [usersLockedDefault] default ((0)) for [locked]
end
else
begin
   print 'Default constraint already exists for users.locked'
end
if exists (select * from sys.columns where object_id = object_id('[bypass].[users]') and name = 'failedLoginAttempts' and [default_object_id]=0)
begin
   print 'Creating default constraint on users.failedLoginAttempts'
   alter table [bypass].[users] add constraint [usersFailedLoginAttemptsDefault] default ((0)) for [failedLoginAttempts]
end
else
begin
   print 'Default constraint already exists for users.failedLoginAttempts'
end
if exists (select * from sys.columns where object_id = object_id('[bypass].[users]') and name = 'forceChangePassword' and [default_object_id]=0)
begin
   print 'Creating default constraint on users.forceChangePassword'
   alter table [bypass].[users] add constraint [usersForceChangePasswordDefault] default ((0)) for [forceChangePassword]
end
else
begin
   print 'Default constraint already exists for users.forceChangePassword'
end
if exists (select * from sys.columns where object_id = object_id('[bypass].[users]') and name = 'dateAdded' and [default_object_id]=0)
begin
   print 'Creating default constraint on users.dateAdded'
   alter table [bypass].[users] add constraint [usersDateAddedDefault] default (getdate()) for [dateAdded]
end
else
begin
   print 'Default constraint already exists for users.dateAdded'
end
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
-- CHECK CONSTRAINTS --
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
-- PRIMARY KEY / UNIQUE KEY CONSTRAINTS / INDEXES --
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
declare @idxExists bit = 0,
@idxIsUnique bit = 0,
@idxIsUniqueConstraint bit = 0,
@idxIsPKConstraint bit = 0,
@idxType tinyInt = NULL,
@idxIsClustered bit = 0,
@idxShouldBeUnique bit = 0,
@idxShouldBeUniqueConstraint bit = 0,
@idxShouldBePKConstraint bit = 0,
@idxShouldBeClustered bit = 0,
--the following are used for FKS when the object to be dropped is a PK or a unique constraint
@dropComm as varchar (max),
@addComm as varchar (max),
@addComm2 as varchar (max)
select @idxIsUnique=is_unique, @idxIsUniqueConstraint=is_unique_constraint, @idxIsPKConstraint=is_primary_key, @idxType=type from sys.indexes where object_id = object_id('[bypass].[users]') and name = 'usersIndex'
set @idxExists = case when @idxType is null then 0 else 1 end
set @idxIsClustered = case when @idxType = 1 then 1 else 0 end
set @idxIsUnique = isnull(@idxIsUnique, 0)
set @idxIsUniqueConstraint = isnull(@idxIsUniqueConstraint, 0)
set @idxIsPKConstraint = isnull(@idxIsPKConstraint, 0)
set @idxShouldBeUnique = 1
set @idxShouldBeUniqueConstraint = 0
set @idxShouldBePKConstraint = 0
set @idxShouldBeClustered = 0
if (@idxExists = 0)
begin
   print 'Creating index usersIndex on users'
   create unique nonclustered index [usersIndex] on [bypass].[users] (
      [userName] ASC
   )
   with ( PAD_INDEX = OFF, ALLOW_PAGE_LOCKS = ON, ALLOW_ROW_LOCKS = ON, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, SORT_IN_TEMPDB = OFF, FILLFACTOR = 70 ) on [PRIMARY]
end
else if ((@idxIsPKConstraint <> @idxShouldBePKConstraint) or
         (@idxIsUnique <> @idxShouldBeUnique) or
         (@idxIsUniqueConstraint <> @idxShouldBeUniqueConstraint) or
         (@idxIsClustered <> @idxShouldBeClustered))
begin
   print 'Recreating index usersIndex on users'
   if (@idxIsPKConstraint = 1 or @idxIsUniqueConstraint = 1)
   begin
      exec DropAddForeignKeys @tableName = 'users', @dropCommands = @dropComm OUTPUT, @addCommands = @addComm OUTPUT, @addCommands2 = @addComm2 OUTPUT
      exec(@dropComm)
   end
   alter table [bypass].[users] drop constraint [usersIndex]
   create unique nonclustered index [usersIndex] on [bypass].[users] (
      [userName] ASC
   )
   with ( PAD_INDEX = OFF, ALLOW_PAGE_LOCKS = ON, ALLOW_ROW_LOCKS = ON, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, SORT_IN_TEMPDB = OFF, FILLFACTOR = 70 ) on [PRIMARY]
   if ((@idxIsPKConstraint = 1 or @idxIsUniqueConstraint = 1) and (@idxShouldBePKConstraint = 1 or @idxShouldBeUniqueConstraint = 1) )
   begin
      exec(@addComm)
      exec(@addComm2)
   end
end
else
begin
   print '	Index usersIndex already exists on users'
end
select @idxIsUnique=is_unique, @idxIsUniqueConstraint=is_unique_constraint, @idxIsPKConstraint=is_primary_key, @idxType=type from sys.indexes where object_id = object_id('[bypass].[users]') and name = 'usersPrimaryKey'
set @idxExists = case when @idxType is null then 0 else 1 end
set @idxIsClustered = case when @idxType = 1 then 1 else 0 end
set @idxIsUnique = isnull(@idxIsUnique, 0)
set @idxIsUniqueConstraint = isnull(@idxIsUniqueConstraint, 0)
set @idxIsPKConstraint = isnull(@idxIsPKConstraint, 0)
set @idxShouldBeUnique = 1
set @idxShouldBeUniqueConstraint = 0
set @idxShouldBePKConstraint = 1
set @idxShouldBeClustered = 1
if (@idxExists = 0)
begin
   print 'Creating  PK constraint usersPrimaryKey on users'
   alter table [bypass].[users] add constraint [usersPrimaryKey] primary key clustered (
      [userId] ASC
   )
   with ( PAD_INDEX = OFF, ALLOW_PAGE_LOCKS = ON, ALLOW_ROW_LOCKS = ON, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, SORT_IN_TEMPDB = OFF ) on [PRIMARY]
end
else if ((@idxIsPKConstraint <> @idxShouldBePKConstraint) or
         (@idxIsUnique <> @idxShouldBeUnique) or
         (@idxIsUniqueConstraint <> @idxShouldBeUniqueConstraint) or
         (@idxIsClustered <> @idxShouldBeClustered))
begin
   print 'Recreating PK constraint usersPrimaryKey on users'
   if (@idxIsPKConstraint = 1 or @idxIsUniqueConstraint = 1)
   begin
      exec DropAddForeignKeys @tableName = 'users', @dropCommands = @dropComm OUTPUT, @addCommands = @addComm OUTPUT, @addCommands2 = @addComm2 OUTPUT
      exec(@dropComm)
   end
   alter table [bypass].[users] drop constraint [usersPrimaryKey]
   alter table [bypass].[users] add constraint [usersPrimaryKey] primary key clustered (
      [userId] ASC
   )
   with ( PAD_INDEX = OFF, ALLOW_PAGE_LOCKS = ON, ALLOW_ROW_LOCKS = ON, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, SORT_IN_TEMPDB = OFF ) on [PRIMARY]
   if ((@idxIsPKConstraint = 1 or @idxIsUniqueConstraint = 1) and (@idxShouldBePKConstraint = 1 or @idxShouldBeUniqueConstraint = 1) )
   begin
      exec(@addComm)
      exec(@addComm2)
   end
end
else
begin
   print '	PK constraint usersPrimaryKey already exists on users'
end
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
-- FOREIGN KEYS - users --
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
-- TRIGGERS --
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
GO
/* drop table [bypass].[userRoles] */
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
-- TABLE CREATION --
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
if not exists(select * from sys.tables where name = 'userRoles' and schema_id = (select schema_id from sys.schemas where name = 'bypass'))
begin
   print 'Creating userRoles table'
   create table [bypass].[userRoles] (
      [userId] int not null,
      [roleId] int not null,
      [applicationId] int not null,
   ) on [PRIMARY]
end
else
begin
   print 'userRoles table already exists'
end
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
-- NULL CONSTRAINTS --
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
if exists (select * from sys.columns where object_id = object_id('[bypass].[userRoles]') and name = 'userId' and is_nullable=1)
begin
   print 'Converting column userId in userRoles to disallow nulls'
   alter table [bypass].[userRoles] alter column [userId] int not null
end
else
begin
   print '	Column userId already in userRoles already disallows nulls'
end
if exists (select * from sys.columns where object_id = object_id('[bypass].[userRoles]') and name = 'roleId' and is_nullable=1)
begin
   print 'Converting column roleId in userRoles to disallow nulls'
   alter table [bypass].[userRoles] alter column [roleId] int not null
end
else
begin
   print '	Column roleId already in userRoles already disallows nulls'
end
if exists (select * from sys.columns where object_id = object_id('[bypass].[userRoles]') and name = 'applicationId' and is_nullable=1)
begin
   print 'Converting column applicationId in userRoles to disallow nulls'
   alter table [bypass].[userRoles] alter column [applicationId] int not null
end
else
begin
   print '	Column applicationId already in userRoles already disallows nulls'
end
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
-- DEFAULT CONSTRAINTS --
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
-- CHECK CONSTRAINTS --
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
-- PRIMARY KEY / UNIQUE KEY CONSTRAINTS / INDEXES --
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
declare @idxExists bit = 0,
@idxIsUnique bit = 0,
@idxIsUniqueConstraint bit = 0,
@idxIsPKConstraint bit = 0,
@idxType tinyInt = NULL,
@idxIsClustered bit = 0,
@idxShouldBeUnique bit = 0,
@idxShouldBeUniqueConstraint bit = 0,
@idxShouldBePKConstraint bit = 0,
@idxShouldBeClustered bit = 0,
--the following are used for FKS when the object to be dropped is a PK or a unique constraint
@dropComm as varchar (max),
@addComm as varchar (max),
@addComm2 as varchar (max)
select @idxIsUnique=is_unique, @idxIsUniqueConstraint=is_unique_constraint, @idxIsPKConstraint=is_primary_key, @idxType=type from sys.indexes where object_id = object_id('[bypass].[userRoles]') and name = 'userRolesPrimaryKey'
set @idxExists = case when @idxType is null then 0 else 1 end
set @idxIsClustered = case when @idxType = 1 then 1 else 0 end
set @idxIsUnique = isnull(@idxIsUnique, 0)
set @idxIsUniqueConstraint = isnull(@idxIsUniqueConstraint, 0)
set @idxIsPKConstraint = isnull(@idxIsPKConstraint, 0)
set @idxShouldBeUnique = 1
set @idxShouldBeUniqueConstraint = 0
set @idxShouldBePKConstraint = 1
set @idxShouldBeClustered = 1
if (@idxExists = 0)
begin
   print 'Creating  PK constraint userRolesPrimaryKey on userRoles'
   alter table [bypass].[userRoles] add constraint [userRolesPrimaryKey] primary key clustered (
      [userId] ASC,
      [roleId] ASC,
      [applicationId] ASC
   )
   with ( PAD_INDEX = OFF, ALLOW_PAGE_LOCKS = ON, ALLOW_ROW_LOCKS = ON, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, SORT_IN_TEMPDB = OFF, FILLFACTOR = 70 ) on [PRIMARY]
end
else if ((@idxIsPKConstraint <> @idxShouldBePKConstraint) or
         (@idxIsUnique <> @idxShouldBeUnique) or
         (@idxIsUniqueConstraint <> @idxShouldBeUniqueConstraint) or
         (@idxIsClustered <> @idxShouldBeClustered))
begin
   print 'Recreating PK constraint userRolesPrimaryKey on userRoles'
   if (@idxIsPKConstraint = 1 or @idxIsUniqueConstraint = 1)
   begin
      exec DropAddForeignKeys @tableName = 'userRoles', @dropCommands = @dropComm OUTPUT, @addCommands = @addComm OUTPUT, @addCommands2 = @addComm2 OUTPUT
      exec(@dropComm)
   end
   alter table [bypass].[userRoles] drop constraint [userRolesPrimaryKey]
   alter table [bypass].[userRoles] add constraint [userRolesPrimaryKey] primary key clustered (
      [userId] ASC,
      [roleId] ASC,
      [applicationId] ASC
   )
   with ( PAD_INDEX = OFF, ALLOW_PAGE_LOCKS = ON, ALLOW_ROW_LOCKS = ON, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, SORT_IN_TEMPDB = OFF, FILLFACTOR = 70 ) on [PRIMARY]
   if ((@idxIsPKConstraint = 1 or @idxIsUniqueConstraint = 1) and (@idxShouldBePKConstraint = 1 or @idxShouldBeUniqueConstraint = 1) )
   begin
      exec(@addComm)
      exec(@addComm2)
   end
end
else
begin
   print '	PK constraint userRolesPrimaryKey already exists on userRoles'
end
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
-- FOREIGN KEYS - userRoles --
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
if not exists (select * from sys.foreign_keys where name = 'userRolesApplicationsForeignKey' and parent_object_id = object_id('[bypass].[userRoles]'))
begin
   print 'Creating foreign key constraint userRolesApplicationsForeignKey for userRoles'
   alter table [bypass].[userRoles] with check add constraint [userRolesApplicationsForeignKey] foreign key ([applicationId]) references [bypass].[applications]([applicationId])
   alter table [bypass].[userRoles] check constraint [userRolesApplicationsForeignKey]
end
else
begin
   print 'Foreign key constraint userRolesApplicationsForeignKey already exists for userRoles'
end
if not exists (select * from sys.foreign_keys where name = 'userRolesRolesForeignKey' and parent_object_id = object_id('[bypass].[userRoles]'))
begin
   print 'Creating foreign key constraint userRolesRolesForeignKey for userRoles'
   alter table [bypass].[userRoles] with check add constraint [userRolesRolesForeignKey] foreign key ([roleId]) references [bypass].[roles]([roleId])
   alter table [bypass].[userRoles] check constraint [userRolesRolesForeignKey]
end
else
begin
   print 'Foreign key constraint userRolesRolesForeignKey already exists for userRoles'
end
if not exists (select * from sys.foreign_keys where name = 'userRolesUsersForeignKey' and parent_object_id = object_id('[bypass].[userRoles]'))
begin
   print 'Creating foreign key constraint userRolesUsersForeignKey for userRoles'
   alter table [bypass].[userRoles] with check add constraint [userRolesUsersForeignKey] foreign key ([userId]) references [bypass].[users]([userId])
   alter table [bypass].[userRoles] check constraint [userRolesUsersForeignKey]
end
else
begin
   print 'Foreign key constraint userRolesUsersForeignKey already exists for userRoles'
end
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
-- TRIGGERS --
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
GO
-- drop table [bypass_static].[userAuditActions]
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
-- TABLE CREATION --
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
if not exists(select * from sys.tables where name = 'userAuditActions' and schema_id = (select schema_id from sys.schemas where name = 'bypass_static'))
begin
   print 'Creating userAuditActions table'
   create table [bypass_static].[userAuditActions] (
      [userAuditActionId] tinyint not null identity (1,1),
      [auditDescription] varchar(64) null,
      [dateAdded] datetime not null constraint [userAuditActionsDateAddedDefault] default (getdate()),
   ) on [PRIMARY]
end
else
begin
   print 'userAuditActions table already exists'
end
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
-- NULL CONSTRAINTS --
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
if exists (select * from sys.columns where object_id = object_id('[bypass_static].[userAuditActions]') and name = 'userAuditActionId' and is_nullable=1)
begin
   print 'Converting column userAuditActionId in userAuditActions to disallow nulls'
   alter table [bypass_static].[userAuditActions] alter column [userAuditActionId] tinyint not null
end
else
begin
   print '	Column userAuditActionId already in userAuditActions already disallows nulls'
end
if exists (select * from sys.columns where object_id = object_id('[bypass_static].[userAuditActions]') and name = 'auditDescription' and is_nullable=0)
begin
   print 'Converting column auditDescription in userAuditActions to allow nulls'
   alter table [bypass_static].[userAuditActions] alter column [auditDescription] varchar(64) null
end
else
begin
   print '	Column auditDescription already in userAuditActions already allows nulls'
end
if exists (select * from sys.columns where object_id = object_id('[bypass_static].[userAuditActions]') and name = 'dateAdded' and is_nullable=1)
begin
   print 'Converting column dateAdded in userAuditActions to disallow nulls'
   alter table [bypass_static].[userAuditActions] alter column [dateAdded] datetime not null
end
else
begin
   print '	Column dateAdded already in userAuditActions already disallows nulls'
end
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
-- DEFAULT CONSTRAINTS --
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
if exists (select * from sys.columns where object_id = object_id('[bypass_static].[userAuditActions]') and name = 'dateAdded' and [default_object_id]=0)
begin
   print 'Creating default constraint on userAuditActions.dateAdded'
   alter table [bypass_static].[userAuditActions] add constraint [userAuditActionsDateAddedDefault] default (getdate()) for [dateAdded]
end
else
begin
   print 'Default constraint already exists for userAuditActions.dateAdded'
end
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
-- CHECK CONSTRAINTS --
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
-- PRIMARY KEY / UNIQUE KEY CONSTRAINTS / INDEXES --
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
declare @idxExists bit = 0,
@idxIsUnique bit = 0,
@idxIsUniqueConstraint bit = 0,
@idxIsPKConstraint bit = 0,
@idxType tinyInt = NULL,
@idxIsClustered bit = 0,
@idxShouldBeUnique bit = 0,
@idxShouldBeUniqueConstraint bit = 0,
@idxShouldBePKConstraint bit = 0,
@idxShouldBeClustered bit = 0,
--the following are used for FKS when the object to be dropped is a PK or a unique constraint
@dropComm as varchar (max),
@addComm as varchar (max),
@addComm2 as varchar (max)
select @idxIsUnique=is_unique, @idxIsUniqueConstraint=is_unique_constraint, @idxIsPKConstraint=is_primary_key, @idxType=type from sys.indexes where object_id = object_id('[bypass_static].[userAuditActions]') and name = 'auditDescriptionIndex'
set @idxExists = case when @idxType is null then 0 else 1 end
set @idxIsClustered = case when @idxType = 1 then 1 else 0 end
set @idxIsUnique = isnull(@idxIsUnique, 0)
set @idxIsUniqueConstraint = isnull(@idxIsUniqueConstraint, 0)
set @idxIsPKConstraint = isnull(@idxIsPKConstraint, 0)
set @idxShouldBeUnique = 1
set @idxShouldBeUniqueConstraint = 0
set @idxShouldBePKConstraint = 0
set @idxShouldBeClustered = 0
if (@idxExists = 0)
begin
   print 'Creating index auditDescriptionIndex on userAuditActions'
   create unique nonclustered index [auditDescriptionIndex] on [bypass_static].[userAuditActions] (
      [auditDescription] ASC
   )
   with ( PAD_INDEX = OFF, ALLOW_PAGE_LOCKS = ON, ALLOW_ROW_LOCKS = ON, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, SORT_IN_TEMPDB = OFF, FILLFACTOR = 70 ) on [PRIMARY]
end
else if ((@idxIsPKConstraint <> @idxShouldBePKConstraint) or
         (@idxIsUnique <> @idxShouldBeUnique) or
         (@idxIsUniqueConstraint <> @idxShouldBeUniqueConstraint) or
         (@idxIsClustered <> @idxShouldBeClustered))
begin
   print 'Recreating index auditDescriptionIndex on userAuditActions'
   if (@idxIsPKConstraint = 1 or @idxIsUniqueConstraint = 1)
   begin
      exec DropAddForeignKeys @tableName = 'userAuditActions', @dropCommands = @dropComm OUTPUT, @addCommands = @addComm OUTPUT, @addCommands2 = @addComm2 OUTPUT
      exec(@dropComm)
   end
   alter table [bypass_static].[userAuditActions] drop constraint [auditDescriptionIndex]
   create unique nonclustered index [auditDescriptionIndex] on [bypass_static].[userAuditActions] (
      [auditDescription] ASC
   )
   with ( PAD_INDEX = OFF, ALLOW_PAGE_LOCKS = ON, ALLOW_ROW_LOCKS = ON, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, SORT_IN_TEMPDB = OFF, FILLFACTOR = 70 ) on [PRIMARY]
   if ((@idxIsPKConstraint = 1 or @idxIsUniqueConstraint = 1) and (@idxShouldBePKConstraint = 1 or @idxShouldBeUniqueConstraint = 1) )
   begin
      exec(@addComm)
      exec(@addComm2)
   end
end
else
begin
   print '	Index auditDescriptionIndex already exists on userAuditActions'
end
select @idxIsUnique=is_unique, @idxIsUniqueConstraint=is_unique_constraint, @idxIsPKConstraint=is_primary_key, @idxType=type from sys.indexes where object_id = object_id('[bypass_static].[userAuditActions]') and name = 'userAuditActionsPrimaryKey'
set @idxExists = case when @idxType is null then 0 else 1 end
set @idxIsClustered = case when @idxType = 1 then 1 else 0 end
set @idxIsUnique = isnull(@idxIsUnique, 0)
set @idxIsUniqueConstraint = isnull(@idxIsUniqueConstraint, 0)
set @idxIsPKConstraint = isnull(@idxIsPKConstraint, 0)
set @idxShouldBeUnique = 1
set @idxShouldBeUniqueConstraint = 0
set @idxShouldBePKConstraint = 1
set @idxShouldBeClustered = 1
if (@idxExists = 0)
begin
   print 'Creating  PK constraint userAuditActionsPrimaryKey on userAuditActions'
   alter table [bypass_static].[userAuditActions] add constraint [userAuditActionsPrimaryKey] primary key clustered (
      [userAuditActionId] ASC
   )
   with ( PAD_INDEX = OFF, ALLOW_PAGE_LOCKS = ON, ALLOW_ROW_LOCKS = ON, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, SORT_IN_TEMPDB = OFF ) on [PRIMARY]
end
else if ((@idxIsPKConstraint <> @idxShouldBePKConstraint) or
         (@idxIsUnique <> @idxShouldBeUnique) or
         (@idxIsUniqueConstraint <> @idxShouldBeUniqueConstraint) or
         (@idxIsClustered <> @idxShouldBeClustered))
begin
   print 'Recreating PK constraint userAuditActionsPrimaryKey on userAuditActions'
   if (@idxIsPKConstraint = 1 or @idxIsUniqueConstraint = 1)
   begin
      exec DropAddForeignKeys @tableName = 'userAuditActions', @dropCommands = @dropComm OUTPUT, @addCommands = @addComm OUTPUT, @addCommands2 = @addComm2 OUTPUT
      exec(@dropComm)
   end
   alter table [bypass_static].[userAuditActions] drop constraint [userAuditActionsPrimaryKey]
   alter table [bypass_static].[userAuditActions] add constraint [userAuditActionsPrimaryKey] primary key clustered (
      [userAuditActionId] ASC
   )
   with ( PAD_INDEX = OFF, ALLOW_PAGE_LOCKS = ON, ALLOW_ROW_LOCKS = ON, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, SORT_IN_TEMPDB = OFF ) on [PRIMARY]
   if ((@idxIsPKConstraint = 1 or @idxIsUniqueConstraint = 1) and (@idxShouldBePKConstraint = 1 or @idxShouldBeUniqueConstraint = 1) )
   begin
      exec(@addComm)
      exec(@addComm2)
   end
end
else
begin
   print '	PK constraint userAuditActionsPrimaryKey already exists on userAuditActions'
end
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
-- FOREIGN KEYS - userAuditActions --
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
-- TRIGGERS --
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
GO
/* drop table [bypass].[userAudits] */
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
-- TABLE CREATION --
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
if not exists(select * from sys.tables where name = 'userAudits' and schema_id = (select schema_id from sys.schemas where name = 'bypass'))
begin
   print 'Creating userAudits table'
   create table [bypass].[userAudits] (
      [userAuditId] int not null identity (1,1),
      [auditDate] datetime null constraint [userAuditsAuditDateDefault] default (getdate()),
      [performerUserId] int not null,
      [affectedUserId] int not null,
      [userAuditActionId] tinyint not null,
      [userSubAuditActionId] tinyint null,
      [beforeValue] varchar(256) null,
      [afterValue] varchar(256) null,
   ) on [PRIMARY]
end
else
begin
   print 'userAudits table already exists'
end
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
-- NULL CONSTRAINTS --
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
if exists (select * from sys.columns where object_id = object_id('[bypass].[userAudits]') and name = 'userAuditId' and is_nullable=1)
begin
   print 'Converting column userAuditId in userAudits to disallow nulls'
   alter table [bypass].[userAudits] alter column [userAuditId] int not null
end
else
begin
   print '	Column userAuditId already in userAudits already disallows nulls'
end
if exists (select * from sys.columns where object_id = object_id('[bypass].[userAudits]') and name = 'auditDate' and is_nullable=0)
begin
   print 'Converting column auditDate in userAudits to allow nulls'
   alter table [bypass].[userAudits] alter column [auditDate] datetime null
end
else
begin
   print '	Column auditDate already in userAudits already allows nulls'
end
if exists (select * from sys.columns where object_id = object_id('[bypass].[userAudits]') and name = 'performerUserId' and is_nullable=1)
begin
   print 'Converting column performerUserId in userAudits to disallow nulls'
   alter table [bypass].[userAudits] alter column [performerUserId] int not null
end
else
begin
   print '	Column performerUserId already in userAudits already disallows nulls'
end
if exists (select * from sys.columns where object_id = object_id('[bypass].[userAudits]') and name = 'affectedUserId' and is_nullable=1)
begin
   print 'Converting column affectedUserId in userAudits to disallow nulls'
   alter table [bypass].[userAudits] alter column [affectedUserId] int not null
end
else
begin
   print '	Column affectedUserId already in userAudits already disallows nulls'
end
if exists (select * from sys.columns where object_id = object_id('[bypass].[userAudits]') and name = 'userAuditActionId' and is_nullable=1)
begin
   print 'Converting column userAuditActionId in userAudits to disallow nulls'
   alter table [bypass].[userAudits] alter column [userAuditActionId] tinyint not null
end
else
begin
   print '	Column userAuditActionId already in userAudits already disallows nulls'
end
if exists (select * from sys.columns where object_id = object_id('[bypass].[userAudits]') and name = 'userSubAuditActionId' and is_nullable=0)
begin
   print 'Converting column userSubAuditActionId in userAudits to allow nulls'
   alter table [bypass].[userAudits] alter column [userSubAuditActionId] tinyint null
end
else
begin
   print '	Column userSubAuditActionId already in userAudits already allows nulls'
end
if exists (select * from sys.columns where object_id = object_id('[bypass].[userAudits]') and name = 'beforeValue' and is_nullable=0)
begin
   print 'Converting column beforeValue in userAudits to allow nulls'
   alter table [bypass].[userAudits] alter column [beforeValue] varchar(256) null
end
else
begin
   print '	Column beforeValue already in userAudits already allows nulls'
end
if exists (select * from sys.columns where object_id = object_id('[bypass].[userAudits]') and name = 'afterValue' and is_nullable=0)
begin
   print 'Converting column afterValue in userAudits to allow nulls'
   alter table [bypass].[userAudits] alter column [afterValue] varchar(256) null
end
else
begin
   print '	Column afterValue already in userAudits already allows nulls'
end
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
-- DEFAULT CONSTRAINTS --
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
if exists (select * from sys.columns where object_id = object_id('[bypass].[userAudits]') and name = 'auditDate' and [default_object_id]=0)
begin
   print 'Creating default constraint on userAudits.auditDate'
   alter table [bypass].[userAudits] add constraint [userAuditsAuditDateDefault] default (getdate()) for [auditDate]
end
else
begin
   print 'Default constraint already exists for userAudits.auditDate'
end
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
-- CHECK CONSTRAINTS --
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
-- PRIMARY KEY / UNIQUE KEY CONSTRAINTS / INDEXES --
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
declare @idxExists bit = 0,
@idxIsUnique bit = 0,
@idxIsUniqueConstraint bit = 0,
@idxIsPKConstraint bit = 0,
@idxType tinyInt = NULL,
@idxIsClustered bit = 0,
@idxShouldBeUnique bit = 0,
@idxShouldBeUniqueConstraint bit = 0,
@idxShouldBePKConstraint bit = 0,
@idxShouldBeClustered bit = 0,
--the following are used for FKS when the object to be dropped is a PK or a unique constraint
@dropComm as varchar (max),
@addComm as varchar (max),
@addComm2 as varchar (max)
select @idxIsUnique=is_unique, @idxIsUniqueConstraint=is_unique_constraint, @idxIsPKConstraint=is_primary_key, @idxType=type from sys.indexes where object_id = object_id('[bypass].[userAudits]') and name = 'userAuditsPrimaryKey'
set @idxExists = case when @idxType is null then 0 else 1 end
set @idxIsClustered = case when @idxType = 1 then 1 else 0 end
set @idxIsUnique = isnull(@idxIsUnique, 0)
set @idxIsUniqueConstraint = isnull(@idxIsUniqueConstraint, 0)
set @idxIsPKConstraint = isnull(@idxIsPKConstraint, 0)
set @idxShouldBeUnique = 1
set @idxShouldBeUniqueConstraint = 0
set @idxShouldBePKConstraint = 1
set @idxShouldBeClustered = 1
if (@idxExists = 0)
begin
   print 'Creating  PK constraint userAuditsPrimaryKey on userAudits'
   alter table [bypass].[userAudits] add constraint [userAuditsPrimaryKey] primary key clustered (
      [userAuditId] ASC
   )
   with ( PAD_INDEX = OFF, ALLOW_PAGE_LOCKS = ON, ALLOW_ROW_LOCKS = ON, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, SORT_IN_TEMPDB = OFF ) on [PRIMARY]
end
else if ((@idxIsPKConstraint <> @idxShouldBePKConstraint) or
         (@idxIsUnique <> @idxShouldBeUnique) or
         (@idxIsUniqueConstraint <> @idxShouldBeUniqueConstraint) or
         (@idxIsClustered <> @idxShouldBeClustered))
begin
   print 'Recreating PK constraint userAuditsPrimaryKey on userAudits'
   if (@idxIsPKConstraint = 1 or @idxIsUniqueConstraint = 1)
   begin
      exec DropAddForeignKeys @tableName = 'userAudits', @dropCommands = @dropComm OUTPUT, @addCommands = @addComm OUTPUT, @addCommands2 = @addComm2 OUTPUT
      exec(@dropComm)
   end
   alter table [bypass].[userAudits] drop constraint [userAuditsPrimaryKey]
   alter table [bypass].[userAudits] add constraint [userAuditsPrimaryKey] primary key clustered (
      [userAuditId] ASC
   )
   with ( PAD_INDEX = OFF, ALLOW_PAGE_LOCKS = ON, ALLOW_ROW_LOCKS = ON, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, SORT_IN_TEMPDB = OFF ) on [PRIMARY]
   if ((@idxIsPKConstraint = 1 or @idxIsUniqueConstraint = 1) and (@idxShouldBePKConstraint = 1 or @idxShouldBeUniqueConstraint = 1) )
   begin
      exec(@addComm)
      exec(@addComm2)
   end
end
else
begin
   print '	PK constraint userAuditsPrimaryKey already exists on userAudits'
end
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
-- FOREIGN KEYS - userAudits --
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
if not exists (select * from sys.foreign_keys where name = 'userAuditsUserAuditActions02ForeignKey0' and parent_object_id = object_id('[bypass].[userAudits]'))
begin
   print 'Creating foreign key constraint userAuditsUserAuditActions02ForeignKey0 for userAudits'
   alter table [bypass].[userAudits] with check add constraint [userAuditsUserAuditActions02ForeignKey0] foreign key ([userSubAuditActionId]) references [bypass_static].[userAuditActions]([userAuditActionId])
   alter table [bypass].[userAudits] check constraint [userAuditsUserAuditActions02ForeignKey0]
end
else
begin
   print 'Foreign key constraint userAuditsUserAuditActions02ForeignKey0 already exists for userAudits'
end
if not exists (select * from sys.foreign_keys where name = 'userAuditsUserAuditActionsForeignKey' and parent_object_id = object_id('[bypass].[userAudits]'))
begin
   print 'Creating foreign key constraint userAuditsUserAuditActionsForeignKey for userAudits'
   alter table [bypass].[userAudits] with check add constraint [userAuditsUserAuditActionsForeignKey] foreign key ([userAuditActionId]) references [bypass_static].[userAuditActions]([userAuditActionId])
   alter table [bypass].[userAudits] check constraint [userAuditsUserAuditActionsForeignKey]
end
else
begin
   print 'Foreign key constraint userAuditsUserAuditActionsForeignKey already exists for userAudits'
end
if not exists (select * from sys.foreign_keys where name = 'userAuditsUsers02ForeignKey' and parent_object_id = object_id('[bypass].[userAudits]'))
begin
   print 'Creating foreign key constraint userAuditsUsers02ForeignKey for userAudits'
   alter table [bypass].[userAudits] with check add constraint [userAuditsUsers02ForeignKey] foreign key ([affectedUserId]) references [bypass].[users]([userId])
   alter table [bypass].[userAudits] check constraint [userAuditsUsers02ForeignKey]
end
else
begin
   print 'Foreign key constraint userAuditsUsers02ForeignKey already exists for userAudits'
end
if not exists (select * from sys.foreign_keys where name = 'userAuditsUsersForeignKey' and parent_object_id = object_id('[bypass].[userAudits]'))
begin
   print 'Creating foreign key constraint userAuditsUsersForeignKey for userAudits'
   alter table [bypass].[userAudits] with check add constraint [userAuditsUsersForeignKey] foreign key ([performerUserId]) references [bypass].[users]([userId])
   alter table [bypass].[userAudits] check constraint [userAuditsUsersForeignKey]
end
else
begin
   print 'Foreign key constraint userAuditsUsersForeignKey already exists for userAudits'
end
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
-- TRIGGERS --
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
GO
/* drop table [bypass].[databaseConfiguration] */
if not exists(select * from sys.tables where name = 'databaseConfiguration' and schema_id = (select schema_id from sys.schemas where name = 'bypass'))
begin
   print 'Creating databaseConfiguration table'
   create table [bypass].[databaseConfiguration] (
      [TraceIvrSearch] bit NOT NULL CONSTRAINT [DF_databaseConfiguration_TraceIvrSearch] DEFAULT (0)
   ) on [PRIMARY]
end
else
begin
   print 'databaseConfiguration table already exists'
end
GO
/* drop table [bypass].[ivrSearchTrace] */
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
-- TABLE CREATION --
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
if not exists(select * from sys.tables where name = 'ivrSearchTrace' and schema_id = (select schema_id from sys.schemas where name = 'bypass'))
begin
   print 'Creating ivrSearchTrace table'
   create table [bypass].[ivrSearchTrace] (
      [ivrSearchTraceId] int not null identity (1,1),
      [dateAdded] datetime not null constraint [ivrSearchTraceDateAddedDefault] default (getdate()),
      [duration] int NOT NULL,
      --input params
      [appName] varchar(32),
      [language] varchar(32),
      [dnis] varchar(32),
      [destination] varchar(32),
      [rank] varchar(6),
      [offerId] varchar(8),
      [offerType] varchar(128),
      --output
      [bypassConfigurationId] int,
      [order] int
   ) on [PRIMARY]
end
else
begin
   print 'ivrSearchTrace table already exists'
end
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
-- NULL CONSTRAINTS --
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
if exists (select * from sys.columns where object_id = object_id('[bypass].[ivrSearchTrace]') and name = 'ivrSearchTraceId' and is_nullable=1)
begin
   print 'Converting column ivrSearchTraceId in ivrSearchTrace to disallow nulls'
   alter table [bypass].[ivrSearchTrace] alter column [ivrSearchTraceId] int not null
end
else
begin
   print '	Column ivrSearchTraceId already in ivrSearchTrace already disallows nulls'
end
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
-- DEFAULT CONSTRAINTS --
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
if exists (select * from sys.columns where object_id = object_id('[bypass].[ivrSearchTrace]') and name = 'dateAdded' and [default_object_id]=0)
begin
   print 'Creating default constraint on ivrSearchTrace.dateAdded'
   alter table [bypass].[ivrSearchTrace] add constraint [ivrSearchTraceDateAddedDefault] default (getdate()) for [dateAdded]
end
else
begin
   print 'Default constraint already exists for ivrSearchTrace.dateAdded'
end
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
-- CHECK CONSTRAINTS --
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
-- PRIMARY KEY / UNIQUE KEY CONSTRAINTS / INDEXES --
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
declare @idxExists bit = 0,
@idxIsUnique bit = 0,
@idxIsUniqueConstraint bit = 0,
@idxIsPKConstraint bit = 0,
@idxType tinyInt = NULL,
@idxIsClustered bit = 0,
@idxShouldBeUnique bit = 0,
@idxShouldBeUniqueConstraint bit = 0,
@idxShouldBePKConstraint bit = 0,
@idxShouldBeClustered bit = 0,
--the following are used for FKS when the object to be dropped is a PK or a unique constraint
@dropComm as varchar (max),
@addComm as varchar (max),
@addComm2 as varchar (max)
select @idxIsUnique=is_unique, @idxIsUniqueConstraint=is_unique_constraint, @idxIsPKConstraint=is_primary_key, @idxType=type from sys.indexes where object_id = object_id('[bypass].[ivrSearchTrace]') and name = 'ivrSearchTracePrimaryKey'
set @idxExists = case when @idxType is null then 0 else 1 end
set @idxIsClustered = case when @idxType = 1 then 1 else 0 end
set @idxIsUnique = isnull(@idxIsUnique, 0)
set @idxIsUniqueConstraint = isnull(@idxIsUniqueConstraint, 0)
set @idxIsPKConstraint = isnull(@idxIsPKConstraint, 0)
set @idxShouldBeUnique = 1
set @idxShouldBeUniqueConstraint = 0
set @idxShouldBePKConstraint = 1
set @idxShouldBeClustered = 1
if (@idxExists = 0)
begin
   print 'Creating PK constraint ivrSearchTracePrimaryKey on ivrSearchTrace'
   alter table [bypass].[ivrSearchTrace] add constraint [ivrSearchTracePrimaryKey] primary key clustered (
      [ivrSearchTraceId] ASC
   )
   with ( PAD_INDEX = OFF, ALLOW_PAGE_LOCKS = ON, ALLOW_ROW_LOCKS = ON, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, SORT_IN_TEMPDB = OFF ) on [PRIMARY]
end
else if ((@idxIsPKConstraint <> @idxShouldBePKConstraint) or
         (@idxIsUnique <> @idxShouldBeUnique) or
         (@idxIsUniqueConstraint <> @idxShouldBeUniqueConstraint) or
         (@idxIsClustered <> @idxShouldBeClustered))
begin
   print 'Recreating PK constraint ivrSearchTracePrimaryKey on ivrSearchTrace'
   if (@idxIsPKConstraint = 1 or @idxIsUniqueConstraint = 1)
   begin
      exec DropAddForeignKeys @tableName = 'ivrSearchTrace', @dropCommands = @dropComm OUTPUT, @addCommands = @addComm OUTPUT, @addCommands2 = @addComm2 OUTPUT
      exec(@dropComm)
   end
   alter table [bypass].[ivrSearchTrace] drop constraint [ivrSearchTracePrimaryKey]
   alter table [bypass].[ivrSearchTrace] add constraint [ivrSearchTracePrimaryKey] primary key clustered (
      [ivrSearchTraceId] ASC
   )
   with ( PAD_INDEX = OFF, ALLOW_PAGE_LOCKS = ON, ALLOW_ROW_LOCKS = ON, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, SORT_IN_TEMPDB = OFF ) on [PRIMARY]
   if ((@idxIsPKConstraint = 1 or @idxIsUniqueConstraint = 1) and (@idxShouldBePKConstraint = 1 or @idxShouldBeUniqueConstraint = 1) )
   begin
      exec(@addComm)
      exec(@addComm2)
   end
end
else
begin
   print '	PK constraint ivrSearchTracePrimaryKey already exists on ivrSearchTrace'
end
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
-- FOREIGN KEYS - ivrSearchTrace --
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
-- TRIGGERS --
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
GO
/* Stored procedures */
/* drop procedure GetLanguages */
if not exists (select * from sys.procedures where name = 'GetLanguages' and schema_name(schema_id) = 'bypass')
begin
   print 'Creating emtpy GetLanguages stored procedure'
   execute('create procedure [bypass].[GetLanguages] as select 1')
end
GO
print 'Altering stored procedure GetLanguages to latest version'
GO
alter procedure [bypass].[GetLanguages]
as
SELECT [languageId], [language] FROM [bypass].[languages]
GO
/* drop procedure GetApplications */
if not exists (select * from sys.procedures where name = 'GetApplications' and schema_name(schema_id) = 'bypass')
begin
   print 'Creating emtpy GetApplications stored procedure'
   execute('create procedure [bypass].[GetApplications] as select 1')
end
GO
print 'Altering stored procedure GetApplications to latest version'
GO
alter procedure [bypass].[GetApplications]
as
SELECT [applicationId], [application], [userIdAdd]
FROM [bypass].[applications]
GO
/* drop procedure AddApplication */
if not exists (select * from sys.procedures where name = 'AddApplication' and schema_name(schema_id) = 'bypass')
begin
   print 'Creating emtpy AddApplication stored procedure'
   execute('create procedure [bypass].[AddApplication] as select 1')
end
GO
print 'Altering stored procedure AddApplication to latest version'
GO
alter procedure [bypass].[AddApplication](@appname varchar(32), @userId int)
as
set nocount on
INSERT INTO [bypass].[applications] ([application], [userIdAdd]) VALUES (@appname, @userId)
SELECT [applicationId], [application], [userIdAdd]
FROM [bypass].[applications]
WHERE [application] = @appname
GO
/* drop procedure GetUser */
if not exists (select * from sys.procedures where name = 'GetUser' and schema_name(schema_id) = 'bypass')
begin
   print 'Creating emtpy GetUser stored procedure'
   execute('create procedure [bypass].[GetUser] as select 1')
end
GO
print 'Altering stored procedure GetUser to latest version'
GO
alter procedure [bypass].[GetUser](
 @userId int = null,
 @userName varchar(100) = null
)
as
if(@userId is not null)
begin
 SELECT [userId],
  [userName],
  [password],
  [deleted],
  [disabled],
  [isSuperAdmin],
  [isUsanUser],
  [lastLoginDate],
  [locked],
  [failedLoginAttempts],
  [lastPasswordChangeDate],
  [forceChangePassword],
  [dateAdded]
 FROM [bypass].[users] WHERE [userId] = @userId
end
else if(@userName is not null)
begin
 SELECT [userId],
  [userName],
  [password],
  [deleted],
  [disabled],
  [isSuperAdmin],
  [isUsanUser],
  [lastLoginDate],
  [locked],
  [failedLoginAttempts],
  [lastPasswordChangeDate],
  [forceChangePassword],
  [dateAdded]
 FROM [bypass].[users] WHERE [userName] = @username
end
GO
/* drop procedure GetUsers */
IF NOT EXISTS (
  SELECT *
  FROM sys.procedures
  WHERE name = 'GetUsers'
   AND schema_name(schema_id) = 'bypass'
  )
BEGIN
 PRINT 'Creating emtpy GetUsers stored procedure'
 EXECUTE ('create procedure [bypass].[GetUsers] as select 1')
END
GO
PRINT 'Altering stored procedure GetUsers to latest version'
GO
ALTER PROCEDURE [bypass].[GetUsers] (
 @userName VARCHAR(100)
 ,@deleted BIT
 ,@isUsanUser BIT
 ,@start INT
 ,@limit INT
 ,@sortOrder VARCHAR(100) = 'userName'
 ,@sortDir VARCHAR(10) = 'asc'
 )
AS
SET NOCOUNT ON
BEGIN
 DECLARE @systemUserId INT = - 1
 SELECT TOP (@limit) userId
  ,userName
  ,password
  ,deleted
  ,disabled
  ,isSuperAdmin
  ,isUsanUser
  ,locked
  ,forceChangePassword
  ,failedLoginAttempts
  ,lastPasswordChangeDate
  ,lastLoginDate
  ,RowNum
 FROM (
  SELECT userId
   ,userName
   ,password
   ,deleted
   ,disabled
   ,isSuperAdmin
   ,isUsanUser
   ,locked
   ,forceChangePassword
   ,failedLoginAttempts
   ,lastPasswordChangeDate
   ,lastLoginDate
   ,ROW_NUMBER() OVER (
    ORDER BY CASE
      WHEN @sortOrder = 'userName'
       AND @sortDir = 'asc'
       THEN userName
      END ASC
     ,CASE
      WHEN @sortOrder = 'userName'
       AND @sortDir = 'desc'
       THEN userName
      END DESC
     ,CASE
      WHEN @sortOrder = 'isSuperAdmin'
       AND @sortDir = 'asc'
       THEN isSuperAdmin
      END ASC
     ,CASE
      WHEN @sortOrder = 'isSuperAdmin'
       AND @sortDir = 'desc'
       THEN isSuperAdmin
      END DESC
     ,CASE
      WHEN @sortOrder = 'isUsanUser'
       AND @sortDir = 'asc'
       THEN isUsanUser
      END ASC
     ,CASE
      WHEN @sortOrder = 'isUsanUser'
       AND @sortDir = 'desc'
       THEN isUsanUser
      END DESC
     ,CASE
      WHEN @sortOrder = 'lastLoginDate'
       AND @sortDir = 'asc'
       THEN lastLoginDate
      END ASC
     ,CASE
      WHEN @sortOrder = 'lastLoginDate'
       AND @sortDir = 'desc'
       THEN lastLoginDate
      END DESC
    ) AS RowNum
  FROM (
   SELECT userId
    ,userName
    ,password
    ,deleted
    ,disabled
    ,isSuperAdmin
    ,isUsanUser
    ,locked
    ,forceChangePassword
    ,failedLoginAttempts
    ,lastPasswordChangeDate
    ,lastLoginDate
   FROM bypass.users AS users
   WHERE (
     @userName IS NULL
     OR userName LIKE '%' + @userName + '%'
     )
    AND -- Gets every user if there is no user specified in the params
    deleted = @deleted
    AND -- Specify whether we want deleted users to be shown as well since those are retained in the DB still for restoration
    isUsanUser = (
     CASE
      WHEN @isUsanUser = 1
       THEN isUsanUser
      ELSE 0
      END
     )
    AND -- Either gets all USAN users or only gets non-USAN users if not specified? Look like user cannot determine this value, so this might be a way to keep USAN users in DB but have them be hidden for customer.
    userId != @systemUserId -- Don't want to return SYSTEM user, should be hidden
   ) AS q1
  ) AS data
 WHERE data.RowNum > @start -- cutting off the first rows returned?
 ORDER BY CASE
   WHEN @sortOrder = 'userName'
    AND @sortDir = 'asc'
    THEN userName
   END ASC
  ,CASE
   WHEN @sortOrder = 'userName'
    AND @sortDir = 'desc'
    THEN userName
   END DESC
  ,CASE
   WHEN @sortOrder = 'isSuperAdmin'
    AND @sortDir = 'asc'
    THEN isSuperAdmin
   END ASC
  ,CASE
   WHEN @sortOrder = 'isSuperAdmin'
    AND @sortDir = 'desc'
    THEN isSuperAdmin
   END DESC
  ,CASE
   WHEN @sortOrder = 'isUsanUser'
    AND @sortDir = 'asc'
    THEN isUsanUser
   END ASC
  ,CASE
   WHEN @sortOrder = 'isUsanUser'
    AND @sortDir = 'desc'
    THEN isUsanUser
   END DESC
  ,CASE
   WHEN @sortOrder = 'lastLoginDate'
    AND @sortDir = 'asc'
    THEN lastLoginDate
   END ASC
  ,CASE
   WHEN @sortOrder = 'lastLoginDate'
    AND @sortDir = 'desc'
    THEN lastLoginDate
   END DESC
 RETURN
END
GO
/* drop procedure GetUsersCount */
if not exists (select * from sys.procedures where name = 'GetUsersCount' and schema_name(schema_id) = 'bypass')
begin
   print 'Creating emtpy GetUsersCount stored procedure'
   execute('create procedure [bypass].[GetUsersCount] as select 1')
end
GO
print 'Altering stored procedure GetUsersCount to latest version'
GO
ALTER PROCEDURE [bypass].[GetUsersCount] (
 @userName VARCHAR(100)
 ,@deleted BIT
 ,@isUsanUser BIT
 )
AS
SET NOCOUNT ON
BEGIN
 DECLARE @systemUserId INT = - 1
 SELECT count(*) AS userCount
 FROM bypass.users AS users
 WHERE userName = (
   CASE
    WHEN @userName IS NULL
     THEN userName
    ELSE @userName
    END
   )
  AND deleted = @deleted
  AND isUsanUser = (
   CASE
    WHEN @isUsanUser = 1
     THEN isUsanUser
    ELSE 0
    END
   )
  AND userId != @systemUserId
END
GO
/* drop procedure AddUser */
if not exists (select * from sys.procedures where name = 'AddUser' and schema_name(schema_id) = 'bypass')
begin
   print 'Creating emtpy AddUser stored procedure'
   execute('create procedure [bypass].[AddUser] as select 1')
end
GO
print 'Altering stored procedure AddUser to latest version'
GO
alter procedure [bypass].[AddUser](
 @username as varchar(100),
 @pwd as varchar(256)
)
as
set nocount on
INSERT INTO [bypass].[users] ([userName], [password]) VALUES (@username, @pwd)
EXECUTE [bypass].[GetUser] NULL, @username
GO
/* drop procedure UpdateUser */
if not exists (select * from sys.procedures where name = 'UpdateUser' and schema_name(schema_id) = 'bypass')
begin
   print 'Creating emtpy UpdateUser stored procedure'
   execute('create procedure [bypass].[UpdateUser] as select 1')
end
GO
print 'Altering stored procedure UpdateUser to latest version'
GO
alter procedure [bypass].[UpdateUser](
 @userId int,
 @pwd as varchar(256) = null,
 @delete bit = null,
 @disable bit = null,
 @isSuperAdmin bit = null,
 @isUsanUser bit = null,
 @locked bit = null,
 @forceChangePassword bit = null,
 @failedLoginAttempts int = null,
 @lastLoginDate datetime = null
)
as
set nocount on
UPDATE [bypass].[users]
SET [password] = (case when @pwd is not null then @pwd else [password] end),
 [deleted] = (case when @delete is not null then @delete else [deleted] end),
 [disabled] = (case when @disable is not null then @disable else [disabled] end),
 [isSuperAdmin] = (case when @isSuperAdmin is not null then @isSuperAdmin else [isSuperAdmin] end),
 [isUsanUser] = (case when @isUsanUser is not null then @isUsanUser else [isUsanUser] end),
 [locked] = (case when @locked is not null then @locked else [locked] end),
 [forceChangePassword] =
  (case when @forceChangePassword is not null then @forceChangePassword
   when @pwd is not null then 0
   else [forceChangePassword] end),
 [lastPasswordChangeDate] = (case when @pwd is not null then getdate() else [lastPasswordChangeDate] end),
 [failedLoginAttempts] = (case when @failedLoginAttempts is not null then @failedLoginAttempts else [failedLoginAttempts] end),
 [lastLoginDate] = (
        CASE
            WHEN @lastLoginDate = '1753-01-01 00:00:00.000' THEN GETDATE() -- Special placeholder that tells us to get the current date
            WHEN @lastLoginDate IS NULL THEN [lastLoginDate]
            ELSE @lastLoginDate
        END
    )
WHERE [userId] = @userId
EXECUTE [bypass].[GetUser] @userId
GO
/* drop procedure AddUserRole */
if not exists (select * from sys.procedures where name = 'AddUserRole' and schema_name(schema_id) = 'bypass')
begin
   print 'Creating emtpy AddUserRole stored procedure'
   execute('create procedure [bypass].[AddUserRole] as select 1')
end
GO
print 'Altering stored procedure AddUserRole to latest version'
GO
alter procedure [bypass].[AddUserRole](
 @userId int,
 @roleId int,
 @applicationId int
)
as
INSERT INTO [bypass].[userRoles] ([userId], [roleId], [applicationId])
 VALUES(@userId, @roleId, @applicationId)
GO
/* drop procedure RemoveUserRole */
if not exists (select * from sys.procedures where name = 'RemoveUserRole' and schema_name(schema_id) = 'bypass')
begin
   print 'Creating emtpy RemoveUserRole stored procedure'
   execute('create procedure [bypass].[RemoveUserRole] as select 1')
end
GO
print 'Altering stored procedure RemoveUserRole to latest version'
GO
ALTER procedure [bypass].[RemoveUserRole](
 @userId int,
 @roldId int,
 @applicationId int
)
as
DELETE FROM [bypass].[userRoles]
WHERE [userId] = @userId
 AND [roleId] = @roldId
 AND [applicationId] = @applicationId
GO
/* drop procedure UpdateUserRoles */
if not exists (select * from sys.procedures where name = 'UpdateUserRoles' and schema_name(schema_id) = 'bypass')
begin
   print 'Creating emtpy UpdateUserRoles stored procedure'
   execute('create procedure [bypass].[UpdateUserRoles] as select 1')
end
GO
print 'Altering stored procedure UpdateUserRoles to latest version'
GO
ALTER PROCEDURE [bypass].[UpdateUserRoles] (
 @userId INT
 ,@applicationName VARCHAR(100)
 ,@accessLevelRead BIT
 ,@accessLevelEdit BIT
 ,@accessLevelAdmin BIT
 ,@accessLevelNone BIT
 )
AS
BEGIN
 BEGIN TRANSACTION
 DECLARE @readStr VARCHAR(10) = 'View'
 DECLARE @editStr VARCHAR(10) = 'Edit'
 DECLARE @adminStr VARCHAR(20) = 'Update Users'
 DECLARE @applicationId INT = (
   SELECT applicationId
   FROM bypass.applications AS applications
   WHERE applications.application = @applicationName
   )
 DECLARE @readRoleId INT = (
   SELECT roleId
   FROM bypass.roles AS roles
   WHERE roles.name = @readStr
   )
 DECLARE @editRoleId INT = (
   SELECT roleId
   FROM bypass.roles AS roles
   WHERE roles.name = @editStr
   )
 DECLARE @adminRoleId INT = (
   SELECT roleId
   FROM bypass.roles AS roles
   WHERE roles.name = @adminStr
   )
 DECLARE @exisitingReadRoleId INT = (
   SELECT roleId
   FROM bypass.userRoles AS ur
   WHERE ur.userId = @userId
    AND ur.applicationId = @applicationId
    AND roleId = @readRoleId
   )
 DECLARE @exisitingEditRoleId INT = (
   SELECT roleId
   FROM bypass.userRoles AS ur
   WHERE ur.userId = @userId
    AND ur.applicationId = @applicationId
    AND roleId = @editRoleId
   )
 DECLARE @exisitingAdminRoleId INT = (
   SELECT roleId
   FROM bypass.userRoles AS ur
   WHERE ur.userId = @userId
    AND ur.applicationId = @applicationId
    AND roleId = @adminRoleId
   )
 IF @accessLevelNone = 1
 BEGIN
  DELETE
  FROM bypass.userRoles
  WHERE userId = @userId
   AND applicationId = @applicationId
   AND roleId IN (
    @readRoleId
    ,@editRoleId
    ,@adminRoleId
    )
 END
 ELSE
 BEGIN
  IF @exisitingReadRoleId IS NULL
   AND @accessLevelRead = 1
  BEGIN
   INSERT INTO bypass.userRoles (
    userId
    ,applicationId
    ,roleId
    )
   VALUES (
    @userId
    ,@applicationId
    ,@readRoleId
    )
  END
  ELSE IF @accessLevelRead = 0
  BEGIN
   DELETE
   FROM bypass.userRoles
   WHERE userId = @userId
    AND applicationId = @applicationId
    AND roleId = @readRoleId
  END
  IF @exisitingEditRoleId IS NULL
   AND @accessLevelEdit = 1
  BEGIN
   INSERT INTO bypass.userRoles (
    userId
    ,applicationId
    ,roleId
    )
   VALUES (
    @userId
    ,@applicationId
    ,@editRoleId
    )
  END
  ELSE IF @accessLevelEdit = 0
  BEGIN
   DELETE
   FROM bypass.userRoles
   WHERE userId = @userId
    AND applicationId = @applicationId
    AND roleId = @editRoleId
  END
  IF @exisitingAdminRoleId IS NULL
   AND @accessLevelAdmin = 1
  BEGIN
   INSERT INTO bypass.userRoles (
    userId
    ,applicationId
    ,roleId
    )
   VALUES (
    @userId
    ,@applicationId
    ,@adminRoleId
    )
  END
  ELSE IF @accessLevelAdmin = 0
  BEGIN
   DELETE
   FROM bypass.userRoles
   WHERE userId = @userId
    AND applicationId = @applicationId
    AND roleId = @adminRoleId
  END
 END
 COMMIT
END
GO
/* drop procedure GetUserRoles */
IF NOT EXISTS (
  SELECT *
  FROM sys.procedures
  WHERE name = 'GetUserRoles'
   AND schema_name(schema_id) = 'bypass'
  )
BEGIN
 PRINT 'Creating emtpy GetUserRoles stored procedure'
 EXECUTE ('create procedure [bypass].[GetUserRoles] as select 1')
END
GO
PRINT 'Altering stored procedure GetUserRoles to latest version'
GO
ALTER PROCEDURE [bypass].[GetUserRoles] (@userId INT)
AS
BEGIN
 SELECT users.userId
  ,application
  ,roles
 FROM bypass.applications AS apps
 LEFT JOIN bypass.[GetRolesByUserId](@userId) AS fnUser ON apps.applicationId = fnUser.applicationId
 LEFT JOIN bypass.users AS users ON users.userId = @userId
END
GO
/* drop function GetRolesByUserId */
IF NOT EXISTS (
  SELECT *
  FROM sys.objects
  WHERE name = 'GetRolesByUserId'
   AND schema_name(schema_id) = 'bypass'
  )
BEGIN
 PRINT 'Creating emtpy GetRolesByUserId function'
 EXECUTE ('CREATE FUNCTION [bypass].[GetRolesByUserId] (@userId INT) RETURNS TABLE AS RETURN (SELECT 1 AS placeholder)')
END
GO
PRINT 'Altering function GetRolesByUserId to latest version'
GO
ALTER FUNCTION [bypass].[GetRolesByUserId] (@userId INT)
RETURNS TABLE
AS
RETURN
SELECT a.userid
 ,a.applicationid
 ,roles = STUFF((
   SELECT ',' + y.name
   FROM bypass.userRoles x
   JOIN bypass.roles y ON x.roleid = y.roleid
   WHERE x.userid = a.userid
    AND x.applicationId = a.applicationId
   FOR XML PATH('')
   ), 1, 1, '')
FROM bypass.userRoles a
JOIN bypass.roles b ON a.roleId = b.roleId
JOIN bypass.applications c ON a.applicationId = c.applicationId
WHERE userId = @userId
GROUP BY a.userid
 ,a.applicationid
GO
/* drop procedure AddConfiguration */
if not exists (select * from sys.procedures where name = 'AddConfiguration' and schema_name(schema_id) = 'bypass')
begin
   print 'Creating emtpy AddConfiguration stored procedure'
   execute('create procedure [bypass].[AddConfiguration] as select 1')
end
GO
print 'Altering stored procedure AddConfiguration to latest version'
GO
ALTER PROCEDURE [bypass].[AddConfiguration] (
 @applicationName VARCHAR(32),
 @languageName VARCHAR(32),
 @dnis VARCHAR(32),
 @destination VARCHAR(32),
 @rank VARCHAR(6),
 @offerId VARCHAR(8),
 @offerType VARCHAR(128),
 @peg VARCHAR(128),
 @skillId VARCHAR(16),
 @skillName VARCHAR(64),
 @agentsAvailable INT,
 @med INT,
 @overflowSkillId VARCHAR(16),
 @overflowSkillName VARCHAR(64),
 @overflowAgentsAvailable INT,
 @overflowMed INT,
 @lastModifiedUserName VARCHAR(32),
 @order INT
)
AS
BEGIN
 SET NOCOUNT ON;
 -- Declare and populate IDs
 DECLARE @applicationId INT,
   @languageId INT,
   @lastModifiedUserId INT;
 SELECT @applicationId = applicationId
 FROM bypass.applications
 WHERE application = @applicationName;
 SELECT @languageId = languageId
 FROM bypass.languages
 WHERE language = @languageName;
 SELECT @lastModifiedUserId = userId
 FROM bypass.users
 WHERE userName = @lastModifiedUserName;
 -- Set order if not provided
 IF (@order IS NULL)
 BEGIN
  SET @order = ISNULL((
   SELECT MAX([order]) + 1
   FROM [bypass].[configurations]
   WHERE [applicationId] = @applicationId
  ), 1);
 END
 -- Insert configuration
 INSERT INTO [bypass].[configurations] (
  [applicationId],
  [languageId],
  [dnis],
  [destination],
  [rank],
  [offerId],
  [offerType],
  [peg],
  [skillId],
  [skillName],
  [agentsAvailable],
  [med],
  [overflowSkillId],
  [overflowSkillName],
  [overflowAgentsAvailable],
  [overflowMed],
  [lastModifiedUserId],
  [order]
 )
 VALUES (
  @applicationId,
  @languageId,
  @dnis,
  @destination,
  @rank,
  @offerId,
  @offerType,
  @peg,
  @skillId,
  @skillName,
  @agentsAvailable,
  @med,
  @overflowSkillId,
  @overflowSkillName,
  @overflowAgentsAvailable,
  @overflowMed,
  @lastModifiedUserId,
  @order
 );
 -- Return the newly inserted configuration
 SELECT
  [bypassConfigurationId],
  [order],
  [apps].[applicationId],
  [apps].[application],
  [langs].[languageId],
  [langs].[language],
  [dnis],
  [destination],
  [rank],
  [peg],
  [offerId],
  [offerType],
  [skillId],
  [skillName],
  [agentsAvailable],
  [med],
  [overflowSkillId],
  [overflowSkillName],
  [overflowAgentsAvailable],
  [overflowMed],
  [lastModifiedUserId],
  [lastModifiedDateTime]
 FROM [bypass].[configurations] AS [configs]
 JOIN [bypass].[applications] AS [apps] ON [apps].[applicationId] = [configs].[applicationId]
 JOIN [bypass].[languages] AS [langs] ON [langs].[languageId] = [configs].[languageId]
 WHERE [configs].[applicationId] = @applicationId
  AND [configs].[languageId] = @languageId
  AND [configs].[dnis] = @dnis
  AND [configs].[destination] = @destination
  AND [configs].[rank] = @rank
  AND [configs].[offerId] = @offerId
  AND [configs].[offerType] = @offerType
  AND [configs].[peg] = @peg
  AND [configs].[skillId] = @skillId
  AND [configs].[skillName] = @skillName
  AND [configs].[agentsAvailable] = @agentsAvailable
  AND [configs].[med] = @med
  AND [configs].[overflowSkillId] = @overflowSkillId
  AND [configs].[overflowSkillName] = @overflowSkillName
  AND [configs].[overflowAgentsAvailable] = @overflowAgentsAvailable
  AND [configs].[overflowMed] = @overflowMed
  AND [configs].[lastModifiedUserId] = @lastModifiedUserId;
END
GO
/* drop procedure UpdateConfiguration */
if not exists (select * from sys.procedures where name = 'UpdateConfiguration' and schema_name(schema_id) = 'bypass')
begin
   print 'Creating emtpy UpdateConfiguration stored procedure'
   execute('create procedure [bypass].[UpdateConfiguration] as select 1')
end
GO
print 'Altering stored procedure UpdateConfiguration to latest version'
GO
ALTER PROCEDURE [bypass].[UpdateConfiguration] (
 @configurationId INT
 ,@applicationName VARCHAR(32)
 ,@languageName VARCHAR(32)
 ,@dnis VARCHAR(32)
 ,@destination VARCHAR(32)
 ,@rank VARCHAR(6)
 ,@offerId VARCHAR(8)
 ,@offerType VARCHAR(128)
 ,@peg VARCHAR(128)
 ,@skillId VARCHAR(16)
 ,@skillName VARCHAR(64)
 ,@agentsAvailable INT
 ,@med INT
 ,@overflowSkillId VARCHAR(16)
 ,@overflowSkillName VARCHAR(64)
 ,@overflowAgentsAvailable INT
 ,@overflowMed INT
 ,@lastModifiedUserName VARCHAR(32)
 ,@order INT = NULL
 )
AS
BEGIN
 SET NOCOUNT ON;
 -- Declare and populate IDs
 DECLARE @applicationId INT
  ,@languageId INT
  ,@lastModifiedUserId INT;
 SELECT @applicationId = applicationId
 FROM bypass.applications
 WHERE application = @applicationName;
 SELECT @languageId = languageId
 FROM bypass.languages
 WHERE LANGUAGE = @languageName;
 SELECT @lastModifiedUserId = userId
 FROM bypass.users
 WHERE userName = @lastModifiedUserName;
 -- Keep order number as is if not specified
 SET @order = ISNULL((
    SELECT [order]
    FROM [bypass].[configurations]
    WHERE [bypassConfigurationId] = @configurationId
    ), @order);
 -- Update configuration
 UPDATE [bypass].[configurations]
 SET [applicationId] = @applicationId
  ,[languageId] = @languageId
  ,[dnis] = @dnis
  ,[destination] = @destination
  ,[rank] = @rank
  ,[offerId] = @offerId
  ,[offerType] = @offerType
  ,[peg] = @peg
  ,[skillId] = @skillId
  ,[skillName] = @skillName
  ,[agentsAvailable] = @agentsAvailable
  ,[med] = @med
  ,[overflowSkillId] = @overflowSkillId
  ,[overflowSkillName] = @overflowSkillName
  ,[overflowAgentsAvailable] = @overflowAgentsAvailable
  ,[overflowMed] = @overflowMed
  ,[lastModifiedUserId] = @lastModifiedUserId
  ,[lastModifiedDateTime] = GETDATE()
  ,[order] = @order
 WHERE [bypassConfigurationId] = @configurationId;
 -- Return the updated configuration
 SELECT configs.[bypassConfigurationId]
  ,configs.[order]
  ,apps.[applicationId]
  ,apps.[application]
  ,langs.[languageId]
  ,langs.[language]
  ,configs.[dnis]
  ,configs.[destination]
  ,configs.[rank]
  ,configs.[peg]
  ,configs.[offerId]
  ,configs.[offerType]
  ,configs.[skillId]
  ,configs.[skillName]
  ,configs.[agentsAvailable]
  ,configs.[med]
  ,configs.[overflowSkillId]
  ,configs.[overflowSkillName]
  ,configs.[overflowAgentsAvailable]
  ,configs.[overflowMed]
  ,configs.[lastModifiedUserId]
  ,configs.[lastModifiedDateTime]
 FROM [bypass].[configurations] AS configs
 JOIN [bypass].[applications] AS apps ON apps.[applicationId] = configs.[applicationId]
 JOIN [bypass].[languages] AS langs ON langs.[languageId] = configs.[languageId]
 WHERE configs.[bypassConfigurationId] = @configurationId;
END
GO
/* drop procedure RemoveConfiguration */
if not exists (select * from sys.procedures where name = 'RemoveConfiguration' and schema_name(schema_id) = 'bypass')
begin
   print 'Creating emtpy RemoveConfiguration stored procedure'
   execute('create procedure [bypass].[RemoveConfiguration] as select 1')
end
GO
print 'Altering stored procedure RemoveConfiguration to latest version'
GO
ALTER PROCEDURE [bypass].[RemoveConfiguration] (
 @bypassConfigurationId INT
)
AS
BEGIN
 SET NOCOUNT ON;
 -- Optional: output the record before deletion
 SELECT [bypassConfigurationId]
  ,[order]
  ,[applicationId]
  ,[languageId]
  ,[dnis]
  ,[destination]
  ,[rank]
  ,[offerId]
  ,[offerType]
  ,[peg]
  ,[skillId]
  ,[skillName]
  ,[agentsAvailable]
  ,[med]
  ,[overflowSkillId]
  ,[overflowSkillName]
  ,[overflowAgentsAvailable]
  ,[overflowMed]
  ,[lastModifiedUserId]
  ,[lastModifiedDateTime]
 INTO #DeletedConfig
 FROM [bypass].[configurations]
 WHERE [bypassConfigurationId] = @bypassConfigurationId;
 -- Delete the configuration
 DELETE FROM [bypass].[configurations]
 WHERE [bypassConfigurationId] = @bypassConfigurationId;
 -- Return the deleted row (if needed)
 SELECT * FROM #DeletedConfig;
 DROP TABLE #DeletedConfig;
END
GO
/* drop procedure GetConfigurations */
if not exists (select * from sys.procedures where name = 'GetConfigurations' and schema_name(schema_id) = 'bypass')
begin
   print 'Creating emtpy GetConfigurations stored procedure'
   execute('create procedure [bypass].[GetConfigurations] as select 1')
end
GO
print 'Altering stored procedure GetConfigurations to latest version'
GO
ALTER PROCEDURE [bypass].[GetConfigurations] (
 @userName VARCHAR(64)
 ,@application VARCHAR(64) = NULL
 ,@language VARCHAR(64) = NULL
 ,@dnis VARCHAR(64) = NULL
 ,@destinationPhoneNumber VARCHAR(64) = NULL
 ,@peg VARCHAR(64) = NULL
 ,@rank VARCHAR(64) = NULL
 ,@offerID VARCHAR(64) = NULL
 ,@offerType VARCHAR(64) = NULL
 ,@lastModifiedBy VARCHAR(64) = NULL
 ,@lastModifiedDate DATETIME = NULL
 )
AS
SELECT [bypassConfigurationId]
 ,[order]
 ,[apps].[applicationId]
 ,[apps].[application]
 ,[langs].[languageId]
 ,[langs].[language]
 ,[dnis]
 ,[destination]
 ,[rank]
 ,[offerId]
 ,[offerType]
 ,[peg]
 ,[skillId]
 ,[skillName]
 ,[agentsAvailable]
 ,[med]
 ,[overflowSkillId]
 ,[overflowSkillName]
 ,[overflowAgentsAvailable]
 ,[overflowMed]
 ,[lastModifiedUserId]
 ,(
  SELECT [userName]
  FROM [bypass].[users]
  WHERE [users].[userId] = [lastModifiedUserId]
  ) AS [lastModifiedUserName] -- For getting last modified userId, not the user id of the user calling this SP
 ,[lastModifiedDateTime]
FROM [bypass].[configurations] AS [configs]
JOIN [bypass].[applications] AS [apps] ON [apps].[applicationId] = [configs].[applicationId]
LEFT JOIN [bypass].[languages] AS [langs] ON [langs].[languageId] = [configs].[languageId]
JOIN [bypass].[users] AS [users] ON [users].[userName] = @userName
WHERE [configs].[applicationId] IN (
  SELECT [applicationId]
  FROM [bypass].[userRoles] AS ur
  WHERE ur.[userId] = [users].[userId] -- Use the joined UserID
  )
 AND (
  @application IS NULL
  OR [apps].[application] = @application
  )
 AND (
  @language IS NULL
  OR [langs].[language] = @language
  )
 AND (
  @dnis IS NULL
  OR [configs].[dnis] LIKE '%' + @dnis + '%'
  )
 AND (
  @destinationPhoneNumber IS NULL
  OR [configs].[destination] LIKE '%' + @destinationPhoneNumber + '%'
  )
 AND (
  @peg IS NULL
  OR [configs].[peg] LIKE '%' + @peg + '%'
  )
 AND (
  @rank IS NULL
  OR [configs].[rank] LIKE '%' + @rank + '%'
  )
 AND (
  @offerID IS NULL
  OR [configs].[offerId] LIKE '%' + @offerID + '%'
  )
 AND (
  @offerType IS NULL
  OR [configs].[offerType] LIKE '%' + @offerType + '%'
  )
 AND (
  @lastModifiedBy IS NULL
  OR (
   SELECT userName
   FROM bypass.users
   WHERE userId = configs.lastModifiedUserId
   ) LIKE '%' + @lastModifiedBy + '%'
  )
 AND (
  @lastModifiedDate IS NULL
  OR CAST([configs].[lastModifiedDateTime] AS DATE) = CAST(@lastModifiedDate AS DATE)
  )
ORDER BY [apps].[applicationId]
 ,[order] ASC;
GO
IF TYPE_ID(N'bypass.ConfigurationOrderList') IS NULL
BEGIN
    CREATE TYPE [bypass].[ConfigurationOrderList] AS TABLE(
        [configurationId] [int] NULL,
        [order] [int] NULL
    )
    PRINT 'User-defined table type [bypass].[ConfigurationOrderList] created successfully.'
END
ELSE
BEGIN
    PRINT 'User-defined table type [bypass].[ConfigurationOrderList] already exists. No action taken.'
END
GO
/* drop procedure UpdateConfigurationOrder */
if not exists (select * from sys.procedures where name = 'UpdateConfigurationOrder' and schema_name(schema_id) = 'bypass')
begin
   print 'Creating emtpy UpdateConfigurationOrder stored procedure'
   execute('create procedure [bypass].[UpdateConfigurationOrder] as select 1')
end
GO
print 'Altering stored procedure UpdateConfigurationOrder to latest version'
GO
ALTER PROCEDURE [bypass].[UpdateConfigurationOrder] (@ConfigurationOrderList bypass.ConfigurationOrderList READONLY)
AS
BEGIN
 SET NOCOUNT ON;
 WITH Numbered
 AS (
  SELECT configurationId
   ,ROW_NUMBER() OVER (
    ORDER BY configurationId
    ) AS rowNumber
  FROM @ConfigurationOrderList
  )
  ,MaxOrder
 AS (
  SELECT MAX([order]) AS maxOrder
  FROM [bypass].[configurations]
  )
 -- Change the orders of the rows to be updated laters to a new current max value because of unique order constraint
 UPDATE configs
 SET [configs].[order] = maxOrder + rowNumber + 1
 FROM [bypass].[configurations] configs
 JOIN Numbered numbered ON configs.bypassConfigurationId = numbered.configurationId
 CROSS JOIN MaxOrder
 -- Update configurations based on the list
 UPDATE configs
 SET configs.[order] = col.[order]
 FROM [bypass].[configurations] configs
 INNER JOIN @ConfigurationOrderList col ON configs.[bypassConfigurationId] = col.configurationId;
END
GO
/* drop procedure AddUserAudit */
IF NOT EXISTS (
  SELECT *
  FROM sys.procedures
  WHERE name = 'AddUserAudit'
   AND schema_name(schema_id) = 'bypass'
  )
BEGIN
 PRINT 'Creating emtpy AddUserAudit stored procedure'
 EXECUTE ('create procedure [bypass].[AddUserAudit] as select 1')
END
GO
PRINT 'Altering stored procedure AddUserAudit to latest version'
GO
ALTER PROCEDURE [bypass].[AddUserAudit] (
 @performerUserId INT
 ,@affectedUserId INT
 ,@userAuditActionId TINYINT
 ,@beforeValue AS VARCHAR(256) = NULL
 ,@afterValue AS VARCHAR(256) = NULL
 )
AS
BEGIN
 SET NOCOUNT ON;
 INSERT INTO [bypass].[UserAudits] (
  PerformerUserId
  ,AffectedUserId
  ,UserAuditActionId
  ,BeforeValue
  ,AfterValue
  )
 VALUES (
  @performerUserId
  ,@affectedUserId
  ,@userAuditActionId
  ,@beforeValue
  ,@afterValue
  );
END;
GO
/* drop procedure GetUserAuditHistoryCount */
if not exists (select * from sys.procedures where name = 'GetUserAuditHistoryCount' and schema_name(schema_id) = 'bypass')
begin
   print 'Creating emtpy GetUserAuditHistoryCount stored procedure'
   execute('create procedure [bypass].[GetUserAuditHistoryCount] as select 1')
end
GO
print 'Altering stored procedure GetUserAuditHistoryCount to latest version'
GO
ALTER PROCEDURE [bypass].[GetUserAuditHistoryCount] (
 @affectedUserName VARCHAR(100)
 ,@performerUserName VARCHAR(100)
 ,@userAuditActionName VARCHAR(100)
 ,@startDate DATETIME
 ,@endDate DATETIME
 ,@isUsanUser INT
 )
AS
SET NOCOUNT ON
BEGIN
 IF @isUsanUser = 1
 BEGIN
  SELECT count(*) AS historyCount
  FROM bypass.[userAudits] AS userAudits
  LEFT OUTER JOIN bypass.users AS performerUser ON performerUser.userId = userAudits.performerUserId
  LEFT OUTER JOIN bypass.users AS affectedUser ON affectedUser.userId = userAudits.affectedUserId
  JOIN bypass_static.userAuditActions ON bypass_static.userAuditActions.userAuditActionId = userAudits.userAuditActionId
  WHERE (
    @affectedUserName IS NULL
    OR affectedUser.userName LIKE '%' + @affectedUserName + '%'
    )
   AND (
    @performerUserName IS NULL
    OR performerUser.userName LIKE '%' + @performerUserName + '%'
    )
   AND (
    @userAuditActionName IS NULL
    OR auditDescription LIKE '%' + @userAuditActionName + '%'
    )
   AND (
    auditDate <= (
     CASE
      WHEN @endDate = ''
       THEN GETDATE()
      ELSE @endDate
      END
     )
    AND auditDate > (
     CASE
      WHEN @startDate = ''
       THEN '1970-01-01'
      ELSE @startDate
      END
     )
    )
   AND afterValue != 'Failed Login'
 END
 ELSE
 BEGIN
  SELECT count(*) AS historyCount
  FROM bypass.[userAudits]
  LEFT OUTER JOIN bypass.users AS performerUser ON performerUser.userId = userAudits.performerUserId
  LEFT OUTER JOIN bypass.users AS affectedUser ON affectedUser.userId = userAudits.affectedUserId
  JOIN bypass_static.userAuditActions ON bypass_static.userAuditActions.userAuditActionId = userAudits.userAuditActionId
  WHERE (
    @affectedUserName IS NULL
    OR affectedUser.userName LIKE '%' + @affectedUserName + '%'
    )
   AND (
    @performerUserName IS NULL
    OR performerUser.userName LIKE '%' + @performerUserName + '%'
    )
   AND (
    @userAuditActionName IS NULL
    OR auditDescription LIKE '%' + @userAuditActionName + '%'
    )
   AND (
    auditDate <= (
     CASE
      WHEN @endDate = ''
       THEN GETDATE()
      ELSE @endDate
      END
     )
    AND auditDate > (
     CASE
      WHEN @startDate = ''
       THEN '1970-01-01'
      ELSE @startDate
      END
     )
    )
   AND (
    performerUser.isUsanUser = 0
    OR performerUserId IS NULL
    )
   AND (
    affectedUser.isUsanUser = 0
    OR affectedUserId IS NULL
    )
   AND afterValue != 'Failed Login'
 END
END
GO
/* drop procedure GetUserAuditHistory */
if not exists (select * from sys.procedures where name = 'GetUserAuditHistory' and schema_name(schema_id) = 'bypass')
begin
   print 'Creating emtpy GetUserAuditHistory stored procedure'
   execute('create procedure [bypass].[GetUserAuditHistory] as select 1')
end
GO
print 'Altering stored procedure GetUserAuditHistory to latest version'
GO
ALTER PROCEDURE [bypass].[GetUserAuditHistory] (
 @start INT
 ,@limit INT
 ,@affectedUserName VARCHAR(100)
 ,@performerUserName VARCHAR(100)
 ,@userAuditActionName VARCHAR(100)
 ,@startDate DATETIME
 ,@endDate DATETIME
 ,@isUsanUser INT
 ,@sortOrder VARCHAR(100) = 'auditDate'
 ,@sortDir VARCHAR(10) = 'asc'
 )
AS
SET NOCOUNT ON
BEGIN
 IF @isUsanUser = 1
 BEGIN
  SELECT TOP (@limit) *
  FROM (
   SELECT userAuditId
    ,auditDate
    ,performerUserId
    ,performerUserName
    ,affectedUserId
    ,affectedUserName
    ,userAuditActionId
    ,auditDescription
    ,afterValue
    ,ROW_NUMBER() OVER (
     ORDER BY CASE
       WHEN @sortOrder = 'auditDate'
        AND @sortDir = 'asc'
        THEN auditDate
       END ASC
      ,CASE
       WHEN @sortOrder = 'auditDate'
        AND @sortDir = 'desc'
        THEN auditDate
       END DESC
      ,CASE
       WHEN @sortOrder = 'performerUserId'
        AND @sortDir = 'asc'
        THEN performerUserId
       END ASC
      ,CASE
       WHEN @sortOrder = 'performerUserId'
        AND @sortDir = 'desc'
        THEN performerUserId
       END DESC
      ,CASE
       WHEN @sortOrder = 'affectedUserId'
        AND @sortDir = 'asc'
        THEN affectedUserId
       END ASC
      ,CASE
       WHEN @sortOrder = 'affectedUserId'
        AND @sortDir = 'desc'
        THEN affectedUserId
       END DESC
      ,CASE
       WHEN @sortOrder = 'auditDescription'
        AND @sortDir = 'asc'
        THEN auditDescription
       END ASC
      ,CASE
       WHEN @sortOrder = 'auditDescription'
        AND @sortDir = 'desc'
        THEN auditDescription
       END DESC
     ) AS RowNum
   FROM (
    SELECT userAuditId
     ,auditDate
     ,performerUserId
     ,performerUser.userName AS performerUserName
     ,affectedUserId
     ,affectedUser.userName AS affectedUserName
     ,userAudits.userAuditActionId
     ,auditDescription
     ,afterValue
    FROM bypass.userAudits AS userAudits
    JOIN bypass_static.userAuditActions ON bypass_static.userAuditActions.userAuditActionId = userAudits.userAuditActionId
    LEFT OUTER JOIN bypass.users AS performerUser ON performerUser.userId = performerUserId
    LEFT OUTER JOIN bypass.users AS affectedUser ON affectedUser.userId = affectedUserId
    WHERE (
      @affectedUserName IS NULL
      OR affectedUser.userName LIKE '%' + @affectedUserName + '%'
      )
     AND (
      @performerUserName IS NULL
      OR performerUser.userName LIKE '%' + @performerUserName + '%'
      )
     AND (
      @userAuditActionName IS NULL
      OR auditDescription LIKE '%' + @userAuditActionName + '%'
      )
     AND (
      auditDate <= (
       CASE
        WHEN @endDate = ''
         THEN GETDATE()
        ELSE @endDate
        END
       )
      AND auditDate >= (
       CASE
        WHEN @startDate = ''
         THEN '1970-01-01'
        ELSE @startDate
        END
       )
      )
     AND afterValue != 'Failed Login'
    ) AS q1
   ) AS data
  WHERE data.RowNum > @start
  ORDER BY CASE
    WHEN @sortOrder = 'auditDate'
     AND @sortDir = 'asc'
     THEN auditDate
    END ASC
   ,CASE
    WHEN @sortOrder = 'auditDate'
     AND @sortDir = 'desc'
     THEN auditDate
    END DESC
   ,CASE
    WHEN @sortOrder = 'performerUserId'
     AND @sortDir = 'asc'
     THEN performerUserId
    END ASC
   ,CASE
    WHEN @sortOrder = 'performerUserId'
     AND @sortDir = 'desc'
     THEN performerUserId
    END DESC
   ,CASE
    WHEN @sortOrder = 'affectedUserId'
     AND @sortDir = 'asc'
     THEN affectedUserId
    END ASC
   ,CASE
    WHEN @sortOrder = 'affectedUserId'
     AND @sortDir = 'desc'
     THEN affectedUserId
    END DESC
   ,CASE
    WHEN @sortOrder = 'auditDescription'
     AND @sortDir = 'asc'
     THEN auditDescription
    END ASC
   ,CASE
    WHEN @sortOrder = 'auditDescription'
     AND @sortDir = 'desc'
     THEN auditDescription
    END DESC
 END
 ELSE
 BEGIN
  SELECT TOP (@limit) *
  FROM (
   SELECT userAuditId
    ,auditDate
    ,performerUserId
    ,performerUserName
    ,affectedUserId
    ,affectedUserName
    ,userAuditActionId
    ,auditDescription
    ,afterValue
    ,ROW_NUMBER() OVER (
     ORDER BY CASE
       WHEN @sortOrder = 'auditDate'
        AND @sortDir = 'asc'
        THEN auditDate
       END ASC
      ,CASE
       WHEN @sortOrder = 'auditDate'
        AND @sortDir = 'desc'
        THEN auditDate
       END DESC
      ,CASE
       WHEN @sortOrder = 'performerUserId'
        AND @sortDir = 'asc'
        THEN performerUserId
       END ASC
      ,CASE
       WHEN @sortOrder = 'performerUserId'
        AND @sortDir = 'desc'
        THEN performerUserId
       END DESC
      ,CASE
       WHEN @sortOrder = 'affectedUserId'
        AND @sortDir = 'asc'
        THEN affectedUserId
       END ASC
      ,CASE
       WHEN @sortOrder = 'affectedUserId'
        AND @sortDir = 'desc'
        THEN affectedUserId
       END DESC
      ,CASE
       WHEN @sortOrder = 'auditDescription'
        AND @sortDir = 'asc'
        THEN auditDescription
       END ASC
      ,CASE
       WHEN @sortOrder = 'auditDescription'
        AND @sortDir = 'desc'
        THEN auditDescription
       END DESC
     ) AS RowNum
   FROM (
    SELECT userAuditId
     ,auditDate
     ,performerUserId
     ,performerUser.userName AS performerUserName
     ,affectedUserId
     ,affectedUser.userName AS affectedUserName
     ,userAudits.userAuditActionId
     ,auditDescription
     ,afterValue
     ,ROW_NUMBER() OVER (
      ORDER BY CASE
        WHEN @sortOrder = 'auditDate'
         AND @sortDir = 'asc'
         THEN auditDate
        END ASC
       ,CASE
        WHEN @sortOrder = 'auditDate'
         AND @sortDir = 'desc'
         THEN auditDate
        END DESC
       ,CASE
        WHEN @sortOrder = 'performerUserId'
         AND @sortDir = 'asc'
         THEN performerUserId
        END ASC
       ,CASE
        WHEN @sortOrder = 'performerUserId'
         AND @sortDir = 'desc'
         THEN performerUserId
        END DESC
       ,CASE
        WHEN @sortOrder = 'affectedUserId'
         AND @sortDir = 'asc'
         THEN affectedUserId
        END ASC
       ,CASE
        WHEN @sortOrder = 'affectedUserId'
         AND @sortDir = 'desc'
         THEN affectedUserId
        END DESC
       ,CASE
        WHEN @sortOrder = 'auditDescription'
         AND @sortDir = 'asc'
         THEN auditDescription
        END ASC
       ,CASE
        WHEN @sortOrder = 'auditDescription'
         AND @sortDir = 'desc'
         THEN auditDescription
        END DESC
      ) AS RowNum
    FROM bypass.userAudits AS userAudits
    JOIN bypass_static.userAuditActions ON bypass_static.userAuditActions.userAuditActionId = userAudits.userAuditActionId
    LEFT OUTER JOIN bypass.users AS performerUser ON performerUser.userId = performerUserId
    LEFT OUTER JOIN bypass.users AS affectedUser ON affectedUser.userId = affectedUserId
    WHERE (
      @affectedUserName IS NULL
      OR affectedUser.userName LIKE '%' + @affectedUserName + '%'
      )
     AND (
      @performerUserName IS NULL
      OR performerUser.userName LIKE '%' + @performerUserName + '%'
      )
     AND (
      @userAuditActionName IS NULL
      OR auditDescription LIKE '%' + @userAuditActionName + '%'
      )
     AND (
      auditDate <= (
       CASE
        WHEN @endDate = ''
         THEN GETDATE()
        ELSE @endDate
        END
       )
      AND auditDate >= (
       CASE
        WHEN @startDate = ''
         THEN '1970-01-01'
        ELSE @startDate
        END
       )
      )
     AND (
      performerUser.isUsanUser = 0
      OR performerUserId IS NULL
      )
     AND (
      affectedUser.isUsanUser = 0
      OR affectedUserId IS NULL
      )
     AND afterValue != 'Failed Login'
    ) AS q1
   ) AS data
  WHERE data.RowNum > @start
  ORDER BY CASE
    WHEN @sortOrder = 'auditDate'
     AND @sortDir = 'asc'
     THEN auditDate
    END ASC
   ,CASE
    WHEN @sortOrder = 'auditDate'
     AND @sortDir = 'desc'
     THEN auditDate
    END DESC
   ,CASE
    WHEN @sortOrder = 'performerUserId'
     AND @sortDir = 'asc'
     THEN performerUserId
    END ASC
   ,CASE
    WHEN @sortOrder = 'performerUserId'
     AND @sortDir = 'desc'
     THEN performerUserId
    END DESC
   ,CASE
    WHEN @sortOrder = 'affectedUserId'
     AND @sortDir = 'asc'
     THEN affectedUserId
    END ASC
   ,CASE
    WHEN @sortOrder = 'affectedUserId'
     AND @sortDir = 'desc'
     THEN affectedUserId
    END DESC
   ,CASE
    WHEN @sortOrder = 'auditDescription'
     AND @sortDir = 'asc'
     THEN auditDescription
    END ASC
   ,CASE
    WHEN @sortOrder = 'auditDescription'
     AND @sortDir = 'desc'
     THEN auditDescription
    END DESC
 END
 RETURN
END
GO
/* drop procedure IvrSearchConfigs */
if not exists (select * from sys.procedures where name = 'IvrSearchConfigs' and schema_name(schema_id) = 'bypass')
begin
   print 'Creating emtpy IvrSearchConfigs stored procedure'
   execute('create procedure [bypass].[IvrSearchConfigs] as select 1')
end
GO
print 'Altering stored procedure IvrSearchConfigs to latest version'
GO
alter procedure [bypass].[IvrSearchConfigs](
 @appname varchar(32),
 @language varchar(32) = '*',
 @dnis as varchar(32) = '*',
 @destination as varchar(32) = '*',
 @rank as varchar(6) = '*',
 @offerId as varchar(8) = '*',
 @offerType as varchar(128) = '*'
)
as
declare @startTime datetime = CURRENT_TIMESTAMP
if(len(@language) = 1)
begin
 if(@language = 'E')
 begin
  set @language = 'English'
 end
 else if(@language = 'S')
 begin
  set @language = 'Spanish'
 end
 else if(@language = 'F')
 begin
  set @language = 'French'
 end
end
declare @configId int, @order int, @peg varchar(128)
declare @skill varchar(16), @skillName varchar(64), @agents int, @med int
declare @overflowSkill varchar(16), @overflowSkillName varchar(64), @overflowAgents int, @overflowMed int
declare @username varchar(100), @lastModTime datetime
SELECT TOP 1
 @configId = [bypassConfigurationId],
 @order = [order],
 @peg = [peg],
 @skill = [skillId],
 @skillName = [skillName],
 @agents = [agentsAvailable],
 @med = [med],
 @overflowSkill = [overflowSkillId],
 @overflowSkillName = [overflowSkillName],
 @overflowAgents = [overflowAgentsAvailable],
 @overflowMed = [overflowMed],
 @username = [users].[userName],
 @lastModTime = [lastModifiedDateTime]
FROM [bypass].[configurations] as [configs]
JOIN [bypass].[applications] as [apps]
 ON [apps].[applicationId] = [configs].[applicationId]
LEFT OUTER JOIN [bypass].[languages] as [langs]
 ON [langs].[languageId] = [configs].[languageId]
JOIN [bypass].[users] as [users]
 ON [users].[userId] = [configs].[lastModifiedUserId]
WHERE [apps].[application] = @appname
 AND (@language = '*' OR [configs].[languageId] is null OR [langs].[language] IN (@language, '*'))
 AND (@dnis = '*' OR [configs].[dnis] is null OR [configs].[dnis] = '*' OR [configs].[dnis] = @dnis)
 AND (@destination = '*' OR [configs].[destination] is null OR [configs].[destination] = '*' OR [configs].[destination] = @destination)
 AND (@rank = '*' OR [configs].[rank] is null OR [configs].[rank] = '*' OR [configs].[rank] = @rank)
 AND (@offerId = '*' OR [configs].[offerId] is null OR [configs].[offerId] = '*' OR [configs].[offerId] = @offerId)
 AND (@offerType = '*' OR [configs].[offerType] is null OR [configs].[offerType] = '*' OR [configs].[offerType] = @offerType)
ORDER BY [order] ASC
if exists (SELECT TOP 1 [TraceIvrSearch] FROM [databaseConfiguration] WHERE [TraceIvrSearch] = 1)
begin
 declare @duration int = datediff(ms, @startTime, CURRENT_TIMESTAMP)
 INSERT INTO [ivrSearchTrace] (
  [duration],
  [appName],
  [language],
  [dnis],
  [destination],
  [rank],
  [offerId],
  [offerType],
  [bypassConfigurationId],
  [order])
 VALUES (
  @duration,
  @appname,
  @language,
  @dnis,
  @destination,
  @rank,
  @offerId,
  @offerType,
  @configId,
  @order
 )
end
SELECT @configId as [bypassConfigurationId],
 @order as [order],
 @peg as [peg],
 @skill as [skillId],
 @skillName as [skillName],
 @agents as [agentsAvailable],
 @med as [med],
 @overflowSkill as [overflowSkillId],
 @overflowSkillName as [overflowSkillName],
 @overflowAgents as [overflowAgentsAvailable],
 @overflowMed as [overflowMed],
 @username as [userName],
 @lastModTime as [lastModifiedDateTime]
GO
/* Seed data for tables */
declare @languageTable table (
 [language_name] varchar(32)
)
INSERT INTO @languageTable ([language_name]) VALUES
 ('English'),
 ('Spanish'),
 ('French'),
 ('*')
MERGE [bypass].[languages] as [languages] USING @languageTable as [langs]
 ON [langs].[language_name] = [languages].[language]
WHEN NOT MATCHED THEN
 INSERT ([language]) VALUES ([langs].[language_name])
WHEN NOT MATCHED BY SOURCE
 THEN DELETE
;
GO
if not exists(select 1 from [bypass].[applications] where [application] ='BRANDSCS')
begin
 print 'Adding initial static data for [bypass].[applications]'
 set identity_insert [bypass].[applications] on
 insert [bypass].[applications] ([applicationId], [application], [dateAdded], [userIdAdd]) values (1, 'BRANDSCS', getdate(), -1)
 set identity_insert [bypass].[applications] off
end
GO
if not exists(select 1 from [bypass].[applications] where [application] ='CRSCS')
begin
 print 'Adding CRSCS static data for [bypass].[applications]'
 set identity_insert [bypass].[applications] on
 insert into [bypass].[applications] ([applicationId], [application],[dateAdded], [userIdAdd]) values( 2, 'CRSCS', getdate(), -1)
 set identity_insert [bypass].[applications] off
end
GO
if not exists(select 1 from [bypass].[applications] where [application] ='BANKCARDNRI')
begin
 print 'Adding BANKCARDNRI static data for [bypass].[applications]'
 set identity_insert [bypass].[applications] on
 insert into [bypass].[applications] ([applicationId], [application],[dateAdded], [userIdAdd]) values( 3, 'BANKCARDNRI', getdate(), -1)
 set identity_insert [bypass].[applications] off
end
GO
if ( not exists (select 1 from bypass.roles ) )
begin
 set identity_insert bypass.roles on
 insert into bypass.roles ( roleId, name, description, dateadded) values ( 1, 'View','View', getdate())
 insert into bypass.roles ( roleId, name, description, dateadded) values ( 2, 'Edit','Edit', getdate())
 insert into bypass.roles ( roleId, name, description, dateadded) values ( 3, 'Update Users','Update Users', getdate())
 set identity_insert bypass.roles off
end
if ( not exists (select 1 from bypass.users ) )
begin
 set identity_insert bypass.users on
 insert into bypass.users (userid, username, deleted, [password], [disabled], isSuperAdmin, isUsanUser, locked,failedloginAttempts, lastPasswordChangeDate, forceChangePassword, dateadded)
  values (-1, 'SYSTEM', 0, 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3', 0, 1, 1, 0, 0, null, 0, getdate() -1 )
 insert into bypass.users (userid, username, deleted, [password], [disabled], isSuperAdmin, isUsanUser, locked,failedloginAttempts, lastPasswordChangeDate, forceChangePassword, dateadded)
  values (1, 'arohi.rajput@usan.com', 0, '536e185bb1291d4c62fa0dc61ae9766d1b410d65bdf486073fe3a9d644d33f9f', 0, 1, 1, 0, 0, null, 0, getdate() -1 )
 insert into bypass.users (userid, username, deleted, [password], [disabled], isSuperAdmin, isUsanUser, locked,failedloginAttempts, lastPasswordChangeDate, forceChangePassword, dateadded)
  values (2, 'chris.loguidice@usan.com', 0, '536e185bb1291d4c62fa0dc61ae9766d1b410d65bdf486073fe3a9d644d33f9f', 0, 1, 1, 0, 0, null, 0, getdate() -1 )
 insert into bypass.users (userid, username, deleted, [password], [disabled], isSuperAdmin, isUsanUser, locked,failedloginAttempts, lastPasswordChangeDate, forceChangePassword, dateadded)
  values (3, 'kerry.anderson@usan.com', 0, '536e185bb1291d4c62fa0dc61ae9766d1b410d65bdf486073fe3a9d644d33f9f', 0, 1, 1, 0, 0, null, 0, getdate() -1 )
 insert into bypass.users (userid, username, deleted, [password], [disabled], isSuperAdmin, isUsanUser, locked,failedloginAttempts, lastPasswordChangeDate, forceChangePassword, dateadded)
  values (4, 'noah.wallace@usan.com', 0, '536e185bb1291d4c62fa0dc61ae9766d1b410d65bdf486073fe3a9d644d33f9f', 0, 1, 1, 0, 0, null, 0, getdate() -1 )
 insert into bypass.users (userid, username, deleted, [password], [disabled], isSuperAdmin, isUsanUser, locked,failedloginAttempts, lastPasswordChangeDate, forceChangePassword, dateadded)
  values (5, 'gina.saucer@citi.com', 0, '536e185bb1291d4c62fa0dc61ae9766d1b410d65bdf486073fe3a9d644d33f9f', 0, 1, 0, 0, 0, null, 0, getdate() -1 )
 set identity_insert bypass.users off
end
--assign admin permissons for all apps
INSERT INTO bypass.userRoles (userId, roleId, applicationId)
SELECT u.userId, r.roleId, a.applicationId
FROM bypass.users u
CROSS JOIN bypass.roles r
CROSS JOIN bypass.applications a
WHERE u.userName IN ('kerry.anderson@usan.com', 'arohi.rajput@usan.com','chris.loguidice@usan.com', 'noah.wallace@usan.com')
AND NOT EXISTS (
    SELECT 1
    FROM bypass.userRoles ur
    WHERE ur.userId = u.userId
      AND ur.roleId = r.roleId
      AND ur.applicationId = a.applicationId
);
if not exists(select 1 from [bypass_static].[userAuditActions])
begin
 print 'Adding initial static data for [bypass_static].[userAuditActions]'
 set identity_insert [bypass_static].[userAuditActions] on
 insert [bypass_static].[userAuditActions] ([userAuditActionId], [auditDescription], [dateAdded]) values (1, N'Add User', GETDATE())
 insert [bypass_static].[userAuditActions] ([userAuditActionId], [auditDescription], [dateAdded]) values (2, N'Delete User', GETDATE())
 insert [bypass_static].[userAuditActions] ([userAuditActionId], [auditDescription], [dateAdded]) values (3, N'Update User', GETDATE())
 insert [bypass_static].[userAuditActions] ([userAuditActionId], [auditDescription], [dateAdded]) values (4, N'Add Role', GETDATE())
 insert [bypass_static].[userAuditActions] ([userAuditActionId], [auditDescription], [dateAdded]) values (5, N'Delete Role', GETDATE())
 insert [bypass_static].[userAuditActions] ([userAuditActionId], [auditDescription], [dateAdded]) values (6, N'Update Role', GETDATE())
 insert [bypass_static].[userAuditActions] ([userAuditActionId], [auditDescription], [dateAdded]) values (7, N'Failed Login', GETDATE())
 insert [bypass_static].[userAuditActions] ([userAuditActionId], [auditDescription], [dateAdded]) values (8, N'Login', GETDATE())
 insert [bypass_static].[userAuditActions] ([userAuditActionId], [auditDescription], [dateAdded]) values (9, N'Change User Role', GETDATE())
 insert [bypass_static].[userAuditActions] ([userAuditActionId], [auditDescription], [dateAdded]) values (10, N'Create Configuration', GETDATE())
 insert [bypass_static].[userAuditActions] ([userAuditActionId], [auditDescription], [dateAdded]) values (11, N'Edit Configuration', GETDATE())
 insert [bypass_static].[userAuditActions] ([userAuditActionId], [auditDescription], [dateAdded]) values (12, N'Copy Configuration', GETDATE())
 insert [bypass_static].[userAuditActions] ([userAuditActionId], [auditDescription], [dateAdded]) values (13, N'Delete Configuration', GETDATE())
 insert [bypass_static].[userAuditActions] ([userAuditActionId], [auditDescription], [dateAdded]) values (14, N'Update Configuration Order', GETDATE())
 insert [bypass_static].[userAuditActions] ([userAuditActionId], [auditDescription], [dateAdded]) values (15, N'Change Password', GETDATE())
 insert [bypass_static].[userAuditActions] ([userAuditActionId], [auditDescription], [dateAdded]) values (16, N'Reset Password', GETDATE())
 set identity_insert [bypass_static].[userAuditActions] off
end
if not exists (select * from [bypass_static].[userAuditActions] where [userAuditActionId] = 1)
begin
 print 'Populating userAuditActions table with Delete Queue entry'
 set nocount on
 set xact_abort on
 begin transaction
 set identity_insert [bypass_static].[userAuditActions] on
 insert [bypass_static].[userAuditActions] ([userAuditActionId], [auditDescription], [dateAdded])
 values (19, N'Delete Queue', getdate())
 set identity_insert [bypass_static].[userAuditActions] off
 commit transaction
 set nocount off
end
else
begin
 print 'userAuditActions table already contains Delete Queue entry'
end
go
IF NOT EXISTS(SELECT * FROM [bypass].[databaseConfiguration])
begin
 INSERT INTO [bypass].[databaseConfiguration] DEFAULT VALUES
end
GO
/* Cleanup Script */
/*

	Purpose: Set values that have blanks or dashes to null, or delete them if doing so violates the unqiue key constraint.

	Records that violate the unique constraint when fixed should not exist. This script keeps the existing correct row.

	Not running this script will cause IvrSearchConfigs to work on data created after CTG-9603 updates, 

	but not on old data as rows were incorrectly being inserted with blank values (and sometimes placeholder dashes) instead of null.

*/
BEGIN TRAN;
-- Delete duplicates based on what the unique key will look like after '' and '-' are converted to NULL.
WITH normalized AS
(
    SELECT
        bypassConfigurationId,
        ROW_NUMBER() OVER
        (
            PARTITION BY
    [applicationId], -- always id
    [languageId], -- always id or null
                NULLIF(NULLIF([dnis], ''), '-'),
                NULLIF(NULLIF([destination], ''), '-'),
    NULLIF(NULLIF([rank], ''), '-'),
    NULLIF(NULLIF([offerId], ''), '-'),
    NULLIF(NULLIF([offerType], ''), '-')
            ORDER BY bypassConfigurationId
        ) AS rn
    FROM [bypass].[configurations]
)
DELETE FROM normalized
WHERE rn > 1;
COMMIT;
-- iterate over columns and fix values per-column
BEGIN TRAN;
 DECLARE @TableName NVARCHAR(128) = 'configurations';
 DECLARE @ColumnName NVARCHAR(128);
 DECLARE @Schema NVARCHAR(128) = 'bypass';
 DECLARE @SQL NVARCHAR(MAX) = N'';
 DECLARE col_cursor CURSOR FOR
 SELECT COLUMN_NAME
 FROM information_schema.columns
 WHERE TABLE_NAME = @TableName
  AND TABLE_SCHEMA = @Schema
  AND COLUMN_NAME not in ('bypassConfigurationId', 'lastModifiedDateTime');
 OPEN col_cursor;
 FETCH NEXT FROM col_cursor INTO @ColumnName;
 WHILE @@FETCH_STATUS = 0
 BEGIN
  SET @SQL = @SQL +
  N'UPDATE ' + QUOTENAME(@Schema) + N'.' + QUOTENAME(@TableName) + N' ' +
  N'SET ' + QUOTENAME(@ColumnName) + N' = NULL ' +
  N'WHERE ' + QUOTENAME(@ColumnName) + N' in('''', ''-'');';
  FETCH NEXT FROM col_cursor INTO @ColumnName;
 END
 CLOSE col_cursor;
 DEALLOCATE col_cursor;
 EXEC sp_executesql @SQL
COMMIT;
