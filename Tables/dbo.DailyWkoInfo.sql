CREATE TABLE [dbo].[DailyWkoInfo]
(
[DailyWkoInfoId] [int] NOT NULL IDENTITY(1, 1),
[Sku] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserType] [smallint] NULL,
[WkoCount] [smallint] NULL,
[IsCoached] [smallint] NULL,
[DateAdded] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DailyWkoInfo] ADD CONSTRAINT [DailyWkoInfo_pk] PRIMARY KEY CLUSTERED  ([DailyWkoInfoId]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
