/* drop procedure GetUserAuditHistoryCount */
if not exists (select * from sys.procedures where name = 'GetUserAuditHistoryCount' and schema_name(schema_id) = 'bypass')
begin
   print 'Creating emtpy GetUserAuditHistoryCount stored procedure'
   execute('create procedure [bypass].[GetUserAuditHistoryCount] as select 1')
end
GO

print 'Altering stored procedure GetUserAuditHistoryCount to latest version'
GO

ALTER PROCEDURE [bypass].[GetUserAuditHistoryCount] (
	@affectedUserName VARCHAR(100)
	,@performerUserName VARCHAR(100)
	,@userAuditActionName VARCHAR(100)
	,@startDate DATETIME
	,@endDate DATETIME
	,@isUsanUser INT
	)
AS
SET NOCOUNT ON

BEGIN
	IF @isUsanUser = 1
	BEGIN
		SELECT count(*) AS historyCount
		FROM bypass.[userAudits] AS userAudits
		LEFT OUTER JOIN bypass.users AS performerUser ON performerUser.userId = userAudits.performerUserId
		LEFT OUTER JOIN bypass.users AS affectedUser ON affectedUser.userId = userAudits.affectedUserId
		JOIN bypass_static.userAuditActions ON bypass_static.userAuditActions.userAuditActionId = userAudits.userAuditActionId
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
				AND auditDate > (
					CASE 
						WHEN @startDate = ''
							THEN '1970-01-01'
						ELSE @startDate
						END
					)
				)
			AND afterValue != 'Failed Login'
	END
	ELSE
	BEGIN
		SELECT count(*) AS historyCount
		FROM bypass.[userAudits]
		LEFT OUTER JOIN bypass.users AS performerUser ON performerUser.userId = userAudits.performerUserId
		LEFT OUTER JOIN bypass.users AS affectedUser ON affectedUser.userId = userAudits.affectedUserId
		JOIN bypass_static.userAuditActions ON bypass_static.userAuditActions.userAuditActionId = userAudits.userAuditActionId
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
				AND auditDate > (
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
	END
END

GO
