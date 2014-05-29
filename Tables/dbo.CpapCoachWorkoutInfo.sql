CREATE TABLE [dbo].[CpapCoachWorkoutInfo]
(
[CoachId] [int] NULL,
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
[WorkoutsWithPower] [int] NULL,
[TotalWorkoutCount] [int] NULL
) ON [PRIMARY]
GO
