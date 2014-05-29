SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE VIEW [dbo].[v_CPAPAthlete_Normalized]
AS
SELECT     PersonId, LtsTotal, CASE WHEN LTSTotal > 357 THEN 1 ELSE 0 END AS IsTopDecile, UserType, TrialPremiumSubCouponUsed, 
                      CASE WHEN CoachedByPersonId > 0 THEN 1 ELSE 0 END AS IsCoached, AthleteSubscribesToDailyWoEmail, CoachSuppliedWorkoutPlan, CoachSuppliedMealPlan, 
                      CASE WHEN IsHeartRateZoneDefault = 'NotDefault' THEN 1 ELSE 0 END AS IsHeartRateZoneDefaultCleaned, 
                      CASE WHEN IsPowerZoneDefault = 'NotDefault' THEN 1 ELSE 0 END AS IsPowerZoneDefaultCleaned, 
                      CASE WHEN IsSpeedZoneDefault = 'NotDefault' THEN 1 ELSE 0 END AS IsSpeedZoneDefaultCleaned, FitnessSummary, DailyCalories, Macronutrients, GettingStarted, 
                      DailyMetrics, DistanceByWeek_Day, DurationByWeek_Day, PMC, PeakPower, TimeinHRZones, FitnessHistory, TSSbyWeekDay, PowerProfile, 
                      TimeInHRZonesByWeek, GroceryList, PeakHearRate, TimeInPowerZones, TimeInPowerZonesByWeek, KJPerWeek, RaceReports, WeatherPod, 
                      LongestWorkoutDuration, LongestWorkoutDistance, PeakPace, PeakSpeed, PeakCadence, MicroNutrients, RoutesHistory, TimeInSpeedZonesByWeek, 
                      TimeInSpeedZones, PeakPaceByDistance, HealthVaultSync, HasCustomizedDashboard, MonthsActiveOnSystem, 
                      CASE WHEN MonthsOnSystem > 0 THEN MonthsAsUserType1 / MonthsOnSystem ELSE MonthsAsUserType1 END AS MonthsAsUserType1Normalized, 
                      CASE WHEN MonthsOnSystem > 0 THEN NumberOfVisits / MonthsOnSystem ELSE NumberOfVisits END AS NumberOfVisitsNormalized, 
                      CASE WHEN MonthsOnSystem > 0 THEN ATPYearsWithGoals / MonthsOnSystem ELSE ATPYearsWithGoals END AS ATPYearsWithGoalsNormalized, 
                      CASE WHEN MonthsOnSystem > 0 THEN ATPYearsWithObjectives / MonthsOnSystem ELSE ATPYearsWithObjectives END AS ATPYearsWithObjectivesNormalized, 
                      CASE WHEN MonthsOnSystem > 0 THEN ATPTotalRaceCount / MonthsOnSystem ELSE ATPTotalRaceCount END AS ATPTotalRaceCountNormalized, 
                      CASE WHEN MonthsOnSystem > 0 THEN WorkoutLibraryCount / MonthsOnSystem ELSE WorkoutLibraryCount END AS WorkoutLibraryCountNormalized, 
                      CASE WHEN MonthsOnSystem > 0 THEN MealLibraryCount / MonthsOnSystem ELSE MealLibraryCount END AS MealLibraryCountNormalized, 
                      CASE WHEN MonthsOnSystem > 0 THEN PlannedMealCount / MonthsOnSystem ELSE PlannedMealCount END AS PlannedMealCountNormalized, 
                      CASE WHEN MonthsOnSystem > 0 THEN PlannedLoggedMealCount / MonthsOnSystem ELSE PlannedLoggedMealCount END AS PlannedLoggedMealCountNormalized, 
                      CASE WHEN MonthsOnSystem > 0 THEN UnPlannedLoggedMealCount / MonthsOnSystem ELSE UnPlannedLoggedMealCount END AS UnPlannedLoggedMealCountNormalized,
                      CASE WHEN MonthsOnSystem > 0 THEN UserPlannedNotCompletedWorkoutCount / MonthsOnSystem ELSE UserPlannedNotCompletedWorkoutCount END AS UserPlannedNotCompletedWorkoutCountNormalized,
                      CASE WHEN MonthsOnSystem > 0 THEN TrainingPlanWorkoutCount / MonthsOnSystem ELSE TrainingPlanWorkoutCount END AS TrainingPlanWorkoutCountNormalized,
                      CASE WHEN MonthsOnSystem > 0 THEN UserUsedPlannedFieldsWorkoutCount / MonthsOnSystem ELSE UserUsedPlannedFieldsWorkoutCount END AS UserUsedPlannedFieldsWorkoutCountNormalized,
                      CASE WHEN MonthsOnSystem > 0 THEN CompletedWorkouts / MonthsOnSystem ELSE CompletedWorkouts END AS CompletedWorkoutsNormalized, 
                      CASE WHEN MonthsOnSystem > 0 THEN WorkoutsWithTitle / MonthsOnSystem ELSE WorkoutsWithTitle END AS WorkoutsWithTitleNormalized, 
                      CASE WHEN MonthsOnSystem > 0 THEN WorkoutsWithDescriptionNotTrainingPlan / MonthsOnSystem ELSE WorkoutsWithDescriptionNotTrainingPlan END AS WorkoutsWithDescriptionNotTrainingPlanNormalized,
                      CASE WHEN MonthsOnSystem > 0 THEN WorkoutsWithTSS / MonthsOnSystem ELSE WorkoutsWithTSS END AS WorkoutsWithTSSNormalized, 
                      CASE WHEN MonthsOnSystem > 0 THEN SwimWorkouts / MonthsOnSystem ELSE SwimWorkouts END AS SwimWorkoutsNormalized, 
                      CASE WHEN MonthsOnSystem > 0 THEN BikeWorkouts / MonthsOnSystem ELSE BikeWorkouts END AS BikeWorkoutsNormalized, 
                      CASE WHEN MonthsOnSystem > 0 THEN RunWorkouts / MonthsOnSystem ELSE RunWorkouts END AS RunWorkoutsNormalized, 
                      CASE WHEN MonthsOnSystem > 0 THEN MTBWorkouts / MonthsOnSystem ELSE MTBWorkouts END AS MTBWorkoutsNormalized, 
                      CASE WHEN MonthsOnSystem > 0 THEN Races / MonthsOnSystem ELSE Races END AS RacesNormalized, 
                      CASE WHEN MonthsOnSystem > 0 THEN TotalWorkoutCount / MonthsOnSystem ELSE TotalWorkoutCount END AS TotalWorkoutCountNormalized, 
                      CASE WHEN MonthsOnSystem > 0 THEN WorkoutsWithAthleteComments / MonthsOnSystem ELSE WorkoutsWithAthleteComments END AS WorkoutsWithAthleteCommentsNormalized,
                      CASE WHEN MonthsOnSystem > 0 THEN WorkoutsWithCoachComments / MonthsOnSystem ELSE WorkoutsWithCoachComments END AS WorkoutsWithCoachCommentsNormalized,
                      CASE WHEN MonthsOnSystem > 0 THEN TotalUploads / MonthsOnSystem ELSE TotalUploads END AS TotalUploadsNormalized, 
                      CASE WHEN MonthsOnSystem > 0 THEN WorkoutsWithPower / MonthsOnSystem ELSE WorkoutsWithPower END AS WorkoutsWithPowerNormalized, 
                      AvgHoursPerWeek, CASE WHEN (AtpAvgAnnualHours > 0 OR
                      ATPYearsWithGoals > 0 OR
                      ATPYearsWithObjectives > 0 OR
                      ATPTotalRaceCount > 0) THEN 1 ELSE 0 END AS UsedATP, AthleteType, MonthsOnSystem, AffiliateId, CASE WHEN affiliateid IN (277, 596, 818, 883) 
                      THEN 1 ELSE 0 END AS IsTPAffiliate, ARR, LtsSubscription, LtsTrainingPlan, LtsSoftware, BoughtWorkoutPlan, BoughtMealPlan, AtpAvgAnnualHours, 
                      MostPopularDevice, NumberOfDevices, AthleteTypeDesc, Age, Sex, DATEDIFF(Day, LastLogon, GETDATE()) AS DaysSinceLastLogon,
                      CASE When AffiliateId = 723 Then 1 Else 0 End As IsRunnerWorld,
                      CASE When AffiliateId = 450 Then 1 Else 0 End As IsTimex
FROM         dbo.v_CPAPAthlete





GO
EXEC sp_addextendedproperty N'MS_DiagramPane1', N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[43] 4[5] 2[49] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "v_CPAPAthlete"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 264
               Right = 325
            End
            DisplayFlags = 280
            TopColumn = 19
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', 'SCHEMA', N'dbo', 'VIEW', N'v_CPAPAthlete_Normalized', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=1
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'dbo', 'VIEW', N'v_CPAPAthlete_Normalized', NULL, NULL
GO
