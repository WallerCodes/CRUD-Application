if not exists(select 1 from [crud].[applications] where [application] ='BANKCARDNRI')
begin
	print 'Adding BANKCARDNRI static data for [crud].[applications]'
	
	insert into [crud].[applications] ([application],[dateAdded], [userIdAdd]) values('BANKCARDNRI', getdate(), -1)
end

GO

INSERT INTO crud.userRoles (userId, roleId, applicationId)
SELECT u.userId, r.roleId, a.applicationId
FROM crud.users u
CROSS JOIN crud.roles r
CROSS JOIN crud.applications a
WHERE u.userName IN ('kerry.anderson@usan.com', 'arohi.rajput@usan.com','chris.loguidice@usan.com', 'noah.wallace@usan.com')
AND NOT EXISTS (
    SELECT 1
    FROM crud.userRoles ur
    WHERE ur.userId = u.userId
      AND ur.roleId = r.roleId
      AND ur.applicationId = a.applicationId
);

GO