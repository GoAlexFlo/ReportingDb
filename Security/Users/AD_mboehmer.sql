IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'AD\mboehmer')
CREATE LOGIN [AD\mboehmer] FROM WINDOWS
GO
CREATE USER [AD\mboehmer] FOR LOGIN [AD\mboehmer]
GO
