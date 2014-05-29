SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[sp_DailyWkoInfo]
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @CURRENTDATE DATETIME
	SET @CURRENTDATE = GETDATE()
	DECLARE @ROWCNT INT				

	--IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Reporting].[dbo].[DailyWkoInfo]') AND type in (N'U'))
	--		BEGIN
	--			CREATE TABLE [Reporting].[dbo].[DailyWkoInfo](
	--				[DailyWkoInfoId] [int] IDENTITY(1,1) NOT NULL,
	--				[Sku] [varchar](50) NULL,
	--				[UserType] [smallint] NULL,
	--				[WkoCount] [smallint] NULL,
	--				[IsCoached] [smallint] NULL,
	--				[DateAdded] [datetime] NULL,
	--			CONSTRAINT [DailyWkoInfo_pk] PRIMARY KEY CLUSTERED 
	--			(
	--				[DailyWkoInfoId] ASC
	--			)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 95) ON [PRIMARY]
	--			) ON [PRIMARY]
	--		END
	
	--------------------------------------------------------------------------------------
	-- To avoid duplicate rows, check if rows for today exist before inserting new rows. -
	-- If rows exist delete existing rows for today before inserting new rows.           -
	--------------------------------------------------------------------------------------
	Select @ROWCNT = count(*) From Reporting..DailyWkoInfo Where Cast(floor(cast(DATEADD(dd, -3, DateAdded) as float)) as Datetime)=Cast(floor(cast(DATEADD(dd, -3, getdate()) as float)) as Datetime)
	IF (@ROWCNT > 0)
		BEGIN
		   Delete Reporting..DailyWkoInfo Where Cast(floor(cast(DATEADD(dd, -3, DateAdded) as float)) as Datetime)=Cast(floor(cast(DATEADD(dd, -3, getdate()) as float)) as Datetime)
		END 

	INSERT INTO [Reporting].[dbo].[DailyWkoInfo]
		   ([Sku]
		   ,[UserType]
		   ,[WkoCount]
		   ,[IsCoached]
		   ,[DateAdded])
	Select Sku, 
		   p.UserType, 
		   Count(*), 
		   case when a.CoachedByPersonId > 0 then 1 else 0 end as IsCoached, 
		   @CURRENTDATE 	
	From ultrafit_live..SoftwarePaymentForPerson sp 	
		inner join 	
		(	
			Select personid, max(SoftwarePaymentForPersonId) as maxid
			From ultrafit_live..SoftwarePaymentForPerson
			Where Sku in ('wkoa', 'wkou', 'wko3') and ValidationCount > 0
			Group By PersonId
		) As lastWKOPurchase On lastWKOPurchase.PersonId = sp.PersonId AND lastWKOPurchase.maxid = sp.SoftwarePaymentForPersonId	
		inner join ultrafit_live..Person p On p.PersonId = sp.PersonId	
		left outer join ultrafit_live..Athlete a On a.personid = p.personid	
	Group By sku, p.UserType, Case When a.CoachedByPersonId > 0 Then 1 Else 0 End
End



GO
