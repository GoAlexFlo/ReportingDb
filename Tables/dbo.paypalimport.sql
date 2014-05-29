CREATE TABLE [dbo].[paypalimport]
(
[PaypalImportId] [int] NOT NULL IDENTITY(1, 1),
[Total] [int] NOT NULL,
[PaypalDate] [datetime] NOT NULL,
[PersonId] [int] NULL,
[AffiliateCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TransId] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Comment1] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Comment2] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Sku] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AccountNumber] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Type] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Expiration] [char] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OriginalTransId] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PaypalTransactionID] [varchar] (17) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
