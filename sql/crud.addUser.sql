/* drop procedure AddUser */
if not exists (select * from sys.procedures where name = 'AddUser' and schema_name(schema_id) = 'crud')
begin
   print 'Creating emtpy AddUser stored procedure'
   execute('create procedure [crud].[AddUser] as select 1')
end
GO

print 'Altering stored procedure AddUser to latest version'
GO

alter procedure [crud].[AddUser](
	@username as varchar(100), 
	@pwd as varchar(256)
)
as

set nocount on
INSERT INTO [crud].[users] ([userName], [password]) VALUES (@username, @pwd)

EXECUTE [crud].[GetUser] NULL, @username

GO

