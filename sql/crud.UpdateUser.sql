/* drop procedure UpdateUser */
if not exists (select * from sys.procedures where name = 'UpdateUser' and schema_name(schema_id) = 'crud')
begin
   print 'Creating emtpy UpdateUser stored procedure'
   execute('create procedure [crud].[UpdateUser] as select 1')
end
GO

print 'Altering stored procedure UpdateUser to latest version'
GO

alter procedure [crud].[UpdateUser](
	@userId int,
	@pwd as varchar(256) = null,

	@delete bit = null,
	@disable bit = null,
	@isSuperAdmin bit = null,
	@isUsanUser bit = null,
	@locked bit = null,
	@forceChangePassword bit = null,

	@failedLoginAttempts int = null,
	@lastLoginDate datetime = null
)
as

set nocount on
UPDATE [crud].[users] 
SET [password] = (case when @pwd is not null then @pwd else [password] end),
	[deleted] = (case when @delete is not null then @delete else [deleted] end),
	[disabled] = (case when @disable is not null then @disable else [disabled] end),
	[isSuperAdmin] = (case when @isSuperAdmin is not null then @isSuperAdmin else [isSuperAdmin] end),
	[isUsanUser] = (case when @isUsanUser is not null then @isUsanUser else [isUsanUser] end),
	[locked] = (case when @locked is not null then @locked else [locked] end),
	[forceChangePassword] = 
		(case when @forceChangePassword is not null then @forceChangePassword 
			when @pwd is not null then 0
			else [forceChangePassword] end),
	[lastPasswordChangeDate] = (case when @pwd is not null then getdate() else [lastPasswordChangeDate] end),
	[failedLoginAttempts] = (case when @failedLoginAttempts is not null then @failedLoginAttempts else [failedLoginAttempts] end),
	[lastLoginDate] = (
        CASE
            WHEN @lastLoginDate = '1753-01-01 00:00:00.000' THEN GETDATE() -- Special placeholder that tells us to get the current date
            WHEN @lastLoginDate IS NULL THEN [lastLoginDate]
            ELSE @lastLoginDate
        END
    )
WHERE [userId] = @userId

EXECUTE [crud].[GetUser] @userId

GO

