SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_PrtCpapMealInfo] 
	@SourceDbName      Varchar(25),
	@DestinationDbName Varchar(25),
	@WhereCondition Varchar(500),
	@WhereConditionYear Varchar(4)
	
AS
BEGIN
SET NOCOUNT ON;
DECLARE @Sql Varchar(2000)

Set @Sql =
	   'BEGIN
			With Info As
			( 
				SELECT Distinct p.PersonId
				FROM ' + @SourceDbName + '..Person As p Inner Join ' + @SourceDbName + '..Athlete As a On p.PersonId = a.PersonId
				WHERE ' + @WhereCondition + '  
			), PrepInfo As
				(
					Select i.PersonId, 
						Case 
							  When IsPlanned = 1 
							  Then 1 
							  Else 0
							End As PlannedMealCount,
						Case 
							  When IsPlanned = 1 And EXISTS(Select MealId From ' + @SourceDbName + '..Meal Where PlannedMealId=m.MealId)
							  Then 1 
							  Else 0
							End As PlannedLoggedMealCount,
						Case 
							  When IsPlanned = 0 And PlannedMealId is null
							  Then 1 
							  Else 0
							End As UnPlannedLoggedMealCount 
					From Info AS i Inner Join ' + @SourceDbName + '..Meal As m On i.PersonId=m.PersonId
					Where YEAR(MealDate)>=' + @WhereConditionYear + ' And (TotalCalories > 0 OR Description is not null OR Title is not null or MealRecipe is not null or UserComments is not null) And
					IsNull(ParentMealId,0) <>7129144  -- 7129144 is a TP Meal Plan Message Also use the IsNull selection condition.  Otherwise ParentMealId set to null will be omitted.  
				)
				Select PersonId, Sum(PlannedMealCount)As PlannedMealCount, Sum(PlannedLoggedMealCount) As PlannedLoggedMealCount, Sum(UnPlannedLoggedMealCount) As UnPlannedLoggedMealCount
				From PrepInfo
				Group by PersonId
		END'
		
		EXEC(@Sql)
END





GO
