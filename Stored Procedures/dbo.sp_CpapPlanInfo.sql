SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_CpapPlanInfo] 
	@SourceDbName      Varchar(25),
	@DestinationDbName Varchar(25),
	@WhereCondition Varchar(500),
	@WhereConditionYear Varchar(4)
AS
BEGIN
SET NOCOUNT ON;
DECLARE @Sql Varchar(8000)
DECLARE @Empty Varchar(2)
SET @Empty = ''''''


Set @Sql = 
	   'BEGIN
			With AthleteInfo 
		As
		( 
			SELECT Distinct p.PersonId
			FROM ' + @SourceDbName + '..Person As p Inner Join ' + @SourceDbName + '..Athlete As a On p.PersonId = a.PersonId
			WHERE ' + @WhereCondition + '
		),
			UnionInfo As
		   (
			-- Determine If BoughtWorkoutPlan	 
				Select a.PersonId, 1 As BoughtWorkoutPlan, 0 As BoughtNutritionPlan, 0 As BoughtNutritionAndWorkoutComboPlan, 0 As BoughtWorkoutLibrary, 
				                   0 As CoachSuppliedWorkoutPlan, 0 As CoachSuppliedMealPlan, 0 As AppliedPlanCount 
				From AthleteInfo As a Inner Join  ' + @DestinationDbName + '..PayPalProductRevenue As pp On a.PersonId = pp.PersonId
									  Inner Join ' + @SourceDbName + '..[Plan] As p On p.PlanId = pp.PlanId
				Where pp.[Year]>= ' + @WhereConditionYear + ' And 
					  pp.RowType=''TrainingPlan''                  And 
					 (pp.CreditDesc Not like ''NewSaleCredited:%'' And pp.CreditDesc Not like ''NewSalesCredit:%'') And 
					  pp.PlanId Is Not Null And
					  p.WorkoutCount>0 And (p.MealCount=0 Or p.MealCount is Null)
				      
				Union All		      
			-- Determine If BoughtNutritionPlan	 
				Select a.PersonId, 0 As BoughtWorkoutPlan, 1 As BoughtNutritionPlan, 0 As BoughtNutritionAndWorkoutComboPlan, 0 As BoughtWorkoutLibrary, 
				                   0 As CoachSuppliedWorkoutPlan, 0 As CoachSuppliedMealPlan, 0 As AppliedPlanCount 
				From AthleteInfo As a Inner Join  ' + @DestinationDbName + '..PayPalProductRevenue As pp On a.PersonId = pp.PersonId
									  Inner Join ' + @SourceDbName + '..[Plan] As p On p.PlanId = pp.PlanId
				Where pp.[Year]>= ' + @WhereConditionYear + ' And 
					  pp.RowType=''TrainingPlan''                  And 
					 (pp.CreditDesc Not like ''NewSaleCredited:%'' And pp.CreditDesc Not like ''NewSalesCredit:%'') And 
					  pp.PlanId Is Not Null And
					  p.MealCount>0 And (p.WorkoutCount=0 Or p.WorkoutCount is Null)
				
				Union All		      
			-- Determine If User BoughtWorkoutPlan And BoughtNutritionPlan 
				Select a.PersonId, 0 As BoughtWorkoutPlan, 0 As BoughtNutritionPlan, 1 As BoughtNutritionAndWorkoutComboPlan, 0 As BoughtWorkoutLibrary, 
				                   0 As CoachSuppliedWorkoutPlan, 0 As CoachSuppliedMealPlan, 0 As AppliedPlanCount 
				From AthleteInfo As a Inner Join  ' + @DestinationDbName + '..PayPalProductRevenue As pp On a.PersonId = pp.PersonId
									  Inner Join ' + @SourceDbName + '..[Plan] As p On p.PlanId = pp.PlanId
				Where pp.[Year]>= ' + @WhereConditionYear + ' And 
					  pp.RowType=''TrainingPlan''                  And 
					 (pp.CreditDesc Not like ''NewSaleCredited:%'' And pp.CreditDesc Not like ''NewSalesCredit:%'') And 
					  pp.PlanId Is Not Null And
					  p.MealCount>0 And p.WorkoutCount>0
					  
			Union All		      
			-- Determine If User BoughtWorkoutLibrary 
				Select a.PersonId, 0 As BoughtWorkoutPlan, 0 As BoughtNutritionPlan, 0 As BoughtNutritionAndWorkoutComboPlan, 1 As BoughtWorkoutLibrary,
				                   0 As CoachSuppliedWorkoutPlan, 0 As CoachSuppliedMealPlan, 0 As AppliedPlanCount 
				From AthleteInfo As a Inner Join  ' + @DestinationDbName + '..PayPalProductRevenue As pp On a.PersonId = pp.PersonId
				Where pp.[Year]>= ' + @WhereConditionYear + ' And 
					  pp.RowType=''WorkoutLibrary''           And 
					 (pp.CreditDesc =' + @Empty + ') 
				
				Union All		      
			-- Determine If CoachSuppliedWorkoutPlan	 
				Select  a.PersonId, 0 As BoughtWorkoutPlan, 0 As BoughtNutritionPlan, 0 As BoughtNutritionAndWorkoutComboPlan, 0 As BoughtWorkoutLibrary, 
				                    1 As CoachSuppliedWorkoutPlan, 0 As CoachSuppliedMealPlan, 0 As AppliedPlanCount 
				From AthleteInfo As a Inner Join ' + @SourceDbName + '..[PlanAccess] As p On a.PersonId = p.PersonId 
									  Inner Join ' + @SourceDbName + '..[Plan] As pn On p.PlanId = pn.PlanId
				Where pn.WorkoutCount>0 And
					  p.GrantedFromPersonId >0
				      
				Union All
			-- Determine If CoachSuppliedWorkoutPlan From AppliedPlan	 
				Select PersonId, 0 As BoughtWorkoutPlan, 0 As BoughtNutritionPlan, 0 As BoughtNutritionAndWorkoutComboPlan, 0 As BoughtWorkoutLibrary, 
				                 1 As CoachSuppliedWorkoutPlan, 0 As CoachSuppliedMealPlan, 0 As AppliedPlanCount  
				From ' + @SourceDbName + '..AppliedPlan as a Inner Join ' + @SourceDbName + '..[Plan] as p On a.PlanId=p.PlanId
				WHERE p.workoutCount>0 And a.PlanId<>30819 And a.AppliedByCoach=1 And YEAR(a.EndDate)>=' + @WhereConditionYear + ' And 
					  a.PersonId Not In 
						(
							Select a.PersonId
							From AthleteInfo As a Inner Join ' + @SourceDbName + '..[PlanAccess] As p On a.PersonId = p.PersonId 
												  Inner Join ' + @SourceDbName + '..[Plan] As pn On p.PlanId = pn.PlanId
							Where pn.WorkoutCount>0 And
								  p.GrantedFromPersonId >0
						 )
				
				Union All		      
			-- Determine If CoachSuppliedMealPlan	 
				Select  a.PersonId, 0 As BoughtWorkoutPlan, 0 As BoughtNutritionPlan, 0 As BoughtNutritionAndWorkoutComboPlan, 0 As BoughtWorkoutLibrary, 
				                    0 As CoachSuppliedWorkoutPlan, 1 As CoachSuppliedMealPlan, 0 As AppliedPlanCount 
				From AthleteInfo As a Inner Join ' + @SourceDbName + '..[PlanAccess] As p On a.PersonId = p.PersonId 
									  Inner Join ' + @SourceDbName + '..[Plan] As pn On p.PlanId = pn.PlanId
				Where pn.MealCount>0 And
					  p.GrantedFromPersonId >0
				      
				Union All
			-- Determine If CoachSuppliedMealPlan From AppliedPlan	 
				Select a.PersonId, 0 As BoughtWorkoutPlan, 0 As BoughtNutritionPlan, 0 As BoughtNutritionAndWorkoutComboPlan, 0 As BoughtWorkoutLibrary, 
				                 0 As CoachSuppliedWorkoutPlan, 1 As CoachSuppliedMealPlan, 0 As AppliedPlanCount 
				From ' + @SourceDbName + '..AppliedPlan as a Inner Join ' + @SourceDbName + '..[Plan] as p On a.PlanId=p.PlanId
				WHERE p.MealCount>0 And a.PlanId<>30819 And a.AppliedByCoach=1 And YEAR(a.EndDate)>=' + @WhereConditionYear + ' And 
					  a.PersonId Not In 
						(
							Select a.PersonId
							From AthleteInfo As a Inner Join ' + @SourceDbName + '..[PlanAccess] As p On a.PersonId = p.PersonId 
												  Inner Join ' + @SourceDbName + '..[Plan] As pn On p.PlanId = pn.PlanId
							Where pn.WorkoutCount>0 And
								  p.GrantedFromPersonId >0
						 )
						 
				Union All
			-- Count How Many plan where Applied	 
				Select a.PersonId, 0 As BoughtWorkoutPlan, 0 As BoughtNutritionPlan, 0 As BoughtNutritionAndWorkoutComboPlan, 0 As BoughtWorkoutLibrary, 
				                   0 As CoachSuppliedWorkoutPlan, 0 As CoachSuppliedMealPlan, 1 As AppliedPlanCount 
				From ' + @SourceDbName + '..AppliedPlan as a
				Where PlanId<>30819 And YEAR(EndDate)>=' + @WhereConditionYear + '
		)
		Select PersonId, SUM(BoughtWorkoutPlan) As BoughtWorkoutPlan, 
		                 SUM(BoughtNutritionPlan) As BoughtNutritionPlan, 
		                 SUM(BoughtNutritionAndWorkoutComboPlan) As BoughtNutritionAndWorkoutComboPlan,
		                 SUM(BoughtWorkoutLibrary) As BoughtWorkoutLibrary,
		                 SUM(CoachSuppliedWorkoutPlan) As CoachSuppliedWorkoutPlan, 
		                 SUM(CoachSuppliedMealPlan) As CoachSuppliedMealPlan, 
		                 SUM(AppliedPlanCount) As AppliedPlanCount 
		From UnionInfo
		Group By PersonId
	END'
	EXEC(@Sql)
END

GO
