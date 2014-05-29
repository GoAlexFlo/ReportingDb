SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE PROCEDURE [dbo].[sp_CpapCoachWorkout] 
	@SourceDbName      Varchar(25),
	@DestinationDbName Varchar(25)
AS
BEGIN
SET NOCount ON;
DECLARE @Sql Varchar(5000)

SET @Sql = '
BEGIN
		TRUNCATE TABLE ' + @DestinationDbName + '..[CpapCoachWorkoutInfo]
				   
		Insert Into ' + @DestinationDbName + '..[CpapCoachWorkoutInfo]
				   ([CoachId]
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
				   ,[TotalWorkoutCount])
		Select      [CoachId]
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
		From (
		Select 
			w.CoachId,
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
		From ' + @DestinationDbName + '..v_CpapCoachWorkout w Left Outer Join ' + @SourceDbName + '..AppliedPlan ap On ap.AppliedPlanId = w.AppliedPlanId 
		Where (PlanId <> 30819 Or PlanId Is Null)
		Group By w.CoachId) As WorkoutStats
END'

	
	EXEC(@Sql)
END


GO
