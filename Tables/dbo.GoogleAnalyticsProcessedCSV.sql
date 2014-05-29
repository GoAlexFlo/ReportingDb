CREATE TABLE [dbo].[GoogleAnalyticsProcessedCSV]
(
[GoogleAnalyticsProcessedCSVId] [int] NOT NULL IDENTITY(1, 1),
[ProfileId] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GaStartDate] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GaEndDate] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CsvFilePath] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CsvFileName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProcessedDate] [datetime] NULL,
[DateAdded] [datetime] NULL
) ON [PRIMARY]
GO
