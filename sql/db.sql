USE master
GO

if not exists(select* from sysdatabases where name = 'crudConfiguration')
begin
print 'Creating crudConfiguration database.'

declare @cmdShellActive as integer
declare @showAdvancedActive as integer
declare @cmd as varchar(128)

set @showAdvancedActive = (select cast(value_in_use as integer) from sys.configurations where name = 'show advanced options')
set @cmdShellActive = (select cast(value_in_use as integer) from sys.configurations where name = 'xp_cmdshell')

if (@cmdShellActive = 0)
begin
	if (@showAdvancedActive = 0)
	begin
        execute sp_configure 'show advanced options', 1
		RECONFIGURE
    end


    execute sp_configure 'xp_cmdshell', 1

    RECONFIGURE
end

execute xp_cmdshell 'mkdir e:\databases\crudConfiguration'

CREATE DATABASE crudConfiguration
ON
(NAME = 'crudConfiguration_Data1',
  FILENAME = 'e:\databases\crudConfiguration\crudConfiguration_Data1.MDF',
  SIZE = 20GB,
  FILEGROWTH = 10GB )
LOG ON
(NAME = 'crudConfiguration_Log',
  FILENAME = 'e:\databases\crudConfiguration\crudConfiguration_Log.LDF',
  SIZE = 1GB,
  FILEGROWTH = 500MB )

if CONVERT(VARCHAR(128), SERVERPROPERTY('productversion')) like '8%'
   or CONVERT(VARCHAR(128), SERVERPROPERTY('productversion')) like '9%'
   or CONVERT(VARCHAR(128), SERVERPROPERTY('productversion')) like '10.0%'
   or CONVERT(VARCHAR(128), SERVERPROPERTY('productversion')) like '10.5%'
begin
   execute sp_dboption 'crudConfiguration', 'select into/bulkcopy', 'FALSE'
   execute sp_dboption 'crudConfiguration', 'trunc. log on chkpt.', 'TRUE'
end
alter database crudConfiguration
set recovery full

end else begin
print 'crudConfiguration database exists'
end

GO

USE crudConfiguration
GO
