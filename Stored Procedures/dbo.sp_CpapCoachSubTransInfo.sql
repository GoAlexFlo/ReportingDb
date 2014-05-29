SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[sp_CpapCoachSubTransInfo] 
	@SourceDbName      Varchar(25),
	@DestinationDbName Varchar(25)
AS
BEGIN
SET NOCOUNT ON;
DECLARE @Sql Varchar(2000)
DECLARE @Empty Varchar(2)
SET @Empty = ''''''


Set @Sql =
	   'BEGIN
			Select a.CoachId, a.PersonId, a.CoachedFromDate, a.CoachedToDate, 
			  Case
   				When p.Usertype=4 And RowOrder=(Select MAX(RowOrder) From PayPalProductRevenue Where PersonId=p.PersonId And RowType=''Subscription'' And CreditDesc=' + @Empty + ')
   				Then 0
				When EXISTS(Select Top 1 * From PayPalProductRevenue Where PersonId=p.PersonId And RowOrder>p.RowOrder And Convert(Varchar(10),SubscriptionFrom,111)<=Convert(Varchar(10),DATEADD(dd,5,p.SubscriptionTo),111) And RowType=''Subscription'' And CreditDesc=' + @Empty + ' )
				Then 0
				Else 1
				End As Lapsed,
			 Case
				When p.TransDesc =''NewSale''
				Then 1
				Else 0
				End As NewSaleCount,
			  Case
				When p.TransDesc =''RenewSale''
				Then 1
				Else 0
				End As RenewSaleCount,
			Case
				When p.TransDesc =''RecurSale''
				Then 1
				Else 0
				End As RecurSaleCount,
				Case
			When p.TransDesc =''NewSale''
				Then SubscriptionMonths
				Else Null
				End As TermOfNew,
			DATEDIFF(DAY, SubscriptionTo, GetDate()) As DaysSinceLastPremSub 
			From ' + @DestinationDbName + '..CoachedAthletes As a Inner Join ' + @DestinationDbName + '..PayPalProductRevenue As p 
			     On a.PersonId = p.PersonId And Convert(Date,TransactionDate) Between a.CoachedFromDate And  a.CoachedToDate
			Where p.RowType=''Subscription'' and p.CreditDesc=' + @Empty + ' 	
		END'
		
		EXEC(@Sql)
END





GO
