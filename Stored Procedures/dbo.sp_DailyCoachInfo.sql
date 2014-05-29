SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[sp_DailyCoachInfo]
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @CURRENTDATE DATETIME
	DECLARE @PRIORMONTH INT				
	DECLARE @PRIORYEAR INT
	DECLARE @ROWCNT INT				
					
	SET @CURRENTDATE = GETDATE()
	SET @PRIORMONTH = datepart(mm,DATEADD(mm,-1,GETDATE())) 
	SET @PRIORYEAR = datepart(YYYY,DATEADD(mm,-1,GETDATE())) 

	--IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Reporting].[dbo].[DailyCoachInfo]') AND type in (N'U'))
	--	BEGIN
	--		CREATE TABLE [Reporting].[dbo].[DailyCoachInfo](
	--			[DailyCoachInfoId] [int] IDENTITY(1,1) NOT NULL,
	--			[GroupName] [varchar](200) NULL,
	--			[GroupOwnerPersonId] [int] NULL,
	--			[GroupOwnerPerson] [nvarchar](150) NULL,
	--			[CoachingGroupId] [int] NULL,
	--			[BasicAthlete] [smallint] NULL,
	--			[PremiumAs1] [smallint] NULL,
	--			[PremiumAs4] [smallint] NULL,
	--			[CoachCount] [smallint] NULL,
	--			[CompdUBC] [smallint] NULL,
	--			[UBC] [smallint] NULL,
	--			[PaidCoach] [smallint] NULL,
	--			[DemoCoach] [smallint] NULL,
	--			[cvap-1] [float] NULL,
	--			[cvr-1] [float] NULL,
	--			[cv-1] [float] NULL,
	--			[other] [float] NULL,
	--			[DateAdded] [datetime] NULL,
	--			[ForYear] [smallint] NULL,
	--			[ForMonth] [smallint] NULL,
	--		CONSTRAINT [DailyCoachInfo_pk] PRIMARY KEY CLUSTERED 
	--		(
	--			[DailyCoachInfoId] ASC
	--		)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 95) ON [PRIMARY]
	--		) ON [PRIMARY]
	--	END
					
	--------------------------------------------------------------------------------------
	-- To avoid duplicate rows, check if rows for today exist before inserting new rows. -
	-- If rows exist delete before inserting new rows.                                   -
	--------------------------------------------------------------------------------------
	Select @ROWCNT = count(*) From Reporting..DailyCoachInfo Where Cast(floor(cast(DATEADD(dd, -3, DateAdded) as float)) as Datetime)=Cast(floor(cast(DATEADD(dd, -3, getdate()) as float)) as Datetime)
	IF (@ROWCNT > 0)
		BEGIN
		   Delete Reporting..DailyCoachInfo Where Cast(floor(cast(DATEADD(dd, -3, DateAdded) as float)) as Datetime)=Cast(floor(cast(DATEADD(dd, -3, getdate()) as float)) as Datetime)
		END 

	;with 
	ActiveCoachingGroup as				
	(				
		select * from ultrafit_live..coachinggroup where IsDeleted = 0			
	),				
	AthleteUserTypesInCoachingGroup as 				
	(				
		select cg.GroupName, cg.CoachingGroupId,			
		SUM(case when pa.UserType = 4 then 1 else 0 end) as PremiumAs4,			
		SUM(case when pa.UserType = 6 then 1 else 0 end) as BasicAthlete,			
		SUM(case when pa.UserType = 1 then 1 else 0 end) as PremiumAs1			
		from ultrafit_live..Person pa			
		inner join ultrafit_live..Athlete a on a.PersonId = pa.PersonId			
		inner join ultrafit_live..Coach c on c.personid = a.CoachedByPersonId			
		inner join ActiveCoachingGroup cg on cg.CoachingGroupId = c.CoachingGroupId			
		group by cg.groupname, cg.CoachingGroupId			
	),				
	CoachPayments as 				
	(				
		select fixed.*, other.other from (			
			select personid, [cvap-1], [cv-1], [cvr-1]		
			from(		
			select sku, PersonId, Total		
			from reporting..paypalproductrevenue rev		
			where DATEPART(m,TransactionDate) = @PRIORMONTH and DATEPART(YYYY, TransactionDate) = @PRIORYEAR 		
			and isathlete = 0 and Sku in ('cvap-1', 'cvr-1', 'cv-1'))as src		
			PIVOT		
			(		
				SUM(Total)	
				FOR Sku in ([cvap-1], [cv-1], [cvr-1])	
			) as pvt		
		) as fixed			
		left outer join (			
			select PersonId, SUM (TOTAL) as other		
			from reporting..PayPalProductRevenue rev 		
			where Sku not in ('cvap-1', 'cvr-1', 'cv-1') and DATEPART(m,TransactionDate) = @PRIORMONTH 		
				AND DATEPART(YYYY, TransactionDate) = @PRIORYEAR AND isathlete = 0	
			group by PersonId 		
		) as other on other.PersonId = fixed.PersonId			
	),				
	CoachWithUBC as				
	(				
		select 	ch.PersonId as coachid, ch.CoachingGroupId,		
			CASE WHEN exists(select * from ultrafit_live..RecurringPaymentProfileForPerson WHERE ((isActive = 1) 		
					OR (isActive = 0 and PaidThrough >= getDate())) AND PersonId = ch.PersonId AND ProfileType = 0) 
				THEN 1 ELSE 0 END as UBC,	
			CASE WHEN exists(select * from ultrafit_live..RecurringPaymentProfileForPerson WHERE (		
				(isActive = 1) OR (PaidThrough >= getDate() and isActive = 0))	
				AND OverridesPaypal = 1 	
				AND PersonId = ch.PersonId AND ProfileType = 0) 	
				THEN 1 ELSE 0 END as CompdUBC,	
			case when pc.UserType = 2 then 1 else 0 end as PaidCoach,		
			case when pc.UserType = 5 then 1 else 0 end as DemoCoach,		
			cp.*		
		from ultrafit_live..Coach ch			
		inner join ultrafit_live..Person pc on pc.personid = ch.personid			
		inner join ActiveCoachingGroup cg on cg.CoachingGroupId = ch.CoachingGroupId			
		left outer join CoachPayments cp on cp.PersonId = ch.PersonId			
		where exists (select ath.personid from ultrafit_live..Athlete ath where ath.CoachedByPersonId = ch.PersonId)			
	),				
	CoachWithUBCAggregate as				
	(				
		select COUNT(c.coachid) as CoachCount, SUM(PaidCoach) as PaidCoach, SUM(DemoCoach) as DemoCOach,			
		 SUM(c.UBC) as UBC, SUM(c.CompdUBC) as CompdUBC, cg.GroupName, cg.CoachingGroupId, SUM(IsNull(c.[cvap-1],0)) as [cvap-1],			
		 SUM(IsNull(c.[cvr-1],0)) as [cvr-1], SUM(IsNull(c.[cv-1], 0)) as [cv-1], SUM(IsNull(c.other,0)) as other			
		from CoachWithUBC c			
		inner join ActiveCoachingGroup cg on cg.CoachingGroupId = c.CoachingGroupId			
		group by cg.GroupName, cg.CoachingGroupId			
	)	
	INSERT INTO [Reporting]..[DailyCoachInfo]
			   ([GroupName]
			   ,[GroupOwnerPersonId]
			   ,[GroupOwnerPerson]
			   ,[CoachingGroupId]
			   ,[BasicAthlete]
			   ,[PremiumAs1]
			   ,[PremiumAs4]
			   ,[CoachCount]
			   ,[UBC]
			   ,[CompdUBC]
			   ,[PaidCoach]
			   ,[DemoCoach]
			   ,[cvap-1]
			   ,[cvr-1]
			   ,[cv-1]
			   ,[other]
			   ,[DateAdded]
			   ,[ForYear]
			   ,[ForMonth])
		 SELECT
				at.GroupName, 
				cg.GroupOwnerPersonId, 
				p.FullName, 
				cg.CoachingGroupId, 
				at.BasicAthlete, 
				at.PremiumAs1, 
				at.PremiumAs4, 
				CoachCount,
				UBC, 
				CompdUBC, 
				PaidCoach, 
				DemoCoach, 
				[cvap-1], 
				[cvr-1], 
				[cv-1], 
				other, 
				@CURRENTDATE, 
				@PRIORYEAR, 
				@PRIORMONTH
		FROM AthleteUserTypesInCoachingGroup at
				inner join CoachWithUBCAggregate ca on ca.GroupName = at.GroupName and at.CoachingGroupId = ca.CoachingGroupId
				inner join ActiveCoachingGroup cg on at.GroupName = cg.GroupName and at.CoachingGroupId = cg.CoachingGroupId
				inner join ultrafit_live..person p on cg.GroupOwnerPersonId = p.PersonId
End



GO
