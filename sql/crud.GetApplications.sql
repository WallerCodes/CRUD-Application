/* drop procedure GetApplications */
if not exists (select * from sys.procedures where name = 'GetApplications' and schema_name(schema_id) = 'crud')
begin
   print 'Creating emtpy GetApplications stored procedure'
   execute('create procedure [crud].[GetApplications] as select 1')
end
GO

print 'Altering stored procedure GetApplications to latest version'
GO

alter procedure [crud].[GetApplications]
as

SELECT [applicationId], [application], [userIdAdd]
FROM [crud].[applications]

GO

