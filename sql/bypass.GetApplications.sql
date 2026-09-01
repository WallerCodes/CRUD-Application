/* drop procedure GetApplications */
if not exists (select * from sys.procedures where name = 'GetApplications' and schema_name(schema_id) = 'bypass')
begin
   print 'Creating emtpy GetApplications stored procedure'
   execute('create procedure [bypass].[GetApplications] as select 1')
end
GO

print 'Altering stored procedure GetApplications to latest version'
GO

alter procedure [bypass].[GetApplications]
as

SELECT [applicationId], [application], [userIdAdd]
FROM [bypass].[applications]

GO

