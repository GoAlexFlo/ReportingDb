SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_CpapCoachLtsInfo] 
	@SourceDbName      Varchar(25),
	@DestinationDbName Varchar(25)
AS
BEGIN
SET NOCOUNT ON;
DECLARE @Sql Varchar(5000)
DECLARE @Empty Varchar(2)
SET @Empty = ''''''

		
Set @Sql =		
		'BEGIN
		  Select i.CoachId, Count(Distinct i.PersonId) As TotalCoachedAthletes,
		      Sum(Case 
			  	  When p.rowType=''Subscription'' And p.IsAthlete=1 And
			  	      (CreditDesc Not like ''NewSaleCredited:%'' And CreditDesc Not like ''NewSalesCredit:%'' And CreditDesc Not like ''NoSalesTransactionFound%'')  -- Exclude Credits tranactions and their Credited Sale
				  Then p.Total
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
				  Else 0
				  End) As LtsSoftware,
			  Sum(Case 
				  When p.rowType=''WorkoutLibrary'' And p.IsAthlete=1 And
			  	      (CreditDesc ='''')  -- Exclude Credits tranactions and their Credited Sale 
				  Then p.Total
				  Else 0
				  End) As LtsLibrary,
			  Sum(Total) As LtsTotal
		   From ' + @DestinationDbName + '..CoachedAthletes AS i Left Outer Join ' + @DestinationDbName + '..PayPalProductRevenue As p 
										   On i.PersonId=p.PersonId And CONVERT(Date,p.TransactionDate) Between i.CoachedFromDate And i.CoachedToDate
		   Group By i.CoachId
	END'
	EXEC(@Sql)
END

GO
