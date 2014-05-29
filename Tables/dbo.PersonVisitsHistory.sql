CREATE TABLE [dbo].[PersonVisitsHistory]
(
[PersonId] [int] NOT NULL,
[GaProfileId] [int] NOT NULL,
[MarketingPreferenceSharedKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserType] [int] NULL,
[VisitDate] [date] NULL,
[DeviceType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DeviceInfo] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NumberOfVisits] [int] NULL,
[IsSampleData] [bit] NULL,
[DateAdded] [datetime] NULL
) ON [PRIMARY]
GO
