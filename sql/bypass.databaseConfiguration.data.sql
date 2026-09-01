IF NOT EXISTS(SELECT * FROM [bypass].[databaseConfiguration])
begin
	INSERT INTO [bypass].[databaseConfiguration] DEFAULT VALUES
end

GO