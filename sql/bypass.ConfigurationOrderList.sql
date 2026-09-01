IF TYPE_ID(N'bypass.ConfigurationOrderList') IS NULL
BEGIN
    CREATE TYPE [bypass].[ConfigurationOrderList] AS TABLE(
        [configurationId] [int] NULL,
        [order] [int] NULL
    )
    PRINT 'User-defined table type [bypass].[ConfigurationOrderList] created successfully.'
END
ELSE
BEGIN
    PRINT 'User-defined table type [bypass].[ConfigurationOrderList] already exists. No action taken.'
END
GO