/* drop table [crud].[configurations] */
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
-- TABLE CREATION --
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
IF NOT EXISTS (
		SELECT *
		FROM sys.tables
		WHERE name = 'configurations'
			AND schema_id = (
				SELECT schema_id
				FROM sys.schemas
				WHERE name = 'crud'
				)
		)
BEGIN
	PRINT 'Creating configurations table'

	CREATE TABLE [crud].[configurations] (
		[crudConfigurationId] INT NOT NULL identity(1, 1)
		,[order] INT NOT NULL
		,[applicationId] INT NOT NULL
		,[languageId] INT
		,[dnis] VARCHAR(32)
		,[destination] VARCHAR(32)
		,[rank] VARCHAR(6)
		,[offerId] VARCHAR(8)
		,[offerType] VARCHAR(128)
		,[peg] VARCHAR(128)
		,[skillId] VARCHAR(16)
		,[skillName] VARCHAR(64)
		,[agentsAvailable] INT
		,[med] INT
		,[overflowSkillId] VARCHAR(16)
		,[overflowSkillName] VARCHAR(64)
		,[overflowAgentsAvailable] INT
		,[overflowMed] INT
		,[lastModifiedUserId] INT NOT NULL
		,[lastModifiedDateTime] DATETIME NOT NULL
		) ON [PRIMARY]
END
ELSE
BEGIN
	PRINT 'configurations table already exists'
END

--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
-- NULL CONSTRAINTS --
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
IF EXISTS (
		SELECT *
		FROM sys.columns
		WHERE object_id = object_id('[crud].[configurations]')
			AND name = 'crudConfigurationId'
			AND is_nullable = 1
		)
BEGIN
	PRINT 'Converting column crudConfigurationId in configurations to disallow nulls'

	ALTER TABLE [crud].[configurations]

	ALTER COLUMN [crudConfigurationId] INT NOT NULL
END
ELSE
BEGIN
	PRINT '	Column crudConfigurationId already in configurations already disallows nulls'
END

IF EXISTS (
		SELECT *
		FROM sys.columns
		WHERE object_id = object_id('[crud].[configurations]')
			AND name = 'order'
			AND is_nullable = 1
		)
BEGIN
	PRINT 'Converting column order in configurations to disallow nulls'

	ALTER TABLE [crud].[configurations]

	ALTER COLUMN [order] INT NOT NULL
END
ELSE
BEGIN
	PRINT '	Column order already in configurations already disallows nulls'
END

IF EXISTS (
		SELECT *
		FROM sys.columns
		WHERE object_id = object_id('[crud].[configurations]')
			AND name = 'applicationId'
			AND is_nullable = 1
		)
BEGIN
	PRINT 'Converting column applicationId in configurations to disallow nulls'

	ALTER TABLE [crud].[configurations]

	ALTER COLUMN [applicationId] INT NOT NULL
END
ELSE
BEGIN
	PRINT '	Column applicationId already in configurations already disallows nulls'
END

IF EXISTS (
		SELECT *
		FROM sys.columns
		WHERE object_id = object_id('[crud].[configurations]')
			AND name = 'languageId'
			AND is_nullable = 0
		)
BEGIN
	PRINT 'Converting column languageId in configurations to allow nulls'

	ALTER TABLE [crud].[configurations]

	ALTER COLUMN [languageId] INT NULL
END
ELSE
BEGIN
	PRINT '	Column languageId already in configurations already allows nulls'
END

IF EXISTS (
		SELECT *
		FROM sys.columns
		WHERE object_id = object_id('[crud].[configurations]')
			AND name = 'dnis'
			AND is_nullable = 0
		)
BEGIN
	PRINT 'Converting column dnis in configurations to allow nulls'

	ALTER TABLE [crud].[configurations]

	ALTER COLUMN [dnis] VARCHAR(32) NULL
END
ELSE
BEGIN
	PRINT '	Column dnis already in configurations already allows nulls'
END

IF EXISTS (
		SELECT *
		FROM sys.columns
		WHERE object_id = object_id('[crud].[configurations]')
			AND name = 'destination'
			AND is_nullable = 0
		)
BEGIN
	PRINT 'Converting column destination in configurations to allow nulls'

	ALTER TABLE [crud].[configurations]

	ALTER COLUMN [destination] VARCHAR(32) NULL
END
ELSE
BEGIN
	PRINT '	Column destination already in configurations already allows nulls'
END

IF EXISTS (
		SELECT *
		FROM sys.columns
		WHERE object_id = object_id('[crud].[configurations]')
			AND name = 'rank'
			AND is_nullable = 0
		)
BEGIN
	PRINT 'Converting column rank in configurations to allow nulls'

	ALTER TABLE [crud].[configurations]

	ALTER COLUMN [rank] INT NULL
END
ELSE
BEGIN
	PRINT '	Column rank already in configurations already allows nulls'
END

IF EXISTS (
		SELECT *
		FROM sys.columns
		WHERE object_id = object_id('[crud].[configurations]')
			AND name = 'offerId'
			AND is_nullable = 0
		)
BEGIN
	PRINT 'Converting column offerId in configurations to allow nulls'

	ALTER TABLE [crud].[configurations]

	ALTER COLUMN [offerId] INT NULL
END
ELSE
BEGIN
	PRINT '	Column offerId already in configurations already allows nulls'
END

IF EXISTS (
		SELECT *
		FROM sys.columns
		WHERE object_id = object_id('[crud].[configurations]')
			AND name = 'offerType'
			AND is_nullable = 0
		)
BEGIN
	PRINT 'Converting column offerType in configurations to allow nulls'

	ALTER TABLE [crud].[configurations]

	ALTER COLUMN [offerType] INT NULL
END
ELSE
BEGIN
	PRINT '	Column offerType already in configurations already allows nulls'
END

IF EXISTS (
		SELECT *
		FROM sys.columns
		WHERE object_id = object_id('[crud].[configurations]')
			AND name = 'skillId'
			AND is_nullable = 0
		)
BEGIN
	PRINT 'Converting column skillId in configurations to allow nulls'

	ALTER TABLE [crud].[configurations]

	ALTER COLUMN [skillId] VARCHAR(16) NULL
END
ELSE
BEGIN
	PRINT '	Column skillId already in configurations already allows nulls'
END

IF EXISTS (
		SELECT *
		FROM sys.columns
		WHERE object_id = object_id('[crud].[configurations]')
			AND name = 'skillName'
			AND is_nullable = 0
		)
BEGIN
	PRINT 'Converting column skillName in configurations to allow nulls'

	ALTER TABLE [crud].[configurations]

	ALTER COLUMN [skillName] VARCHAR(64) NULL
END
ELSE
BEGIN
	PRINT '	Column skillName already in configurations already allows nulls'
END

IF EXISTS (
		SELECT *
		FROM sys.columns
		WHERE object_id = object_id('[crud].[configurations]')
			AND name = 'agentsAvailable'
			AND is_nullable = 0
		)
BEGIN
	PRINT 'Converting column agentsAvailable in configurations to allow nulls'

	ALTER TABLE [crud].[configurations]

	ALTER COLUMN [agentsAvailable] INT NULL
END
ELSE
BEGIN
	PRINT '	Column agentsAvailable already in configurations already allows nulls'
END

IF EXISTS (
		SELECT *
		FROM sys.columns
		WHERE object_id = object_id('[crud].[configurations]')
			AND name = 'med'
			AND is_nullable = 0
		)
BEGIN
	PRINT 'Converting column med in configurations to allow nulls'

	ALTER TABLE [crud].[configurations]

	ALTER COLUMN [med] INT NULL
END
ELSE
BEGIN
	PRINT '	Column med already in configurations already allows nulls'
END

IF EXISTS (
		SELECT *
		FROM sys.columns
		WHERE object_id = object_id('[crud].[configurations]')
			AND name = 'overflowSkillId'
			AND is_nullable = 0
		)
BEGIN
	PRINT 'Converting column overflowSkillId in configurations to allow nulls'

	ALTER TABLE [crud].[configurations]

	ALTER COLUMN [overflowSkillId] VARCHAR(64) NULL
END
ELSE
BEGIN
	PRINT '	Column overflowSkillId already in configurations already allows nulls'
END

IF EXISTS (
		SELECT *
		FROM sys.columns
		WHERE object_id = object_id('[crud].[configurations]')
			AND name = 'overflowSkillName'
			AND is_nullable = 0
		)
BEGIN
	PRINT 'Converting column overflowSkillName in configurations to allow nulls'

	ALTER TABLE [crud].[configurations]

	ALTER COLUMN [overflowSkillName] VARCHAR(64) NULL
END
ELSE
BEGIN
	PRINT '	Column overflowSkillName already in configurations already allows nulls'
END

IF EXISTS (
		SELECT *
		FROM sys.columns
		WHERE object_id = object_id('[crud].[configurations]')
			AND name = 'overflowAgentsAvailable'
			AND is_nullable = 0
		)
BEGIN
	PRINT 'Converting column overflowAgentsAvailable in configurations to allow nulls'

	ALTER TABLE [crud].[configurations]

	ALTER COLUMN [overflowAgentsAvailable] INT NULL
END
ELSE
BEGIN
	PRINT '	Column overflowAgentsAvailable already in configurations already allows nulls'
END

IF EXISTS (
		SELECT *
		FROM sys.columns
		WHERE object_id = object_id('[crud].[configurations]')
			AND name = 'overflowMed'
			AND is_nullable = 0
		)
BEGIN
	PRINT 'Converting column overflowMed in configurations to allow nulls'

	ALTER TABLE [crud].[configurations]

	ALTER COLUMN [overflowMed] INT NULL
END
ELSE
BEGIN
	PRINT '	Column overflowMed already in configurations already allows nulls'
END

IF EXISTS (
		SELECT *
		FROM sys.columns
		WHERE object_id = object_id('[crud].[configurations]')
			AND name = 'lastModifiedUserId'
			AND is_nullable = 1
		)
BEGIN
	PRINT 'Converting column lastModifiedUserId in configurations to disallow nulls'

	ALTER TABLE [crud].[configurations]

	ALTER COLUMN [lastModifiedUserId] INT NOT NULL
END
ELSE
BEGIN
	PRINT '	Column lastModifiedUserId already in configurations already disallows nulls'
END

IF EXISTS (
		SELECT *
		FROM sys.columns
		WHERE object_id = object_id('[crud].[configurations]')
			AND name = 'lastModifiedDateTime'
			AND is_nullable = 1
		)
BEGIN
	PRINT 'Converting column lastModifiedDateTime in configurations to disallow nulls'

	ALTER TABLE [crud].[configurations]

	ALTER COLUMN [lastModifiedDateTime] DATETIME NOT NULL
END
ELSE
BEGIN
	PRINT '	Column lastModifiedDateTime already in configurations already disallows nulls'
END

--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
-- DEFAULT CONSTRAINTS --
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
IF EXISTS (
		SELECT *
		FROM sys.columns
		WHERE object_id = object_id('[crud].[configurations]')
			AND name = 'lastModifiedDateTime'
			AND [default_object_id] = 0
		)
BEGIN
	PRINT 'Creating default constraint on configurations.lastModifiedDateTime'

	ALTER TABLE [crud].[configurations] ADD CONSTRAINT [configurationsLastModifiedDateTimeDefault] DEFAULT(getdate())
	FOR [lastModifiedDateTime]
END
ELSE
BEGIN
	PRINT 'Default constraint already exists for configurations.lastModifiedDateTime'
END

--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
-- CHECK CONSTRAINTS --
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
-- PRIMARY KEY / UNIQUE KEY CONSTRAINTS / INDEXES --
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
DECLARE @idxExists BIT = 0
	,@idxIsUnique BIT = 0
	,@idxIsUniqueConstraint BIT = 0
	,@idxIsPKConstraint BIT = 0
	,@idxType TINYINT = NULL
	,@idxIsClustered BIT = 0
	,@idxShouldBeUnique BIT = 0
	,@idxShouldBeUniqueConstraint BIT = 0
	,@idxShouldBePKConstraint BIT = 0
	,@idxShouldBeClustered BIT = 0
	,
	--the following are used for FKS when the object to be dropped is a PK or a unique constraint
	@dropComm AS VARCHAR(max)
	,@addComm AS VARCHAR(max)
	,@addComm2 AS VARCHAR(max)

--primary key
SET @idxType = NULL

SELECT @idxIsUnique = is_unique
	,@idxIsUniqueConstraint = is_unique_constraint
	,@idxIsPKConstraint = is_primary_key
	,@idxType = type
FROM sys.indexes
WHERE object_id = object_id('[crud].[configurations]')
	AND name = 'configurationsPrimaryKey'

SET @idxExists = CASE 
		WHEN @idxType IS NULL
			THEN 0
		ELSE 1
		END
SET @idxIsClustered = CASE 
		WHEN @idxType = 1
			THEN 1
		ELSE 0
		END
SET @idxIsUnique = isnull(@idxIsUnique, 0)
SET @idxIsUniqueConstraint = isnull(@idxIsUniqueConstraint, 0)
SET @idxIsPKConstraint = isnull(@idxIsPKConstraint, 0)
SET @idxShouldBeUnique = 1
SET @idxShouldBeUniqueConstraint = 0
SET @idxShouldBePKConstraint = 1
SET @idxShouldBeClustered = 1

IF (@idxExists = 0)
BEGIN
	PRINT 'Creating  PK constraint configurationsPrimaryKey on configurations'

	ALTER TABLE [crud].[configurations] ADD CONSTRAINT [configurationsPrimaryKey] PRIMARY KEY CLUSTERED ([crudConfigurationId] ASC)
		WITH (
				PAD_INDEX = OFF
				,ALLOW_PAGE_LOCKS = ON
				,ALLOW_ROW_LOCKS = ON
				,STATISTICS_NORECOMPUTE = OFF
				,IGNORE_DUP_KEY = OFF
				,SORT_IN_TEMPDB = OFF
				) ON [PRIMARY]
END
ELSE IF (
		(@idxIsPKConstraint <> @idxShouldBePKConstraint)
		OR (@idxIsUnique <> @idxShouldBeUnique)
		OR (@idxIsUniqueConstraint <> @idxShouldBeUniqueConstraint)
		OR (@idxIsClustered <> @idxShouldBeClustered)
		)
BEGIN
	PRINT 'Recreating PK constraint configurationsPrimaryKey on configurations'

	IF (
			@idxIsPKConstraint = 1
			OR @idxIsUniqueConstraint = 1
			)
	BEGIN
		EXEC DropAddForeignKeys @tableName = 'configurations'
			,@dropCommands = @dropComm OUTPUT
			,@addCommands = @addComm OUTPUT
			,@addCommands2 = @addComm2 OUTPUT

		EXEC (@dropComm)
	END

	ALTER TABLE [crud].[configurations]

	DROP CONSTRAINT [configurationsPrimaryKey]

	ALTER TABLE [crud].[configurations] ADD CONSTRAINT [configurationsPrimaryKey] PRIMARY KEY CLUSTERED ([dnisId] ASC)
		WITH (
				PAD_INDEX = OFF
				,ALLOW_PAGE_LOCKS = ON
				,ALLOW_ROW_LOCKS = ON
				,STATISTICS_NORECOMPUTE = OFF
				,IGNORE_DUP_KEY = OFF
				,SORT_IN_TEMPDB = OFF
				) ON [PRIMARY]

	IF (
			(
				@idxIsPKConstraint = 1
				OR @idxIsUniqueConstraint = 1
				)
			AND (
				@idxShouldBePKConstraint = 1
				OR @idxShouldBeUniqueConstraint = 1
				)
			)
	BEGIN
		EXEC (@addComm)

		EXEC (@addComm2)
	END
END
ELSE
BEGIN
	PRINT '	PK constraint configurationsPrimaryKey already exists on configurations'
END

--unique constraint - [applicationId], [languageId], [dnis], [destination], [rank], [offerId]
SET @idxType = NULL

SELECT @idxIsUnique = is_unique
	,@idxIsUniqueConstraint = is_unique_constraint
	,@idxIsPKConstraint = is_primary_key
	,@idxType = type
FROM sys.indexes
WHERE object_id = object_id('[crud].[configurations]')
	AND name = 'configurationCombinedUniqueIndex'

SET @idxExists = CASE 
		WHEN @idxType IS NULL
			THEN 0
		ELSE 1
		END
SET @idxIsClustered = CASE 
		WHEN @idxType = 1
			THEN 1
		ELSE 0
		END
SET @idxIsUnique = isnull(@idxIsUnique, 0)
SET @idxIsUniqueConstraint = isnull(@idxIsUniqueConstraint, 0)
SET @idxIsPKConstraint = isnull(@idxIsPKConstraint, 0)
SET @idxShouldBeUnique = 1
SET @idxShouldBeUniqueConstraint = 0
SET @idxShouldBePKConstraint = 0
SET @idxShouldBeClustered = 0

IF (@idxExists = 0)
BEGIN
	PRINT 'Creating index configurationCombinedUniqueIndex on configurations'

	CREATE UNIQUE NONCLUSTERED INDEX [configurationCombinedUniqueIndex] ON [crud].[configurations] (
		[applicationId]
		,[languageId]
		,[dnis]
		,[destination]
		,[rank]
		,[offerId]
		)
		WITH (
				PAD_INDEX = OFF
				,ALLOW_PAGE_LOCKS = ON
				,ALLOW_ROW_LOCKS = ON
				,STATISTICS_NORECOMPUTE = OFF
				,IGNORE_DUP_KEY = OFF
				,SORT_IN_TEMPDB = OFF
				,FILLFACTOR = 70
				) ON [PRIMARY]
END
ELSE IF (
		(@idxIsPKConstraint <> @idxShouldBePKConstraint)
		OR (@idxIsUnique <> @idxShouldBeUnique)
		OR (@idxIsUniqueConstraint <> @idxShouldBeUniqueConstraint)
		OR (@idxIsClustered <> @idxShouldBeClustered)
		)
BEGIN
	PRINT 'Recreating index configurationCombinedUniqueIndex on configurations'

	IF (
			@idxIsPKConstraint = 1
			OR @idxIsUniqueConstraint = 1
			)
	BEGIN
		EXEC DropAddForeignKeys @tableName = 'configurations'
			,@dropCommands = @dropComm OUTPUT
			,@addCommands = @addComm OUTPUT
			,@addCommands2 = @addComm2 OUTPUT

		EXEC (@dropComm)
	END

	ALTER TABLE [crud].[configurations]

	DROP CONSTRAINT [configurationCombinedUniqueIndex]

	CREATE UNIQUE NONCLUSTERED INDEX [configurationCombinedUniqueIndex] ON [crud].[configurations] (
		[applicationId]
		,[languageId]
		,[dnis]
		,[destination]
		,[rank]
		,[offerId]
		)
		WITH (
				PAD_INDEX = OFF
				,ALLOW_PAGE_LOCKS = ON
				,ALLOW_ROW_LOCKS = ON
				,STATISTICS_NORECOMPUTE = OFF
				,IGNORE_DUP_KEY = OFF
				,SORT_IN_TEMPDB = OFF
				,FILLFACTOR = 70
				) ON [PRIMARY]

	IF (
			(
				@idxIsPKConstraint = 1
				OR @idxIsUniqueConstraint = 1
				)
			AND (
				@idxShouldBePKConstraint = 1
				OR @idxShouldBeUniqueConstraint = 1
				)
			)
	BEGIN
		EXEC (@addComm)

		EXEC (@addComm2)
	END
END
ELSE
BEGIN
	PRINT '	Index configurationCombinedUniqueIndex already exists on configurations'
END

--unique constraint - order
SET @idxType = NULL

SELECT @idxIsUnique = is_unique
	,@idxIsUniqueConstraint = is_unique_constraint
	,@idxIsPKConstraint = is_primary_key
	,@idxType = type
FROM sys.indexes
WHERE object_id = object_id('[crud].[configurations]')
	AND name = 'configurationOrderUniqueIndex'

SET @idxExists = CASE 
		WHEN @idxType IS NULL
			THEN 0
		ELSE 1
		END
SET @idxIsClustered = CASE 
		WHEN @idxType = 1
			THEN 1
		ELSE 0
		END
SET @idxIsUnique = isnull(@idxIsUnique, 0)
SET @idxIsUniqueConstraint = isnull(@idxIsUniqueConstraint, 0)
SET @idxIsPKConstraint = isnull(@idxIsPKConstraint, 0)
SET @idxShouldBeUnique = 1
SET @idxShouldBeUniqueConstraint = 0
SET @idxShouldBePKConstraint = 0
SET @idxShouldBeClustered = 0

IF (@idxExists = 0)
BEGIN
	PRINT 'Creating index configurationOrderUniqueIndex on configurations'

	CREATE UNIQUE NONCLUSTERED INDEX [configurationOrderUniqueIndex] ON [crud].[configurations] (
		[applicationId]
		,[order]
		)
		WITH (
				PAD_INDEX = OFF
				,ALLOW_PAGE_LOCKS = ON
				,ALLOW_ROW_LOCKS = ON
				,STATISTICS_NORECOMPUTE = OFF
				,IGNORE_DUP_KEY = OFF
				,SORT_IN_TEMPDB = OFF
				,FILLFACTOR = 70
				) ON [PRIMARY]
END
ELSE IF (
		(@idxIsPKConstraint <> @idxShouldBePKConstraint)
		OR (@idxIsUnique <> @idxShouldBeUnique)
		OR (@idxIsUniqueConstraint <> @idxShouldBeUniqueConstraint)
		OR (@idxIsClustered <> @idxShouldBeClustered)
		)
BEGIN
	PRINT 'Recreating index configurationOrderUniqueIndex on configurations'

	IF (
			@idxIsPKConstraint = 1
			OR @idxIsUniqueConstraint = 1
			)
	BEGIN
		EXEC DropAddForeignKeys @tableName = 'configurations'
			,@dropCommands = @dropComm OUTPUT
			,@addCommands = @addComm OUTPUT
			,@addCommands2 = @addComm2 OUTPUT

		EXEC (@dropComm)
	END

	ALTER TABLE [crud].[configurations]

	DROP CONSTRAINT [configurationOrderUniqueIndex]

	CREATE UNIQUE NONCLUSTERED INDEX [configurationOrderUniqueIndex] ON [crud].[configurations] (
		[applicationId]
		,[order]
		)
		WITH (
				PAD_INDEX = OFF
				,ALLOW_PAGE_LOCKS = ON
				,ALLOW_ROW_LOCKS = ON
				,STATISTICS_NORECOMPUTE = OFF
				,IGNORE_DUP_KEY = OFF
				,SORT_IN_TEMPDB = OFF
				,FILLFACTOR = 70
				) ON [PRIMARY]

	IF (
			(
				@idxIsPKConstraint = 1
				OR @idxIsUniqueConstraint = 1
				)
			AND (
				@idxShouldBePKConstraint = 1
				OR @idxShouldBeUniqueConstraint = 1
				)
			)
	BEGIN
		EXEC (@addComm)

		EXEC (@addComm2)
	END
END
ELSE
BEGIN
	PRINT '	Index configurationOrderUniqueIndex already exists on configurations'
END

--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
-- FOREIGN KEYS - configurations --
--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
IF NOT EXISTS (
		SELECT *
		FROM sys.foreign_keys
		WHERE name = 'configurationsApplicationsForeignKey'
			AND parent_object_id = object_id('[crud].[configurations]')
		)
BEGIN
	PRINT 'Creating foreign key constraint configurationsApplicationsForeignKey for configurations'

	ALTER TABLE [crud].[configurations]
		WITH CHECK ADD CONSTRAINT [configurationsApplicationsForeignKey] FOREIGN KEY ([applicationId]) REFERENCES [crud].[applications]([applicationId])

	ALTER TABLE [crud].[configurations] CHECK CONSTRAINT [configurationsApplicationsForeignKey]
END
ELSE
BEGIN
	PRINT 'Foreign key constraint configurationsApplicationsForeignKey already exists for configurations'
END

IF NOT EXISTS (
		SELECT *
		FROM sys.foreign_keys
		WHERE name = 'configurationsLanguagesForeignKey'
			AND parent_object_id = object_id('[crud].[configurations]')
		)
BEGIN
	PRINT 'Creating foreign key constraint configurationsLanguagesForeignKey for configurations'

	ALTER TABLE [crud].[configurations]
		WITH CHECK ADD CONSTRAINT [configurationsLanguagesForeignKey] FOREIGN KEY ([languageId]) REFERENCES [crud].[languages]([languageId])

	ALTER TABLE [crud].[configurations] CHECK CONSTRAINT [configurationsLanguagesForeignKey]
END
ELSE
BEGIN
	PRINT 'Foreign key constraint configurationsLanguagesForeignKey already exists for configurations'
END
		--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
		-- TRIGGERS --
		--$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########$$$$$$$$$$$###########--
GO


