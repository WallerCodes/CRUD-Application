-- drop table [crud_static].[userAuditActions] 


--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
-- TABLE CREATION --
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
if not exists(select * from sys.tables where name = 'userAuditActions' and schema_id = (select schema_id from sys.schemas where name = 'crud_static'))
begin
   print 'Creating userAuditActions table'

   create table [crud_static].[userAuditActions] (
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
if exists (select * from sys.columns where object_id = object_id('[crud_static].[userAuditActions]') and name = 'userAuditActionId' and is_nullable=1)
begin
   print 'Converting column userAuditActionId in userAuditActions to disallow nulls'

   alter table [crud_static].[userAuditActions] alter column [userAuditActionId] tinyint not null
end
else
begin
   print '	Column userAuditActionId already in userAuditActions already disallows nulls'
end

if exists (select * from sys.columns where object_id = object_id('[crud_static].[userAuditActions]') and name = 'auditDescription' and is_nullable=0)
begin
   print 'Converting column auditDescription in userAuditActions to allow nulls'

   alter table [crud_static].[userAuditActions] alter column [auditDescription] varchar(64) null
end
else
begin
   print '	Column auditDescription already in userAuditActions already allows nulls'
end

if exists (select * from sys.columns where object_id = object_id('[crud_static].[userAuditActions]') and name = 'dateAdded' and is_nullable=1)
begin
   print 'Converting column dateAdded in userAuditActions to disallow nulls'

   alter table [crud_static].[userAuditActions] alter column [dateAdded] datetime not null
end
else
begin
   print '	Column dateAdded already in userAuditActions already disallows nulls'
end


--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
-- DEFAULT CONSTRAINTS --
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
if exists (select * from sys.columns where object_id = object_id('[crud_static].[userAuditActions]') and name = 'dateAdded' and [default_object_id]=0)
begin
   print 'Creating default constraint on userAuditActions.dateAdded'

   alter table [crud_static].[userAuditActions] add constraint [userAuditActionsDateAddedDefault] default (getdate()) for [dateAdded]
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

select @idxIsUnique=is_unique,  @idxIsUniqueConstraint=is_unique_constraint, @idxIsPKConstraint=is_primary_key, @idxType=type from sys.indexes where object_id = object_id('[crud_static].[userAuditActions]') and name = 'auditDescriptionIndex'
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
   print 'Creating index auditDescriptionIndex on userAuditActions'

   create unique nonclustered index [auditDescriptionIndex] on [crud_static].[userAuditActions] (
      [auditDescription] ASC
   )
   with ( PAD_INDEX = OFF, ALLOW_PAGE_LOCKS = ON, ALLOW_ROW_LOCKS = ON, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, SORT_IN_TEMPDB = OFF, FILLFACTOR = 70 )   on [PRIMARY]
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

   alter table [crud_static].[userAuditActions] drop constraint [auditDescriptionIndex]

   create unique nonclustered index [auditDescriptionIndex] on [crud_static].[userAuditActions] (
      [auditDescription] ASC
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
   print '	Index auditDescriptionIndex already exists on userAuditActions'
end

select @idxIsUnique=is_unique,  @idxIsUniqueConstraint=is_unique_constraint, @idxIsPKConstraint=is_primary_key, @idxType=type from sys.indexes where object_id = object_id('[crud_static].[userAuditActions]') and name = 'userAuditActionsPrimaryKey'
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
   print 'Creating  PK constraint userAuditActionsPrimaryKey on userAuditActions'

   alter table [crud_static].[userAuditActions] add constraint [userAuditActionsPrimaryKey] primary key clustered (
      [userAuditActionId] ASC
   )
   with ( PAD_INDEX = OFF, ALLOW_PAGE_LOCKS = ON, ALLOW_ROW_LOCKS = ON, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, SORT_IN_TEMPDB = OFF )   on [PRIMARY]
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

   alter table [crud_static].[userAuditActions] drop constraint [userAuditActionsPrimaryKey]

   alter table [crud_static].[userAuditActions] add constraint [userAuditActionsPrimaryKey] primary key clustered (
      [userAuditActionId] ASC
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
   print '	PK constraint userAuditActionsPrimaryKey already exists on userAuditActions'
end



--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
-- FOREIGN KEYS - userAuditActions --
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--


--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
-- TRIGGERS --
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--


GO

