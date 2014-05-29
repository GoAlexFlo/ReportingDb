IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'dbxtra')
CREATE LOGIN [dbxtra] WITH PASSWORD = 'p@ssw0rd'
GO
CREATE USER [dbxtra] FOR LOGIN [dbxtra]
GO
GRANT EXECUTE TO [dbxtra]
