IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'AD\blantz')
CREATE LOGIN [AD\blantz] FROM WINDOWS
GO
CREATE USER [AD\blantz] FOR LOGIN [AD\blantz]
GO
