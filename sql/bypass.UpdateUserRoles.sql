/* drop procedure UpdateUserRoles */
if not exists (select * from sys.procedures where name = 'UpdateUserRoles' and schema_name(schema_id) = 'bypass')
begin
   print 'Creating emtpy UpdateUserRoles stored procedure'
   execute('create procedure [bypass].[UpdateUserRoles] as select 1')
end
GO

print 'Altering stored procedure UpdateUserRoles to latest version'
GO

ALTER PROCEDURE [bypass].[UpdateUserRoles] (
	@userId INT
	,@applicationName VARCHAR(100)
	,@accessLevelRead BIT
	,@accessLevelEdit BIT
	,@accessLevelAdmin BIT
	,@accessLevelNone BIT
	)
AS
BEGIN
	BEGIN TRANSACTION

	DECLARE @readStr VARCHAR(10) = 'View'
	DECLARE @editStr VARCHAR(10) = 'Edit'
	DECLARE @adminStr VARCHAR(20) = 'Update Users'
	DECLARE @applicationId INT = (
			SELECT applicationId
			FROM bypass.applications AS applications
			WHERE applications.application = @applicationName
			)
	DECLARE @readRoleId INT = (
			SELECT roleId
			FROM bypass.roles AS roles
			WHERE roles.name = @readStr
			)
	DECLARE @editRoleId INT = (
			SELECT roleId
			FROM bypass.roles AS roles
			WHERE roles.name = @editStr
			)
	DECLARE @adminRoleId INT = (
			SELECT roleId
			FROM bypass.roles AS roles
			WHERE roles.name = @adminStr
			)
	DECLARE @exisitingReadRoleId INT = (
			SELECT roleId
			FROM bypass.userRoles AS ur
			WHERE ur.userId = @userId
				AND ur.applicationId = @applicationId
				AND roleId = @readRoleId
			)
	DECLARE @exisitingEditRoleId INT = (
			SELECT roleId
			FROM bypass.userRoles AS ur
			WHERE ur.userId = @userId
				AND ur.applicationId = @applicationId
				AND roleId = @editRoleId
			)
	DECLARE @exisitingAdminRoleId INT = (
			SELECT roleId
			FROM bypass.userRoles AS ur
			WHERE ur.userId = @userId
				AND ur.applicationId = @applicationId
				AND roleId = @adminRoleId
			)

	IF @accessLevelNone = 1
	BEGIN
		DELETE
		FROM bypass.userRoles
		WHERE userId = @userId
			AND applicationId = @applicationId
			AND roleId IN (
				@readRoleId
				,@editRoleId
				,@adminRoleId
				)
	END
	ELSE
	BEGIN
		IF @exisitingReadRoleId IS NULL
			AND @accessLevelRead = 1
		BEGIN
			INSERT INTO bypass.userRoles (
				userId
				,applicationId
				,roleId
				)
			VALUES (
				@userId
				,@applicationId
				,@readRoleId
				)
		END
		ELSE IF @accessLevelRead = 0
		BEGIN
			DELETE
			FROM bypass.userRoles
			WHERE userId = @userId
				AND applicationId = @applicationId
				AND roleId = @readRoleId
		END

		IF @exisitingEditRoleId IS NULL
			AND @accessLevelEdit = 1
		BEGIN
			INSERT INTO bypass.userRoles (
				userId
				,applicationId
				,roleId
				)
			VALUES (
				@userId
				,@applicationId
				,@editRoleId
				)
		END
		ELSE IF @accessLevelEdit = 0
		BEGIN
			DELETE
			FROM bypass.userRoles
			WHERE userId = @userId
				AND applicationId = @applicationId
				AND roleId = @editRoleId
		END

		IF @exisitingAdminRoleId IS NULL
			AND @accessLevelAdmin = 1
		BEGIN
			INSERT INTO bypass.userRoles (
				userId
				,applicationId
				,roleId
				)
			VALUES (
				@userId
				,@applicationId
				,@adminRoleId
				)
		END
		ELSE IF @accessLevelAdmin = 0
		BEGIN
			DELETE
			FROM bypass.userRoles
			WHERE userId = @userId
				AND applicationId = @applicationId
				AND roleId = @adminRoleId
		END
	END

	COMMIT
END

GO
