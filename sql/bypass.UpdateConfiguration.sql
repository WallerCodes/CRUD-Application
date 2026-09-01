/* drop procedure UpdateConfiguration */
if not exists (select * from sys.procedures where name = 'UpdateConfiguration' and schema_name(schema_id) = 'bypass')
begin
   print 'Creating emtpy UpdateConfiguration stored procedure'
   execute('create procedure [bypass].[UpdateConfiguration] as select 1')
end
GO

print 'Altering stored procedure UpdateConfiguration to latest version'
GO

ALTER PROCEDURE [bypass].[UpdateConfiguration] (
	@configurationId INT
	,@applicationName VARCHAR(32)
	,@languageName VARCHAR(32)
	,@dnis VARCHAR(32)
	,@destination VARCHAR(32)
	,@rank VARCHAR(6)
	,@offerId VARCHAR(8)
	,@offerType VARCHAR(128)
	,@peg VARCHAR(128)
	,@skillId VARCHAR(16)
	,@skillName VARCHAR(64)
	,@agentsAvailable INT
	,@med INT
	,@overflowSkillId VARCHAR(16)
	,@overflowSkillName VARCHAR(64)
	,@overflowAgentsAvailable INT
	,@overflowMed INT
	,@lastModifiedUserName VARCHAR(32)
	,@order INT = NULL
	)
AS
BEGIN
	SET NOCOUNT ON;

	-- Declare and populate IDs
	DECLARE @applicationId INT
		,@languageId INT
		,@lastModifiedUserId INT;

	SELECT @applicationId = applicationId
	FROM bypass.applications
	WHERE application = @applicationName;

	SELECT @languageId = languageId
	FROM bypass.languages
	WHERE LANGUAGE = @languageName;

	SELECT @lastModifiedUserId = userId
	FROM bypass.users
	WHERE userName = @lastModifiedUserName;

	-- Keep order number as is if not specified
	SET @order = ISNULL((
				SELECT [order]
				FROM [bypass].[configurations]
				WHERE [bypassConfigurationId] = @configurationId
				), @order);

	-- Update configuration
	UPDATE [bypass].[configurations]
	SET [applicationId] = @applicationId
		,[languageId] = @languageId
		,[dnis] = @dnis
		,[destination] = @destination
		,[rank] = @rank
		,[offerId] = @offerId
		,[offerType] = @offerType
		,[peg] = @peg
		,[skillId] = @skillId
		,[skillName] = @skillName
		,[agentsAvailable] = @agentsAvailable
		,[med] = @med
		,[overflowSkillId] = @overflowSkillId
		,[overflowSkillName] = @overflowSkillName
		,[overflowAgentsAvailable] = @overflowAgentsAvailable
		,[overflowMed] = @overflowMed
		,[lastModifiedUserId] = @lastModifiedUserId
		,[lastModifiedDateTime] = GETDATE()
		,[order] = @order
	WHERE [bypassConfigurationId] = @configurationId;

	-- Return the updated configuration
	SELECT configs.[bypassConfigurationId]
		,configs.[order]
		,apps.[applicationId]
		,apps.[application]
		,langs.[languageId]
		,langs.[language]
		,configs.[dnis]
		,configs.[destination]
		,configs.[rank]
		,configs.[peg]
		,configs.[offerId]
		,configs.[offerType]
		,configs.[skillId]
		,configs.[skillName]
		,configs.[agentsAvailable]
		,configs.[med]
		,configs.[overflowSkillId]
		,configs.[overflowSkillName]
		,configs.[overflowAgentsAvailable]
		,configs.[overflowMed]
		,configs.[lastModifiedUserId]
		,configs.[lastModifiedDateTime]
	FROM [bypass].[configurations] AS configs
	JOIN [bypass].[applications] AS apps ON apps.[applicationId] = configs.[applicationId]
	JOIN [bypass].[languages] AS langs ON langs.[languageId] = configs.[languageId]
	WHERE configs.[bypassConfigurationId] = @configurationId;
END

GO

