if not exists (select * from sys.schemas where name = N'crud')
begin
   print 'Creating schema crud'
   execute('create schema [crud] authorization [dbo]')
end
else
begin
   print 'crud schema already exists'
end
GO
