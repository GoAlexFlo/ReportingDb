SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






CREATE PROCEDURE [dbo].[sp_Cpap2013MealInfo] 
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
	      	With Info As
			( 
				SELECT Distinct p.PersonId
				FROM ' + @SourceDbName + '..Person As p 
				WHERE ' + @WhereCondition + ' 
			), dataPass1 As
			  (
					Select i.PersonId, m.MealId, DisplayCode, IsNull(Title,' + @Empty + ') As Title, IsNull([Description],' + @Empty + ') AS Description, 
					       m.IsPlanned, PlannedMealId, MealDate, Convert(VARCHAR(7),m.MealDate,111) As MealDateYYMM
					       ,TotalCalories, IsNull(MealRecipe,' + @Empty + ') As MealRecipe, IsNull(UserComments,' + @Empty + ') As UserComments 
					From Info AS i Inner Join ' + @SourceDbName + '..Meal As m On i.PersonId=m.PersonId
					Where YEAR(MealDate)=' + @WhereConditionYear + ' And DisplayCode=1 And 
					      (TotalCalories > 0 OR ([Description] Is Not Null And [Description] <>' + @Empty + ') OR 
					      (Title Is Not Null And Title <>' + @Empty + ') Or (MealRecipe Is Not Null And MealRecipe<>' + @Empty + ') Or 
					      (UserComments Is Not Null And UserComments<>' + @Empty + ')) And
					      IsNull(ParentMealId,0) <>7129144  -- 7129144 is a TP Meal Plan Message Also use the IsNull selection condition.  Otherwise ParentMealId set to null will be omitted. 
			  ), dataPass2 As -- Prep by Labeling Meal Data 
				(
				  Select PersonId, Title, [Description], IsPlanned, PlannedMealId, MealDate, TotalCalories,MealRecipe, UserComments,
				         Case 
							  When (IsPlanned = 1 And PlannedMealId Is Null)  Or    -- Planned Meal Not Consumed
							       (IsPlanned = 0 And PlannedMealId Is Not Null)    -- Planned Meal Consumed
							  Then 1 
							  Else 0
						 End As PlannedMealCount,
						 Case 
							  When (IsPlanned = 0 And PlannedMealId Is Not Null)     -- Planned Meal Consumed
							  Then 1 
							  Else 0
						 End As PlannedLoggedMealCount,
						 Case 
							  When (IsPlanned = 1 And PlannedMealId Is Null)         -- Planned Meal Not Consumed
							  Then 1 
							  Else 0
						 End As PlannedUnLoggedMealCount,
						 Case 
							  When (IsPlanned = 0 And PlannedMealId Is Null)         -- No Planning - Add meals after consuming
							  Then 1 
							  Else 0
						 End As UnPlannedLoggedMealCount,
						 
						 Case 
							  When (IsPlanned = 1 And PlannedMealId Is Null)  Or    -- Planned Meal Not Consumed
							       (IsPlanned = 0 And PlannedMealId Is Not Null)    -- Planned Meal Consumed
						      Then MealDateYYMM	 
						      Else Null
						 End As PlannedMealMonth,
						 Case 
							  When (IsPlanned = 0 And PlannedMealId Is Not Null)     -- Planned Meal Consumed
						      Then MealDateYYMM	 
						      Else Null
						 End As PlannedLoggedMealMonth,
						 Case 
							  When (IsPlanned = 1 And PlannedMealId Is Null)         -- Planned Meal Not Consumed
							  Then MealDateYYMM 
							  Else Null
						 End As PlannedUnLoggedMealMonth,
						 Case 
							  When (IsPlanned = 0 And PlannedMealId Is Null)         -- No Planning - Add meals after consuming
						      Then MealDateYYMM	 
						      Else Null
						 End As UnPlannedLoggedMealMonth
				  From dataPass1 As d1
  			    ), dataPass3 As  -- Pull Unique Meals - Drop Dups
				(
  					Select 	PersonId, MealDate, PlannedMealCount, PlannedUnLoggedMealCount, PlannedLoggedMealCount, UnPlannedLoggedMealCount,
  					        PlannedMealMonth, PlannedLoggedMealMonth, PlannedUnLoggedMealMonth, UnPlannedLoggedMealMonth, 
  							MealRecipe, UserComments, Count(*) As dups
  					From dataPass2
  					Group by PersonId, MealDate, PlannedMealCount, PlannedUnLoggedMealCount, PlannedLoggedMealCount, UnPlannedLoggedMealCount,
  					         PlannedMealMonth, PlannedLoggedMealMonth, PlannedUnLoggedMealMonth, UnPlannedLoggedMealMonth,
  					         MealRecipe, UserComments
  				) -- Summarize Data
  			        Select  PersonId,
  			                SUM(PlannedMealCount) As PlannedMealCount, 
  			                SUM(PlannedUnLoggedMealCount) As PlannedUnLoggedMealCount, 
  			                SUM(PlannedLoggedMealCount) As PlannedLoggedMealCount, 
  			                SUM(UnPlannedLoggedMealCount) As UnPlannedLoggedMealCount, 
  			                COUNT(Distinct PlannedMealMonth) As PlannedMealMonths,
  			                COUNT(Distinct PlannedUnLoggedMealMonth) As PlannedUnLoggedMealMonths, 
  			                COUNT(Distinct PlannedLoggedMealMonth) As PlannedLoggedMealMonths,
  			                COUNT(Distinct UnPlannedLoggedMealMonth) As UnPlannedLoggedMealMonths
  			        From  dataPass3
  			        Group By PersonId
		END'
		
		EXEC(@Sql)
END







GO
