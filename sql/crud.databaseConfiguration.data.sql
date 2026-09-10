IF NOT EXISTS(SELECT * FROM [crud].[databaseConfiguration])
begin
	INSERT INTO [crud].[databaseConfiguration] DEFAULT VALUES
end

GO