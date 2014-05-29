CREATE TABLE [dbo].[ErrorLog]
(
[ErrorLogID] [int] NOT NULL IDENTITY(1, 1),
[Date] [datetime] NOT NULL,
[SessionID] [uniqueidentifier] NULL,
[PersonID] [int] NULL,
[Url] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Thread] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Level] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Logger] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CustomMessage] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Exception] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ServerName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Handled] [bit] NOT NULL CONSTRAINT [DF__ErrorLog__Handle__0EA330E9] DEFAULT ((0))
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[ErrorLog] ADD CONSTRAINT [PK_ErrorLogID] PRIMARY KEY CLUSTERED  ([ErrorLogID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_Errorlog_HandledDateLevel] ON [dbo].[ErrorLog] ([Handled], [Date]) INCLUDE ([Level]) ON [PRIMARY]
GO
CREATE FULLTEXT INDEX ON [dbo].[ErrorLog] KEY INDEX [PK_ErrorLogID] ON [ErrorLog]
GO
ALTER FULLTEXT INDEX ON [dbo].[ErrorLog] ADD ([Url] LANGUAGE 1033)
GO
ALTER FULLTEXT INDEX ON [dbo].[ErrorLog] ADD ([CustomMessage] LANGUAGE 1033)
GO
ALTER FULLTEXT INDEX ON [dbo].[ErrorLog] ADD ([Exception] LANGUAGE 1033)
GO
