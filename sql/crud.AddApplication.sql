/* drop procedure AddApplication */
if not exists (select * from sys.procedures where name = 'AddApplication' and schema_name(schema_id) = 'crud')
begin
   print 'Creating emtpy AddApplication stored procedure'
   execute('create procedure [crud].[AddApplication] as select 1')
end
GO

print 'Altering stored procedure AddApplication to latest version'
GO

alter procedure [crud].[AddApplication](@appname varchar(32), @userId int)
as

set nocount on
INSERT INTO [crud].[applications] ([application], [userIdAdd]) VALUES (@appname, @userId)

SELECT [applicationId], [application], [userIdAdd]
FROM [crud].[applications] 
WHERE [application] = @appname

GO

