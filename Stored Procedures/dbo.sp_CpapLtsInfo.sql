SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_CpapLtsInfo] 
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
				Select Distinct p.PersonId, p.usertype, p.AccountCreationDate
				From ' + @SourceDbName + '..Person As p Inner Join ' + @SourceDbName + '..Athlete As a On p.PersonId = a.PersonId
				Where ' + @WhereCondition + '
			), PrepInfo As 
			   (
			    Select i.PersonId,  
			             Sum(Case 
							 When ((DATEDIFF (MONTH, i.AccountCreationDate, GETDATE ())/12.0) >0) And p.[Year]>=' + @WhereConditionYear + ' 
							 Then (TOTAL)/(DATEDIFF (MONTH, i.AccountCreationDate, GETDATE ())/12.0) 
							 Else 0 
							 End) As ARR,
					      Sum(Case 
						  	  When p.rowType=''Subscription'' And p.IsAthlete=1 And
						  	      (CreditDesc Not like ''NewSaleCredited:%'' And CreditDesc Not like ''NewSalesCredit:%'' And CreditDesc Not like ''NoSalesTransactionFound%'')  -- Exclude Credits tranactions and their Credited Sale
							  Then p.Total
							  -- This was removed because logic is now handled in the generation of the PAYPALREVENUEPRODUCT table
							  --When p.rowType=''Software'' And Sku Like ''%procombo%'' And p.IsAthlete=1 And
						  	  --    (CreditDesc Not like ''NewSaleCredited:%'' And CreditDesc Not like ''NewSalesCredit:%'' And CreditDesc Not like ''NoSalesTransactionFound%'')  -- Exclude Credits tranactions and their Credited Sale 
							  --Then (p.Total-129)
							  Else 0
							  End) As LtsSubscription,
						  Sum(Case 
							  When p.rowType=''TrainingPlan'' And p.IsAthlete=1 And
						  	      (CreditDesc Not like ''NewSaleCredited:%'' And CreditDesc Not like ''NewSalesCredit:%'' And CreditDesc Not like ''NoSalesTransactionFound%'')  -- Exclude Credits tranactions and their Credited Sale 
							  Then p.Total
							  Else 0
							  End) As LtsTrainingPlan,
						  Sum(Case 
							  When p.rowType=''Software'' And Sku Not Like ''%procombo%'' And p.IsAthlete=1 And
						  	      (CreditDesc Not like ''NewSaleCredited:%'' And CreditDesc Not like ''NewSalesCredit:%'' And CreditDesc Not like ''NoSalesTransactionFound%'')  -- Exclude Credits tranactions and their Credited Sale
							  Then p.Total
							  -- This was removed because logic is now handled in the generation of the PAYPALREVENUEPRODUCT table
							  --When p.rowType=''Software'' And Sku Like ''%procombo%'' And p.IsAthlete=1 And
						  	  --    (CreditDesc Not like ''NewSaleCredited:%'' And CreditDesc Not like ''NewSalesCredit:%'' And CreditDesc Not like ''NoSalesTransactionFound%'')  -- Exclude Credits tranactions and their Credited Sale 
							  --Then 129
							  Else 0
							  End) As LtsSoftware,
						  Sum(Case 
							  When p.rowType=''WorkoutLibrary'' And p.IsAthlete=1 And
						  	      (CreditDesc =' + @Empty + ')  -- Exclude Credits tranactions and their Credited Sale 
							  Then p.Total
							  Else 0
							  End) As LtsLibrary,
						  Sum(Total) As LtsTotal
			   From Info AS i left outer Join ' + @DestinationDbName + '..PayPalProductRevenue As p On i.PersonId=p.PersonId
			   Group By i.PersonId, i.AccountCreationDate
			 )
			 Select PersonId, Sum(ARR) As ARR, Sum(LtsSubscription) As LtsSubscription, Sum(LtsTrainingPlan) As LtsTrainingPlan, 
			                  Sum(LtsSoftware) As LtsSoftware, Sum(LtsLibrary) As LtsLibrary, Sum(LtsTotal) As LtsTotal
			 From PrepInfo
			 Group By PersonId
	END'
	

		EXEC(@Sql)
END

GO
