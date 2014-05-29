SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


















CREATE VIEW [dbo].[v_CPAP2010Athlete]
AS
SELECT    a.CpapAthleteId, a.PersonId, a.AccountCreationDate, a.LastLogon, a.NumberOfVisits, 
          a.UserType, a.AffiliateId, a.MonthsOnSystem, a.MonthsOnSystemSince2010, a.MonthsActiveOnSystem, a.MonthsActiveOnSystemSince2010, 
          a.PercentOfMonthsActiveOnSystem, a.PercentOfMonthsActiveOnSystemSince2010, a.TrialPremiumSubCouponUsed, 
          a.AthleteSubscribesToDailyWoEmail, a.CoachedByPersonId, a.AllowMarketingEmails, a.ThresholdsNotifyAthlete, a.ThresholdsAutoApply,
          a.BoughtWorkoutPlan, a.BoughtNutritionPlan, a.BoughtNutritionAndWorkoutComboPlan, a.BoughtWorkoutLibrary, a.CoachSuppliedWorkoutPlan, a.CoachSuppliedMealPlan, AppliedPlanCount, 
          a.AtpYearsWithGoals, a.AtpYearsWithObjectives, a.AtpTotalRaceCount, a.AtpAvgAnnualHours, a.WorkoutsInLibraryCount, 
          a.MealsCreatedByUserCount, a.IsHeartRateZoneDefault, a.IsPowerZoneDefault, a.IsSpeedZoneDefault, 
          a.FitnessSummary, a.DailyCalories, a.Macronutrients, a.GettingStarted, a.DailyMetrics, 
          a.DistanceByWeek_Day, a.DurationByWeek_Day, a.PMC, a.PeakPower, a.TimeinHRZones, 
          a.FitnessHistory, a.TSSbyWeekDay, a.PowerProfile, a.TimeInHRZonesByWeek, 
          a.GroceryList, a.PeakHearRate, a.TimeInPowerZones, a.TimeInPowerZonesByWeek, 
          a.KJPerWeek, a.RaceReports, a.WeatherPod, a.LongestWorkoutDuration, 
          a.LongestWorkoutDistance, a.PeakPace, a.PeakSpeed, a.PeakCadence, a.MicroNutrients, 
          a.RoutesHistory, a.TimeInSpeedZonesByWeek, a.TimeInSpeedZones, a.PeakPaceByDistance, 
          a.HealthVaultSync, a.HasCustomizedDashboard, a.PlannedMealCount, a.PlannedUnLoggedMealCount, a.PlannedLoggedMealCount, a.UnPlannedLoggedMealCount,  
	      a.PlannedMealMonths, a.PlannedUnLoggedMealMonths, a.PlannedLoggedMealMonths, a.UnPlannedLoggedMealMonths,
          a.MonthsAsUserType1, a.MonthsSinceUserType1, a.MonthsAsPaidUserType4, a.ARR, a.LtsSubscription, 
          a.LtsTrainingPlan, a.LtsSoftware, a.LtsLibrary, a.LtsTotal, w.UserPlannedNotCompletedWorkoutCount, w.TrainingPlanWorkoutCount, 
          w.UserUsedPlannedFieldsWorkoutCount, w.CompletedWorkouts, w.WorkoutsWithTitle, 
          w.WorkoutsWithDescriptionNotTrainingPlan, w.WorkoutsWithTSS, w.SwimWorkouts, 
          w.BikeWorkouts, w.RunWorkouts, w.MTBWorkouts, w.Races, 
          w.TotalWorkoutCount, w.WorkoutsWithAthleteComments, w.WorkoutsWithCoachComments, 
          a.AthleteType, a.MostPopularDevice, a.TotalUploads, a.NumberOfDevices, 
          a.AthleteTypeDesc, a.Age, a.Sex, w.WorkoutsWithPower, w.AvgHoursPerWeek,
          a.EquipmentBikeCount, a.EquipmentShoeCount, a.RouteCount, a.WeightInKilogramsMetric, a.SleepQualityMetric, 
          a.SleepHoursMetric, a.FatigueMetric, a.SorenessMetric, a.StressMetric, a.PulseMetric, a.SleepElevationInMetersMetric, a.OverallFeelingMetric, 
          a.PercentFatMetric, LapseCount, RenewSaleCount, RecurSaleCount, a.DaysSinceLastPremSub, a.FavoriteFoodCount, a.DaysToPremSub, a.FirstPremTerm, 
          a.MarketingPreferenceSharedKey, a.GaMonthsActiveOnSystem, a.LastGaVisit,  a.DaysSinceLastGaVisit, a.UsesMobile,
          a.GaNativeAppiOSVisits, a.GaNativeAppAndroidVisits, a.GaWebAppDesktopVisits, a.GaWebAppiOSVisits, 
          a.GaWebAppAndroidVisits, a.GaOtherVisits, a.DateAdded
FROM      dbo.Cpap2010Athlete As a LEFT OUTER JOIN dbo.Cpap_2010WorkoutInfo As w ON w.PersonId = a.PersonId





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
', 'SCHEMA', N'dbo', 'VIEW', N'v_CPAP2010Athlete', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=1
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'dbo', 'VIEW', N'v_CPAP2010Athlete', NULL, NULL
GO
