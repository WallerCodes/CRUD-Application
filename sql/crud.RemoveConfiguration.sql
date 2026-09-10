/* drop procedure RemoveConfiguration */
if not exists (select * from sys.procedures where name = 'RemoveConfiguration' and schema_name(schema_id) = 'crud')
begin
   print 'Creating emtpy RemoveConfiguration stored procedure'
   execute('create procedure [crud].[RemoveConfiguration] as select 1')
end
GO

print 'Altering stored procedure RemoveConfiguration to latest version'
GO

ALTER PROCEDURE [crud].[RemoveConfiguration] (
	@crudConfigurationId INT
)
AS
BEGIN
	SET NOCOUNT ON;

	-- Optional: output the record before deletion
	SELECT [crudConfigurationId]
		,[order]
		,[applicationId]
		,[languageId]
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
		,[lastModifiedDateTime]
	INTO #DeletedConfig
	FROM [crud].[configurations]
	WHERE [crudConfigurationId] = @crudConfigurationId;

	-- Delete the configuration
	DELETE FROM [crud].[configurations]
	WHERE [crudConfigurationId] = @crudConfigurationId;

	-- Return the deleted row (if needed)
	SELECT * FROM #DeletedConfig;

	DROP TABLE #DeletedConfig;
END

GO

