/* drop procedure GetConfigurations */
if not exists (select * from sys.procedures where name = 'GetConfigurations' and schema_name(schema_id) = 'bypass')
begin
   print 'Creating emtpy GetConfigurations stored procedure'
   execute('create procedure [bypass].[GetConfigurations] as select 1')
end
GO

print 'Altering stored procedure GetConfigurations to latest version'
GO

ALTER PROCEDURE [bypass].[GetConfigurations] (
	@userName VARCHAR(64)
	,@application VARCHAR(64) = NULL
	,@language VARCHAR(64) = NULL
	,@dnis VARCHAR(64) = NULL
	,@destinationPhoneNumber VARCHAR(64) = NULL
	,@peg VARCHAR(64) = NULL
	,@rank VARCHAR(64) = NULL
	,@offerID VARCHAR(64) = NULL
	,@offerType VARCHAR(64) = NULL
	,@lastModifiedBy VARCHAR(64) = NULL
	,@lastModifiedDate DATETIME = NULL
	)
AS
SELECT [bypassConfigurationId]
	,[order]
	,[apps].[applicationId]
	,[apps].[application]
	,[langs].[languageId]
	,[langs].[language]
	,[dnis]
	,[destination]
	,[rank]
	,[offerId]
	,[offerType]
	,[peg]
	,[skillId]
	,[skillName]
	,[agentsAvailable]
	,[med]
	,[overflowSkillId]
	,[overflowSkillName]
	,[overflowAgentsAvailable]
	,[overflowMed]
	,[lastModifiedUserId]
	,(
		SELECT [userName]
		FROM [bypass].[users]
		WHERE [users].[userId] = [lastModifiedUserId]
		) AS [lastModifiedUserName] -- For getting last modified userId, not the user id of the user calling this SP
	,[lastModifiedDateTime]
FROM [bypass].[configurations] AS [configs]
JOIN [bypass].[applications] AS [apps] ON [apps].[applicationId] = [configs].[applicationId]
LEFT JOIN [bypass].[languages] AS [langs] ON [langs].[languageId] = [configs].[languageId]
JOIN [bypass].[users] AS [users] ON [users].[userName] = @userName
WHERE [configs].[applicationId] IN (
		SELECT [applicationId]
		FROM [bypass].[userRoles] AS ur
		WHERE ur.[userId] = [users].[userId] -- Use the joined UserID
		)
	AND (
		@application IS NULL
		OR [apps].[application] = @application
		)
	AND (
		@language IS NULL
		OR [langs].[language] = @language
		)
	AND (
		@dnis IS NULL
		OR [configs].[dnis] LIKE '%' + @dnis + '%'
		)
	AND (
		@destinationPhoneNumber IS NULL
		OR [configs].[destination] LIKE '%' + @destinationPhoneNumber + '%'
		)
	AND (
		@peg IS NULL
		OR [configs].[peg] LIKE '%' + @peg + '%'
		)
	AND (
		@rank IS NULL
		OR [configs].[rank] LIKE '%' + @rank + '%'
		)
	AND (
		@offerID IS NULL
		OR [configs].[offerId] LIKE '%' + @offerID + '%'
		)
	AND (
		@offerType IS NULL
		OR [configs].[offerType] LIKE '%' + @offerType + '%'
		)
	AND (
		@lastModifiedBy IS NULL
		OR (
			SELECT userName
			FROM bypass.users
			WHERE userId = configs.lastModifiedUserId
			) LIKE '%' + @lastModifiedBy + '%'
		)
	AND (
		@lastModifiedDate IS NULL
		OR CAST([configs].[lastModifiedDateTime] AS DATE) = CAST(@lastModifiedDate AS DATE)
		)
ORDER BY [apps].[applicationId]
	,[order] ASC;

GO