if ( not exists (select 1 from crud.roles ) )
begin
	set identity_insert crud.roles on
	insert into crud.roles (  roleId, name, description, dateadded) values ( 1, 'View','View', getdate())
	insert into crud.roles (  roleId, name, description, dateadded) values ( 2, 'Edit','Edit', getdate())
	insert into crud.roles (  roleId, name, description, dateadded) values ( 3, 'Admin','Admin', getdate())
	set identity_insert crud.roles off
end

if ( not exists (select 1 from crud.users ) )
begin
	set identity_insert crud.users on
	insert into crud.users (userid, username, deleted, [password], [disabled], isSuperAdmin, isUsanUser, locked,failedloginAttempts, lastPasswordChangeDate, forceChangePassword, dateadded) 
		values (-1, 'SYSTEM', 0, 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3', 0, 1, 1, 0, 0, null, 0, getdate() -1 )
	insert into crud.users (userid, username, deleted, [password], [disabled], isSuperAdmin, isUsanUser, locked,failedloginAttempts, lastPasswordChangeDate, forceChangePassword, dateadded) 
		values (0, 'noah.wallace@usan.com', 0, '536e185bb1291d4c62fa0dc61ae9766d1b410d65bdf486073fe3a9d644d33f9f', 0, 1, 1, 0, 0, null, 0, getdate() -1 )

	set identity_insert crud.users off
end

--assign admin permissions for all apps
INSERT INTO crud.userRoles (userId, roleId, applicationId)
SELECT 0, 3, a.applicationId
FROM crud.users u
CROSS JOIN crud.applications a
WHERE u.userName = 'noah.wallace@usan.com'
AND NOT EXISTS (
    SELECT 1
    FROM crud.userRoles ur
    WHERE ur.userId = u.userId
      AND ur.roleId = 3
      AND ur.applicationId = a.applicationId
);


