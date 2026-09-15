USE master
GO

if not exists(select* from sysdatabases where name = 'crud')
begin
print 'Creating crud database.'

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

execute xp_cmdshell 'mkdir c:\databases\crud'

CREATE DATABASE crud
ON
(NAME = 'crud_Data1',
  FILENAME = 'c:\databases\crud\crud_Data1.MDF',
  SIZE = 10240MB,
  FILEGROWTH = 5120MB )
LOG ON
(NAME = 'crud_Log',
  FILENAME = 'c:\databases\crud\crud_Log.LDF',
  SIZE = 1GB,
  FILEGROWTH = 500MB )

if CONVERT(VARCHAR(128), SERVERPROPERTY('productversion')) like '8%'
   or CONVERT(VARCHAR(128), SERVERPROPERTY('productversion')) like '9%'
   or CONVERT(VARCHAR(128), SERVERPROPERTY('productversion')) like '10.0%'
   or CONVERT(VARCHAR(128), SERVERPROPERTY('productversion')) like '10.5%'
begin
   execute sp_dboption 'crud', 'select into/bulkcopy', 'FALSE'
   execute sp_dboption 'crud', 'trunc. log on chkpt.', 'TRUE'
end
alter database crud
set recovery full

end else begin
print 'crud database exists'
end

GO

USE crud
GO
