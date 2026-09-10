/* drop procedure AddUserRole */
if not exists (select * from sys.procedures where name = 'AddUserRole' and schema_name(schema_id) = 'crud')
begin
   print 'Creating emtpy AddUserRole stored procedure'
   execute('create procedure [crud].[AddUserRole] as select 1')
end
GO

print 'Altering stored procedure AddUserRole to latest version'
GO

alter procedure [crud].[AddUserRole](
	@userId int,
	@roleId int,
	@applicationId int
)
as

INSERT INTO [crud].[userRoles] ([userId], [roleId], [applicationId])
	VALUES(@userId, @roleId, @applicationId)


GO
