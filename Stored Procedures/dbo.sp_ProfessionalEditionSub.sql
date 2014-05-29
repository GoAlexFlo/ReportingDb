SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_ProfessionalEditionSub]
AS
BEGIN
	SET NOCOUNT ON;

	CREATE TABLE #RunningTotal
	(DatePeriod datetime, PersonId int, NewPaidCoach int, NonRenewalCoach int, RevivedCoach int);
	
	With Info As (
		Select p.PersonId, -- New Coaches that paid using Paypa1 
		Convert(Date,Convert(VARCHAR(7),p.TransactionDate,111) + '/01') As TransDate, 1 As NewPaidCoach, 0 As NonRenewalCoach, 0 As RevivedCoach
		From dbo.PayPalProductRevenue As p
		Where RowType= 'CoachSubscription' And TransDesc ='NewSale' And [Type]='Sale' And Total > 0 
			  And Convert(VARCHAR(7),TransactionDate,111) >= '2009/01' 
			  
		Union All
		Select p.PersonId, -- Coaches that have expired
		Convert(Date,Convert(VARCHAR(7),p.TransactionDate,111) + '/01') As TransDate, 0 As NewPaidCoach, 1 As NonRenewalCoach, 0 As RevivedCoach
		From dbo.PayPalProductRevenue As p
		Where RowType= 'CoachSubscription' And TransDesc ='Expired'  
			  And Convert(VARCHAR(7),TransactionDate,111) >= '2009/01' 

		Union All  --  Pull Coaches that make manual payments (Check, Credit Card)  Exception: Manual Payments could be made through PayPal 
		Select CoachId As PersonId, 
		Convert(Date,Min(Convert(VARCHAR(7),client_count.thedate,111) + '/01')) As TransDate, 1 As NewPaidCoach, 0 As NonRenewalCoach, 0 As RevivedCoach
		From client_count inner join coachinggroup on coachinggroup.coachinggroupid = client_count.CoachingGroupId 
		Where coachinggroup.AutoBillMonthly = 0 
		Group By coachid
		Having  Min(Convert(VARCHAR(7),client_count.thedate,111)) >= '2009/01' 
		
		Union All 
		Select PersonId, -- Pull Revived Coaches
		    Convert(Date,Convert(VARCHAR(7),TransactionDate,111) + '/01') As TransDate, 0 As NewPaidCoach, 0 As NonRenewalCoach, 1 As RevivedCoach
			From PayPalProductRevenue As p 
			Where (p.RowType= 'CoachSubscription' And p.TransDesc ='RevivedSale' And p.[Type]='Sale' And p.Total > 0) And TransactionDate >='2009-01-01' 
			Group By PersonId, Convert(Date,Convert(VARCHAR(7),TransactionDate,111) + '/01')
	)
		INSERT INTO #RunningTotal
				   (DatePeriod,
				    PersonId,
					NewPaidCoach,
					NonRenewalCoach,
					RevivedCoach)
		Select TransDate, PersonId, Max(NewPaidCoach), Max(NonRenewalCoach),  Max(RevivedCoach)
		From Info
		Group By TransDate, PersonId; -- Group in case a new coach has a paypal and manual payment on record.  We don't want to double count new coaches 
		
	Declare @cnt int  -- (I don't like doing this) Since Paypal transactions do not go back to the start of business, let's insert a starting NewPaidCoach total for 2008-12-01.  This stating number was pulled from the original Professional Edition Report. 
	Set @cnt = 1;
	While @cnt<605
	begin
		INSERT INTO #RunningTotal 
			(DatePeriod, PersonId, NewPaidCoach, NonRenewalCoach, RevivedCoach)
			Select '2008-12-01', @cnt, 1, 0, 0;
		Set @cnt=@cnt+1
	End;

--- Let's accumulate the number of new coaches per month
	CREATE TABLE #RunningCoachCount
	(NewCoachDate datetime, NewCoachCount int);

    With getTot As 
	(
	  Select distinct  Convert(Date,Convert(VARCHAR(7),TransactionDate,111) + '/01') As ProcessDate 
	  From PayPalProductRevenue 
	  Where Convert(VARCHAR(7),TransactionDate,111)> '2008/12' 
	)
   		INSERT INTO #RunningCoachCount
			   (NewCoachDate,
			    NewCoachCount)
       Select g.ProcessDate, 
        ((Select Count(Personid) From #RunningTotal Where DatePeriod <= g.ProcessDate And NewPaidCoach>0) +
        (Select Count(Personid) From #RunningTotal Where DatePeriod <= g.ProcessDate And RevivedCoach>0)) -
        (Select Count(Personid) From #RunningTotal Where DatePeriod <= g.ProcessDate And NonRenewalCoach>0)
       From getTot As g order by ProcessDate;

--- Here start the number crunching
	Select CONVERT(char(10),d.ReportDate, 101) As ReportDate, 
		   Sum(TrialsInMonth) As TrialsInMonth, 
		   Sum(d.NewPaidCoachesPerMonth) As NewPaidCoachesPerMonth,
		   Sum(d.CoachAccountsRevived) As CoachAccountsRevived,
		   Round(Sum(Convert(Float,d.NewPaidCoachesPerMonth+d.PriorMonthPaidCoaches))/Sum(Convert(Float,TrialsInMonth+d.PriorMonthTrials))*100,2)  As  Trailing2MnCoachConversionRate,
		   Sum(d.NewCoachedAthlete) As NewCoachedAthlete,
		   Sum(d.AcutualCoachesTotal) As ActualCoaches,
		   Sum(d.NonRenewalCoach) As LostCoaches,
		   Sum(d.NonRenewalCoach) As ChurnRate,
		   Sum(d.TotalUBC) As TotalUBC,
		   Sum(d.PaidUBC) As PaidUBC,
		   Sum(d.PremiumClients) As PremiumClients,
		   Sum(d.UbcClients) As UbcClients,
		   Sum(d.UbcClientsActive) As UbcClientsActive,
		   Sum(d.UbcClientsInActive) As UbcClientsInActive,
		   Sum(d.SelfPaidPremiumClients) As SelfPaidPremiumClients,
		   Sum(d.UBC$) As UBC$,
		   Sum(d.Premium$ ) As Premium$,
		   Sum(d.Premium$ ) + Sum(d.UBC$) As Total$,
		   Round((Sum(d.Premium$ ) + Sum(d.UBC$)) / Sum(d.AcutualCoachesTotal),2) As AvgRevPerCoach      
	From (
			Select  Convert(Date,Convert(VARCHAR(7),AccountCreationDate,111) + '/01') As ReportDate,
					0 As NewPaidCoachesPerMonth,
					0 As CoachAccountsRevived,
					0 As PriorMonthPaidCoaches, 
					0 As NewCoachedAthlete, 
					Count(*) As TrialsInMonth, 
					0 As PriorMonthTrials,
					0 As NonRenewalCoach,
					0 As AcutualCoachesTotal,
					0 As ActualCoaches,  
					0 As TotalUBC,
					0 As PaidUBC,
					0 As PremiumClients,
				    0 As UbcClients,
				    0 As UbcClientsActive,
				    0 As UbcClientsInActive,
					0 As SelfPaidPremiumClients,
					0 As UBC$,
					0 As Premium$      
			From Person
			Where usertype in (2,5) And Convert(VARCHAR(7),AccountCreationDate,111) >= '2009/01'
			Group By Convert(VARCHAR(7),AccountCreationDate,111)
			
			Union All
			Select  DATEADD(MONTH, 1, Convert(Date,Convert(VARCHAR(7),AccountCreationDate,111) + '/01')) As ReportDate,
					0 As NewPaidCoachesPerMonth,
					0 As CoachAccountsRevived,
					0 As PriorMonthPaidCoaches, 
					0 As NewCoachedAthlete,
					0 As TrialsInMonth, 
					Count(*) As PriorMonthTrials,
					0 As NonRenewalCoach,
					0 As AcutualCoachesTotal,
					0 As ActualCoaches,  
					0 As TotalUBC,
					0 As PaidUBC,
					0 As PremiumClients,
				    0 As UbcClients,
				    0 As UbcClientsActive,
				    0 As UbcClientsInActive,
					0 As SelfPaidPremiumClients,
					0 As UBC$,
					0 As Premium$     
			From Person
			Where usertype in (2,5) And Convert(VARCHAR(7),AccountCreationDate,111) >= '2009/01' 
			Group By Convert(VARCHAR(7),AccountCreationDate,111)

			Union All
					Select DatePeriod As ReportDate, 
					Count( PersonId) As NewPaidCoachesPerMonth,
					0 As CoachAccountsRevived,
					0 As PriorMonthPaidCoaches, 
					0 As NewCoachedAthlete, 
					0 As TrialsInMonth, 
					0 As PriorMonthTrials,
					0 As NonRenewalCoach,
					0 As AcutualCoachesTotal,
					0 As ActualCoaches,  
					0 As TotalUBC,
					0 As PaidUBC,
					0 As PremiumClients,
				    0 As UbcClients,
				    0 As UbcClientsActive,
				    0 As UbcClientsInActive,
					0 As SelfPaidPremiumClients,
					0 As UBC$,
					0 As Premium$      
			From #RunningTotal
			Where NewPaidCoach > 0 And DatePeriod >= '2009/01/01'
			Group By DatePeriod
			
			Union All
					Select Convert(Date,Convert(VARCHAR(7),TransactionDate,111) + '/01') As ReportDate,
					0 As NewPaidCoachesPerMonth,
					Count(*) As CoachAccountsRevived,
					0 As PriorMonthPaidCoaches, 
					0 As NewCoachedAthlete, 
					0 As TrialsInMonth, 
					0 As PriorMonthTrials,
					0 As NonRenewalCoach,
					0 As AcutualCoachesTotal,
					0 As ActualCoaches,  
					0 As TotalUBC,
					0 As PaidUBC,
					0 As PremiumClients,
				    0 As UbcClients,
				    0 As UbcClientsActive,
				    0 As UbcClientsInActive,
					0 As SelfPaidPremiumClients,
					0 As UBC$,
					0 As Premium$      
			From PayPalProductRevenue As p 
			Where (p.RowType= 'CoachSubscription' And p.TransDesc ='RevivedSale' And p.[Type]='Sale' And p.Total > 0) And TransactionDate >='2009-01-01' -- Revived Coaches
			Group By Convert(Date,Convert(VARCHAR(7),TransactionDate,111) + '/01')

			Union All
			Select  DATEADD(MONTH, 1, DatePeriod) As ReportDate, 
					0 As NewPaidCoachesPerMonth,
					0 As CoachAccountsRevived,
					Count(Distinct PersonId) As PriorMonthPaidCoaches,  
					0 As NewCoachedAthlete, 
					0 As TrialsInMonth, 
					0 As PriorMonthTrials,
					0 As NonRenewalCoach,
					0 As AcutualCoachesTotal,
					0 As ActualCoaches,  
					0 As TotalUBC,
					0 As PaidUBC,
					0 As PremiumClients,
				    0 As UbcClients,
				    0 As UbcClientsActive,
				    0 As UbcClientsInActive,
					0 As SelfPaidPremiumClients,
					0 As UBC$,
					0 As Premium$      
			From #RunningTotal
			Where NewPaidCoach > 0 And DatePeriod >= '2009/01/01'
			Group By DatePeriod
			
			Union All
			
			Select Convert(Date,Convert(VARCHAR(7),TransactionDate,111) + '/01') As ReportDate,
				   0 As NewPaidCoachesPerMonth,
				   0 As CoachAccountsRevived,
				   0 As PriorMonthPaidCoaches, 
				   Count(*) As NewCoachedAthlete, 
				   0 As TrialsInMonth, 
				   0 As PriorMonthTrials,
				   0 As NonRenewalCoach,
				   0 As AcutualCoachesTotal,
				   0 As ActualCoaches,  
				   0 As TotalUBC,
				   0 As PaidUBC,
				   0 As PremiumClients,
				   0 As UbcClients,
				   0 As UbcClientsActive,
				   0 As UbcClientsInActive,
				   0 As SelfPaidPremiumClients,
				   0 As UBC$,
				   0 As Premium$     
			From PayPalProductRevenue 
			Where RowType= 'CoachTransaction' And [Type] ='Sale' And Sku like 'cvap%' And Total > 0 And TransactionDate >='2009-01-01' -- Revived Coaches]
			Group By Convert(VARCHAR(7),TransactionDate,111)
			
			Union All
			Select (Convert(Date,Convert(VARCHAR(7),TransactionDate,111) + '/01')) As ReportDate, 
				   0 As NewPaidCoachesPerMonth,
				   0 As CoachAccountsRevived,
				   0 As PriorMonthPaidCoaches, 
				   0 As NewCoachedAthlete, 
				   0 As TrialsInMonth, 
				   0 As PriorMonthTrials, 
				   COUNT(*) As NonRenewalCoach,
				   0 As AcutualCoachesTotal,
				   0 As ActualCoaches,  
				   0 As TotalUBC,
				   0 As PaidUBC,
				   0 As PremiumClients,
				   0 As UbcClients,
				   0 As UbcClientsActive,
				   0 As UbcClientsInActive,
				   0 As SelfPaidPremiumClients,
				   0 As UBC$,
				   0 As Premium$   
			From [Reporting].[dbo].[PayPalProductRevenue]
			Where RowType = 'CoachSubscription' and TransDesc = 'Expired'
			Group by (Convert(Date,Convert(VARCHAR(7),TransactionDate,111) + '/01'))
	
			Union All
			Select NewCoachDate  As ReportDate, 
     			   0 As NewPaidCoachesPerMonth,
				   0 As CoachAccountsRevived,
				   0 As PriorMonthPaidCoaches, 
				   0 As NewCoachedAthlete, 
				   0 As TrialsInMonth, 
				   0 As PriorMonthTrials, 
				   0 As NonRenewalCoach,
				   NewCoachCount As AcutualCoachesTotal, 
				   0 As ActualCoaches,  
				   0 As TotalUBC,
				   0 As PaidUBC,
				   0 As PremiumClients,
				   0 As UbcClients,
				   0 As UbcClientsActive,
				   0 As UbcClientsInActive,
				   0 As SelfPaidPremiumClients,
				   0 As UBC$,
				   0 As Premium$   
			From #RunningCoachCount
	        
			Union All	   
			Select Convert(Date,Convert(VARCHAR(7),DateOfLogin,111) + '/01') As ReportDate,
				   0 As NewPaidCoachesPerMonth,
				   0 As CoachAccountsRevived,
				   0 As PriorMonthPaidCoaches, 
				   0 As NewCoachedAthlete, 
				   0 As TrialsInMonth, 
				   0 As PriorMonthTrials, 
				   0 As NonRenewalCoach,
				   0 As AcutualCoachesTotal,
				   0 As ActualCoaches,  
				   max(totalcount) As TotalUBC,
				   0 As PaidUBC,
				   0 As PremiumClients,
				   0 As UbcClients,
				   0 As UbcClientsActive,
				   0 As UbcClientsInActive,
				   0 As SelfPaidPremiumClients,
				   0 As UBC$,
				   0 As Premium$
			From DailyPersonUsage 
			Where reportname = 'UBCCoaches'
			Group By Convert(VARCHAR(7),DateOfLogin,111) 
	        
			Union All	   
			Select (Convert(Date,Convert(VARCHAR(7),DateOfLogin,111) + '/01')) As ReportDate,
				   0 As NewPaidCoachesPerMonth,
				   0 As CoachAccountsRevived,
				   0 As PriorMonthPaidCoaches, 
				   0 As NewCoachedAthlete, 
				   0 As TrialsInMonth, 
				   0 As PriorMonthTrials, 
				   0 As NonRenewalCoach,
				   0 As AcutualCoachesTotal,
				   0 As ActualCoaches,  
				   0 As TotalUBC,
				   max(totalcount) As PaidUBC,
				   0 As PremiumClients,
				   0 As UbcClients,
				   0 As UbcClientsActive,
				   0 As UbcClientsInActive,
				   0 As SelfPaidPremiumClients,
				   0 As UBC$,
				   0 As Premium$
			From DailyPersonUsage 
			Where reportname = 'PaidUBCCoaches'
			Group By (Convert(Date,Convert(VARCHAR(7),DateOfLogin,111) + '/01')) 
	        
			Union All	   
			Select (Convert(Date,Convert(VARCHAR(7),DateOfLogin,111) + '/01')) As ReportDate,
				   0 As NewPaidCoachesPerMonth,
				   0 As CoachAccountsRevived,
				   0 As PriorMonthPaidCoaches, 
				   0 As NewCoachedAthlete, 
				   0 As TrialsInMonth, 
				   0 As PriorMonthTrials, 
				   0 As NonRenewalCoach,
				   0 As AcutualCoachesTotal,
				   0 As ActualCoaches,  
				   0 As TotalUBC,
				   0 As PaidUBC,
				   max(totalcount) As PremiumClients,
				   0 As UbcClients,
				   0 As UbcClientsActive,
				   0 As UbcClientsInActive,
				   0 As SelfPaidPremiumClients,
				   0 As UBC$,
				   0 As Premium$
			From DailyPersonUsage 
			Where reportname = 'CoachedAthletes'
			Group By (Convert(Date,Convert(VARCHAR(7),DateOfLogin,111) + '/01')) 

			Union All	   
			Select (Convert(Date,Convert(VARCHAR(7),DateOfLogin,111) + '/01')) As ReportDate,
				   0 As NewPaidCoachesPerMonth,
				   0 As CoachAccountsRevived,
				   0 As PriorMonthPaidCoaches, 
				   0 As NewCoachedAthlete, 
				   0 As TrialsInMonth, 
				   0 As PriorMonthTrials, 
				   0 As NonRenewalCoach,
				   0 As AcutualCoachesTotal,
				   0 As ActualCoaches,  
				   0 As TotalUBC,
				   0 As PaidUBC,
				   0 As PremiumClients,
				   max(totalcount) As UbcClients,
   				   0 As UbcClientsActive,
				   0 As UbcClientsInActive,
				   0 As SelfPaidPremiumClients,
				   0 As UBC$,
				   0 As Premium$
			From DailyPersonUsage 
			Where reportname = 'UBCClients'
			Group By (Convert(Date,Convert(VARCHAR(7),DateOfLogin,111) + '/01')) 

			Union All	   
			Select (Convert(Date,Convert(VARCHAR(7),DateOfLogin,111) + '/01')) As ReportDate,
				   0 As NewPaidCoachesPerMonth,
				   0 As CoachAccountsRevived,
				   0 As PriorMonthPaidCoaches, 
				   0 As NewCoachedAthlete, 
				   0 As TrialsInMonth, 
				   0 As PriorMonthTrials, 
				   0 As NonRenewalCoach,
				   0 As AcutualCoachesTotal,
				   0 As ActualCoaches,  
				   0 As TotalUBC,
				   0 As PaidUBC,
				   0 As PremiumClients,
				   0 As UbcClients,
				   max(totalcount) As UbcClientsActive,
				   0 As UbcClientsInActive,
				   0 As SelfPaidPremiumClients,
				   0 As UBC$,
				   0 As Premium$
			From DailyPersonUsage 
			Where reportname = 'UBCClientsActive'
			Group By (Convert(Date,Convert(VARCHAR(7),DateOfLogin,111) + '/01')) 
			
			Union All	   
			Select (Convert(Date,Convert(VARCHAR(7),DateOfLogin,111) + '/01')) As ReportDate,
				   0 As NewPaidCoachesPerMonth,
				   0 As CoachAccountsRevived,
				   0 As PriorMonthPaidCoaches, 
				   0 As NewCoachedAthlete, 
				   0 As TrialsInMonth, 
				   0 As PriorMonthTrials, 
				   0 As NonRenewalCoach,
				   0 As AcutualCoachesTotal,
				   0 As ActualCoaches,  
				   0 As TotalUBC,
				   0 As PaidUBC,
				   0 As PremiumClients,
				   0 As UbcClients,
				   0 As UbcClientsActive,
				   max(totalcount) As UbcClientsInActive,
				   0 As SelfPaidPremiumClients,
				   0 As UBC$,
				   0 As Premium$
			From DailyPersonUsage 
			Where reportname = 'UBCClientsInActive'
			Group By (Convert(Date,Convert(VARCHAR(7),DateOfLogin,111) + '/01')) 
	        
			Union All	   
			Select (Convert(Date,Convert(VARCHAR(7),DateOfLogin,111) + '/01')) As ReportDate,
				   0 As NewPaidCoachesPerMonth,
				   0 As CoachAccountsRevived,
				   0 As PriorMonthPaidCoaches, 
				   0 As NewCoachedAthlete, 
				   0 As TrialsInMonth, 
				   0 As PriorMonthTrials, 
				   0 As NonRenewalCoach,
				   0 As AcutualCoachesTotal,
				   0 As ActualCoaches,  
				   0 As TotalUBC,
				   0 As PaidUBC,
				   0 As PremiumClients,
				   0 As UbcClients,
				   0 As UbcClientsActive,
				   0 As UbcClientsInActive,
				   max(totalcount) As SelfPaidPremiumClients,
				   0 As UBC$,
				   0 As Premium$
			From DailyPersonUsage 
			Where reportname = 'self paid premium coached'
			Group By (Convert(Date,Convert(VARCHAR(7),DateOfLogin,111) + '/01'))
	        
			Union All	   
			Select (Convert(Date,Convert(VARCHAR(7),TransactionDate,111) + '/01')) As ReportDate,
				   0 As NewPaidCoachesPerMonth,
				   0 As CoachAccountsRevived,
				   0 As PriorMonthPaidCoaches, 
				   0 As NewCoachedAthlete, 
				   0 As TrialsInMonth, 
				   0 As PriorMonthTrials, 
				   0 As NonRenewalCoach,
				   0 As AcutualCoachesTotal,
				   0 As ActualCoaches,  
				   0 As TotalUBC,
				   0 As PaidUBC,
				   0 As PremiumClients,
				   0 As UbcClients,
				   0 As UbcClientsActive,
				   0 As UbcClientsInActive,
				   0 As SelfPaidPremiumClients,
				   Round(SUM(Total),0) As UBC$,
				   0 As Premium$
			 From PayPalProductRevenue 
			 Where sku LIKE 'cvr%' 
			 Group BY (Convert(Date,Convert(VARCHAR(7),TransactionDate,111) + '/01')) 
			 
			Union All	   
			Select (Convert(Date,Convert(VARCHAR(7),TransactionDate,111) + '/01')) As ReportDate,
				   0 As NewPaidCoachesPerMonth,
				   0 As CoachAccountsRevived,
				   0 As PriorMonthPaidCoaches, 
				   0 As NewCoachedAthlete, 
				   0 As TrialsInMonth, 
				   0 As PriorMonthTrials, 
				   0 As NonRenewalCoach,
				   0 As AcutualCoachesTotal,
				   0 As ActualCoaches,  
				   0 As TotalUBC,
				   0 As PaidUBC,
				   0 As PremiumClients,
				   0 As UbcClients,
				   0 As UbcClientsActive,
				   0 As UbcClientsInActive,
				   0 As SelfPaidPremiumClients,
				   0 As UBC$,
				   Round(SUM(Total),0) As Premium$
			 From PayPalProductRevenue 
			 Where sku LIKE 'cvap%' 
			 Group BY (Convert(Date,Convert(VARCHAR(7),TransactionDate,111) + '/01')) 
			 
	) d
	Group By d.ReportDate
	Having Sum(d.NewPaidCoachesPerMonth) >0 
	Order By d.ReportDate;
	DROP TABLE #RunningTotal;
	DROP TABLE #RunningCoachCount;
End




GO
