IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'hibernate')
CREATE LOGIN [hibernate] WITH PASSWORD = 'p@ssw0rd'
GO
CREATE USER [hibernate] FOR LOGIN [hibernate]
GO
