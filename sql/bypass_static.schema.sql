if not exists (select * from sys.schemas where name = N'bypass_static')
begin
   print 'Creating schema bypass_static'
   execute('create schema [bypass_static] authorization [dbo]')
end
else
begin
   print 'bypass_static schema already exists'
end
GO


