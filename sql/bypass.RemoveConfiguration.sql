/* drop procedure RemoveConfiguration */
if not exists (select * from sys.procedures where name = 'RemoveConfiguration' and schema_name(schema_id) = 'bypass')
begin
   print 'Creating emtpy RemoveConfiguration stored procedure'
   execute('create procedure [bypass].[RemoveConfiguration] as select 1')
end
GO

print 'Altering stored procedure RemoveConfiguration to latest version'
GO

ALTER PROCEDURE [bypass].[RemoveConfiguration] (
	@bypassConfigurationId INT
)
AS
BEGIN
	SET NOCOUNT ON;

	-- Optional: output the record before deletion
	SELECT [bypassConfigurationId]
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
	FROM [bypass].[configurations]
	WHERE [bypassConfigurationId] = @bypassConfigurationId;

	-- Delete the configuration
	DELETE FROM [bypass].[configurations]
	WHERE [bypassConfigurationId] = @bypassConfigurationId;

	-- Return the deleted row (if needed)
	SELECT * FROM #DeletedConfig;

	DROP TABLE #DeletedConfig;
END

GO

