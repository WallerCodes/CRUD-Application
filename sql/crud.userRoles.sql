-- update to put fks in one file later on
--drop table [crud].[userRoles]


--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
-- TABLE CREATION --
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
if not exists(select * from sys.tables where name = 'userRoles' and schema_id = (select schema_id from sys.schemas where name = 'crud'))
begin
   print 'Creating userRoles table'

   create table [crud].[userRoles] (
      [userId] int not null,
      [roleId] int not null,
      [applicationId] int not null,
	  
	  CONSTRAINT UQ_UserRoles UNIQUE (userId, roleId, applicationId) 
   )
end
else
begin
   print 'userRoles table already exists'
end


--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
-- NULL CONSTRAINTS --
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
if exists (select * from sys.columns where object_id = object_id('[crud].[userRoles]') and name = 'userId' and is_nullable=1)
begin
   print 'Converting column userId in userRoles to disallow nulls'

   alter table [crud].[userRoles] alter column [userId] int not null
end
else
begin
   print '	Column userId already in userRoles already disallows nulls'
end

if exists (select * from sys.columns where object_id = object_id('[crud].[userRoles]') and name = 'roleId' and is_nullable=1)
begin
   print 'Converting column roleId in userRoles to disallow nulls'

   alter table [crud].[userRoles] alter column [roleId] int not null
end
else
begin
   print '	Column roleId already in userRoles already disallows nulls'
end

if exists (select * from sys.columns where object_id = object_id('[crud].[userRoles]') and name = 'applicationId' and is_nullable=1)
begin
   print 'Converting column applicationId in userRoles to disallow nulls'

   alter table [crud].[userRoles] alter column [applicationId] int not null
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

select @idxIsUnique=is_unique,  @idxIsUniqueConstraint=is_unique_constraint, @idxIsPKConstraint=is_primary_key, @idxType=type from sys.indexes where object_id = object_id('[crud].[userRoles]') and name = 'userRolesPrimaryKey'
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
   print 'Creating  PK constraint userRolesPrimaryKey on userRoles'

   alter table [crud].[userRoles] add constraint [userRolesPrimaryKey] primary key clustered (
      [userId] ASC,
      [roleId] ASC,
      [applicationId] ASC
   )
   with ( PAD_INDEX = OFF, ALLOW_PAGE_LOCKS = ON, ALLOW_ROW_LOCKS = ON, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, SORT_IN_TEMPDB = OFF, FILLFACTOR = 70 )   on [PRIMARY]
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

   alter table [crud].[userRoles] drop constraint [userRolesPrimaryKey]

   alter table [crud].[userRoles] add constraint [userRolesPrimaryKey] primary key clustered (
      [userId] ASC,
      [roleId] ASC,
      [applicationId] ASC
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
   print '	PK constraint userRolesPrimaryKey already exists on userRoles'
end



--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
-- FOREIGN KEYS - userRoles --
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
if not exists (select * from sys.foreign_keys where name = 'userRolesApplicationsForeignKey' and parent_object_id = object_id('[crud].[userRoles]'))
begin
   print 'Creating foreign key constraint userRolesApplicationsForeignKey for userRoles'

   alter table [crud].[userRoles] with check add constraint [userRolesApplicationsForeignKey] foreign key ([applicationId]) references [crud].[applications]([applicationId])
   alter table [crud].[userRoles] check constraint [userRolesApplicationsForeignKey]
end
else
begin
   print 'Foreign key constraint userRolesApplicationsForeignKey already exists for userRoles'
end

if not exists (select * from sys.foreign_keys where name = 'userRolesRolesForeignKey' and parent_object_id = object_id('[crud].[userRoles]'))
begin
   print 'Creating foreign key constraint userRolesRolesForeignKey for userRoles'

   alter table [crud].[userRoles] with check add constraint [userRolesRolesForeignKey] foreign key ([roleId]) references [crud].[roles]([roleId])
   alter table [crud].[userRoles] check constraint [userRolesRolesForeignKey]
end
else
begin
   print 'Foreign key constraint userRolesRolesForeignKey already exists for userRoles'
end

if not exists (select * from sys.foreign_keys where name = 'userRolesUsersForeignKey' and parent_object_id = object_id('[crud].[userRoles]'))
begin
   print 'Creating foreign key constraint userRolesUsersForeignKey for userRoles'

   alter table [crud].[userRoles] with check add constraint [userRolesUsersForeignKey] foreign key ([userId]) references [crud].[users]([userId])
   alter table [crud].[userRoles] check constraint [userRolesUsersForeignKey]
end
else
begin
   print 'Foreign key constraint userRolesUsersForeignKey already exists for userRoles'
end



--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
-- TRIGGERS --
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--


GO

