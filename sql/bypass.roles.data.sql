if ( not exists (select 1 from bypass.roles ) )
begin
	set identity_insert bypass.roles on
	insert into bypass.roles (  roleId, name, description, dateadded) values ( 1, 'View','View', getdate())
	insert into bypass.roles (  roleId, name, description, dateadded) values ( 2, 'Edit','Edit', getdate())
	insert into bypass.roles (  roleId, name, description, dateadded) values ( 3, 'Update Users','Update Users', getdate())
	set identity_insert bypass.roles off
end

if ( not exists (select 1 from bypass.users ) )
begin
	set identity_insert bypass.users on
	insert into bypass.users (userid, username, deleted, [password], [disabled], isSuperAdmin, isUsanUser, locked,failedloginAttempts, lastPasswordChangeDate, forceChangePassword, dateadded) 
		values (-1, 'SYSTEM', 0, 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3', 0, 1, 1, 0, 0, null, 0, getdate() -1 )
	insert into bypass.users (userid, username, deleted, [password], [disabled], isSuperAdmin, isUsanUser, locked,failedloginAttempts, lastPasswordChangeDate, forceChangePassword, dateadded) 
		values (1, 'arohi.rajput@usan.com', 0, '536e185bb1291d4c62fa0dc61ae9766d1b410d65bdf486073fe3a9d644d33f9f', 0, 1, 1, 0, 0, null, 0, getdate() -1 )
	insert into bypass.users (userid, username, deleted, [password], [disabled], isSuperAdmin, isUsanUser, locked,failedloginAttempts, lastPasswordChangeDate, forceChangePassword, dateadded) 
		values (2, 'chris.loguidice@usan.com', 0, '536e185bb1291d4c62fa0dc61ae9766d1b410d65bdf486073fe3a9d644d33f9f', 0, 1, 1, 0, 0, null, 0, getdate() -1 )
	insert into bypass.users (userid, username, deleted, [password], [disabled], isSuperAdmin, isUsanUser, locked,failedloginAttempts, lastPasswordChangeDate, forceChangePassword, dateadded) 
		values (3, 'kerry.anderson@usan.com', 0, '536e185bb1291d4c62fa0dc61ae9766d1b410d65bdf486073fe3a9d644d33f9f', 0, 1, 1, 0, 0, null, 0, getdate() -1 )
	insert into bypass.users (userid, username, deleted, [password], [disabled], isSuperAdmin, isUsanUser, locked,failedloginAttempts, lastPasswordChangeDate, forceChangePassword, dateadded) 
		values (4, 'noah.wallace@usan.com', 0, '536e185bb1291d4c62fa0dc61ae9766d1b410d65bdf486073fe3a9d644d33f9f', 0, 1, 1, 0, 0, null, 0, getdate() -1 )
	insert into bypass.users (userid, username, deleted, [password], [disabled], isSuperAdmin, isUsanUser, locked,failedloginAttempts, lastPasswordChangeDate, forceChangePassword, dateadded) 
		values (5, 'gina.saucer@citi.com', 0, '536e185bb1291d4c62fa0dc61ae9766d1b410d65bdf486073fe3a9d644d33f9f', 0, 1, 0, 0, 0, null, 0, getdate() -1 )

	set identity_insert bypass.users off
end

--assign admin permissons for all apps
INSERT INTO bypass.userRoles (userId, roleId, applicationId)
SELECT u.userId, r.roleId, a.applicationId
FROM bypass.users u
CROSS JOIN bypass.roles r
CROSS JOIN bypass.applications a
WHERE u.userName IN ('kerry.anderson@usan.com', 'arohi.rajput@usan.com','chris.loguidice@usan.com', 'noah.wallace@usan.com')
AND NOT EXISTS (
    SELECT 1
    FROM bypass.userRoles ur
    WHERE ur.userId = u.userId
      AND ur.roleId = r.roleId
      AND ur.applicationId = a.applicationId
);

