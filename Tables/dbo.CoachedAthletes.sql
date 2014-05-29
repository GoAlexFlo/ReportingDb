CREATE TABLE [dbo].[CoachedAthletes]
(
[Row] [bigint] NULL,
[PersonId] [int] NOT NULL,
[CoachId] [int] NULL,
[CoachingGroupId] [int] NULL,
[CoachedFromDate] [date] NULL,
[CoachedToDate] [date] NULL,
[UserType] [int] NULL,
[IsAthleteUserType1] [int] NOT NULL,
[IsAthleteUserType4] [int] NOT NULL,
[IsAthleteUserType6] [int] NOT NULL,
[IsAthleteTriathlete] [int] NOT NULL,
[IsAthleteRunner] [int] NOT NULL,
[IsAthleteCyclist] [int] NOT NULL,
[IsAthleteOther] [int] NOT NULL
) ON [PRIMARY]
GO
