SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[sp_CpapAthleteOnBoardingWorkout] 
	@SourceDbName      Varchar(25),
	@DestinationDbName Varchar(25),
	@WhereCondition Varchar(500),
	@WhereConditionYear Varchar(4)
AS
BEGIN
SET NOCount ON;
DECLARE @Sql Varchar(5000)

SET @Sql = '
BEGIN
		Insert Into ' + @DestinationDbName + '..[CpapAthleteOnBoardingWorkout]
				   ([PersonId]
				   ,[UserPlannedNotCompletedWorkoutCount]
				   ,[UserUsedPlannedFieldsWorkoutCount]
				   ,[TrainingPlanWorkoutCount]
				   ,[CompletedWorkouts]
				   ,[WorkoutsWithTitle]
				   ,[WorkoutsWithDescriptionNotTrainingPlan]
				   ,[WorkoutsWithTSS]
				   ,[SwimWorkouts]
				   ,[BikeWorkouts]
				   ,[RunWorkouts]
				   ,[MTBWorkouts]
				   ,[Races]
				   ,[WorkoutsWithPower]
				   ,[TotalWorkoutCount]
				   ,[WorkoutsWithAthleteComments]
				   ,[WorkoutsWithCoachComments]
				   ,[AvgHoursPerWeek]
				   ,[DateAdded])
		Select WorkoutStats.[PersonId]
				   ,[UserPlannedNotCompletedWorkoutCount]
				   ,[UserUsedPlannedFieldsWorkoutCount]
				   ,[TrainingPlanWorkoutCount]
				   ,[CompletedWorkouts]
				   ,[WorkoutsWithTitle]
				   ,[WorkoutsWithDescriptionNotTrainingPlan]
				   ,[WorkoutsWithTSS]
				   ,[SwimWorkouts]
				   ,[BikeWorkouts]
				   ,[RunWorkouts]
				   ,[MTBWorkouts]
				   ,[Races]
				   ,[WorkoutsWithPower]
				   ,[TotalWorkoutCount]
				   ,[WorkoutsWithAthleteComments]
				   ,[WorkoutsWithCoachComments]
				   ,[AvgHoursPerWeek]
				   ,GETDATE() 
		From (
		Select 
			w.PersonId,
			Sum (Case When (durationactual Is Null Or durationactual <= 0) And (distance Is Null Or distance <= 0) Then 1 Else 0 End) As UserPlannedNotCompletedWorkoutCount,
			Sum (Case When (DurationPlanned + DistancePlanned + VelocityPlanned +  CaloriesPlanned + ElevationGainPlanned +  TSSPlanned +  IFPlanned +  EnergyPlanned) > 0 And ParentWorkoutId Is Null Then 1 Else 0 End) As UserUsedPlannedFieldsWorkoutCount,
			Sum (Case When ParentWorkoutId Is Not null Then 1 Else 0 End) As TrainingPlanWorkoutCount,
			Sum (Case When durationactual > 0 Or distance > 0 Then 1 Else 0 End) As CompletedWorkouts,
			Sum (Case When Title Is Not null Then 1 Else 0 End) As WorkoutsWithTitle,
			Sum (Case When ParentWorkoutId Is Null And [Description] Is Not null 
			                                             Then 1 Else 0 End) As WorkoutsWithDescriptionNotTrainingPlan,
			Sum (Case When TrainingStressScoreActual > 0 Then 1 Else 0 End) As WorkoutsWithTSS,
			Sum (Case When  WorkoutTypeId = 1            Then 1 Else 0 End) As SwimWorkouts,
			Sum (Case When  WorkoutTypeId = 2            Then 1 Else 0 End) As BikeWorkouts,
			Sum (Case When  WorkoutTypeId = 3            Then 1 Else 0 End) As RunWorkouts,
			Sum (Case When  WorkoutTypeId = 8            Then 1 Else 0 End) As MTBWorkouts,
			Sum (Case When  WorkoutTypeId = 6            Then 1 Else 0 End) As Races,
			Sum (Case When  PowerAvg > 0                 Then 1 Else 0 End) As WorkoutsWithPower,
			Count(*) As TotalWorkoutCount
		From ' + @DestinationDbName + '..v_CpapAthleteOnBoardingWorkout w
		Inner Join ' + @SourceDbName + '..Person p On p.PersonId = w.PersonId
		Left Outer Join ' + @SourceDbName + '..AppliedPlan ap On ap.AppliedPlanId = w.AppliedPlanId 
		Where ' + @WhereCondition + ' And YEAR(w.WorkoutDay)>=' + @WhereConditionYear + ' And (PlanId <> 30819 Or PlanId Is Null)
		Group By w.PersonId) As WorkoutStats
		
		Left Outer Join (Select Sum(Case When AthleteCommentCount > 0 Then 1 Else 0 End) As WorkoutsWithAthleteComments,
							    Sum(Case When CoachCommentCount > 0 Then 1 Else 0 End) As WorkoutsWithCoachComments, PersonId
						 From
						(
						 Select Sum(Case When ws.CommenterPersonId = w.PersonId Then 1 Else 0 End) As AthleteCommentCount,
						        Sum(Case When ws.CommenterPersonId <> w.PersonId Then 1 Else 0 End) As CoachCommentCount, w.WorkoutId, w.PersonId
						 From ' + @DestinationDbName + '..v_CpapAthleteOnBoardingWorkout w
								 Left Join ' + @SourceDbName + '..WorkoutCommentStream As ws On ws.WorkoutId = w.WorkoutId
								 Inner Join ' + @SourceDbName + '..Person As p On p.PersonId = w.PersonId
								 Left Outer Join ' + @SourceDbName + '..AppliedPlan As ap On ap.AppliedPlanId = w.AppliedPlanId
							Where ' + @WhereCondition + ' And YEAR(w.WorkoutDay)>=' + @WhereConditionYear + ' And (PlanId <> 30819 Or PlanId Is Null)
							Group By w.WorkoutId, w.PersonId
						) As comment
		Group By PersonId) As WorkoutCommentStats On WorkoutCommentStats.PersonId = WorkoutStats.PersonId
		
		Left Outer Join (Select AVG (HoursPerWeek) As AvgHoursPerWeek, PersonId
							From (
									Select  Sum(w.DurationActual) As HoursPerWeek, DATEPART (WEEK, w.workoutday) As Week, DATEPART (YEAR, w.WorkoutDay) As Year, w.PersonId 
									From ' + @DestinationDbName + '..v_CpapAthleteOnBoardingWorkout w
									Where YEAR(w.WorkoutDay)>=' + @WhereConditionYear + ' And w.DurationActual > 0
									Group By w.PersonId, DATEPART (WEEK, w.workoutday), DATEPART (YEAR, w.WorkoutDay)
								 ) As SumHrs Group By PersonId
			 ) As AvgHrPerWeekStats On AvgHrPerWeekStats.PersonId = WorkoutStats.PersonId
END'

	
	EXEC(@Sql)
END

GO
