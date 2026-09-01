/* drop procedure GetUsers */
IF NOT EXISTS (
		SELECT *
		FROM sys.procedures
		WHERE name = 'GetUsers'
			AND schema_name(schema_id) = 'bypass'
		)
BEGIN
	PRINT 'Creating emtpy GetUsers stored procedure'

	EXECUTE ('create procedure [bypass].[GetUsers] as select 1')
END
GO

PRINT 'Altering stored procedure GetUsers to latest version'
GO

ALTER PROCEDURE [bypass].[GetUsers] (
	@userName VARCHAR(100)
	,@deleted BIT
	,@isUsanUser BIT
	,@start INT
	,@limit INT
	,@sortOrder VARCHAR(100) = 'userName'
	,@sortDir VARCHAR(10) = 'asc'
	)
AS
SET NOCOUNT ON

BEGIN
	DECLARE @systemUserId INT = - 1

	SELECT TOP (@limit) userId
		,userName
		,password
		,deleted
		,disabled
		,isSuperAdmin
		,isUsanUser
		,locked
		,forceChangePassword
		,failedLoginAttempts
		,lastPasswordChangeDate
		,lastLoginDate
		,RowNum
	FROM (
		SELECT userId
			,userName
			,password
			,deleted
			,disabled
			,isSuperAdmin
			,isUsanUser
			,locked
			,forceChangePassword
			,failedLoginAttempts
			,lastPasswordChangeDate
			,lastLoginDate
			,ROW_NUMBER() OVER (
				ORDER BY CASE 
						WHEN @sortOrder = 'userName'
							AND @sortDir = 'asc'
							THEN userName
						END ASC
					,CASE 
						WHEN @sortOrder = 'userName'
							AND @sortDir = 'desc'
							THEN userName
						END DESC
					,CASE 
						WHEN @sortOrder = 'isSuperAdmin'
							AND @sortDir = 'asc'
							THEN isSuperAdmin
						END ASC
					,CASE 
						WHEN @sortOrder = 'isSuperAdmin'
							AND @sortDir = 'desc'
							THEN isSuperAdmin
						END DESC
					,CASE 
						WHEN @sortOrder = 'isUsanUser'
							AND @sortDir = 'asc'
							THEN isUsanUser
						END ASC
					,CASE 
						WHEN @sortOrder = 'isUsanUser'
							AND @sortDir = 'desc'
							THEN isUsanUser
						END DESC
					,CASE 
						WHEN @sortOrder = 'lastLoginDate'
							AND @sortDir = 'asc'
							THEN lastLoginDate
						END ASC
					,CASE 
						WHEN @sortOrder = 'lastLoginDate'
							AND @sortDir = 'desc'
							THEN lastLoginDate
						END DESC
				) AS RowNum
		FROM (
			SELECT userId
				,userName
				,password
				,deleted
				,disabled
				,isSuperAdmin
				,isUsanUser
				,locked
				,forceChangePassword
				,failedLoginAttempts
				,lastPasswordChangeDate
				,lastLoginDate
			FROM bypass.users AS users
			WHERE (
					@userName IS NULL
					OR userName LIKE '%' + @userName + '%'
					)
				AND -- Gets every user if there is no user specified in the params
				deleted = @deleted
				AND -- Specify whether we want deleted users to be shown as well since those are retained in the DB still for restoration
				isUsanUser = (
					CASE 
						WHEN @isUsanUser = 1
							THEN isUsanUser
						ELSE 0
						END
					)
				AND -- Either gets all USAN users or only gets non-USAN users if not specified? Look like user cannot determine this value, so this might be a way to keep USAN users in DB but have them be hidden for customer.
				userId != @systemUserId -- Don't want to return SYSTEM user, should be hidden
			) AS q1
		) AS data
	WHERE data.RowNum > @start -- cutting off the first rows returned?
	ORDER BY CASE 
			WHEN @sortOrder = 'userName'
				AND @sortDir = 'asc'
				THEN userName
			END ASC
		,CASE 
			WHEN @sortOrder = 'userName'
				AND @sortDir = 'desc'
				THEN userName
			END DESC
		,CASE 
			WHEN @sortOrder = 'isSuperAdmin'
				AND @sortDir = 'asc'
				THEN isSuperAdmin
			END ASC
		,CASE 
			WHEN @sortOrder = 'isSuperAdmin'
				AND @sortDir = 'desc'
				THEN isSuperAdmin
			END DESC
		,CASE 
			WHEN @sortOrder = 'isUsanUser'
				AND @sortDir = 'asc'
				THEN isUsanUser
			END ASC
		,CASE 
			WHEN @sortOrder = 'isUsanUser'
				AND @sortDir = 'desc'
				THEN isUsanUser
			END DESC
		,CASE 
			WHEN @sortOrder = 'lastLoginDate'
				AND @sortDir = 'asc'
				THEN lastLoginDate
			END ASC
		,CASE 
			WHEN @sortOrder = 'lastLoginDate'
				AND @sortDir = 'desc'
				THEN lastLoginDate
			END DESC

	RETURN
END
GO


