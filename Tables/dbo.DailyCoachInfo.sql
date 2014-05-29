CREATE TABLE [dbo].[DailyCoachInfo]
(
[DailyCoachInfoId] [int] NOT NULL IDENTITY(1, 1),
[GroupName] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GroupOwnerPersonId] [int] NULL,
[GroupOwnerPerson] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CoachingGroupId] [int] NULL,
[BasicAthlete] [smallint] NULL,
[PremiumAs1] [smallint] NULL,
[PremiumAs4] [smallint] NULL,
[CoachCount] [smallint] NULL,
[CompdUBC] [smallint] NULL,
[UBC] [smallint] NULL,
[PaidCoach] [smallint] NULL,
[DemoCoach] [smallint] NULL,
[cvap-1] [float] NULL,
[cvr-1] [float] NULL,
[cv-1] [float] NULL,
[other] [float] NULL,
[DateAdded] [datetime] NULL,
[ForYear] [smallint] NULL,
[ForMonth] [smallint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DailyCoachInfo] ADD CONSTRAINT [DailyCoachInfo_pk] PRIMARY KEY CLUSTERED  ([DailyCoachInfoId]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
