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

