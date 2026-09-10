/* drop table [crud].[applications] */

--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
-- TABLE CREATION --
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
if not exists(select * from sys.tables where name = 'applications' and schema_id = (select schema_id from sys.schemas where name = 'crud'))
begin
   print 'Creating applications table'

   create table [crud].[applications] (
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
if exists (select * from sys.columns where object_id = object_id('[crud].[applications]') and name = 'applicationId' and is_nullable=1)
begin
   print 'Converting column applicationId in applications to disallow nulls'

   alter table [crud].[applications] alter column [applicationId] int not null
end
else
begin
   print '	Column applicationId already in applications already disallows nulls'
end

if exists (select * from sys.columns where object_id = object_id('[crud].[applications]') and name = 'application' and is_nullable=1)
begin
   print 'Converting column application in applications to disallow nulls'

   alter table [crud].[applications] alter column [application] varchar(32) not null
end
else
begin
   print '	Column application already in applications already disallows nulls'
end

if exists (select * from sys.columns where object_id = object_id('[crud].[applications]') and name = 'dateAdded' and is_nullable=1)
begin
   print 'Converting column dateAdded in applications to disallow nulls'

   alter table [crud].[applications] alter column [dateAdded] datetime not null
end
else
begin
   print '	Column dateAdded already in applications already disallows nulls'
end

--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
-- DEFAULT CONSTRAINTS --
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
if exists (select * from sys.columns where object_id = object_id('[crud].[applications]') and name = 'dateAdded' and [default_object_id]=0)
begin
   print 'Creating default constraint on applications.dateAdded'

   alter table [crud].[applications] add constraint [applicationsDateAddedDefault] default (getdate()) for [dateAdded]
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

select @idxIsUnique=is_unique,  @idxIsUniqueConstraint=is_unique_constraint, @idxIsPKConstraint=is_primary_key, @idxType=type from sys.indexes where object_id = object_id('[crud].[applications]') and name = 'applicationsPrimaryKey'
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
   print 'Creating PK constraint applicationsPrimaryKey on applications'

   alter table [crud].[applications] add constraint [applicationsPrimaryKey] primary key clustered (
      [applicationId] ASC
   )
   with ( PAD_INDEX = OFF, ALLOW_PAGE_LOCKS = ON, ALLOW_ROW_LOCKS = ON, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, SORT_IN_TEMPDB = OFF )   on [PRIMARY]
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

   alter table [crud].[applications] drop constraint [applicationsPrimaryKey]

   alter table [crud].[applications] add constraint [applicationsPrimaryKey] primary key clustered (
      [applicationId] ASC
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
   print '	PK constraint applicationsPrimaryKey already exists on applications'
end

select @idxIsUnique=is_unique,  @idxIsUniqueConstraint=is_unique_constraint, @idxIsPKConstraint=is_primary_key, @idxType=type from sys.indexes where object_id = object_id('[crud].[applications]') and name = 'applicationIndex'
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
   print 'Creating index applicationIndex on applications'

   create unique nonclustered index [applicationIndex] on [crud].[applications] (
      [application] ASC
   )
   with ( PAD_INDEX = OFF, ALLOW_PAGE_LOCKS = ON, ALLOW_ROW_LOCKS = ON, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, SORT_IN_TEMPDB = OFF, FILLFACTOR = 70 )   on [PRIMARY]
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

   alter table [crud].[applications] drop constraint [applicationIndex]

   create unique nonclustered index [applicationIndex] on [crud].[applications] (
      [application] ASC
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
   print '	Index applicationIndex already exists on applications'
end


--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
-- FOREIGN KEYS - applications --
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--


--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
-- TRIGGERS --
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--


GO

