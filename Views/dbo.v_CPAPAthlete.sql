SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE VIEW [dbo].[v_CPAPAthlete]
AS
SELECT     dbo.CpapAthlete.CpapAthleteId, dbo.CpapAthlete.PersonId, dbo.CpapAthlete.AccountCreationDate, dbo.CpapAthlete.LastLogon, dbo.CpapAthlete.NumberOfVisits, 
                      dbo.CpapAthlete.UserType, dbo.CpapAthlete.AffiliateId, dbo.CpapAthlete.MonthsOnSystem, dbo.CpapAthlete.MonthsActiveOnSystem, dbo.CpapAthlete.TrialPremiumSubCouponUsed, 
                      dbo.CpapAthlete.AthleteSubscribesToDailyWoEmail, dbo.CpapAthlete.CoachedByPersonId, dbo.CpapAthlete.BoughtWorkoutPlan, dbo.CpapAthlete.BoughtMealPlan, 
                      dbo.CpapAthlete.CoachSuppliedWorkoutPlan, dbo.CpapAthlete.CoachSuppliedMealPlan, dbo.CpapAthlete.AtpYearsWithGoals, 
                      dbo.CpapAthlete.AtpYearsWithObjectives, dbo.CpapAthlete.AtpTotalRaceCount, dbo.CpapAthlete.AtpAvgAnnualHours, dbo.CpapAthlete.WorkoutLibraryCount, 
                      dbo.CpapAthlete.MealLibraryCount, dbo.CpapAthlete.IsHeartRateZoneDefault, dbo.CpapAthlete.IsPowerZoneDefault, dbo.CpapAthlete.IsSpeedZoneDefault, 
                      dbo.CpapAthlete.FitnessSummary, dbo.CpapAthlete.DailyCalories, dbo.CpapAthlete.Macronutrients, dbo.CpapAthlete.GettingStarted, dbo.CpapAthlete.DailyMetrics, 
                      dbo.CpapAthlete.DistanceByWeek_Day, dbo.CpapAthlete.DurationByWeek_Day, dbo.CpapAthlete.PMC, dbo.CpapAthlete.PeakPower, dbo.CpapAthlete.TimeinHRZones, 
                      dbo.CpapAthlete.FitnessHistory, dbo.CpapAthlete.TSSbyWeekDay, dbo.CpapAthlete.PowerProfile, dbo.CpapAthlete.TimeInHRZonesByWeek, 
                      dbo.CpapAthlete.GroceryList, dbo.CpapAthlete.PeakHearRate, dbo.CpapAthlete.TimeInPowerZones, dbo.CpapAthlete.TimeInPowerZonesByWeek, 
                      dbo.CpapAthlete.KJPerWeek, dbo.CpapAthlete.RaceReports, dbo.CpapAthlete.WeatherPod, dbo.CpapAthlete.LongestWorkoutDuration, 
                      dbo.CpapAthlete.LongestWorkoutDistance, dbo.CpapAthlete.PeakPace, dbo.CpapAthlete.PeakSpeed, dbo.CpapAthlete.PeakCadence, dbo.CpapAthlete.MicroNutrients, 
                      dbo.CpapAthlete.RoutesHistory, dbo.CpapAthlete.TimeInSpeedZonesByWeek, dbo.CpapAthlete.TimeInSpeedZones, dbo.CpapAthlete.PeakPaceByDistance, 
                      dbo.CpapAthlete.HealthVaultSync, dbo.CpapAthlete.HasCustomizedDashboard, dbo.CpapAthlete.PlannedMealCount, dbo.CpapAthlete.PlannedLoggedMealCount, 
                      dbo.CpapAthlete.UnPlannedLoggedMealCount, dbo.CpapAthlete.MonthsAsAPremAthleteCount As MonthsAsUserType1, dbo.CpapAthlete.ARR, dbo.CpapAthlete.LtsSubscription, 
                      dbo.CpapAthlete.LtsTrainingPlan, dbo.CpapAthlete.LtsSoftware, dbo.CpapAthlete.LtsTotal, dbo.CpapAthlete.DateAdded, 
                      dbo.Cpap_WorkoutInfo.UserPlannedNotCompletedWorkoutCount, dbo.Cpap_WorkoutInfo.TrainingPlanWorkoutCount, 
                      dbo.Cpap_WorkoutInfo.UserUsedPlannedFieldsWorkoutCount, dbo.Cpap_WorkoutInfo.CompletedWorkouts, dbo.Cpap_WorkoutInfo.WorkoutsWithTitle, 
                      dbo.Cpap_WorkoutInfo.WorkoutsWithDescriptionNotTrainingPlan, dbo.Cpap_WorkoutInfo.WorkoutsWithTSS, dbo.Cpap_WorkoutInfo.SwimWorkouts, 
                      dbo.Cpap_WorkoutInfo.BikeWorkouts, dbo.Cpap_WorkoutInfo.RunWorkouts, dbo.Cpap_WorkoutInfo.MTBWorkouts, dbo.Cpap_WorkoutInfo.Races, 
                      dbo.Cpap_WorkoutInfo.TotalWorkoutCount, dbo.Cpap_WorkoutInfo.WorkoutsWithAthleteComments, dbo.Cpap_WorkoutInfo.WorkoutsWithCoachComments, 
                      dbo.CpapAthlete.AthleteType, dbo.CpapAthlete.MostPopularDevice, dbo.CpapAthlete.TotalUploads, dbo.CpapAthlete.NumberOfDevices, 
                      dbo.CpapAthlete.AthleteTypeDesc, dbo.CpapAthlete.Age, dbo.CpapAthlete.Sex, dbo.Cpap_WorkoutInfo.WorkoutsWithPower, dbo.Cpap_WorkoutInfo.AvgHoursPerWeek
FROM         dbo.CpapAthlete LEFT OUTER JOIN
                      dbo.Cpap_WorkoutInfo ON dbo.Cpap_WorkoutInfo.PersonId = dbo.CpapAthlete.PersonId




GO
EXEC sp_addextendedproperty N'MS_DiagramPane1', N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
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
         Begin Table = "CpapAthlete"
            Begin Extent = 
               Top = 44
               Left = 51
               Bottom = 290
               Right = 301
            End
            DisplayFlags = 280
            TopColumn = 62
         End
         Begin Table = "Cpap_WorkoutInfo"
            Begin Extent = 
               Top = 6
               Left = 665
               Bottom = 125
               Right = 952
            End
            DisplayFlags = 280
            TopColumn = 13
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
', 'SCHEMA', N'dbo', 'VIEW', N'v_CPAPAthlete', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=1
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'dbo', 'VIEW', N'v_CPAPAthlete', NULL, NULL
GO
