/* drop procedure AddUserRole */
if not exists (select * from sys.procedures where name = 'AddUserRole' and schema_name(schema_id) = 'bypass')
begin
   print 'Creating emtpy AddUserRole stored procedure'
   execute('create procedure [bypass].[AddUserRole] as select 1')
end
GO

print 'Altering stored procedure AddUserRole to latest version'
GO

alter procedure [bypass].[AddUserRole](
	@userId int,
	@roleId int,
	@applicationId int
)
as

INSERT INTO [bypass].[userRoles] ([userId], [roleId], [applicationId])
	VALUES(@userId, @roleId, @applicationId)


GO
