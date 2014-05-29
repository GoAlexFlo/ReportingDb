CREATE TABLE [dbo].[CpapAthleteOnBoardingWorkoutTest]
(
[PersonId] [int] NULL,
[UserPlannedNotCompletedWorkoutCount] [int] NULL,
[UserUsedPlannedFieldsWorkoutCount] [int] NULL,
[TrainingPlanWorkoutCount] [int] NULL,
[CompletedWorkouts] [int] NULL,
[WorkoutsWithTitle] [int] NULL,
[WorkoutsWithDescriptionNotTrainingPlan] [int] NULL,
[WorkoutsWithTSS] [int] NULL,
[SwimWorkouts] [int] NULL,
[BikeWorkouts] [int] NULL,
[RunWorkouts] [int] NULL,
[MTBWorkouts] [int] NULL,
[Races] [int] NULL,
[TotalWorkoutCount] [int] NULL,
[WorkoutsWithAthleteComments] [int] NULL,
[WorkoutsWithCoachComments] [int] NULL,
[WorkoutsWithPower] [int] NULL,
[AvgHoursPerWeek] [float] NULL,
[DateAdded] [datetime] NULL
) ON [PRIMARY]
GO
