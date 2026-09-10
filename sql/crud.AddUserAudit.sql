/* drop procedure AddUserAudit */
IF NOT EXISTS (
		SELECT *
		FROM sys.procedures
		WHERE name = 'AddUserAudit'
			AND schema_name(schema_id) = 'crud'
		)
BEGIN
	PRINT 'Creating emtpy AddUserAudit stored procedure'

	EXECUTE ('create procedure [crud].[AddUserAudit] as select 1')
END
GO

PRINT 'Altering stored procedure AddUserAudit to latest version'
GO

ALTER PROCEDURE [crud].[AddUserAudit] (
	@performerUserId INT
	,@affectedUserId INT
	,@userAuditActionId TINYINT
	,@beforeValue AS VARCHAR(256) = NULL
	,@afterValue AS VARCHAR(256) = NULL
	)
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO [crud].[UserAudits] (
		PerformerUserId
		,AffectedUserId
		,UserAuditActionId
		,BeforeValue
		,AfterValue
		)
	VALUES (
		@performerUserId
		,@affectedUserId
		,@userAuditActionId
		,@beforeValue
		,@afterValue
		);
END;
GO


