if not exists(select 1 from [crud].[applications] where [application] ='BRANDSCS')
begin
	print 'Adding initial static data for [crud].[applications]'

	set identity_insert [crud].[applications] on
	insert [crud].[applications] ([applicationId], [application], [dateAdded], [userIdAdd]) values (1, 'BRANDSCS', getdate(), -1)
	set identity_insert [crud].[applications] off
end
	
GO

if not exists(select 1 from [crud].[applications] where [application] ='CRSCS')
begin
	print 'Adding CRSCS static data for [crud].[applications]'
	
	set identity_insert [crud].[applications] on
	insert into [crud].[applications] ([applicationId], [application],[dateAdded], [userIdAdd]) values( 2, 'CRSCS', getdate(), -1)
	set identity_insert [crud].[applications] off
end
	
GO

if not exists(select 1 from [crud].[applications] where [application] ='BANKCARDNRI')
begin
	print 'Adding BANKCARDNRI static data for [crud].[applications]'
	
	set identity_insert [crud].[applications] on
	insert into [crud].[applications] ([applicationId], [application],[dateAdded], [userIdAdd]) values( 3, 'BANKCARDNRI', getdate(), -1)
	set identity_insert [crud].[applications] off
end

GO
