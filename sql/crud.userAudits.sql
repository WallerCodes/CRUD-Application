/* drop table [crud].[userAudits] */


--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
-- TABLE CREATION --
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
if not exists(select * from sys.tables where name = 'userAudits' and schema_id = (select schema_id from sys.schemas where name = 'crud'))
begin
   print 'Creating userAudits table'

   create table [crud].[userAudits] (
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
if exists (select * from sys.columns where object_id = object_id('[crud].[userAudits]') and name = 'userAuditId' and is_nullable=1)
begin
   print 'Converting column userAuditId in userAudits to disallow nulls'

   alter table [crud].[userAudits] alter column [userAuditId] int not null
end
else
begin
   print '	Column userAuditId already in userAudits already disallows nulls'
end

if exists (select * from sys.columns where object_id = object_id('[crud].[userAudits]') and name = 'auditDate' and is_nullable=0)
begin
   print 'Converting column auditDate in userAudits to allow nulls'

   alter table [crud].[userAudits] alter column [auditDate] datetime null
end
else
begin
   print '	Column auditDate already in userAudits already allows nulls'
end

if exists (select * from sys.columns where object_id = object_id('[crud].[userAudits]') and name = 'performerUserId' and is_nullable=1)
begin
   print 'Converting column performerUserId in userAudits to disallow nulls'

   alter table [crud].[userAudits] alter column [performerUserId] int not null
end
else
begin
   print '	Column performerUserId already in userAudits already disallows nulls'
end

if exists (select * from sys.columns where object_id = object_id('[crud].[userAudits]') and name = 'affectedUserId' and is_nullable=1)
begin
   print 'Converting column affectedUserId in userAudits to disallow nulls'

   alter table [crud].[userAudits] alter column [affectedUserId] int not null
end
else
begin
   print '	Column affectedUserId already in userAudits already disallows nulls'
end

if exists (select * from sys.columns where object_id = object_id('[crud].[userAudits]') and name = 'userAuditActionId' and is_nullable=1)
begin
   print 'Converting column userAuditActionId in userAudits to disallow nulls'

   alter table [crud].[userAudits] alter column [userAuditActionId] tinyint not null
end
else
begin
   print '	Column userAuditActionId already in userAudits already disallows nulls'
end

if exists (select * from sys.columns where object_id = object_id('[crud].[userAudits]') and name = 'userSubAuditActionId' and is_nullable=0)
begin
   print 'Converting column userSubAuditActionId in userAudits to allow nulls'

   alter table [crud].[userAudits] alter column [userSubAuditActionId] tinyint null
end
else
begin
   print '	Column userSubAuditActionId already in userAudits already allows nulls'
end

if exists (select * from sys.columns where object_id = object_id('[crud].[userAudits]') and name = 'beforeValue' and is_nullable=0)
begin
   print 'Converting column beforeValue in userAudits to allow nulls'

   alter table [crud].[userAudits] alter column [beforeValue] varchar(256) null
end
else
begin
   print '	Column beforeValue already in userAudits already allows nulls'
end

if exists (select * from sys.columns where object_id = object_id('[crud].[userAudits]') and name = 'afterValue' and is_nullable=0)
begin
   print 'Converting column afterValue in userAudits to allow nulls'

   alter table [crud].[userAudits] alter column [afterValue] varchar(256) null
end
else
begin
   print '	Column afterValue already in userAudits already allows nulls'
end


--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
-- DEFAULT CONSTRAINTS --
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
if exists (select * from sys.columns where object_id = object_id('[crud].[userAudits]') and name = 'auditDate' and [default_object_id]=0)
begin
   print 'Creating default constraint on userAudits.auditDate'

   alter table [crud].[userAudits] add constraint [userAuditsAuditDateDefault] default (getdate()) for [auditDate]
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

select @idxIsUnique=is_unique,  @idxIsUniqueConstraint=is_unique_constraint, @idxIsPKConstraint=is_primary_key, @idxType=type from sys.indexes where object_id = object_id('[crud].[userAudits]') and name = 'userAuditsPrimaryKey'
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
   print 'Creating  PK constraint userAuditsPrimaryKey on userAudits'

   alter table [crud].[userAudits] add constraint [userAuditsPrimaryKey] primary key clustered (
      [userAuditId] ASC
   )
   with ( PAD_INDEX = OFF, ALLOW_PAGE_LOCKS = ON, ALLOW_ROW_LOCKS = ON, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, SORT_IN_TEMPDB = OFF )   on [PRIMARY]
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

   alter table [crud].[userAudits] drop constraint [userAuditsPrimaryKey]

   alter table [crud].[userAudits] add constraint [userAuditsPrimaryKey] primary key clustered (
      [userAuditId] ASC
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
   print '	PK constraint userAuditsPrimaryKey already exists on userAudits'
end



--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
-- FOREIGN KEYS - userAudits --
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
if not exists (select * from sys.foreign_keys where name = 'userAuditsUserAuditActions02ForeignKey0' and parent_object_id = object_id('[crud].[userAudits]'))
begin
   print 'Creating foreign key constraint userAuditsUserAuditActions02ForeignKey0 for userAudits'

   alter table [crud].[userAudits] with check add constraint [userAuditsUserAuditActions02ForeignKey0] foreign key ([userSubAuditActionId]) references [crud_static].[userAuditActions]([userAuditActionId])
   alter table [crud].[userAudits] check constraint [userAuditsUserAuditActions02ForeignKey0]
end
else
begin
   print 'Foreign key constraint userAuditsUserAuditActions02ForeignKey0 already exists for userAudits'
end

if not exists (select * from sys.foreign_keys where name = 'userAuditsUserAuditActionsForeignKey' and parent_object_id = object_id('[crud].[userAudits]'))
begin
   print 'Creating foreign key constraint userAuditsUserAuditActionsForeignKey for userAudits'

   alter table [crud].[userAudits] with check add constraint [userAuditsUserAuditActionsForeignKey] foreign key ([userAuditActionId]) references [crud_static].[userAuditActions]([userAuditActionId])
   alter table [crud].[userAudits] check constraint [userAuditsUserAuditActionsForeignKey]
end
else
begin
   print 'Foreign key constraint userAuditsUserAuditActionsForeignKey already exists for userAudits'
end

if not exists (select * from sys.foreign_keys where name = 'userAuditsUsers02ForeignKey' and parent_object_id = object_id('[crud].[userAudits]'))
begin
   print 'Creating foreign key constraint userAuditsUsers02ForeignKey for userAudits'

   alter table [crud].[userAudits] with check add constraint [userAuditsUsers02ForeignKey] foreign key ([affectedUserId]) references [crud].[users]([userId])
   alter table [crud].[userAudits] check constraint [userAuditsUsers02ForeignKey]
end
else
begin
   print 'Foreign key constraint userAuditsUsers02ForeignKey already exists for userAudits'
end

if not exists (select * from sys.foreign_keys where name = 'userAuditsUsersForeignKey' and parent_object_id = object_id('[crud].[userAudits]'))
begin
   print 'Creating foreign key constraint userAuditsUsersForeignKey for userAudits'

   alter table [crud].[userAudits] with check add constraint [userAuditsUsersForeignKey] foreign key ([performerUserId]) references [crud].[users]([userId])
   alter table [crud].[userAudits] check constraint [userAuditsUsersForeignKey]
end
else
begin
   print 'Foreign key constraint userAuditsUsersForeignKey already exists for userAudits'
end



--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
-- TRIGGERS --
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--


GO

