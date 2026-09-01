/* drop procedure GetUser */
if not exists (select * from sys.procedures where name = 'GetUser' and schema_name(schema_id) = 'bypass')
begin
   print 'Creating emtpy GetUser stored procedure'
   execute('create procedure [bypass].[GetUser] as select 1')
end
GO

print 'Altering stored procedure GetUser to latest version'
GO

alter procedure [bypass].[GetUser](
	@userId int = null,
	@userName varchar(100) = null
)
as

if(@userId is not null)
begin
	SELECT [userId], 
		[userName],
		[password],
		[deleted],
		[disabled],
		[isSuperAdmin],
		[isUsanUser],
		[lastLoginDate],
		[locked],
		[failedLoginAttempts],
		[lastPasswordChangeDate],
		[forceChangePassword],
		[dateAdded]
	FROM [bypass].[users] WHERE [userId] = @userId
end
else if(@userName is not null)
begin
	SELECT [userId], 
		[userName],
		[password],
		[deleted],
		[disabled],
		[isSuperAdmin],
		[isUsanUser],
		[lastLoginDate],
		[locked],
		[failedLoginAttempts],
		[lastPasswordChangeDate],
		[forceChangePassword],
		[dateAdded]
	FROM [bypass].[users] WHERE [userName] = @username
end

GO

