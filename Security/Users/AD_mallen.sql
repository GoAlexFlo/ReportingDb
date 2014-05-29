IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'AD\mallen')
CREATE LOGIN [AD\mallen] FROM WINDOWS
GO
CREATE USER [AD\mallen] FOR LOGIN [AD\mallen]
GO
