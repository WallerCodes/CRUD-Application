/* drop function GetRolesByUserId */
IF NOT EXISTS (
		SELECT *
		FROM sys.objects
		WHERE name = 'GetRolesByUserId'
			AND schema_name(schema_id) = 'bypass'
		)
BEGIN
	PRINT 'Creating emtpy GetRolesByUserId function'

	EXECUTE ('CREATE FUNCTION [bypass].[GetRolesByUserId] (@userId INT) RETURNS TABLE AS RETURN (SELECT 1 AS placeholder)')
END
GO

PRINT 'Altering function GetRolesByUserId to latest version'
GO

ALTER FUNCTION [bypass].[GetRolesByUserId] (@userId INT)
RETURNS TABLE
AS
RETURN

SELECT a.userid
	,a.applicationid
	,roles = STUFF((
			SELECT ',' + y.name
			FROM bypass.userRoles x
			JOIN bypass.roles y ON x.roleid = y.roleid
			WHERE x.userid = a.userid
				AND x.applicationId = a.applicationId
			FOR XML PATH('')
			), 1, 1, '')
FROM bypass.userRoles a
JOIN bypass.roles b ON a.roleId = b.roleId
JOIN bypass.applications c ON a.applicationId = c.applicationId
WHERE userId = @userId
GROUP BY a.userid
	,a.applicationid
GO