CREATE ROLE [stored_procs]
AUTHORIZATION [dbo]
GO
EXEC sp_addrolemember N'stored_procs', N'AD\blantz'
GO
GRANT EXECUTE TO [stored_procs]
