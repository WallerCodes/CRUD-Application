/* drop function GetRolesByUserId */
IF NOT EXISTS (
		SELECT *
		FROM sys.objects
		WHERE name = 'GetRolesByUserId'
			AND schema_name(schema_id) = 'crud'
		)
BEGIN
	PRINT 'Creating emtpy GetRolesByUserId function'

	EXECUTE ('CREATE FUNCTION [crud].[GetRolesByUserId] (@userId INT) RETURNS TABLE AS RETURN (SELECT 1 AS placeholder)')
END
GO

PRINT 'Altering function GetRolesByUserId to latest version'
GO

ALTER FUNCTION [crud].[GetRolesByUserId] (@userId INT)
RETURNS TABLE
AS
RETURN

SELECT a.userid
	,a.applicationid
	,roles = STUFF((
			SELECT ',' + y.name
			FROM crud.userRoles x
			JOIN crud.roles y ON x.roleid = y.roleid
			WHERE x.userid = a.userid
				AND x.applicationId = a.applicationId
			FOR XML PATH('')
			), 1, 1, '')
FROM crud.userRoles a
JOIN crud.roles b ON a.roleId = b.roleId
JOIN crud.applications c ON a.applicationId = c.applicationId
WHERE userId = @userId
GROUP BY a.userid
	,a.applicationid
GO