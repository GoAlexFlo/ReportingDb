SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[sp_CpapUserType4Info] 
	@SourceDbName      Varchar(25),
	@DestinationDbName Varchar(25),
	@WhereCondition Varchar(500),
	@WhereConditionYear Varchar(4)
AS
BEGIN
SET NOCOUNT ON;
DECLARE @Sql Varchar(5000)
DECLARE @Empty Varchar(2)
SET @Empty = ''''''
		
Set @Sql =		
		'BEGIN
		    With Info 
			As
			( 
				Select Distinct p.PersonId
				From ' + @SourceDbName + '..Person As p Inner Join ' + @SourceDbName + '..Athlete As a On p.PersonId = a.PersonId
				Where ' + @WhereCondition + '
			)
			   Select i.PersonId, Sum(Month) As MonthsAsPaidUserType4
			   From Info AS i left outer Join ' + @DestinationDbName + '..PayPalProductRevenue As p On i.PersonId=p.PersonId
			   Where [Year]>=' + @WhereConditionYear + ' And  RowType =''Subscription'' And CreditDesc=' + @Empty + '  		         
			   Group By i.PersonId
	END'
	

		EXEC(@Sql)
END


GO
