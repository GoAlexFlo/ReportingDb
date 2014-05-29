IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'AD\dcriswell')
CREATE LOGIN [AD\dcriswell] FROM WINDOWS
GO
CREATE USER [AD\dcriswell] FOR LOGIN [AD\dcriswell]
GO
