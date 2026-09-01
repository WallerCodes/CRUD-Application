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
