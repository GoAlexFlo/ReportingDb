SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[sp_CpapSubTransInfo] 
	@SourceDbName      Varchar(25),
	@DestinationDbName Varchar(25),
	@WhereCondition Varchar(500),
	@WhereConditionYear Varchar(4)
AS
BEGIN
SET NOCOUNT ON;
DECLARE @Sql Varchar(2000)
DECLARE @Empty Varchar(2)
SET @Empty = ''''''


Set @Sql =
	   'BEGIN
			With AthleteInfo As
		( 
			SELECT Distinct p.PersonId
			FROM ' + @SourceDbName + '..Person As p Inner Join ' + @SourceDbName + '..Athlete As a On p.PersonId = a.PersonId
			WHERE ' + @WhereCondition + '  
		), PrepInfo As
		(
			Select p.PersonId, Case When YEAR(Convert(Datetime,SubscriptionTo))>=2010 Then SubscriptionTo Else null End As SubscriptionTo,
			  Case
   				When p.Usertype=4 And RowOrder=(Select MAX(RowOrder) From PayPalProductRevenue Where PersonId=p.PersonId And RowType=''Subscription'' And CreditDesc=' + @Empty + ')
   				Then 0
				When EXISTS(Select Top 1 * From PayPalProductRevenue Where PersonId=p.PersonId And RowOrder>p.RowOrder And Convert(Varchar(10),SubscriptionFrom,111)<=Convert(Varchar(10),DATEADD(dd,5,p.SubscriptionTo),111) And RowType=''Subscription'' And CreditDesc=' + @Empty + ' )
				Then 0
				Else 1
				End As Lapsed,
			  Case
				When p.TransDesc =''RenewSale''
				Then 1
				Else 0
				End As RenewSaleCount,
			Case
				When p.TransDesc =''RecurSale''
				Then 1
				Else 0
				End As RecurSaleCount
			From AthleteInfo As a Inner Join ' + @DestinationDbName + '..PayPalProductRevenue As p On a.PersonId = p.PersonId
			Where p.RowType=''Subscription'' and p.CreditDesc=' + @Empty + ' 
		) 
			Select PersonId, SUM(Lapsed) As LapseCount, 
			                 Sum(RenewSaleCount) As RenewSaleCount, 
			                 Sum(RecurSaleCount) As RecurSaleCount,
			                 DATEDIFF(DAY, Max(SubscriptionTo), GetDate()) As DaysSinceLastPremSub 
			From PrepInfo
			Group By PersonId
		END'
		
		EXEC(@Sql)
		
END





GO
