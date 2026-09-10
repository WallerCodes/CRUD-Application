/* drop procedure GetUserRoles */
IF NOT EXISTS (
		SELECT *
		FROM sys.procedures
		WHERE name = 'GetUserRoles'
			AND schema_name(schema_id) = 'crud'
		)
BEGIN
	PRINT 'Creating emtpy GetUserRoles stored procedure'

	EXECUTE ('create procedure [crud].[GetUserRoles] as select 1')
END
GO

PRINT 'Altering stored procedure GetUserRoles to latest version'
GO

ALTER PROCEDURE [crud].[GetUserRoles] (@userId INT)
AS
BEGIN
	SELECT users.userId
		,application
		,roles
	FROM crud.applications AS apps
	LEFT JOIN crud.[GetRolesByUserId](@userId) AS fnUser ON apps.applicationId = fnUser.applicationId
	LEFT JOIN crud.users AS users ON users.userId = @userId
END
GO


