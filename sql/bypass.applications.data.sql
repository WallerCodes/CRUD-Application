if not exists(select 1 from [bypass].[applications] where [application] ='BRANDSCS')
begin
	print 'Adding initial static data for [bypass].[applications]'

	set identity_insert [bypass].[applications] on
	insert [bypass].[applications] ([applicationId], [application], [dateAdded], [userIdAdd]) values (1, 'BRANDSCS', getdate(), -1)
	set identity_insert [bypass].[applications] off
end
	
GO

if not exists(select 1 from [bypass].[applications] where [application] ='CRSCS')
begin
	print 'Adding CRSCS static data for [bypass].[applications]'
	
	set identity_insert [bypass].[applications] on
	insert into [bypass].[applications] ([applicationId], [application],[dateAdded], [userIdAdd]) values( 2, 'CRSCS', getdate(), -1)
	set identity_insert [bypass].[applications] off
end
	
GO

if not exists(select 1 from [bypass].[applications] where [application] ='BANKCARDNRI')
begin
	print 'Adding BANKCARDNRI static data for [bypass].[applications]'
	
	set identity_insert [bypass].[applications] on
	insert into [bypass].[applications] ([applicationId], [application],[dateAdded], [userIdAdd]) values( 3, 'BANKCARDNRI', getdate(), -1)
	set identity_insert [bypass].[applications] off
end

GO
