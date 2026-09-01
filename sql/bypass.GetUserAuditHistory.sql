/* drop procedure GetUserAuditHistory */
if not exists (select * from sys.procedures where name = 'GetUserAuditHistory' and schema_name(schema_id) = 'bypass')
begin
   print 'Creating emtpy GetUserAuditHistory stored procedure'
   execute('create procedure [bypass].[GetUserAuditHistory] as select 1')
end
GO

print 'Altering stored procedure GetUserAuditHistory to latest version'
GO

ALTER PROCEDURE [bypass].[GetUserAuditHistory] (
	@start INT
	,@limit INT
	,@affectedUserName VARCHAR(100)
	,@performerUserName VARCHAR(100)
	,@userAuditActionName VARCHAR(100)
	,@startDate DATETIME
	,@endDate DATETIME
	,@isUsanUser INT
	,@sortOrder VARCHAR(100) = 'auditDate'
	,@sortDir VARCHAR(10) = 'asc'
	)
AS
SET NOCOUNT ON

BEGIN
	IF @isUsanUser = 1
	BEGIN
		SELECT TOP (@limit) *
		FROM (
			SELECT userAuditId
				,auditDate
				,performerUserId
				,performerUserName
				,affectedUserId
				,affectedUserName
				,userAuditActionId
				,auditDescription
				,afterValue
				,ROW_NUMBER() OVER (
					ORDER BY CASE 
							WHEN @sortOrder = 'auditDate'
								AND @sortDir = 'asc'
								THEN auditDate
							END ASC
						,CASE 
							WHEN @sortOrder = 'auditDate'
								AND @sortDir = 'desc'
								THEN auditDate
							END DESC
						,CASE 
							WHEN @sortOrder = 'performerUserId'
								AND @sortDir = 'asc'
								THEN performerUserId
							END ASC
						,CASE 
							WHEN @sortOrder = 'performerUserId'
								AND @sortDir = 'desc'
								THEN performerUserId
							END DESC
						,CASE 
							WHEN @sortOrder = 'affectedUserId'
								AND @sortDir = 'asc'
								THEN affectedUserId
							END ASC
						,CASE 
							WHEN @sortOrder = 'affectedUserId'
								AND @sortDir = 'desc'
								THEN affectedUserId
							END DESC
						,CASE 
							WHEN @sortOrder = 'auditDescription'
								AND @sortDir = 'asc'
								THEN auditDescription
							END ASC
						,CASE 
							WHEN @sortOrder = 'auditDescription'
								AND @sortDir = 'desc'
								THEN auditDescription
							END DESC
					) AS RowNum
			FROM (
				SELECT userAuditId
					,auditDate
					,performerUserId
					,performerUser.userName AS performerUserName
					,affectedUserId
					,affectedUser.userName AS affectedUserName
					,userAudits.userAuditActionId
					,auditDescription
					,afterValue
				FROM bypass.userAudits AS userAudits
				JOIN bypass_static.userAuditActions ON bypass_static.userAuditActions.userAuditActionId = userAudits.userAuditActionId
				LEFT OUTER JOIN bypass.users AS performerUser ON performerUser.userId = performerUserId
				LEFT OUTER JOIN bypass.users AS affectedUser ON affectedUser.userId = affectedUserId
				WHERE (
						@affectedUserName IS NULL
						OR affectedUser.userName LIKE '%' + @affectedUserName + '%'
						)
					AND (
						@performerUserName IS NULL
						OR performerUser.userName LIKE '%' + @performerUserName + '%'
						)
					AND (
						@userAuditActionName IS NULL
						OR auditDescription LIKE '%' + @userAuditActionName + '%'
						)
					AND (
						auditDate <= (
							CASE 
								WHEN @endDate = ''
									THEN GETDATE()
								ELSE @endDate
								END
							)
						AND auditDate >= (
							CASE 
								WHEN @startDate = ''
									THEN '1970-01-01'
								ELSE @startDate
								END
							)
						)
					AND afterValue != 'Failed Login'
				) AS q1
			) AS data
		WHERE data.RowNum > @start
		ORDER BY CASE 
				WHEN @sortOrder = 'auditDate'
					AND @sortDir = 'asc'
					THEN auditDate
				END ASC
			,CASE 
				WHEN @sortOrder = 'auditDate'
					AND @sortDir = 'desc'
					THEN auditDate
				END DESC
			,CASE 
				WHEN @sortOrder = 'performerUserId'
					AND @sortDir = 'asc'
					THEN performerUserId
				END ASC
			,CASE 
				WHEN @sortOrder = 'performerUserId'
					AND @sortDir = 'desc'
					THEN performerUserId
				END DESC
			,CASE 
				WHEN @sortOrder = 'affectedUserId'
					AND @sortDir = 'asc'
					THEN affectedUserId
				END ASC
			,CASE 
				WHEN @sortOrder = 'affectedUserId'
					AND @sortDir = 'desc'
					THEN affectedUserId
				END DESC
			,CASE 
				WHEN @sortOrder = 'auditDescription'
					AND @sortDir = 'asc'
					THEN auditDescription
				END ASC
			,CASE 
				WHEN @sortOrder = 'auditDescription'
					AND @sortDir = 'desc'
					THEN auditDescription
				END DESC
	END
	ELSE
	BEGIN
		SELECT TOP (@limit) *
		FROM (
			SELECT userAuditId
				,auditDate
				,performerUserId
				,performerUserName
				,affectedUserId
				,affectedUserName
				,userAuditActionId
				,auditDescription
				,afterValue
				,ROW_NUMBER() OVER (
					ORDER BY CASE 
							WHEN @sortOrder = 'auditDate'
								AND @sortDir = 'asc'
								THEN auditDate
							END ASC
						,CASE 
							WHEN @sortOrder = 'auditDate'
								AND @sortDir = 'desc'
								THEN auditDate
							END DESC
						,CASE 
							WHEN @sortOrder = 'performerUserId'
								AND @sortDir = 'asc'
								THEN performerUserId
							END ASC
						,CASE 
							WHEN @sortOrder = 'performerUserId'
								AND @sortDir = 'desc'
								THEN performerUserId
							END DESC
						,CASE 
							WHEN @sortOrder = 'affectedUserId'
								AND @sortDir = 'asc'
								THEN affectedUserId
							END ASC
						,CASE 
							WHEN @sortOrder = 'affectedUserId'
								AND @sortDir = 'desc'
								THEN affectedUserId
							END DESC
						,CASE 
							WHEN @sortOrder = 'auditDescription'
								AND @sortDir = 'asc'
								THEN auditDescription
							END ASC
						,CASE 
							WHEN @sortOrder = 'auditDescription'
								AND @sortDir = 'desc'
								THEN auditDescription
							END DESC
					) AS RowNum
			FROM (
				SELECT userAuditId
					,auditDate
					,performerUserId
					,performerUser.userName AS performerUserName
					,affectedUserId
					,affectedUser.userName AS affectedUserName
					,userAudits.userAuditActionId
					,auditDescription
					,afterValue
					,ROW_NUMBER() OVER (
						ORDER BY CASE 
								WHEN @sortOrder = 'auditDate'
									AND @sortDir = 'asc'
									THEN auditDate
								END ASC
							,CASE 
								WHEN @sortOrder = 'auditDate'
									AND @sortDir = 'desc'
									THEN auditDate
								END DESC
							,CASE 
								WHEN @sortOrder = 'performerUserId'
									AND @sortDir = 'asc'
									THEN performerUserId
								END ASC
							,CASE 
								WHEN @sortOrder = 'performerUserId'
									AND @sortDir = 'desc'
									THEN performerUserId
								END DESC
							,CASE 
								WHEN @sortOrder = 'affectedUserId'
									AND @sortDir = 'asc'
									THEN affectedUserId
								END ASC
							,CASE 
								WHEN @sortOrder = 'affectedUserId'
									AND @sortDir = 'desc'
									THEN affectedUserId
								END DESC
							,CASE 
								WHEN @sortOrder = 'auditDescription'
									AND @sortDir = 'asc'
									THEN auditDescription
								END ASC
							,CASE 
								WHEN @sortOrder = 'auditDescription'
									AND @sortDir = 'desc'
									THEN auditDescription
								END DESC
						) AS RowNum
				FROM bypass.userAudits AS userAudits
				JOIN bypass_static.userAuditActions ON bypass_static.userAuditActions.userAuditActionId = userAudits.userAuditActionId
				LEFT OUTER JOIN bypass.users AS performerUser ON performerUser.userId = performerUserId
				LEFT OUTER JOIN bypass.users AS affectedUser ON affectedUser.userId = affectedUserId
				WHERE (
						@affectedUserName IS NULL
						OR affectedUser.userName LIKE '%' + @affectedUserName + '%'
						)
					AND (
						@performerUserName IS NULL
						OR performerUser.userName LIKE '%' + @performerUserName + '%'
						)
					AND (
						@userAuditActionName IS NULL
						OR auditDescription LIKE '%' + @userAuditActionName + '%'
						)
					AND (
						auditDate <= (
							CASE 
								WHEN @endDate = ''
									THEN GETDATE()
								ELSE @endDate
								END
							)
						AND auditDate >= (
							CASE 
								WHEN @startDate = ''
									THEN '1970-01-01'
								ELSE @startDate
								END
							)
						)
					AND (
						performerUser.isUsanUser = 0
						OR performerUserId IS NULL
						)
					AND (
						affectedUser.isUsanUser = 0
						OR affectedUserId IS NULL
						)
					AND afterValue != 'Failed Login'
				) AS q1
			) AS data
		WHERE data.RowNum > @start
		ORDER BY CASE 
				WHEN @sortOrder = 'auditDate'
					AND @sortDir = 'asc'
					THEN auditDate
				END ASC
			,CASE 
				WHEN @sortOrder = 'auditDate'
					AND @sortDir = 'desc'
					THEN auditDate
				END DESC
			,CASE 
				WHEN @sortOrder = 'performerUserId'
					AND @sortDir = 'asc'
					THEN performerUserId
				END ASC
			,CASE 
				WHEN @sortOrder = 'performerUserId'
					AND @sortDir = 'desc'
					THEN performerUserId
				END DESC
			,CASE 
				WHEN @sortOrder = 'affectedUserId'
					AND @sortDir = 'asc'
					THEN affectedUserId
				END ASC
			,CASE 
				WHEN @sortOrder = 'affectedUserId'
					AND @sortDir = 'desc'
					THEN affectedUserId
				END DESC
			,CASE 
				WHEN @sortOrder = 'auditDescription'
					AND @sortDir = 'asc'
					THEN auditDescription
				END ASC
			,CASE 
				WHEN @sortOrder = 'auditDescription'
					AND @sortDir = 'desc'
					THEN auditDescription
				END DESC
	END

	RETURN
END

GO
