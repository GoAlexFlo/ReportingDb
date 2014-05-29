CREATE TABLE [dbo].[MethodPerformanceLog2]
(
[MethodPerformanceID] [int] NOT NULL IDENTITY(1, 1),
[ServerName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DateLogged] [datetime] NOT NULL,
[Namespace] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClassName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MethodName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ElapsedTimeInMilliseconds] [float] NOT NULL,
[P1] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[P2] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[P3] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[P4] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[P5] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[P6] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[P7] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[P8] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[P9] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[P10] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[P11] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[P12] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[P13] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[P14] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[P15] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[MethodPerformanceLog2] ADD CONSTRAINT [PK__MethodPe__0B4C68A8023D5A04] PRIMARY KEY CLUSTERED  ([MethodPerformanceID]) ON [PRIMARY]
GO
