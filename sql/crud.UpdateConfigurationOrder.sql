/* drop procedure UpdateConfigurationOrder */
if not exists (select * from sys.procedures where name = 'UpdateConfigurationOrder' and schema_name(schema_id) = 'crud')
begin
   print 'Creating emtpy UpdateConfigurationOrder stored procedure'
   execute('create procedure [crud].[UpdateConfigurationOrder] as select 1')
end
GO

print 'Altering stored procedure UpdateConfigurationOrder to latest version'
GO

ALTER PROCEDURE [crud].[UpdateConfigurationOrder] (@ConfigurationOrderList crud.ConfigurationOrderList READONLY)
AS
BEGIN
	SET NOCOUNT ON;

	WITH Numbered
	AS (
		SELECT configurationId
			,ROW_NUMBER() OVER (
				ORDER BY configurationId
				) AS rowNumber
		FROM @ConfigurationOrderList
		)
		,MaxOrder
	AS (
		SELECT MAX([order]) AS maxOrder
		FROM [crud].[configurations]
		)
		
	-- Change the orders of the rows to be updated laters to a new current max value because of unique order constraint
	UPDATE configs
	SET [configs].[order] = maxOrder + rowNumber + 1
	FROM [crud].[configurations] configs
	JOIN Numbered numbered ON configs.crudId = numbered.configurationId
	CROSS JOIN MaxOrder

	-- Update configurations based on the list
	UPDATE configs
	SET configs.[order] = col.[order]
	FROM [crud].[configurations] configs
	INNER JOIN @ConfigurationOrderList col ON configs.[crudId] = col.configurationId;
END

GO
