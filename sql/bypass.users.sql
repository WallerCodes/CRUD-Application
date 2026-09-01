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

select @idxIsUnique=is_unique,  @idxIsUniqueConstraint=is_unique_constraint, @idxIsPKConstraint=is_primary_key, @idxType=type from sys.indexes where object_id = object_id('[bypass].[users]') and name = 'usersIndex'
set @idxExists = case when  @idxType is null then 0 else 1 end
set @idxIsClustered = case when  @idxType = 1 then 1 else 0 end
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
   with ( PAD_INDEX = OFF, ALLOW_PAGE_LOCKS = ON, ALLOW_ROW_LOCKS = ON, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, SORT_IN_TEMPDB = OFF, FILLFACTOR = 70 )   on [PRIMARY]
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
   with ( PAD_INDEX = OFF, ALLOW_PAGE_LOCKS = ON, ALLOW_ROW_LOCKS = ON, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, SORT_IN_TEMPDB = OFF, FILLFACTOR = 70 )   on [PRIMARY]

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

select @idxIsUnique=is_unique,  @idxIsUniqueConstraint=is_unique_constraint, @idxIsPKConstraint=is_primary_key, @idxType=type from sys.indexes where object_id = object_id('[bypass].[users]') and name = 'usersPrimaryKey'
set @idxExists = case when  @idxType is null then 0 else 1 end
set @idxIsClustered = case when  @idxType = 1 then 1 else 0 end
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
   with ( PAD_INDEX = OFF, ALLOW_PAGE_LOCKS = ON, ALLOW_ROW_LOCKS = ON, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, SORT_IN_TEMPDB = OFF )   on [PRIMARY]
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
   with ( PAD_INDEX = OFF, ALLOW_PAGE_LOCKS = ON, ALLOW_ROW_LOCKS = ON, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, SORT_IN_TEMPDB = OFF )   on [PRIMARY]

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

