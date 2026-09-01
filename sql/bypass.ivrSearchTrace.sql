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

select @idxIsUnique=is_unique,  @idxIsUniqueConstraint=is_unique_constraint, @idxIsPKConstraint=is_primary_key, @idxType=type from sys.indexes where object_id = object_id('[bypass].[ivrSearchTrace]') and name = 'ivrSearchTracePrimaryKey'
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
   print 'Creating PK constraint ivrSearchTracePrimaryKey on ivrSearchTrace'

   alter table [bypass].[ivrSearchTrace] add constraint [ivrSearchTracePrimaryKey] primary key clustered (
      [ivrSearchTraceId] ASC
   )
   with ( PAD_INDEX = OFF, ALLOW_PAGE_LOCKS = ON, ALLOW_ROW_LOCKS = ON, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, SORT_IN_TEMPDB = OFF )   on [PRIMARY]
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
   with ( PAD_INDEX = OFF, ALLOW_PAGE_LOCKS = ON, ALLOW_ROW_LOCKS = ON, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, SORT_IN_TEMPDB = OFF )   on [PRIMARY]

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

