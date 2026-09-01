/* drop procedure RemoveUserRole */
if not exists (select * from sys.procedures where name = 'RemoveUserRole' and schema_name(schema_id) = 'bypass')
begin
   print 'Creating emtpy RemoveUserRole stored procedure'
   execute('create procedure [bypass].[RemoveUserRole] as select 1')
end
GO

print 'Altering stored procedure RemoveUserRole to latest version'
GO

ALTER procedure [bypass].[RemoveUserRole](
 @userId int,
 @roldId int,
 @applicationId int
)
as
DELETE FROM [bypass].[userRoles]
WHERE [userId] = @userId
 AND [roleId] = @roldId
 AND [applicationId] = @applicationId

GO
