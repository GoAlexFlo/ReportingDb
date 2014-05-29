CREATE TABLE [dbo].[FixSpeedsStats]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[executionDate] [datetime] NOT NULL,
[recordsUpdated] [int] NOT NULL,
[WorkoutIds] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[FixSpeedsStats] ADD CONSTRAINT [PK__FixSpeed__3213E83F08E035F2] PRIMARY KEY CLUSTERED  ([id]) ON [PRIMARY]
GO
