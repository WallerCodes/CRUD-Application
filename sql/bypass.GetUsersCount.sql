/* drop procedure GetUsersCount */
if not exists (select * from sys.procedures where name = 'GetUsersCount' and schema_name(schema_id) = 'bypass')
begin
   print 'Creating emtpy GetUsersCount stored procedure'
   execute('create procedure [bypass].[GetUsersCount] as select 1')
end
GO

print 'Altering stored procedure GetUsersCount to latest version'
GO

ALTER PROCEDURE [bypass].[GetUsersCount] (
	@userName VARCHAR(100)
	,@deleted BIT
	,@isUsanUser BIT
	)
AS
SET NOCOUNT ON

BEGIN
	DECLARE @systemUserId INT = - 1

	SELECT count(*) AS userCount
	FROM bypass.users AS users
	WHERE userName = (
			CASE 
				WHEN @userName IS NULL
					THEN userName
				ELSE @userName
				END
			)
		AND deleted = @deleted
		AND isUsanUser = (
			CASE 
				WHEN @isUsanUser = 1
					THEN isUsanUser
				ELSE 0
				END
			)
		AND userId != @systemUserId
END

GO

