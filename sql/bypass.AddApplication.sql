/* drop procedure AddApplication */
if not exists (select * from sys.procedures where name = 'AddApplication' and schema_name(schema_id) = 'bypass')
begin
   print 'Creating emtpy AddApplication stored procedure'
   execute('create procedure [bypass].[AddApplication] as select 1')
end
GO

print 'Altering stored procedure AddApplication to latest version'
GO

alter procedure [bypass].[AddApplication](@appname varchar(32), @userId int)
as

set nocount on
INSERT INTO [bypass].[applications] ([application], [userIdAdd]) VALUES (@appname, @userId)

SELECT [applicationId], [application], [userIdAdd]
FROM [bypass].[applications] 
WHERE [application] = @appname

GO

