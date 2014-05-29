SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_CpapCoachUserTypePlanInfo] 
	@SourceDbName      Varchar(25),
	@DestinationDbName Varchar(25),
	@WhereConditionYear Varchar(4)
AS
BEGIN
SET NOCOUNT ON;
DECLARE @Sql   Varchar(MAX)
DECLARE @Sql01 Varchar(MAX)
DECLARE @Sql02 Varchar(MAX)
DECLARE @ReplaceStr Varchar(MAX)
DECLARE @CNT int = 1
DECLARE @STR int = 0
DECLARE @END int = 0
DECLARE @Empty Varchar(2) = ''''''


Set @Sql01 = 
	'BEGIN
		With CoachedAthletesInfo 
		As
		   (
			-- Determine If BoughtWorkoutPlan	 
				Select a.PersonId, a.UserType, a.CoachId, Convert(Date, pp.TransactionDate) As TransactionDate, CoachedFromDate, CoachedToDate,
					   1 As BoughtWorkoutPlan, 0 As BoughtNutritionPlan, 0 As BoughtNutritionAndWorkoutComboPlan, 0 As BoughtWorkoutLibrary, 
					   0 As CoachSuppliedWorkoutPlan, 0 As CoachSuppliedMealPlan, 0 As AppliedPlanCount 
				From ' + @DestinationDbName + '..CoachedAthletes As a Inner Join  ' + @DestinationDbName + '..PayPalProductRevenue As pp On a.PersonId = pp.PersonId And Convert(Date, pp.TransactionDate) Between a.CoachedFromDate And a.CoachedToDate
									  Inner Join ' + @SourceDbName + '..[Plan] As p On p.PlanId = pp.PlanId
				Where pp.[Year]>= ' + @WhereConditionYear + ' And 
					  pp.RowType=''TrainingPlan''             And 
					 (pp.CreditDesc Not like ''NewSaleCredited:%'' And pp.CreditDesc Not like ''NewSalesCredit:%'') And 
					  pp.PlanId Is Not Null And
					  p.WorkoutCount>0 And (p.MealCount=0 Or p.MealCount is Null)
				      
				Union All		      
			-- Determine If BoughtNutritionPlan	 
				Select a.PersonId, a.UserType, a.CoachId, Convert(Date, pp.TransactionDate) As TransactionDate, CoachedFromDate, CoachedToDate, 
					   0 As BoughtWorkoutPlan, 1 As BoughtNutritionPlan, 0 As BoughtNutritionAndWorkoutComboPlan, 0 As BoughtWorkoutLibrary, 
					   0 As CoachSuppliedWorkoutPlan, 0 As CoachSuppliedMealPlan, 0 As AppliedPlanCount 
				From ' + @DestinationDbName + '..CoachedAthletes As a Inner Join  ' + @DestinationDbName + '..PayPalProductRevenue As pp On a.PersonId = pp.PersonId And Convert(Date, pp.TransactionDate) Between a.CoachedFromDate And a.CoachedToDate
									  Inner Join ' + @SourceDbName + '..[Plan] As p On p.PlanId = pp.PlanId
				Where pp.[Year]>= ' + @WhereConditionYear + ' And 
					  pp.RowType=''TrainingPlan''                  And 
					 (pp.CreditDesc Not like ''NewSaleCredited:%'' And pp.CreditDesc Not like ''NewSalesCredit:%'') And 
					  pp.PlanId Is Not Null And
					  p.MealCount>0 And (p.WorkoutCount=0 Or p.WorkoutCount is Null)
				
				Union All		      
			-- Determine If User BoughtWorkoutPlan And BoughtNutritionPlan 
				Select a.PersonId, a.UserType, a.CoachId, Convert(Date, pp.TransactionDate) As TransactionDate, CoachedFromDate, CoachedToDate,  
					   0 As BoughtWorkoutPlan, 0 As BoughtNutritionPlan, 1 As BoughtNutritionAndWorkoutComboPlan, 0 As BoughtWorkoutLibrary, 
					   0 As CoachSuppliedWorkoutPlan, 0 As CoachSuppliedMealPlan, 0 As AppliedPlanCount 
				From ' + @DestinationDbName + '..CoachedAthletes As a Inner Join  ' + @DestinationDbName + '..PayPalProductRevenue As pp On a.PersonId = pp.PersonId And Convert(Date, pp.TransactionDate) Between a.CoachedFromDate And a.CoachedToDate
									  Inner Join ' + @SourceDbName + '..[Plan] As p On p.PlanId = pp.PlanId
				Where pp.[Year]>= ' + @WhereConditionYear + ' And 
					  pp.RowType=''TrainingPlan''             And 
					 (pp.CreditDesc Not like ''NewSaleCredited:%'' And pp.CreditDesc Not like ''NewSalesCredit:%'') And 
					  pp.PlanId Is Not Null And
					  p.MealCount>0 And p.WorkoutCount>0
					  
			Union All		      
			-- Determine If User BoughtWorkoutLibrary 
				Select a.PersonId, a.UserType, a.CoachId, Convert(Date, pp.TransactionDate) As TransactionDate, CoachedFromDate, CoachedToDate,   
					   0 As BoughtWorkoutPlan, 0 As BoughtNutritionPlan, 0 As BoughtNutritionAndWorkoutComboPlan, 1 As BoughtWorkoutLibrary,
					   0 As CoachSuppliedWorkoutPlan, 0 As CoachSuppliedMealPlan, 0 As AppliedPlanCount 
				From ' + @DestinationDbName + '..CoachedAthletes As a Inner Join  ' + @DestinationDbName + '..PayPalProductRevenue As pp On a.PersonId = pp.PersonId  And Convert(Date, pp.TransactionDate) Between a.CoachedFromDate And a.CoachedToDate
				Where pp.[Year]>= ' + @WhereConditionYear + ' And 
					  pp.RowType=''WorkoutLibrary''           And 
					 (pp.CreditDesc =' + @Empty + ') 
				
				Union All		      
			-- Determine If CoachSuppliedWorkoutPlan	 
				Select  a.PersonId, a.UserType, a.CoachId, ''1901-01-01'' As TransactionDate, a.CoachedFromDate, CoachedToDate,  
						0 As BoughtWorkoutPlan, 0 As BoughtNutritionPlan, 0 As BoughtNutritionAndWorkoutComboPlan, 0 As BoughtWorkoutLibrary, 
						1 As CoachSuppliedWorkoutPlan, 0 As CoachSuppliedMealPlan, 0 As AppliedPlanCount 
				From ' + @DestinationDbName + '..CoachedAthletes As a Inner Join ' + @SourceDbName + '..[PlanAccess] As p On a.PersonId = p.PersonId And a.CoachId=p.GrantedFromPersonId
									  Inner Join ' + @SourceDbName + '..[Plan] As pn On p.PlanId = pn.PlanId
				Where pn.WorkoutCount>0 And
					  p.GrantedFromPersonId >0 '

Set @Sql02 = 	
		  ' Union All
			-- Determine If CoachSuppliedWorkoutPlan From AppliedPlan	 
				Select c.PersonId, c.UserType, c.CoachId, Convert(Date, a.DateAdded) As TransactionDate, CoachedFromDate, CoachedToDate,     
					   0 As BoughtWorkoutPlan, 0 As BoughtNutritionPlan, 0 As BoughtNutritionAndWorkoutComboPlan, 0 As BoughtWorkoutLibrary, 
					   1 As CoachSuppliedWorkoutPlan, 0 As CoachSuppliedMealPlan, 0 As AppliedPlanCount  
				From ' + @DestinationDbName + '..CoachedAthletes As c Inner Join ' + @SourceDbName + '..AppliedPlan as a On c.PersonId=a.PersonId  And Convert(Date, a.DateAdded) Between c.CoachedFromDate And c.CoachedToDate
													 Inner Join ' + @SourceDbName + '..[Plan] as p On a.PlanId=p.PlanId
				WHERE p.workoutCount>0 And a.PlanId<>30819 And a.AppliedByCoach=1 And YEAR(a.EndDate)>=' + @WhereConditionYear + ' And 
					  a.PersonId Not In 
						(
							Select Distinct a.PersonId
							From ' + @DestinationDbName + '..CoachedAthletes As a Inner Join ' + @SourceDbName + '..[PlanAccess] As p On a.PersonId = p.PersonId And a.CoachId=p.GrantedFromPersonId
																 Inner Join ' + @SourceDbName + '..[Plan] As pn On p.PlanId = pn.PlanId
							Where pn.WorkoutCount>0 And p.GrantedFromPersonId >0 
						 )
				      			
				Union All		      
			-- Determine If CoachSuppliedMealPlan	 
				Select  a.PersonId, a.UserType, a.CoachId, ''1901-01-01'' As TransactionDate, CoachedFromDate, CoachedToDate,   
						0 As BoughtWorkoutPlan, 0 As BoughtNutritionPlan, 0 As BoughtNutritionAndWorkoutComboPlan, 0 As BoughtWorkoutLibrary, 
						0 As CoachSuppliedWorkoutPlan, 1 As CoachSuppliedMealPlan, 0 As AppliedPlanCount 
				From ' + @DestinationDbName + '..CoachedAthletes As a Inner Join ' + @SourceDbName + '..[PlanAccess] As p On a.PersonId = p.PersonId And a.CoachId=p.GrantedFromPersonId
									  Inner Join ' + @SourceDbName + '..[Plan] As pn On p.PlanId = pn.PlanId
				Where pn.MealCount>0 And
					  p.GrantedFromPersonId >0
				      
				Union All
			-- Determine If CoachSuppliedMealPlan From AppliedPlan
				Select c.PersonId, c.UserType, c.CoachId, Convert(Date, a.DateAdded) As TransactionDate, c.CoachedFromDate, CoachedToDate,     
					   0 As BoughtWorkoutPlan, 0 As BoughtNutritionPlan, 0 As BoughtNutritionAndWorkoutComboPlan, 0 As BoughtWorkoutLibrary, 
					   1 As CoachSuppliedWorkoutPlan, 0 As CoachSuppliedMealPlan, 0 As AppliedPlanCount  
				From ' + @DestinationDbName + '..CoachedAthletes As c Inner Join ' + @SourceDbName + '..AppliedPlan as a On c.PersonId=a.PersonId  And Convert(Date, a.DateAdded) Between c.CoachedFromDate And c.CoachedToDate
													 Inner Join ' + @SourceDbName + '..[Plan] as p On a.PlanId=p.PlanId
				WHERE p.MealCount>0 And a.PlanId<>30819 And a.AppliedByCoach=1 And YEAR(a.EndDate)>=' + @WhereConditionYear + ' And 
					  a.PersonId Not In 
						(
							Select Distinct a.PersonId
							From ' + @DestinationDbName + '..CoachedAthletes As a Inner Join ' + @SourceDbName + '..[PlanAccess] As p On a.PersonId = p.PersonId And a.CoachId=p.GrantedFromPersonId
																 Inner Join ' + @SourceDbName + '..[Plan] As pn On p.PlanId = pn.PlanId
							Where pn.WorkoutCount>0 And p.GrantedFromPersonId >0 
						 )
						 		 
				Union All
			-- Count How Many plan where Applied	 
				Select a.PersonId, c.UserType, c.CoachId, Convert(Date, a.DateAdded) As TransactionDate, CoachedFromDate, CoachedToDate,    
					   0 As BoughtWorkoutPlan, 0 As BoughtNutritionPlan, 0 As BoughtNutritionAndWorkoutComboPlan, 0 As BoughtWorkoutLibrary, 
					   0 As CoachSuppliedWorkoutPlan, 0 As CoachSuppliedMealPlan, 1 As AppliedPlanCount 
				From ' + @DestinationDbName + '..CoachedAthletes As c Inner Join  ' + @SourceDbName + '..AppliedPlan as a On c.PersonId=a.PersonId And Convert(Date, a.DateAdded) Between c.CoachedFromDate And c.CoachedToDate
				Where PlanId<>30819 And YEAR(EndDate)>=' + @WhereConditionYear + '
				
		), prepInfo As
		( 
		  Select CoachId, CONVERT(varchar(10),UserType) As AthleteUserType,
		                  SUM(BoughtWorkoutPlan) As BoughtWorkoutPlan, 
						  SUM(BoughtNutritionPlan) As BoughtNutritionPlan, 
						  SUM(BoughtNutritionAndWorkoutComboPlan) As BoughtNutritionAndWorkoutComboPlan,
						  SUM(BoughtWorkoutLibrary) As BoughtWorkoutLibrary,
						  SUM(CoachSuppliedWorkoutPlan) As CoachSuppliedWorkoutPlan, 
						  SUM(CoachSuppliedMealPlan) As CoachSuppliedMealPlan, 
						  SUM(AppliedPlanCount) As AppliedPlanCount 
		  From CoachedAthletesInfo
		  Group By CoachId, UserType
		)
		Select * 
		From prepInfo
		Union All
		Select CoachId, Max(''Combo'') As AthleteUserType,
               SUM(BoughtWorkoutPlan) As BoughtWorkoutPlan, 
			   SUM(BoughtNutritionPlan) As BoughtNutritionPlan, 
			   SUM(BoughtNutritionAndWorkoutComboPlan) As BoughtNutritionAndWorkoutComboPlan,
			   SUM(BoughtWorkoutLibrary) As BoughtWorkoutLibrary,
			   SUM(CoachSuppliedWorkoutPlan) As CoachSuppliedWorkoutPlan, 
			   SUM(CoachSuppliedMealPlan) As CoachSuppliedMealPlan, 
			   SUM(AppliedPlanCount) As AppliedPlanCount 
		  From prepInfo
		  Group By CoachId
		  Having Count(*)>1
		  Order By CoachId
	END'

 -- The Above SQL code exceeded 8000 characters (VARCHAR limitation).  The code below removes all comments and multiple spaces from string.
    WHILE (@CNT<25)
    BEGIN
		 SET @STR = charindex('--',@Sql01)
		 IF  (@STR>0)
		 BEGIN
			 SET @END = charindex(CHAR(13) + CHAR(10), @Sql01, charindex( '--', @Sql01 ) + 1) - charindex('--',@Sql01)
			 SET @ReplaceStr = Substring(@Sql01, @STR, @END)
			 SET @Sql01 =REPLACE(@Sql01, @ReplaceStr, '')
		 END

		 SET @STR = charindex('--',@Sql02)
		 IF  (@STR>0)
		 BEGIN
			 SET @END = charindex(CHAR(13) + CHAR(10), @Sql02, charindex( '--', @Sql02 ) + 1) - charindex('--',@Sql02)
			 SET @ReplaceStr = Substring(@Sql02, @STR, @END)
			 SET @Sql02 =REPLACE(@Sql02, @ReplaceStr, '')
		 END
		 SET @CNT += @CNT
    END
    
    SET @Sql01 =REPLACE(REPLACE(REPLACE(@Sql01, CHAR(13) + CHAR(10), ' '),CHAR(32), ' '), CHAR(9), ' ') -- Replace Carriage Return and spaces to space
    SET @Sql02 =REPLACE(REPLACE(REPLACE(@Sql02, CHAR(13) + CHAR(10), ' '),CHAR(32), ' '), CHAR(9), ' ') -- Replace Carriage Return and spaces to space
  --Replace multiple spaces to single space
    WHILE CHARINDEX('  ', @Sql01) > 0
      SET @Sql01 = REPLACE(@Sql01, '  ', ' ')
    WHILE CHARINDEX('  ', @Sql02) > 0
      SET @Sql02 = REPLACE(@Sql02, '  ', ' ')	
	
    SET @Sql = REPLACE(@Sql01 + @Sql02, ', 0 ', ',0 ')
    EXEC(@Sql)
END

GO
