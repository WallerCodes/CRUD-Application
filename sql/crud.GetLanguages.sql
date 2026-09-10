/* drop procedure GetLanguages */
if not exists (select * from sys.procedures where name = 'GetLanguages' and schema_name(schema_id) = 'crud')
begin
   print 'Creating emtpy GetLanguages stored procedure'
   execute('create procedure [crud].[GetLanguages] as select 1')
end
GO

print 'Altering stored procedure GetLanguages to latest version'
GO

alter procedure [crud].[GetLanguages]
as

SELECT [languageId], [language] FROM [crud].[languages]

GO

