declare @languageTable table (
	[language_name] varchar(32)
)

INSERT INTO @languageTable ([language_name]) VALUES
 ('English'),
 ('Spanish'),
 ('French'),
 ('*')

MERGE [crud].[languages] as [languages] USING @languageTable as [langs]
	ON [langs].[language_name] = [languages].[language]
WHEN NOT MATCHED THEN
	INSERT ([language]) VALUES ([langs].[language_name])
WHEN NOT MATCHED BY SOURCE 
	THEN DELETE
;
GO
