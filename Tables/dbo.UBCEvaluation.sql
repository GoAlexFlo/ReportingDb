CREATE TABLE [dbo].[UBCEvaluation]
(
[PersonId] [int] NOT NULL,
[FirstUserType] [int] NULL,
[SecondUserType] [int] NULL,
[UserTypeCount] [int] NULL,
[AccountCreationDate] [smalldatetime] NULL,
[BecameCoachedOn] [datetime] NULL,
[DaysToBecomeCoached] [int] NULL,
[CoachId] [int] NULL,
[CoachingGroupId] [int] NULL,
[CoachInfluencedAccountCreation] [int] NOT NULL,
[UserType6sThat] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SubRevenue] [float] NULL,
[TrainingPlanRevenue] [float] NULL,
[WKORevenue] [float] NULL
) ON [PRIMARY]
GO
