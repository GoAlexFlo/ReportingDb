SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO








CREATE PROCEDURE [dbo].[sp_WeeklyMarketingInfo]
AS
BEGIN
	SET NOCOUNT ON;
 -- DECLARE some variables to store the values
	DECLARE @varPersonId int
	DECLARE @varStartDate datetime
	DECLARE @varEndDate datetime;

  --For Testing 
  --DROP TABLE #weekEndingRows;
  --DROP TABLE #prepRows;
  --DROP TABLE #Numbers;
  
  --Temp tables required for process
	CREATE TABLE #prepRows(PersonId int, WeekEnding datetime);
	CREATE TABLE #weekEndingRows(PersonId int, WeekEnding datetime);
	CREATE TABLE #Numbers (Number int);
	DECLARE @x int
	SET @x=0
	WHILE @x<8000
	BEGIN
		SET @x=@x+1
		INSERT INTO #Numbers VALUES (@x)
	END

	-- DECLARE the cursor
	DECLARE CUR CURSOR FAST_FORWARD READ_ONLY FOR			
		Select p.PersonId, Convert(Varchar(10),p.SubscriptionFrom,111) As SubscriptionFrom, Convert(Varchar(10),p.SubscriptionTo,111) As SubscriptionTo 
		From PayPalProductRevenue As p
		Where RowType='Subscription' And CreditDesc='' And DatePart(YEAR, p.AccountCreationDate) >  2008
				
	-- Use the cursor
	OPEN CUR
	FETCH NEXT FROM CUR INTO @varPersonId, @varStartDate, @varEndDate

	WHILE @@FETCH_STATUS = 0
		BEGIN
			
			Insert Into #prepRows(
						PersonId, 
						WeekEnding
						)
				Select Distinct @varPersonId, Convert(VARCHAR(10),DateAdd(dd, 7 - (DatePart(dw, ((CONVERT(datetime,@varStartDate)+n.Number-1)))),((CONVERT(datetime,@varStartDate)+n.Number-1))),111) As WeekEnding
				From #Numbers As n  
				Where Number<=DATEDIFF(day,@varStartDate,CONVERT(datetime,@varEndDate)+1)
		
			FETCH NEXT FROM CUR INTO @varPersonId, @varStartDate, @varEndDate
		END

	CLOSE CUR
	DEALLOCATE CUR

	--This removes dups for subs that overlap
	Insert Into #weekEndingRows(PersonId, WeekEnding)
				Select Distinct PersonId, WeekEnding 
				From #prepRows;
				
	With PreInfo As
	(
	 SELECT convert(varchar(11), p.AccountCreationDate,111) as AccountCreationDate ,p.AffiliateId,
		  (Select top 1 UserTypePrevious From [ultrafit_live]..[PersonHistory] Where personid=p.PersonId Order by UpdateDate) As phUserType,
		   Usertype
	 FROM [ultrafit_live].[dbo].[Person] as p 
	 --Where convert(varchar(7), p.AccountCreationDate,111)='2013/02' and AffiliateId=596
	 Where DatePart(YEAR, AccountCreationDate) > 2008
	 ), Info As
	 (
		Select p.TransDesc As ColumnDescription,
		  Convert(VARCHAR(10),DateAdd(dd, 7 - (DatePart(dw, (p.TransactionDate))),(p.TransactionDate)),111) As WeekEnding, 
		  Count(*) As TransCount,
		  Round(Sum(p.Total), 2) As Total
		From Reporting..PayPalProductRevenue As p
		Where DatePart(YEAR, p.TransactionDate) > 2008 And   p.RowType = 'Subscription' And CreditDesc=''
		Group By p.TransDesc, Convert(VARCHAR(10),DateAdd(dd, 7 - (DatePart(dw,(p.TransactionDate))), (p.TransactionDate)),111)
		
		Union All
		Select 'New Prem Account' As ColumnDescription,
		  Convert(VARCHAR(10),DateAdd(dd, 7 - (DatePart(dw, (p.TransactionDate))),(p.TransactionDate)),111) As WeekEnding, 
		  Count(*) As TransCount,
		  Round(Sum(p.Total), 2) As Total
		From Reporting..PayPalProductRevenue As p
		Where DatePart(YEAR, p.TransactionDate) > 2008 And   p.RowType = 'Subscription' And TransDesc='NewSale' And CreditDesc='' 
		Group By p.TransDesc, Convert(VARCHAR(10),DateAdd(dd, 7 - (DatePart(dw,(p.TransactionDate))), (p.TransactionDate)),111)
	     
	    Union All 
		Select Max('(D1) New Acounts (1,4,6)') As ColumnDescription, 
		       Convert(VARCHAR(10),DateAdd(dd, 7 - (DatePart(dw,(AccountCreationDate))), (AccountCreationDate)),111) As WeekEnding,
		       COUNT(*) As TransCount, 0 As Total
		From PreInfo
		Where ((phUserType In (4,6) Or phUserType is Null) And UserType In (4,6) OR (phUserType In (4,6) And  UserType=1)) 
		Group By Convert(VARCHAR(10),DateAdd(dd, 7 - (DatePart(dw,(AccountCreationDate))), (AccountCreationDate)),111)
	      
		--Union All
		--Select Max('New Acounts (1,4,6)') As ColumnDescription,
		--  Convert(VARCHAR(10),DateAdd(dd, 7 - (DatePart(dw,(p.AccountCreationDate))), (p.AccountCreationDate)),111) As WeekEnding,
		--  COUNT(*) As TransCount, 0 As Total
		--From ultrafit_live..Person As p
		--Where p.UserType In (1, 4, 6) And DatePart(YEAR, p.AccountCreationDate) >  2008
		--Group By Convert(VARCHAR(10),DateAdd(dd, 7 - (DatePart(dw,(p.AccountCreationDate))), (p.AccountCreationDate)),111)
	    
	    --Union All
		--Select Max('(D4) UserType 1 Still 1') As ColumnDescription,
		--  Convert(VARCHAR(10),DateAdd(dd, 7 - (DatePart(dw,
		--  (p.AccountCreationDate))), (p.AccountCreationDate)),111) As WeekEnding,
		--  (Count(Distinct p.PersonId) * -1) As TransCount, 0 As Total
		--From  ultrafit_live..Person As p Left Outer Join
		--  ultrafit_live..PersonHistory As ph On p.PersonId = ph.PersonId
		--Where Convert(VARCHAR(10),p.AccountCreationDate,111) > '2012/12/31' And p.UserType = 1 And ph.PersonId Is Null --And p.AffiliateId<>596
		--Group By Convert(VARCHAR(10),DateAdd(dd, 7 - (DatePart(dw,(p.AccountCreationDate))), (p.AccountCreationDate)),111)

        Union All 
		Select Max('New Non-mobile TP Accounts (1,4,6)') As ColumnDescription, 
		       Convert(VARCHAR(10),DateAdd(dd, 7 - (DatePart(dw,(AccountCreationDate))), (AccountCreationDate)),111) As WeekEnding,
		       COUNT(*) As TransCount, 0 As Total
		From PreInfo
		Where ((phUserType In (4,6) Or phUserType is Null) And UserType In (4,6) OR (phUserType In (4,6) And  UserType=1)) And AffiliateId in (596, 818, 1008)
		Group By Convert(VARCHAR(10),DateAdd(dd, 7 - (DatePart(dw,(AccountCreationDate))), (AccountCreationDate)),111)

	    -- Union All
		--Select Max('New Non-mobile TP Accounts (1,4,6)') As ColumnDescription,
		--  Convert(VARCHAR(10),DateAdd(dd, 7 - (DatePart(dw,(p.AccountCreationDate))), (p.AccountCreationDate)),111) As WeekEnding,
		--  COUNT(*) As TransCount, 0 As Total
		--From ultrafit_live..Person As p
		--Where p.UserType In (1, 4, 6) And DatePart(YEAR, p.AccountCreationDate) >  2008  And AffiliateId in (596, 818, 1008)
		--Group By Convert(VARCHAR(10),DateAdd(dd, 7 - (DatePart(dw,(p.AccountCreationDate))), (p.AccountCreationDate)),111)
	    --   Union All
		--Select Max('(D4) Non-mobile TP UserType 1 Still 1') As ColumnDescription,
		--  Convert(VARCHAR(10),DateAdd(dd, 7 - (DatePart(dw,
		--  (p.AccountCreationDate))), (p.AccountCreationDate)),111) As WeekEnding,
		--  (Count(Distinct p.PersonId) * -1) As TransCount, 0 As Total
		--From  ultrafit_live..Person As p Left Outer Join
		--  ultrafit_live..PersonHistory As ph On p.PersonId = ph.PersonId
		--Where Convert(VARCHAR(10),p.AccountCreationDate,111) > '2012/12/31' And p.UserType = 1 And ph.PersonId Is Null And p.AffiliateId in (596, 818, 1008)
		--Group By Convert(VARCHAR(10),DateAdd(dd, 7 - (DatePart(dw,(p.AccountCreationDate))), (p.AccountCreationDate)),111) 

        Union All 
		Select Max('New Mobile TP Accounts (1,4,6)') As ColumnDescription, 
		       Convert(VARCHAR(10),DateAdd(dd, 7 - (DatePart(dw,(AccountCreationDate))), (AccountCreationDate)),111) As WeekEnding,
		       COUNT(*) As TransCount, 0 As Total
		From PreInfo
		Where ((phUserType In (4,6) Or phUserType is Null) And UserType In (4,6) OR (phUserType In (4,6) And  UserType=1)) And AffiliateId in (1037, 1038, 883, 908)
		Group By Convert(VARCHAR(10),DateAdd(dd, 7 - (DatePart(dw,(AccountCreationDate))), (AccountCreationDate)),111)

	 -- Union All
		--Select Max('New Mobile TP Accounts (1,4,6)') As ColumnDescription,
		--  Convert(VARCHAR(10),DateAdd(dd, 7 - (DatePart(dw,(p.AccountCreationDate))), (p.AccountCreationDate)),111) As WeekEnding,
		--  COUNT(*) As TransCount, 0 As Total
		--From ultrafit_live..Person As p
		--Where p.UserType In (1, 4, 6) And DatePart(YEAR, p.AccountCreationDate) >  2008  And AffiliateId in (1037, 1038, 883, 908)
		--Group By Convert(VARCHAR(10),DateAdd(dd, 7 - (DatePart(dw,(p.AccountCreationDate))), (p.AccountCreationDate)),111)

		--Union All
		--Select Max('(D4) Mobile TP UserType 1 Still 1') As ColumnDescription,
		--  Convert(VARCHAR(10),DateAdd(dd, 7 - (DatePart(dw,
		--  (p.AccountCreationDate))), (p.AccountCreationDate)),111) As WeekEnding,
		--  (Count(Distinct p.PersonId) * -1) As TransCount, 0 As Total
		--From  ultrafit_live..Person As p Left Outer Join
		--  ultrafit_live..PersonHistory As ph On p.PersonId = ph.PersonId
		--Where Convert(VARCHAR(10),p.AccountCreationDate,111) > '2012/12/31' And p.UserType = 1 And ph.PersonId Is Null And p.AffiliateId in (1037, 1038, 883, 908)
		--Group By Convert(VARCHAR(10),DateAdd(dd, 7 - (DatePart(dw,(p.AccountCreationDate))), (p.AccountCreationDate)),111) 
		 
		Union All
		Select Max('Training Plans Sold') As ColumnDescription,
		  Convert(VARCHAR(10),DateAdd(dd, 7 - (DatePart(dw, (p.TransactionDate))),(p.TransactionDate)),111) As WeekEnding, Count(*) As TransCount,
		  Round(Sum(p.Total), 2) As Total
		From Reporting..PayPalProductRevenue As p
		Where p.RowType = 'TrainingPlan' And p.Sku Like 'tp%' And p.Type = 'Sale' And (p.CreditDesc Is Null Or p.CreditDesc = '')
		Group By Convert(VARCHAR(10),DateAdd(dd, 7 - (DatePart(dw,(p.TransactionDate))), (p.TransactionDate)),111)
	      
		Union All
		Select Max('WKO Sold') As ColumnDescription, Convert(VARCHAR(10),DateAdd(dd, 7 - (DatePart(dw, (p.TransactionDate))), (p.TransactionDate)),111) As WeekEnding, 
		Sum(1) As TransCount, 
		Round(Sum(p.Total), 2) As Total
		From Reporting..PayPalProductRevenue As p
		Where p.RowType = 'Software' And (p.Sku Like '%wko%' Or  p.Sku Like '%procombo%') And p.Type = 'Sale' And (p.CreditDesc Is Null  Or p.CreditDesc = '')
		Group By Convert(VARCHAR(10),DateAdd(dd, 7 - (DatePart(dw, (p.TransactionDate))), (p.TransactionDate)),111)
	    
		Union All
		Select 'LapseAccount' As ColumnDescription, 
		  Convert(VARCHAR(10),DateAdd(dd, 7 - (DatePart(dw,(p.SubscriptionTo))), (p.SubscriptionTo)),111) As WeekEnding,
		  Case 
			When p.Usertype=4 And RowOrder=(Select MAX(RowOrder) From PayPalProductRevenue Where PersonId=p.PersonId And RowType='Subscription' And CreditDesc='')
   			Then 0
			When EXISTS (Select Top 1 * From PayPalProductRevenue Where PersonId=p.PersonId And RowOrder>p.RowOrder And Convert(Varchar(10),SubscriptionFrom,111)<=Convert(Varchar(10),DATEADD(dd,5,p.SubscriptionTo),111) And RowType='Subscription' And CreditDesc='' )
			Then 0
			Else 1
			End As TransCount,
		  0 As Total
		From Reporting..PayPalProductRevenue As p
		Where RowType='Subscription' And CreditDesc='' And DatePart(YEAR, p.AccountCreationDate) >  2008 
		)
			Select 'New Acounts' As ColumnDescription, i.WeekEnding, i.TransCount As Total
			From Info i
			Where i.ColumnDescription = '(D1) New Acounts (1,4,6)'
            
            Union All
			Select 'New Non-mobile TP Accounts' As ColumnDescription, i.WeekEnding, i.TransCount As Total
			From Info i
			Where i.ColumnDescription ='New Non-mobile TP Accounts (1,4,6)'
			
			Union All
			Select 'New Mobile TP Accounts' As ColumnDescription, i.WeekEnding, i.TransCount As Total
			From Info i
			Where i.ColumnDescription ='New Mobile TP Accounts (1,4,6)'
			
			Union All
			Select ('New Total $') As ColumnDescription, i.WeekEnding, Sum(i.Total) As Total
			From Info i
			Where i.ColumnDescription In ('NewSale', 'NewCredit')
			Group By i.WeekEnding

			Union All
			Select Max('Renew Total $') As ColumnDescription, i.WeekEnding, Sum(i.Total) As Total
			From Info As i
			Where i.ColumnDescription In ('RenewSale', 'UnallocatedCredit')
			Group By i.WeekEnding

			Union All
			Select Max('Renew Total') As ColumnDescription, i.WeekEnding, Sum(i.TransCount) As Total
			From Info As i
			Where i.ColumnDescription In ('RenewSale', 'UnallocatedCredit')
			Group By i.WeekEnding

			Union All
			Select Max('Recur Total $') As ColumnDescription, i.WeekEnding, Sum(i.Total) As Total
			From Info i
			Where i.ColumnDescription In ('RecurSale', 'RecurCredit')
			Group By i.WeekEnding

			Union All
			Select Max('Recur Total') As ColumnDescription, i.WeekEnding, Sum(i.TransCount) As Total
			From Info i
			Where i.ColumnDescription In ('RecurSale', 'RecurCredit')
			Group By i.WeekEnding

			Union All
			Select Max('Lapse Total'), i.WeekEnding, SUM(i.TransCount) As Total
			From Info As i
			Where i.ColumnDescription = 'LapseAccount' And WeekEnding <= Convert(VARCHAR(10),DateAdd(dd, 7 - (DatePart(dw, (GETDATE()))),(GETDATE())),111)
			Group By i.WeekEnding

			Union All
			Select Max('Prem Account Total'), WeekEnding, COUNT(WeekEnding) As Total
			From #weekEndingRows
			Where WeekEnding <= Convert(VARCHAR(10),DateAdd(dd, 7 - (DatePart(dw, (GETDATE()))),(GETDATE())),111)
			Group By WeekEnding

			Union All
			Select Max('x Coach Trials') As ColumnDescription,
			  Convert(VARCHAR(10),DateAdd(dd, 7 - (DatePart(dw, (p.AccountCreationDate))), (p.AccountCreationDate)),111) As Weekending, 
			  Count(*) As Total
			From  ultrafit_live..Person As p
			Where p.UserType In (2, 5) And DatePart(YEAR, p.AccountCreationDate) > 2008
			Group By Convert(VARCHAR(10),DateAdd(dd, 7 - (DatePart(dw, (p.AccountCreationDate))), (p.AccountCreationDate)),111)

			Union All
			Select i.ColumnDescription, i.WeekEnding, Sum(i.TransCount) As Total
			From Info i
			Where i.ColumnDescription = 'Training Plans Sold'
			Group By i.ColumnDescription, i.WeekEnding

			Union All
			Select i.ColumnDescription, i.WeekEnding, Sum(i.TransCount) As Total
			From Info i
			Where i.ColumnDescription = 'WKO Sold'
			Group By i.ColumnDescription, i.WeekEnding
			
			Union All
			Select i.ColumnDescription, i.WeekEnding, Sum(i.TransCount) As Total
			From Info i
			Where i.ColumnDescription = 'New Prem Account'
			Group By i.ColumnDescription, i.WeekEnding
END







GO
