if not exists (select * from sys.schemas where name = N'bypass')
begin
   print 'Creating schema bypass'
   execute('create schema [bypass] authorization [dbo]')
end
else
begin
   print 'bypass schema already exists'
end
GO
