/*
	Purpose: Set values that have blanks or dashes to null, or delete them if doing so violates the unqiue key constraint.
	Records that violate the unique constraint when fixed should not exist. This script keeps the existing correct row.
	Not running this script will cause IvrSearchConfigs to work on data created after CTG-9603 updates, 
	but not on old data as rows were incorrectly being inserted with blank values (and sometimes placeholder dashes) instead of null.
*/

BEGIN TRAN;

-- Delete duplicates based on what the unique key will look like after '' and '-' are converted to NULL.
WITH normalized AS
(
    SELECT
        crudId,
        ROW_NUMBER() OVER
        (
            PARTITION BY
				[applicationId], -- always id
				[languageId], -- always id or null
                NULLIF(NULLIF([dnis], ''), '-'),
                NULLIF(NULLIF([destination], ''), '-'),
				NULLIF(NULLIF([rank], ''), '-'),
				NULLIF(NULLIF([offerId], ''), '-'),
				NULLIF(NULLIF([offerType], ''), '-')
            ORDER BY crudId
        ) AS rn
    FROM [crud].[configurations]
)
DELETE FROM normalized
WHERE rn > 1;

COMMIT;

-- iterate over columns and fix values per-column
BEGIN TRAN;

	DECLARE @TableName NVARCHAR(128) = 'configurations';
	DECLARE @ColumnName NVARCHAR(128);
	DECLARE @Schema NVARCHAR(128) = 'crud';
	DECLARE @SQL NVARCHAR(MAX) = N'';

	DECLARE col_cursor CURSOR FOR
	SELECT COLUMN_NAME
	FROM information_schema.columns
	WHERE TABLE_NAME = @TableName
		AND TABLE_SCHEMA = @Schema
		AND COLUMN_NAME not in ('crudId', 'lastModifiedDateTime');

	OPEN col_cursor;
	FETCH NEXT FROM col_cursor INTO @ColumnName;
	WHILE @@FETCH_STATUS = 0
	BEGIN

		SET @SQL = @SQL +
		N'UPDATE ' + QUOTENAME(@Schema) + N'.' + QUOTENAME(@TableName) + N' ' +
		N'SET ' + QUOTENAME(@ColumnName) + N' = NULL ' +
		N'WHERE ' + QUOTENAME(@ColumnName) + N' in('''', ''-'');';

		FETCH NEXT FROM col_cursor INTO @ColumnName;

	END
	CLOSE col_cursor;
	DEALLOCATE col_cursor;

	EXEC sp_executesql @SQL
		
COMMIT;