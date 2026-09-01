
if not exists(select 1 from [bypass_static].[userAuditActions])
begin
	print 'Adding initial static data for [bypass_static].[userAuditActions]'

	set identity_insert [bypass_static].[userAuditActions] on
	insert [bypass_static].[userAuditActions] ([userAuditActionId], [auditDescription], [dateAdded]) values (1, N'Add User', GETDATE())
	insert [bypass_static].[userAuditActions] ([userAuditActionId], [auditDescription], [dateAdded]) values (2, N'Delete User', GETDATE())
	insert [bypass_static].[userAuditActions] ([userAuditActionId], [auditDescription], [dateAdded]) values (3, N'Update User', GETDATE())
	insert [bypass_static].[userAuditActions] ([userAuditActionId], [auditDescription], [dateAdded]) values (4, N'Add Role', GETDATE())
	insert [bypass_static].[userAuditActions] ([userAuditActionId], [auditDescription], [dateAdded]) values (5, N'Delete Role', GETDATE())
	insert [bypass_static].[userAuditActions] ([userAuditActionId], [auditDescription], [dateAdded]) values (6, N'Update Role', GETDATE())
	insert [bypass_static].[userAuditActions] ([userAuditActionId], [auditDescription], [dateAdded]) values (7, N'Failed Login', GETDATE())
	insert [bypass_static].[userAuditActions] ([userAuditActionId], [auditDescription], [dateAdded]) values (8, N'Login', GETDATE())
	insert [bypass_static].[userAuditActions] ([userAuditActionId], [auditDescription], [dateAdded]) values (9, N'Change User Role', GETDATE())
	insert [bypass_static].[userAuditActions] ([userAuditActionId], [auditDescription], [dateAdded]) values (10, N'Create Configuration', GETDATE())
	insert [bypass_static].[userAuditActions] ([userAuditActionId], [auditDescription], [dateAdded]) values (11, N'Edit Configuration', GETDATE())
	insert [bypass_static].[userAuditActions] ([userAuditActionId], [auditDescription], [dateAdded]) values (12, N'Copy Configuration', GETDATE())
	insert [bypass_static].[userAuditActions] ([userAuditActionId], [auditDescription], [dateAdded]) values (13, N'Delete Configuration', GETDATE())
	insert [bypass_static].[userAuditActions] ([userAuditActionId], [auditDescription], [dateAdded]) values (14, N'Update Configuration Order', GETDATE())
	insert [bypass_static].[userAuditActions] ([userAuditActionId], [auditDescription], [dateAdded]) values (15, N'Change Password', GETDATE())
	insert [bypass_static].[userAuditActions] ([userAuditActionId], [auditDescription], [dateAdded]) values (16, N'Reset Password', GETDATE())
	set identity_insert [bypass_static].[userAuditActions] off
end


if not exists (select * from [bypass_static].[userAuditActions] where [userAuditActionId] = 1)
begin
	print 'Populating userAuditActions table with Delete Queue entry'

	set nocount on
	set xact_abort on
	begin transaction
	
	set identity_insert [bypass_static].[userAuditActions] on

	insert [bypass_static].[userAuditActions] ([userAuditActionId], [auditDescription], [dateAdded]) 
	values (19, N'Delete Queue', getdate())


	set identity_insert [bypass_static].[userAuditActions] off

	commit transaction
	set nocount off
end
else
begin
	print 'userAuditActions table already contains Delete Queue entry'
end

go