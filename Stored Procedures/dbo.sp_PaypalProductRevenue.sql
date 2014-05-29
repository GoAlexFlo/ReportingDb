SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_PaypalProductRevenue]
AS
BEGIN
	SET NOCOUNT ON;

	Truncate Table Reporting..PayPalProductRevenue;

--Create a temp table to hold PlanId missing in the PayPalImport table.  These rows have a SKU that contains the 'TP' prefix but no PlanId Sufix	
CREATE TABLE #MissingPayPalPlanIds(PaypalImportId int, PersonId int, PlanId int);
With PayPal As (
	SELECT ROW_NUMBER() OVER(partition by PersonId ORDER BY PersonId, PaypalImportId) AS Row, PaypalImportId, PersonId
	FROM Ultrafit_live..PayPalImport 
	WHERE  Sku ='tp' and [Type] <> 'Credit' and TransId not in (Select OriginalTransId  from Ultrafit_live..PayPalImport where PersonId=52076 And OriginalTransId  Is Not Null)
	),
    PlanAccess As
    (
        SELECT ROW_NUMBER() OVER(partition by PersonId ORDER BY PersonId, PlanAccessId) AS Row, PersonId, PlanId
		FROM ultrafit_live..PlanAccess  
		WHERE (TransId is null or TransId ='')
	)
	Insert #MissingPayPalPlanIds (
	       PaypalImportId, 
	       PersonId, 
	       PlanId)
	Select p.PaypalImportId, p.PersonId, pa.PlanId
	From  PayPal As p Left Outer Join PlanAccess As pa on p.Row=pa.Row And p.PersonId=pa.PersonId;
	
	-- Create temp table to hold paypalimport data -- (data clean up)
	Select * into #TpProductRevenue From Ultrafit_live..paypalimport;
	
	--update #TpProductRevenue (Temp Table) for known bad data in the paypalimport file 
	Update #TpProductRevenue set Sku = 
		Case 
		When Total = 1995 
		Then 'sca-1 '
		When Total = 4900 
		Then 'sca-3 '
		When Total = 7900 
		Then 'sca-6 '
		When Total = 11900 
		Then 'sca-12 '
		End + Sku
	Where (Sku='Card Resubmitted' and Type='Delayed Capture' and Total In (1995, 4900, 7900, 11900)) Or 
		  (Sku='mp' and Total In (1995, 4900, 7900, 11900) And Type <>'Authorization');
		  
	--Split into 2 rows where SKU Like '%procomb%'. 
	-- Part 1 - One row contains the WKO software amount ($129) and the remainder goes towards an 1 year subscription
	Update #TpProductRevenue set Total=12900 Where Sku Like '%procomb%';
	
	-- Part 2 - Insert procombo One Year Subscripton SALES transactions
	INSERT INTO #TpProductRevenue
           ([Total]
           ,[PaypalDate]
           ,[PersonId]
           ,[AffiliateCode]
           ,[TransId]
           ,[Comment1]
           ,[Comment2]
           ,[Sku]
           ,[AccountNumber]
           ,[Type]
           ,[Expiration]
           ,[OriginalTransId]
           ,[PaypalTransactionID])
     SELECT
            Total-12900
           ,PaypalDate
           ,PersonId
           ,AffiliateCode
           ,TransId
           ,Comment1
           ,Comment2
           ,'sca-12'
           ,AccountNumber
           ,[Type]
           ,Expiration
           ,OriginalTransId
           ,PaypalTransactionID
      FROM Ultrafit_live..paypalimport
      WHERE SKU Like '%procomb%' And [Type] ='Sale' And 
      -- Don't include procombo sales that have been credited
            TransId Not In (select TransId From Ultrafit_live..paypalimport As p where [Type]='Sale' And Sku Like '%procomb%' and  TransId In (Select OriginalTransId From Ultrafit_live..paypalimport Where PersonId=p.PersonId And Sku Like '%procomb%' And [Type]='Credit')); 

      -- Insert the ZuoraTransaction rows
      INSERT INTO #TpProductRevenue
           ([Total]
           ,[PaypalDate]
           ,[PersonId]
           ,[AffiliateCode]
           ,[TransId]
           ,[Comment1]
           ,[Comment2]
           ,[Sku]
           ,[AccountNumber]
           ,[Type]
           ,[Expiration]
           ,[OriginalTransId]
           ,[PaypalTransactionID])
	SELECT [Amount] * 100
		  ,[TransactionDate]
		  ,[PersonId]
		  ,(Select AffiliateId From ultrafit_live..Person where PersonId=z.PersonId)
		  ,Substring([InvoiceNumber],1,12)
		  ,null
		  ,'ZuoraTransaction'
		  ,CASE
			   WHEN [ChargeNames] like '%SCA%'
			   THEN Replace(Replace(Replace(ChargeNames,'Discount,',''), ',Discount',''), ', Discount','')
			   WHEN PlanID > 0
			   Then 'tp-' + CAST(PlanId As Varchar(10))
		   End
		  ,null
		  ,[Type]
		  ,null
		  ,OriginalTransactionNumber
		  ,CONVERT(INT,SUBSTRING(TransactionNumber,3,15))
	  FROM [ultrafit].[dbo].[ZuoraTransactionImport] As z;

/*********************************
*** START PAYPALREVENUE CREATE ***
**********************************/
			With Info As 
	(
		Select d.RowOrder, d.RowType, d.PaypalImportId, d.ZuoraTransactionId, d.[Year], d.[Month], d.PersonId,
			   d.FirstName, d.LastName, d.FullName, d.AffiliateId, d.AffiliateCode, d.Email, d.Username, 
			   d.UserType, d.AthleteType, d.IsAthlete, d.IsAthleteCoached, d.AthleteIsCoachedByPersonId, d.AthleteIsCoachedBy, 
			   d.City, d.State, d.Zip, d.Country, d.AccountCreationDate, d.LastLogon, d.ExpireDate, d.NumberOfVisits, d.AllowMarketingEmails, d.Age, d.Sex, 
			   d.Language, d.Type, d.ProfileId, d.TransCredited, d.Sku, d. PlanId, d.TransId, d.ContainsPriorSale, d.PriorSalesRecordId, 
			   d.TransactionDate, d.SubscriptionFrom, d.SubscriptionTo, d.PriorFromDate, d.PriorToDate, d.SubscriptionMonths, d.Total 
		From (
		Select p.PaypalImportId, Case When Comment2 = 'ZuoraTransaction' Then p.PaypalTransactionID Else null End As ZuoraTransactionId,
		       IsNull(p.PersonId,0) As PersonId, IsNull(p1.FirstName,'') As FirstName, IsNull(p1.LastName,'') As LastName, IsNull(p1.FullName,'') As FullName, 
			   IsNull(p1.AffiliateId,'') As AffiliateId, IsNull(a.Code,'') As AffiliateCode, IsNull(p1.Email,'') As Email, IsNull(p1.Username, '') AS Username, 
			   IsNull(p1.AthleteType,'') As AthleteType, Case When p1.Usertype In (1,4,6) Then 1 Else 0 End As IsAthlete,
			   Case When IsNull(cb.CoachedByPersonId,0)>0 Then 'Yes' Else 'No' End As IsAthleteCoached, 
			   Case When IsNull(cb.CoachedByPersonId,0)>0 Then cb.CoachedByPersonId Else 0 End As AthleteIsCoachedByPersonId,
			   Case When IsNull(cb.CoachedByPersonId,0)>0 Then (Select cbn.FullName From Ultrafit_live..Person As cbn where cbn.PersonId=p.PersonId) Else '' End As AthleteIsCoachedBy,
			   IsNull(p1.City, '') As City, IsNull(p1.State, '') As State, IsNull(p1.Zip,'') As Zip, 
			   IsNull(p1.Country, '') AS Country, 
			   IsNull(Case When p1.AccountCreationDate Is Null Or p1.AccountCreationDate='1900-01-01'
		                Then (Select Top 1 AccountCreationDate From ultrafit_live..Person Where PersonId<p1.PersonId And AccountCreationDate Is Not Null Order By PersonId Desc)
		                Else  p1.AccountCreationDate 
		           End, '') AccountCreationDate, 
			   IsNull(p1.LastLogon, '') As LastLogon, IsNull(p1.ExpireDate, '') As ExpireDate,
			   IsNull(p1.NumberOfVisits,0) As NumberOfVisits, IsNull(p1.Age, 0) As Age, IsNull(p1.Sex, '') AS Sex, IsNull(p1.Language, '') AS Language,
			   DatePart(YEAR, p.PaypalDate) As Year, DatePart(month, p.PaypalDate) As Month, p.Type, p.Sku, p1.Usertype, p1.AllowMarketingEmails,
			   Case When Substring(Sku,1,3) = 'Tp-'
			        Then Cast(substring(sku,4,20) As Int)
			        When Substring(Sku,1,2) = 'Tp'
			        Then (Select PlanId From #MissingPayPalPlanIds As m Where m.PaypalImportId =p.PaypalImportId)
			        When Substring(Sku,1,4) = 'lib-'
			        Then Cast(substring(sku,5,20) As Int)
		 	        When Substring(Sku,1,5) = 'libr-'
			        Then Cast(substring(sku,6,20) As Int)
			        When Substring(Sku,1,11) = 'item: libr-'
			        Then Cast(substring(sku,12,20) As Int)
			        When Substring(Sku,1,16) = 'Recurring: libr-'
			        Then Cast(substring(sku,17,20) As Int)
			        Else Null
			        End As PlanId, 
			    Case 
				   When IsNumeric((Substring(Comment2, CHARINDEX('recurring profile', Comment2) +18, 10)))<>0 And IsNumeric(Substring(Comment2, CHARINDEX('recurring profile', Comment2) +27, 1))<>0
				   Then 'RP' + Right('0000000000' + CONVERT(NVARCHAR,(Substring(Comment2, CHARINDEX('recurring profile', Comment2) +18, 10))), 10)
				   When IsNumeric((Substring(Comment2, CHARINDEX('recurring profile', Comment2) +18, 9)))<>0 And IsNumeric(Substring(Comment2, CHARINDEX('recurring profile', Comment2) +26, 1))<>0
				   Then 'RP' + Right('0000000000' + CONVERT(NVARCHAR,(Substring(Comment2, CHARINDEX('recurring profile', Comment2) +18, 9))), 10) 
				   When IsNumeric((Substring(Comment2, CHARINDEX('recurring profile', Comment2) +18, 8)))<>0 And IsNumeric(Substring(Comment2, CHARINDEX('recurring profile', Comment2) +25, 1))<>0
				   Then 'RP' + Right('0000000000' + CONVERT(NVARCHAR,(Substring(Comment2, CHARINDEX('recurring profile', Comment2) +18, 8))), 10)
				   When IsNumeric((Substring(Comment2, CHARINDEX('recurring profile', Comment2) +18, 7)))<>0 And IsNumeric(Substring(Comment2, CHARINDEX('recurring profile', Comment2) +24, 1))<>0
				   Then 'RP' + Right('0000000000' + CONVERT(NVARCHAR,(Substring(Comment2, CHARINDEX('recurring profile', Comment2) +18, 7))), 10)
				   When IsNumeric((Substring(Comment2, CHARINDEX('recurring profile', Comment2) +18, 6)))<>0 And IsNumeric(Substring(Comment2, CHARINDEX('recurring profile', Comment2) +23, 1))<>0
				   Then 'RP' + Right('0000000000' + CONVERT(NVARCHAR,(Substring(Comment2, CHARINDEX('recurring profile', Comment2) +18, 6))), 10)
				   When IsNumeric((Substring(Comment2, CHARINDEX('recurring profile', Comment2) +18, 5)))<>0 And IsNumeric(Substring(Comment2, CHARINDEX('recurring profile', Comment2) +22, 1))<>0
				   Then 'RP' + Right('0000000000' + CONVERT(NVARCHAR,(Substring(Comment2, CHARINDEX('recurring profile', Comment2) +18, 5))), 10)
				   When IsNumeric((Substring(Comment2, CHARINDEX('recurring profile', Comment2) +18, 4)))<>0 And IsNumeric(Substring(Comment2, CHARINDEX('recurring profile', Comment2) +21, 1))<>0
				   Then 'RP' + Right('0000000000' + CONVERT(NVARCHAR,(Substring(Comment2, CHARINDEX('recurring profile', Comment2) +18, 4))), 10)
				   When IsNumeric((Substring(Comment2, CHARINDEX('recurring profile', Comment2) +18, 3)))<>0 And IsNumeric(Substring(Comment2, CHARINDEX('recurring profile', Comment2) +20, 1))<>0
				   Then 'RP' + Right('0000000000' + CONVERT(NVARCHAR,(Substring(Comment2, CHARINDEX('recurring profile', Comment2) +18, 3))), 10)
				   When IsNumeric((Substring(Comment2, CHARINDEX('recurring profile', Comment2) +18, 2)))<>0 And IsNumeric(Substring(Comment2, CHARINDEX('recurring profile', Comment2) +19, 1))<>0
				   Then 'RP' + Right('0000000000' + CONVERT(NVARCHAR,(Substring(Comment2, CHARINDEX('recurring profile', Comment2) +18, 2))), 10)
				   When IsNumeric((Substring(Comment2, CHARINDEX('recurring profile', Comment2) +18, 1)))<>0 And IsNumeric(Substring(Comment2, CHARINDEX('recurring profile', Comment2) +18, 1))<>0
				   Then 'RP' + Right('0000000000' + CONVERT(NVARCHAR,(Substring(Comment2, CHARINDEX('recurring profile', Comment2) +18, 1))), 10)
				   When IsNumeric((Substring(Comment2, CHARINDEX('Recurring Profile:', Comment2) +21, 10)))<>0 
				   Then Substring(Comment2, CHARINDEX('Recurring Profile:', Comment2) +19, 12)
				   Else 'RP0000000000'
				   End As ProfileId, 
			   Case 
			   When p.Sku Is Null Or p.Sku =''
			   Then 'Undeterminable'
			   
			   When p.Type='Void' And YEAR(p.PaypalDate)>2011 And 
					Exists(Select pp1.PersonId
					From #TpProductRevenue As pp1             
					Where pp1.PersonId=p.PersonId And pp1.TransId=p.OriginalTransId And pp1.type='Authorization' And pp1.total=p.Total)
			   Then 'PayPalExpress'
			  
			   When p.Type='Void' And 
					Exists(Select pp1.PersonId
					From #TpProductRevenue As pp1             
					Where pp1.PersonId=p.PersonId And pp1.TransId=p.OriginalTransId And pp1.type='Authorization' And pp1.total=p.Total)
			   Then 'Auth/Void'
			   
			   When p.Sku Like 'sca%' Or p.Sku='Recurring billing for item: sca-12'
			   Then 'Subscription'
			   When Left(p.Sku,3)='tp-' Or Left(p.Sku,3)='ACS' Or Left(p.Sku,2)='tp' Or Left(p.Sku,2)='dc' Or p.Sku='Other - charge tp' Or p.Sku In ('schedule-smartcoach', 'Trainingbible_payment', 'trainingpeaks_payment', 'Other - charge tp', 'Other - tp sale', 'Other - recharge tp') 
			   Then 'TrainingPlan' 
			   When Left(p.Sku,4)='lib-' Or p.Sku Like '%libr-9748%'
			   Then 'WorkoutLibrary'
			   When p.Sku In ('cvr-1' , 'cv-1', 'Recurring: cvr-1', 'Recurring billing for item: cvr-1', 'One Year Coach Version', 'Coach Account')
			   Then 'CoachSubscription'
			   When Left(p.Sku,2)='cv' 
			   Then 'CoachTransaction'
			   When p.Sku Like '%computr%' Or p.Sku Like '%crs%' Or p.Sku Like '%erg%' Or p.Sku Like '%r3d%' Or p.Sku Like '%cpsoft%' Or p.Sku Like '%procomb%' Or p.Sku Like '%wko%'
			   Then 'Software'
			   When	((IsNumeric(Left (p.Sku ,1)) <> 0 And IsNumeric(SUBSTRING(p.Sku, 1, 6)) <> 0) Or Left (p.Sku ,2) = 'id' Or Left (p.Sku ,7) = 'Invoice' Or Left (p.Sku ,6) = 'Refund'  Or Left(p.Sku ,5) = 'Other' )
			   Then 'Manual ' + Type 
			   Else 'Undeterminable' 
			   End As RowType, 

			   Case 
			   When p.Type In ('Sale', 'Delayed Capture', 'Credit') And  p.Sku Like 'sca%'  
			   Then (Select COUNT(Distinct p2.TransId) 
					  From #TpProductRevenue As p2 
					  Where p2.PersonId=p.PersonId And p2.Type In ('Sale', 'Delayed Capture') And p2.PaypalDate<p.PaypalDate And p2.Sku Like 'sca%' And
					  (Select COUNT(*) From #TpProductRevenue As p3 where p3.PersonId=p2.PersonId And p3.Type='Credit' And p3.OriginalTransId = p2.TransId)=0
					  )
			   When p.Type In ('Sale', 'Delayed Capture', 'Credit') And  p.Sku In ('cvr-1' , 'cv-1', 'Recurring: cvr-1', 'Recurring billing for item: cvr-1', 'One Year Coach Version', 'Coach Account')  
			   Then (Select COUNT(Distinct p2.TransId) 
					  From #TpProductRevenue As p2 
					  Where p2.PersonId=p.PersonId And p2.Type In ('Sale', 'Delayed Capture') And p2.PaypalDate<p.PaypalDate 
					  And p2.Sku In ('cvr-1' , 'cv-1', 'Recurring: cvr-1', 'Recurring billing for item: cvr-1', 'One Year Coach Version', 'Coach Account') And
					  (Select COUNT(*) From #TpProductRevenue As p3 where p3.PersonId=p2.PersonId And p3.Type='Credit' And p3.OriginalTransId = p2.TransId)=0
					  )  
			   Else 0
			   End As ContainsPriorSale,
			   
			   Case 
			   When p.Type In ('Sale', 'Delayed Capture')
			   Then (Select Top 1  p3.PaypalImportId 
					  From #TpProductRevenue As p3 
					  Where p3.PersonId=p.PersonId And p3.Type In ('Sale', 'Delayed Capture') And p3.PaypalDate<p.PaypalDate And p3.Sku Like 'sca%' And 
						   (Select COUNT(*) From #TpProductRevenue As P4 Where p4.PersonId=p3.PersonId And p4.Type='Credit' And p4.OriginalTransId = p3.TransId)=0
					  Order By p3.PaypalDate Desc)
			   When p.Type='Credit'
			   Then  (Select Top 1 p4.PaypalImportId 
					  From #TpProductRevenue As p4 
					  Where p4.PersonId=p.PersonId And p4.TransId=p.OriginalTransId And p4.Type = 'Sale')
			   Else 0
			   End As PriorSalesRecordId,
			  
			   Case 
			   When p.Type In ('Sale', 'Delayed Capture', 'Credit') And  p.Sku Like 'sca%' 
			   Then  (Select Top 1  Convert(VARCHAR(10),p4.PaypalDate,111)
					 From #TpProductRevenue As p4 
					 Where p4.PersonId=p.PersonId And p4.Type In ('Sale', 'Delayed Capture') And p4.PaypalDate<p.PaypalDate And p4.Sku Like 'sca%' And 
						  (Select COUNT(*) From #TpProductRevenue As p5 where p5.PersonId=p4.PersonId And p5.Type='Credit' And p5.OriginalTransId = p4.TransId)=0
					 Order By p4.PaypalDate Desc)
			   Else '' 
			   End As PriorFromDate,
			   
  			   Case 
			   When p.Type In ('Sale', 'Delayed Capture', 'Credit') And  p.Sku Like 'sca%' And IsNumeric(SUBSTRING(p.Sku, (CHARINDEX('-', p.Sku)+1) ,2)) <> 0
  			   Then (Select Top 1  
  			          --
  			          --  If paypaldate falls on the end of the month then calculate the last day of month for subscription to date.
  			          --  If not end of month then the day the subscription starts must be the day on the Subscription to date.
  			          --
  			          Case 
  			          When SUBSTRING(p5.Sku,(CHARINDEX('-', p5.Sku)+1) ,2) Not In ('1','2','3','4','5','6','7','8','9','10','11','12')
  			          Then '2099-01-01'
					  When CONVERT(VARCHAR(10), p5.PaypalDate, 111)<>CONVERT(VARCHAR(10), DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,p5.PaypalDate)+1,0)),111) -- Is Subscription From Date (paypalDate) Not on the Last day of the month
					  Then CONVERT(VARCHAR(8),DATEADD(MONTH, +(CONVERT(INT,Abs(Convert(INT,SUBSTRING(p5.Sku,(CHARINDEX('-', p5.Sku)+1) ,2))))), p5.PaypalDate),111) + CONVERT(VARCHAR(2), DATEADD(MONTH, +(CONVERT(INT,Abs(Convert(INT,SUBSTRING(p5.Sku,(CHARINDEX('-', p5.Sku)+1) ,2))))), p5.PaypalDate), 103)
					  Else CONVERT(VARCHAR(10),DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,CONVERT(DATETIME,(CONVERT(VARCHAR(8),(DATEADD(MONTH, +(CONVERT(INT,Abs(CONVERT(INT,SUBSTRING(p5.Sku,(CHARINDEX('-', p5.Sku)+1) ,2))))), p5.PaypalDate)),111) + '01')))+1,0)),111)
			          End
					  From #TpProductRevenue As p5 
					  Where p5.PersonId=p.PersonId And p5.Type In ('Sale', 'Delayed Capture') And p5.PaypalDate<p.PaypalDate And p5.Sku Like 'sca%' And
						   (Select COUNT(*) From #TpProductRevenue As p6 where p6.PersonId=p.PersonId And p6.Type='Credit' And p6.OriginalTransId = p5.TransId)=0
					  Order By p5.PaypalDate Desc)
			   Else ''
			   End As PriorToDate,
			          
			   Case 
			   When p.Type In ('Sale', 'Delayed Capture', 'Credit') And  p.Sku Like 'sca%' 
			   Then (Select COUNT(*) From #TpProductRevenue As p4 where p4.PersonId=p.PersonId And p4.Type='Credit' And p4.OriginalTransId = p.TransId)
			   When p.Type = 'Sale' And  Substring(p.Sku,1,2) = 'tp' 
			   Then (Select COUNT(*) From #TpProductRevenue As p4 where p4.PersonId=p.PersonId And p4.Type='Credit' And p4.OriginalTransId = p.TransId) 
			   When p.Type = 'Sale' And (Sku Like '%wko%' or Sku like '%procombo%') 
			   Then (Select COUNT(*) From #TpProductRevenue As p4 where p4.PersonId=p.PersonId And p4.Type='Credit' And p4.OriginalTransId = p.TransId) 
			   End As TransCredited,
			 
			   Case 
			   When p.Type In ('Sale', 'Delayed Capture') 
			   Then p.TransId 
			   When p.Type ='Credit' 
			   Then p.OriginalTransId 
			   End As TransId, 
			 
			   Convert(VARCHAR(10),p.PaypalDate,111) As TransactionDate,
			   
			   Case
			   When p.Type In ('Sale', 'Delayed Capture', 'Credit') And  
			       (p.Sku Like 'sca%' Or p.Sku In ('cvr-1' , 'cv-1', 'Recurring: cvr-1', 'Recurring billing for item: cvr-1', 'One Year Coach Version', 'Coach Account')) 
			   Then Convert(VARCHAR(10),p.PaypalDate,111)
			   Else '' 
			   End As SubscriptionFrom,
			   
			   Case 
	           --
	           --  If paypaldate falls on the end of the month then calculate the last day of month for subscription to date.
	           --  If not end of month then the day the subscription starts must be the day on the Subscription to date.
	           --
			   When p.Type In ('Sale', 'Delayed Capture', 'Credit') And  p.Sku Like 'sca%'  And IsNumeric(SUBSTRING(p.Sku, (CHARINDEX('-', p.Sku)+1) ,2)) <> 0 And
			        CONVERT(VARCHAR(10), p.PaypalDate, 111)<>CONVERT(VARCHAR(10), DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,p.PaypalDate)+1,0)),111) -- Is Subscription From Date (paypalDate) not on the Last day of the month
			   Then CONVERT(VARCHAR(8),DATEADD(MONTH, +(CONVERT(INT,Abs(CONVERT(INT,SUBSTRING(p.Sku,(CHARINDEX('-', p.Sku)+1) ,2))))), p.PaypalDate),111) + CONVERT(VARCHAR(2), DATEADD(MONTH, +(CONVERT(INT,Abs(CONVERT(INT,SUBSTRING(p.Sku,(CHARINDEX('-', p.Sku)+1) ,2))))), p.PaypalDate), 103)
			   When p.Type In ('Sale', 'Delayed Capture', 'Credit') And  p.Sku Like 'sca%'  And IsNumeric(SUBSTRING(p.Sku, (CHARINDEX('-', p.Sku)+1) ,2)) <> 0 And
			        CONVERT(VARCHAR(10), p.PaypalDate, 111)=CONVERT(VARCHAR(10), DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,p.PaypalDate)+1,0)),111) -- Is Subscription From Date (paypalDate) on the Last day of the month
			   Then CONVERT(VARCHAR(10),DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,CONVERT(DATETIME,(CONVERT(VARCHAR(8),(DATEADD(MONTH, +(CONVERT(INT,Abs(CONVERT(INT,SUBSTRING(p.Sku,(CHARINDEX('-', p.Sku)+1) ,2))))), p.PaypalDate)),111) + '01')))+1,0)),111)
			   When p.Type In ('Sale', 'Delayed Capture', 'Credit') And  
			        p.Sku In ('cvr-1' , 'cv-1', 'Recurring: cvr-1', 'Recurring billing for item: cvr-1', 'One Year Coach Version', 'Coach Account')
   			   Then CONVERT(VARCHAR(8),DATEADD(MONTH, +1, p.PaypalDate),111) + CONVERT(VARCHAR(2), DATEADD(MONTH, +1, p.PaypalDate), 103)
			   Else '' 
			   End As SubscriptionTo, 
			   
			   Case 
			   When p.Sku In ('cvr-1' , 'cv-1', 'Recurring: cvr-1', 'Recurring billing for item: cvr-1', 'One Year Coach Version', 'Coach Account')
			   Then 1
			   When p.Type In ('Sale', 'Delayed Capture', 'Credit') And  p.Sku Like 'sca%' And IsNumeric(SUBSTRING(p.Sku, (CHARINDEX('-', p.Sku)+1) ,2)) <> 0 
			   Then Convert(INT,SubString(p.Sku,(CharIndex('-', p.Sku) + 1), 2)) 
			   Else '' 
			   End As SubscriptionMonths,
			   
			   Case 
			   When p.Type In ('Credit', 'Void')
			   Then p.Total *-.01 
			   Else p.Total *.01 
			   End As Total,
			   
  			   row_number() Over(partition by p.PersonId order by  p.PaypalDate) as RowOrder
		
		From #TpProductRevenue p Left Outer Join ultrafit_live..Person As p1 On p.PersonId = p1.PersonId 
		                    Left Outer Join ultrafit_live..athlete As cb On cb.PersonId = p1.PersonId
							Left Outer join ultrafit_live..affiliate As a On p1.AffiliateId=a.AffiliateId
		Where p.Type <> 'Authorization'
		) d  
	)

   		INSERT INTO Reporting..[PayPalProductRevenue]
			   ([PersonId]
			   ,[RowOrder]
			   ,[RowType]
			   ,[FirstName]
			   ,[LastName]
			   ,[FullName]
			   ,[AffiliateId]
			   ,[AffiliateCode]
			   ,[Email]
			   ,[Username]
			   ,[AthleteType]
			   ,[IsAthlete]
			   ,[IsAthleteCoached]
	           ,[AthleteIsCoachedByPersonId]
	           ,[AthleteIsCoachedBy]
			   ,[City]
			   ,[State]
			   ,[Zip]
			   ,[Country]
			   ,[AccountCreationDate]
			   ,[LastLogon]
			   ,[ExpireDate]
			   ,[NumberOfVisits]
			   ,[AllowMarketingEmails]
			   ,[Age]
			   ,[Sex]
			   ,[Language]
			   ,[UserType]
			   ,[UserTypeDesc]
			   ,[NumberOfCoachedAthletes]
			   ,[NumberOfBasicCoachedAthletes]
			   ,[NumberOfSelfCoachedAthletes]
			   ,[NumberOfPremiumCoachedAthletes]
			   ,[IsThisCoachUBC]	
			   ,[PaypalImportId]
			   ,[ZuoraTransactionId]
			   ,[Year]
			   ,[Month]
			   ,[Sku]
			   ,[PlanId]
			   ,[Type]
			   ,[ProfileId]
			   ,[TransactionDate]
			   ,[SubscriptionFrom]
			   ,[SubscriptionTo]
			   ,[SubscriptionMonths]
			   ,[TransDesc]
			   ,[CreditDesc]
			   ,[Total])
		Select i.PersonId, i.RowOrder, i.RowType, i.FirstName ,i.LastName, i.FullName, i.AffiliateId, i.AffiliateCode, i.Email, i.Username, i.AthleteType, i.IsAthlete, 
		       i.IsAthleteCoached, i.AthleteIsCoachedByPersonId, i.AthleteIsCoachedBy, i.City, i.State, i.Zip, i.Country, i.AccountCreationDate, i.LastLogon, i.[ExpireDate], 
		       i.NumberOfVisits, i.AllowMarketingEmails, i.Age, i.Sex, i.[Language], i.UserType,
			   
			   Case 
				When i.UserType = 1 
				Then 'Prem Athlete (Paid For By Coach)' 
				When i.UserType = 2 
				Then 'Paid Coach'
				When i.UserType = 4 
				Then 'Prem Athlete (Paid By Athlete)'  
				When i.UserType = 5 
				Then 'Demo Coach'
				When i.UserType = 6 
				Then 'Basic Athlete'
				Else '' 
				End As UserTypeDesc,
			   
			   Case 
				When i.UserType IN (2,5)
				Then (Select COUNT(*) FROM ultrafit_live..Athlete Where Athlete.CoachedByPersonId = i.PersonId) 
				Else 0
				End As NumberOfCoachedAthletes,

				Case 
				When i.UserType IN (2,5)   
				Then (Select Count(*)
		       		  From ultrafit_live..Person p1 Inner JOIN ultrafit_live..athlete a1 On p1.PersonId = a1.PersonId
					  Where p1.UserType = 6 And a1.CoachedByPersonId = i.PersonId) 
				Else 0
				End As NumberOfBasicCoachedAthletes,
	      
				Case 
				When i.UserType IN (2,5)
				Then (Select Count(*)
					  From ultrafit_live..Person p1 Inner JOIN ultrafit_live..athlete a1 On p1.PersonId = a1.PersonId
					  Where p1.UserType = 4 And a1.CoachedByPersonId = i.PersonId)
   				Else 0 
				End As NumberOfSelfCoachedAthletes, 

				Case 
				When i.UserType IN (2,5)             
				Then (Select Count(*)
		  			  From ultrafit_live..Person p1 Inner JOIN ultrafit_live..athlete a1 On p1.PersonId = a1.PersonId
					  Where p1.UserType = 1 And a1.CoachedByPersonId = i.PersonId)
				Else 0 
				End As NumberOfPremiumCoachedAthletes,
	      
			   Case 
				When i.UserType IN (2,5) And 
					 Exists(Select PersonId FROM ultrafit_live..RecurringPaymentProfileForPerson
					 Where ((RecurringPaymentProfileForPerson.isActive = 1) Or (RecurringPaymentProfileForPerson.isActive = 0 And
							 RecurringPaymentProfileForPerson.PaidThrough >= GetDate())) And RecurringPaymentProfileForPerson.PersonId = i.PersonId And
							 RecurringPaymentProfileForPerson.ProfileType = 0) 
				Then 'Yes'
				When Exists(Select * From ultrafit_live..Person Where Person.UserType = 5 And Person.ExpireDate > GetDate() And Person.PersonId = i.PersonId) 
				Then 'Yes' 
				When i.UserType IN (2,5)
				Then 'No'
				Else '' 
				End As IsThisCoachUBC,
			    
			   i.PaypalImportId, i.ZuoraTransactionId, i.[Year], i.[Month], i.Sku, i.PlanId, i.Type, i.ProfileId, i.TransactionDate, i.SubscriptionFrom, i.SubscriptionTo, i.SubscriptionMonths,		   
			   Case 
				   When i.PriorToDate='2099-01-01'
				   Then 'BadPriorToDate'
				   When i.PersonId Is Null
				   Then 'UnallocatedCredit'
  				   When i.RowType In ('PayPalExpress', 'Auth/Void')
				   Then 'Auth/Void'
   				   When i.Type In ('Sale', 'Delayed Capture') And i.RowType In ('TrainingPlan', 'Workoutlibrary', 'CoachTransaction', 'Software', 'Undeterminable') Or Left(i.RowType,6) = 'Manual'
				   Then i.RowType
				   When i.Type In ('Sale', 'Delayed Capture') And i.ContainsPriorSale=0
				   Then 'NewSale'
				   When i.RowType = 'CoachSubscription' And i.Type In ('Sale', 'Delayed Capture') And i.ContainsPriorSale>0 
				   Then 'RecurSale'
				   When i.Type In ('Sale', 'Delayed Capture') And i.ContainsPriorSale>0 And i.SubscriptionFrom Between i.PriorFromDate And DateAdd (DAY, 5, i.PriorToDate)
				   Then 'RecurSale'
				   When i.Type In ('Sale', 'Delayed Capture')
				   Then 'RenewSale'
				   
				   When i.Type In ('Credit', 'Void') And i.RowType In ('TrainingPlan', 'Workoutlibrary', 'Workoutlibrary', 'CoachTransaction', 'Software', 'Undeterminable') Or Left(i.RowType,6) = 'Manual'
				   Then 'Credit ' + i.RowType
				   When i.Type In ('Credit', 'Void') And i.PriorSalesRecordId Is Null
				   Then 'UnallocatedCredit'
				   When i.Type In ('Credit', 'Void') And i.ContainsPriorSale=0 And i.PriorSalesRecordId Is Not Null
				   Then 'NewCredit'
  				   When i.Type In ('Credit', 'Void') And i.ContainsPriorSale>0 And 
						 Exists(Select i2.PersonId From Info AS i2 Where i2.PaypalImportId=i.PriorSalesRecordId And i2.TransactionDate Between i2.PriorFromDate And i2.PriorToDate)              
				   Then 'RecurCredit'
   				   When i.Type In ('Credit', 'Void') And i.ContainsPriorSale>0 And 
						 Not Exists(Select i2.PersonId From Info AS i2 Where i2.PaypalImportId=i.PriorSalesRecordId And i2.TransactionDate Between i2.PriorFromDate And i2.PriorToDate)              
				   Then 'RenewCredit'
				   When i.Type In ('Credit', 'Void') And i.ContainsPriorSale>=0  
				   Then 'NewCredit'
				   Else
				   'UnknownCondition'
			   End As TransDesc,

				   Case 
				   When i.PersonId Is Null
				   Then 'NoSalesTransactionFound: ' + i.TransId
				   When i.Type='Sale' And i.ContainsPriorSale=0 And TransCredited<>0
				   Then 'NewSaleCredited: ' + i.TransId
				   When i.Type='Sale' And i.ContainsPriorSale>0 And TransCredited<>0 And i.SubscriptionFrom Between i.PriorFromDate And i.PriorToDate
				   Then 'RecurSaleCredited: ' + i.TransId
				   When i.Type='Sale' And TransCredited=1
				   Then 'RenewSaleCredited: ' + i.TransId
		   	   
		   		   When i.Type='Credit' And i.PriorSalesRecordId Is Null
				   Then 'NoSalesTransactionFound: ' + i.TransId
				   When i.Type='Credit' And i.ContainsPriorSale=0 And i.PriorSalesRecordId Is Not Null
				   Then 'NewSalesCredit: ' + i.TransId
  				   When i.Type='Credit' And i.ContainsPriorSale>0 And 
						 Exists(Select PersonId From Info AS i2 Where i2.PaypalImportId=i.PriorSalesRecordId And i2.TransactionDate Between i2.PriorFromDate And i2.PriorToDate)              
				   Then 'RecurSaleCredit: ' + i.TransId
				   When i.Type='Credit' And i.ContainsPriorSale>0 And 
						 Not Exists(Select i2.PersonId From Info AS i2 Where i2.PaypalImportId=i.PriorSalesRecordId And i2.TransactionDate Between i2.PriorFromDate And i2.PriorToDate)              
				   Then 'RenewCredit'
   				   When i.Type='Credit' And i.ContainsPriorSale>0  
				   Then 'NewCredit: ' + i.TransId
				   When i.Type='Credit' And i.ContainsPriorSale>0  
				   Then 'RenewSaleCredit: ' + i.TransId
				   Else ''
				   End As CreditDesc, 
				
				Case
				When i.RowType In ('PayPalExpress', 'Auth/Void')
				Then 0
				Else i.Total 
				End AS Total
		From Info As i;
	
	Drop table #TpProductRevenue	
	Drop table #MissingPayPalPlanIds	
End

GO
