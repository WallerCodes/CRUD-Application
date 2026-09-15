/* drop procedure AddConfiguration */
if not exists (select * from sys.procedures where name = 'AddConfiguration' and schema_name(schema_id) = 'crud')
begin
   print 'Creating emtpy AddConfiguration stored procedure'
   execute('create procedure [crud].[AddConfiguration] as select 1')
end
GO

print 'Altering stored procedure AddConfiguration to latest version'
GO

ALTER PROCEDURE [crud].[AddConfiguration] (
	@applicationName VARCHAR(32),
	@languageName VARCHAR(32),
	@dnis VARCHAR(32),
	@destination VARCHAR(32),
	@rank VARCHAR(6),
	@offerId VARCHAR(8),
	@offerType VARCHAR(128),
	@peg VARCHAR(128),
	@skillId VARCHAR(16),
	@skillName VARCHAR(64),
	@agentsAvailable INT,
	@med INT,
	@overflowSkillId VARCHAR(16),
	@overflowSkillName VARCHAR(64),
	@overflowAgentsAvailable INT,
	@overflowMed INT,
	@lastModifiedUserName VARCHAR(32),
	@order INT
)
AS
BEGIN
	SET NOCOUNT ON;

	-- Declare and populate IDs
	DECLARE @applicationId INT,
			@languageId INT,
			@lastModifiedUserId INT;

	SELECT @applicationId = applicationId
	FROM crud.applications
	WHERE application = @applicationName;

	SELECT @languageId = languageId
	FROM crud.languages
	WHERE language = @languageName;

	SELECT @lastModifiedUserId = userId
	FROM crud.users
	WHERE userName = @lastModifiedUserName;

	-- Set order if not provided
	IF (@order IS NULL)
	BEGIN
		SET @order = ISNULL((
			SELECT MAX([order]) + 1
			FROM [crud].[configurations]
			WHERE [applicationId] = @applicationId
		), 1);
	END

	-- Insert configuration
	INSERT INTO [crud].[configurations] (
		[applicationId],
		[languageId],
		[dnis],
		[destination],
		[rank],
		[offerId],
		[offerType],
		[peg],
		[skillId],
		[skillName],
		[agentsAvailable],
		[med],
		[overflowSkillId],
		[overflowSkillName],
		[overflowAgentsAvailable],
		[overflowMed],
		[lastModifiedUserId],
		[order]
	)
	VALUES (
		@applicationId,
		@languageId,
		@dnis,
		@destination,
		@rank,
		@offerId,
		@offerType,
		@peg,
		@skillId,
		@skillName,
		@agentsAvailable,
		@med,
		@overflowSkillId,
		@overflowSkillName,
		@overflowAgentsAvailable,
		@overflowMed,
		@lastModifiedUserId,
		@order
	);

	-- Return the newly inserted configuration
	SELECT 
		[crudId],
		[order],
		[apps].[applicationId],
		[apps].[application],
		[langs].[languageId],
		[langs].[language],
		[dnis],
		[destination],
		[rank],
		[peg],
		[offerId],
		[offerType],
		[skillId],
		[skillName],
		[agentsAvailable],
		[med],
		[overflowSkillId],
		[overflowSkillName],
		[overflowAgentsAvailable],
		[overflowMed],
		[lastModifiedUserId],
		[lastModifiedDateTime]
	FROM [crud].[configurations] AS [configs]
	JOIN [crud].[applications] AS [apps] ON [apps].[applicationId] = [configs].[applicationId]
	JOIN [crud].[languages] AS [langs] ON [langs].[languageId] = [configs].[languageId]
	WHERE [configs].[applicationId] = @applicationId
		AND [configs].[languageId] = @languageId
		AND [configs].[dnis] = @dnis
		AND [configs].[destination] = @destination
		AND [configs].[rank] = @rank
		AND [configs].[offerId] = @offerId
		AND [configs].[offerType] = @offerType
		AND [configs].[peg] = @peg
		AND [configs].[skillId] = @skillId
		AND [configs].[skillName] = @skillName
		AND [configs].[agentsAvailable] = @agentsAvailable
		AND [configs].[med] = @med
		AND [configs].[overflowSkillId] = @overflowSkillId
		AND [configs].[overflowSkillName] = @overflowSkillName
		AND [configs].[overflowAgentsAvailable] = @overflowAgentsAvailable
		AND [configs].[overflowMed] = @overflowMed
		AND [configs].[lastModifiedUserId] = @lastModifiedUserId;
END

GO

