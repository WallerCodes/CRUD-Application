/* drop procedure GetUserRoles */
IF NOT EXISTS (
		SELECT *
		FROM sys.procedures
		WHERE name = 'GetUserRoles'
			AND schema_name(schema_id) = 'bypass'
		)
BEGIN
	PRINT 'Creating emtpy GetUserRoles stored procedure'

	EXECUTE ('create procedure [bypass].[GetUserRoles] as select 1')
END
GO

PRINT 'Altering stored procedure GetUserRoles to latest version'
GO

ALTER PROCEDURE [bypass].[GetUserRoles] (@userId INT)
AS
BEGIN
	SELECT users.userId
		,application
		,roles
	FROM bypass.applications AS apps
	LEFT JOIN bypass.[GetRolesByUserId](@userId) AS fnUser ON apps.applicationId = fnUser.applicationId
	LEFT JOIN bypass.users AS users ON users.userId = @userId
END
GO


