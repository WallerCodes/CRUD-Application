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