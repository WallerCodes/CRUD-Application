IF TYPE_ID(N'crud.ConfigurationOrderList') IS NULL
BEGIN
    CREATE TYPE [crud].[ConfigurationOrderList] AS TABLE(
        [configurationId] [int] NULL,
        [order] [int] NULL
    )
    PRINT 'User-defined table type [crud].[ConfigurationOrderList] created successfully.'
END
ELSE
BEGIN
    PRINT 'User-defined table type [crud].[ConfigurationOrderList] already exists. No action taken.'
END
GO