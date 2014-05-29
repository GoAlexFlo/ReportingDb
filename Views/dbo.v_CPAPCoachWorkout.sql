SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[v_CPAPCoachWorkout]
AS

With Info As 
(
   Select w.WorkoutId,
	      w.PersonId,
		  w.ParentWorkoutId,
		  w.AppliedPlanId,
		  w.Title, 
		  w.[Description],
		  w.TrainingStressScoreActual,
		  w.PowerAvg,
		  w.WorkoutTypeId,
		  wt.WorkoutDesc, 
		  Convert(VARCHAR(10),w.WorkoutDay,111) As WorkoutDay,
		  Round(IsNull(w.DurationActual, 0),3) As DurationActual, 
		  Round(IsNull(w.DurationPlanned, 0),3) As DurationPlanned,
		  Round(IsNull(w.Distance, 0) * 0.000621371, 2) As Distance,
		  Round(IsNull(w.DistancePlanned, 0) * 0.000621371, 2) As DistancePlanned,
		  Case 
		    When ISNUMERIC(w.Distance)=1 And ISNUMERIC(w.DurationActual)=1 And IsNull(w.Distance, 0)<>0 And IsNull(w.DurationActual, 0)<>0 
		    Then Round(w.Distance * 0.000621371/w.DurationActual, 2) 
		    Else 0 
		  End As Pace,
		  w.VelocityPlanned,
		  w.CaloriesPlanned,
		  w.ElevationGainPlanned,
		  w.TSSPlanned,
		  w.IFPlanned,
		  w.EnergyPlanned
	From   Reporting..CpapCoach As c Inner Join ultrafit_live..Athlete As a On c.CoachId = a.CoachedByPersonId
	                                 Inner Join ultrafit_live..Person As p On a.PersonId = p.PersonId    
	                                 Left Outer Join ultrafit_live..Workout As w On p.PersonId=w.PersonId
					                 Inner Join ultrafit_live..WorkoutType As wt On w.WorkoutTypeId=wt.WorkoutTypeId
	Where p.UserType In (1, 4, 6) And Convert(Varchar(10), workoutday, 111) >= '2013/11/14'
), PrepInfo As 
(
	Select i.WorkoutId,
          (Select Top 1 CoachId From Reporting..CoachedAthletes Where PersonId=i.PersonId And i.WorkoutDay Between CoachedFromDate And CoachedToDate Order by Row Desc) As CoachId,
	       i.personid,
		   i.ParentWorkoutId,
		   i.AppliedPlanId,
		   i.Title,
		   i.[Description],
		   i.TrainingStressScoreActual,
		   i.PowerAvg,
		   i.WorkoutTypeId, 
		   i.WorkoutDesc,
		   i.WorkoutDay, 
		   Round(i.DurationActual,3) As DurationActual, 
		   Round(i.DurationPlanned,3) As DurationPlanned, 
		   i.Distance,
		   i.DistancePlanned, 
		   i.Pace,
		   i.VelocityPlanned,
		   i.CaloriesPlanned,
		   i.ElevationGainPlanned,
		   i.TSSPlanned,
		   i.IFPlanned,
		   i.EnergyPlanned,
		   Case When i.WorkoutTypeId=1 And Pace Between 1 And 5  Then 1
				When i.WorkoutTypeId=2 And Pace Between 1 And 60 Then 1
				When i.WorkoutTypeId=3 And Pace Between 1 And 25 Then 1
				When IsNull(i.DurationActual,0)>0 And IsNull(i.DurationActual,0)<48 Then 1
		        When i.Distance>0 And Distance <=400 Then 1 
				Else 0 End As LegitimateWorkout     
	From Info As i 
	)
		Select min(WorkoutId) As WorkoutId, 
		       CoachId,
		       ParentWorkoutId, 
		       AppliedPlanId, 
		       Title, [Description], 
		       TrainingStressScoreActual, 
		       PowerAvg, 
		       WorkoutTypeId, 
		       WorkoutDesc, 
		       WorkoutDay, 
		       DurationActual, 
		       DurationPlanned, 
		       Distance, 
		       DistancePlanned, 
		       Pace, 
		       VelocityPlanned, 
		       CaloriesPlanned,
		       ElevationGainPlanned, 
		       TSSPlanned, 
		       IFPlanned, 
		       EnergyPlanned,
		       COUNT(*) AS Dups 
		From PrepInfo
		Where LegitimateWorkout=1
		Group By CoachId, ParentWorkoutId, AppliedPlanId, Title, [Description], TrainingStressScoreActual, PowerAvg, 
		         WorkoutTypeId, WorkoutDesc, WorkoutDay, DurationActual, DurationPlanned, Distance, DistancePlanned, Pace,
		         VelocityPlanned, CaloriesPlanned, ElevationGainPlanned, TSSPlanned, IFPlanned, EnergyPlanned
GO
