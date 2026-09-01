if not exists(select 1 from [bypass].[applications] where [application] ='BANKCARDNRI')
begin
	print 'Adding BANKCARDNRI static data for [bypass].[applications]'
	
	insert into [bypass].[applications] ([application],[dateAdded], [userIdAdd]) values('BANKCARDNRI', getdate(), -1)
end

GO

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

GO