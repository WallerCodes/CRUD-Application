declare @languageTable table (
 [language_name] varchar(32)
)
INSERT INTO @languageTable ([language_name]) VALUES
 ('English'),
 ('Spanish'),
 ('French'),
 ('*')
MERGE [bypass].[languages] as [languages] USING @languageTable as [langs]
 ON [langs].[language_name] = [languages].[language]
WHEN NOT MATCHED THEN
 INSERT ([language]) VALUES ([langs].[language_name])
WHEN NOT MATCHED BY SOURCE
 THEN DELETE
;
GO
/* drop procedure IvrSearchConfigs */
if not exists (select * from sys.procedures where name = 'IvrSearchConfigs' and schema_name(schema_id) = 'bypass')
begin
   print 'Creating emtpy IvrSearchConfigs stored procedure'
   execute('create procedure [bypass].[IvrSearchConfigs] as select 1')
end
GO
print 'Altering stored procedure IvrSearchConfigs to latest version'
GO
alter procedure [bypass].[IvrSearchConfigs](
 @appname varchar(32),
 @language varchar(32) = '*',
 @dnis as varchar(32) = '*',
 @destination as varchar(32) = '*',
 @rank as varchar(6) = '*',
 @offerId as varchar(8) = '*',
 @offerType as varchar(128) = '*'
)
as
declare @startTime datetime = CURRENT_TIMESTAMP
if(len(@language) = 1)
begin
 if(@language = 'E')
 begin
  set @language = 'English'
 end
 else if(@language = 'S')
 begin
  set @language = 'Spanish'
 end
 else if(@language = 'F')
 begin
  set @language = 'French'
 end
end
declare @configId int, @order int, @peg varchar(128)
declare @skill varchar(16), @skillName varchar(64), @agents int, @med int
declare @overflowSkill varchar(16), @overflowSkillName varchar(64), @overflowAgents int, @overflowMed int
declare @username varchar(100), @lastModTime datetime
SELECT TOP 1
 @configId = [bypassConfigurationId],
 @order = [order],
 @peg = [peg],
 @skill = [skillId],
 @skillName = [skillName],
 @agents = [agentsAvailable],
 @med = [med],
 @overflowSkill = [overflowSkillId],
 @overflowSkillName = [overflowSkillName],
 @overflowAgents = [overflowAgentsAvailable],
 @overflowMed = [overflowMed],
 @username = [users].[userName],
 @lastModTime = [lastModifiedDateTime]
FROM [bypass].[configurations] as [configs]
JOIN [bypass].[applications] as [apps]
 ON [apps].[applicationId] = [configs].[applicationId]
LEFT OUTER JOIN [bypass].[languages] as [langs]
 ON [langs].[languageId] = [configs].[languageId]
JOIN [bypass].[users] as [users]
 ON [users].[userId] = [configs].[lastModifiedUserId]
WHERE [apps].[application] = @appname
 AND (@language = '*' OR [configs].[languageId] is null OR [langs].[language] IN (@language, '*'))
 AND (@dnis = '*' OR [configs].[dnis] is null OR [configs].[dnis] = '*' OR [configs].[dnis] = @dnis)
 AND (@destination = '*' OR [configs].[destination] is null OR [configs].[destination] = '*' OR [configs].[destination] = @destination)
 AND (@rank = '*' OR [configs].[rank] is null OR [configs].[rank] = '*' OR [configs].[rank] = @rank)
 AND (@offerId = '*' OR [configs].[offerId] is null OR [configs].[offerId] = '*' OR [configs].[offerId] = @offerId)
 AND (@offerType = '*' OR [configs].[offerType] is null OR [configs].[offerType] = '*' OR [configs].[offerType] = @offerType)
ORDER BY [order] ASC
if exists (SELECT TOP 1 [TraceIvrSearch] FROM [databaseConfiguration] WHERE [TraceIvrSearch] = 1)
begin
 declare @duration int = datediff(ms, @startTime, CURRENT_TIMESTAMP)
 INSERT INTO [ivrSearchTrace] (
  [duration],
  [appName],
  [language],
  [dnis],
  [destination],
  [rank],
  [offerId],
  [offerType],
  [bypassConfigurationId],
  [order])
 VALUES (
  @duration,
  @appname,
  @language,
  @dnis,
  @destination,
  @rank,
  @offerId,
  @offerType,
  @configId,
  @order
 )
end
SELECT @configId as [bypassConfigurationId],
 @order as [order],
 @peg as [peg],
 @skill as [skillId],
 @skillName as [skillName],
 @agents as [agentsAvailable],
 @med as [med],
 @overflowSkill as [overflowSkillId],
 @overflowSkillName as [overflowSkillName],
 @overflowAgents as [overflowAgentsAvailable],
 @overflowMed as [overflowMed],
 @username as [userName],
 @lastModTime as [lastModifiedDateTime]
GO
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
        bypassConfigurationId,
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
            ORDER BY bypassConfigurationId
        ) AS rn
    FROM [bypass].[configurations]
)
DELETE FROM normalized
WHERE rn > 1;
COMMIT;
-- iterate over columns and fix values per-column
BEGIN TRAN;
 DECLARE @TableName NVARCHAR(128) = 'configurations';
 DECLARE @ColumnName NVARCHAR(128);
 DECLARE @Schema NVARCHAR(128) = 'bypass';
 DECLARE @SQL NVARCHAR(MAX) = N'';
 DECLARE col_cursor CURSOR FOR
 SELECT COLUMN_NAME
 FROM information_schema.columns
 WHERE TABLE_NAME = @TableName
  AND TABLE_SCHEMA = @Schema
  AND COLUMN_NAME not in ('bypassConfigurationId', 'lastModifiedDateTime');
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
