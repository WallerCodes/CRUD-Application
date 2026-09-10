if not exists (select * from sys.schemas where name = N'crud_static')
begin
   print 'Creating schema crud_static'
   execute('create schema [crud_static] authorization [dbo]')
end
else
begin
   print 'crud_static schema already exists'
end
GO


