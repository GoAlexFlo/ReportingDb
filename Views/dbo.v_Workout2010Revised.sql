SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO







CREATE VIEW [dbo].[v_Workout2010Revised]
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
		  t.WorkoutDesc, 
		  Convert(VARCHAR(10),w.WorkoutDay,111) As WorkoutDay,
		  Round(IsNull(w.DurationActual, 0),3) As DurationActual, 
		  Round(IsNull(w.DurationPlanned, 0),3) As DurationPlanned,
		  Round(IsNull(w.Distance, 0) * 0.000621371, 2) As Distance,
		  Round(IsNull(w.DistancePlanned, 0) * 0.000621371, 2) As DistancePlanned,
		  Case 
		    When ISNUMERIC(w.Distance)=1 And ISNUMERIC(w.DurationActual)=1 And IsNull(w.Distance, 0)<>0 And IsNull(w.DurationActual, 0)<>0 
		    Then Round(w.Distance * 0.000621371/w.DurationActual, 2) 
		    Else 0 End As Pace,
		  w.VelocityPlanned,
		  w.CaloriesPlanned,
		  w.ElevationGainPlanned,
		  w.TSSPlanned,
		  w.IFPlanned,
		  w.EnergyPlanned
		From   Reporting..Cpap2010Athlete As c Inner Join ultrafit..Person As p On c.PersonId=p.PersonId
		                                       Inner Join ultrafit..Workout As w On c.PersonId=w.PersonId
											   LEFT Outer Join ultrafit..WorkoutType As t On w.WorkoutTypeId=t.WorkoutTypeId
	Where p.UserType In (1, 4, 6) And Convert(Varchar(10), workoutday, 111) >= Convert(Varchar(10), p.AccountCreationDate, 111) 
), PrepInfo As 
(
	Select i.WorkoutId, 
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
		Select Min(WorkoutId) As WorkoutId, PersonId, ParentWorkoutId, AppliedPlanId, Title, [Description], TrainingStressScoreActual, PowerAvg, 
		       WorkoutTypeId, WorkoutDesc, WorkoutDay, DurationActual, DurationPlanned, Distance, DistancePlanned, Pace, VelocityPlanned, CaloriesPlanned,
		       ElevationGainPlanned, TSSPlanned, IFPlanned, EnergyPlanned, COUNT(*) AS Dups 
		From PrepInfo
		Where LegitimateWorkout=1
		Group By PersonId, ParentWorkoutId, AppliedPlanId, Title, [Description], TrainingStressScoreActual, PowerAvg, 
		         WorkoutTypeId, WorkoutDesc, WorkoutDay, DurationActual, DurationPlanned, Distance, DistancePlanned, Pace,
		         VelocityPlanned, CaloriesPlanned, ElevationGainPlanned, TSSPlanned, IFPlanned, EnergyPlanned







GO
