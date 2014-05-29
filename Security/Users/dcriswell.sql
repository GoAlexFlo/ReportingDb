IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'dcriswell')
CREATE LOGIN [dcriswell] WITH PASSWORD = 'p@ssw0rd'
GO
CREATE USER [dcriswell] FOR LOGIN [dcriswell]
GO
