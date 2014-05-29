SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO







CREATE VIEW [dbo].[v_CPAPCoach_NormalizedPerAthlete]
AS
SELECT c.CoachId,
		  CoachingGroupId,
		  AccountCreationDate,
		  LastLogon,
		  NumberOfVisits,
		  UserType,
		  TotalTriathletes,
		  TotalRunners,
		  TotalCyclists,
		  TotalOtherSports,
		  TotalUserType1,
		  TotalUserType4,
		  TotalUserType6,
		  CASE WHEN TotalNumberOfLogins IS NOT NULL THEN TotalNumberOfLogins/TotalCoachedAthletes ELSE 0 END AS TotalNumberOfLogins,
		  CASE WHEN NumberOfDaysSinceLastLogon IS NOT NULL THEN NumberOfDaysSinceLastLogon/TotalCoachedAthletes ELSE 0 END AS NumberOfDaysSinceLastLogon,
		  TotalCoachedAthletes,
	      CASE WHEN BoughtWorkoutPlan IS NOT NULL THEN BoughtWorkoutPlan/TotalCoachedAthletes ELSE 0 END AS BoughtWorkoutPlan,
		  CASE WHEN BoughtMealPlan IS NOT NULL THEN BoughtMealPlan/TotalCoachedAthletes ELSE 0 END AS BoughtMealPlan,
		  CASE WHEN BoughtNutritionAndWorkoutComboPlan IS NOT NULL THEN BoughtNutritionAndWorkoutComboPlan/TotalCoachedAthletes ELSE 0 END AS BoughtNutritionAndWorkoutComboPlan,
		  CASE WHEN BoughtWorkoutLibrary IS NOT NULL THEN BoughtWorkoutLibrary/TotalCoachedAthletes ELSE 0 END AS BoughtWorkoutLibrary,
		  CASE WHEN CoachSuppliedWorkoutPlan IS NOT NULL THEN CoachSuppliedWorkoutPlan/TotalCoachedAthletes ELSE 0 END AS CoachSuppliedWorkoutPlan,
		  CASE WHEN CoachSuppliedMealPlan IS NOT NULL THEN CoachSuppliedMealPlan/TotalCoachedAthletes ELSE 0 END AS CoachSuppliedMealPlan,
		  CASE WHEN AppliedPlanCount IS NOT NULL THEN AppliedPlanCount/TotalCoachedAthletes ELSE 0 END AS AppliedPlanCount,
		  CASE WHEN TotalAthletesPlannedMealCount IS NOT NULL THEN TotalAthletesPlannedMealCount/TotalCoachedAthletes ELSE 0 END AS TotalAthletesPlannedMealCount,
		  CASE WHEN TotalAthletesPlannedUnLoggedMealCount IS NOT NULL THEN TotalAthletesPlannedUnLoggedMealCount/TotalCoachedAthletes ELSE 0 END AS TotalAthletesPlannedUnLoggedMealCount,
		  CASE WHEN TotalAthletesPlannedLoggedMealCount IS NOT NULL THEN TotalAthletesPlannedLoggedMealCount/TotalCoachedAthletes ELSE 0 END AS TotalAthletesPlannedLoggedMealCount,
		  CASE WHEN TotalAthletesUnPlannedLoggedMealCount IS NOT NULL THEN TotalAthletesUnPlannedLoggedMealCount/TotalCoachedAthletes ELSE 0 END AS TotalAthletesUnPlannedLoggedMealCount,
		  CASE WHEN TotalAthletesPlannedMealMonths IS NOT NULL THEN TotalAthletesPlannedMealMonths/TotalCoachedAthletes ELSE 0 END AS TotalAthletesPlannedMealMonths,
		  CASE WHEN TotalAthletesPlannedUnLoggedMealMonths IS NOT NULL THEN TotalAthletesPlannedUnLoggedMealMonths/TotalCoachedAthletes ELSE 0 END AS TotalAthletesPlannedUnLoggedMealMonths,
		  CASE WHEN TotalAthletesPlannedLoggedMealMonths IS NOT NULL THEN TotalAthletesPlannedLoggedMealMonths/TotalCoachedAthletes ELSE 0 END AS TotalAthletesPlannedLoggedMealMonths,
		  CASE WHEN TotalAthletesUnPlannedLoggedMealMonths IS NOT NULL THEN TotalAthletesUnPlannedLoggedMealMonths/TotalCoachedAthletes ELSE 0 END AS TotalAthletesUnPlannedLoggedMealMonths,
		  CASE WHEN TotalAthletesRouteCount IS NOT NULL THEN TotalAthletesRouteCount/TotalCoachedAthletes ELSE 0 END AS TotalAthletesRouteCount,
		  CASE WHEN TotalAthleteWeightInKilogramsMetric IS NOT NULL THEN TotalAthleteWeightInKilogramsMetric/TotalCoachedAthletes ELSE 0 END AS TotalAthleteWeightInKilogramsMetric,
		  CASE WHEN TotalAthleteWithSleepQualityMetric IS NOT NULL THEN TotalAthleteWithSleepQualityMetric/TotalCoachedAthletes ELSE 0 END AS TotalAthleteWithSleepQualityMetric,
		  CASE WHEN TotalAthleteWithSleepHoursMetric IS NOT NULL THEN TotalAthleteWithSleepHoursMetric/TotalCoachedAthletes ELSE 0 END AS TotalAthleteWithSleepHoursMetric,
		  CASE WHEN TotalAthleteWithFatigueMetric IS NOT NULL THEN TotalAthleteWithFatigueMetric/TotalCoachedAthletes ELSE 0 END AS TotalAthleteWithFatigueMetric,
		  CASE WHEN TotalAthleteWithSorenessMetric IS NOT NULL THEN TotalAthleteWithSorenessMetric/TotalCoachedAthletes ELSE 0 END AS TotalAthleteWithSorenessMetric,
		  CASE WHEN TotalAthleteWithStressMetric IS NOT NULL THEN TotalAthleteWithStressMetric/TotalCoachedAthletes ELSE 0 END AS TotalAthleteWithStressMetric,
		  CASE WHEN TotalAthleteWithPulseMetric IS NOT NULL THEN TotalAthleteWithPulseMetric/TotalCoachedAthletes ELSE 0 END AS TotalAthleteWithPulseMetric,
		  CASE WHEN TotalAthleteWithSleepElevationInMetersMetric IS NOT NULL THEN TotalAthleteWithSleepElevationInMetersMetric/TotalCoachedAthletes ELSE 0 END AS TotalAthleteWithSleepElevationInMetersMetric,
		  CASE WHEN TotalAthleteWithOverallFeelingMetric IS NOT NULL THEN TotalAthleteWithOverallFeelingMetric/TotalCoachedAthletes ELSE 0 END AS TotalAthleteWithOverallFeelingMetric,
		  CASE WHEN TotalAthleteWithPercentFatMetric IS NOT NULL THEN TotalAthleteWithPercentFatMetric/TotalCoachedAthletes ELSE 0 END AS TotalAthleteWithPercentFatMetric,
		  CASE WHEN TotalAthleteThatHaveLapse IS NOT NULL THEN TotalAthleteThatHaveLapse/TotalCoachedAthletes ELSE 0 END AS TotalAthleteThatHaveLapse,
		  CASE WHEN TotalAthleteThatHaveNewSale IS NOT NULL THEN TotalAthleteThatHaveNewSale/TotalCoachedAthletes ELSE 0 END AS TotalAthleteThatHaveNewSale,
		  CASE WHEN TotalAthleteThatHaveRenewSale IS NOT NULL THEN TotalAthleteThatHaveRenewSale/TotalCoachedAthletes ELSE 0 END AS TotalAthleteThatHaveRenewSale,
		  CASE WHEN TotalAthleteThatHaveRecurSale IS NOT NULL THEN TotalAthleteThatHaveRecurSale/TotalCoachedAthletes ELSE 0 END AS TotalAthleteThatHaveRecurSale,
		  CASE WHEN TotalTermOfNewSale IS NOT NULL THEN TotalTermOfNewSale/TotalCoachedAthletes ELSE 0 END AS TotalTermOfNewSale,
		  CoachedAthleteSubscribesToDailyWoEmail,
		  CoachedAthleteAllowMarketingEmails,
		  CoachedAthleteThresholdsNotify,
		  CoachedAthleteThresholdsAutoApply,
		  CASE WHEN CoachedAthletesWithHrZoneThreshold IS NOT NULL THEN CoachedAthletesWithHrZoneThreshold/TotalCoachedAthletes ELSE 0 END AS CoachedAthletesWithHrZoneThreshold,
		  CASE WHEN CoachedAthletesWithPwZoneThreshold IS NOT NULL THEN CoachedAthletesWithPwZoneThreshold/TotalCoachedAthletes ELSE 0 END AS CoachedAthletesWithPwZoneThreshold,
		  CASE WHEN CoachedAthletesWithSpZoneThreshold IS NOT NULL THEN CoachedAthletesWithSpZoneThreshold/TotalCoachedAthletes ELSE 0 END AS CoachedAthletesWithSpZoneThreshold,
		  CASE WHEN CoachedAthleteFitnessSummary IS NOT NULL THEN CoachedAthleteFitnessSummary/TotalCoachedAthletes ELSE 0 END AS CoachedAthleteFitnessSummary,
		  CASE WHEN CoachedAthleteDailyCalories IS NOT NULL THEN CoachedAthleteDailyCalories/TotalCoachedAthletes ELSE 0 END AS CoachedAthleteDailyCalories,
		  CASE WHEN CoachedAthleteMacronutrients IS NOT NULL THEN CoachedAthleteMacronutrients/TotalCoachedAthletes ELSE 0 END AS CoachedAthleteMacronutrients,
		  CASE WHEN CoachedAthleteGettingStarted IS NOT NULL THEN CoachedAthleteGettingStarted/TotalCoachedAthletes ELSE 0 END AS CoachedAthleteGettingStarted,
		  CASE WHEN CoachedAthleteDailyMetrics IS NOT NULL THEN CoachedAthleteDailyMetrics/TotalCoachedAthletes ELSE 0 END AS CoachedAthleteDailyMetrics,
		  CASE WHEN CoachedAthleteDistanceByWeek_Day IS NOT NULL THEN CoachedAthleteDistanceByWeek_Day/TotalCoachedAthletes ELSE 0 END AS CoachedAthleteDistanceByWeek_Day,
		  CASE WHEN CoachedAthleteDurationByWeek_Day IS NOT NULL THEN CoachedAthleteDurationByWeek_Day/TotalCoachedAthletes ELSE 0 END AS CoachedAthleteDurationByWeek_Day,
		  CASE WHEN CoachedAthletePMC IS NOT NULL THEN CoachedAthletePMC/TotalCoachedAthletes ELSE 0 END AS CoachedAthletePMC,
		  CASE WHEN CoachedAthletePeakPower IS NOT NULL THEN CoachedAthletePeakPower/TotalCoachedAthletes ELSE 0 END AS CoachedAthletePeakPower,
		  CASE WHEN CoachedAthleteTimeinHRZones IS NOT NULL THEN CoachedAthleteTimeinHRZones/TotalCoachedAthletes ELSE 0 END AS CoachedAthleteTimeinHRZones,
		  CASE WHEN CoachedAthleteFitnessHistory IS NOT NULL THEN CoachedAthleteFitnessHistory/TotalCoachedAthletes ELSE 0 END AS CoachedAthleteFitnessHistory,
		  CASE WHEN CoachedAthleteTSSbyWeekDay IS NOT NULL THEN CoachedAthleteTSSbyWeekDay/TotalCoachedAthletes ELSE 0 END AS CoachedAthleteTSSbyWeekDay,
		  CASE WHEN CoachedAthletePowerProfile IS NOT NULL THEN CoachedAthletePowerProfile/TotalCoachedAthletes ELSE 0 END AS CoachedAthletePowerProfile,
		  CASE WHEN CoachedAthleteTimeInHRZonesByWeek IS NOT NULL THEN CoachedAthleteTimeInHRZonesByWeek/TotalCoachedAthletes ELSE 0 END AS CoachedAthleteTimeInHRZonesByWeek,
		  CASE WHEN CoachedAthleteGroceryList IS NOT NULL THEN CoachedAthleteGroceryList/TotalCoachedAthletes ELSE 0 END AS CoachedAthleteGroceryList,
		  CASE WHEN CoachedAthletePeakHearRate IS NOT NULL THEN CoachedAthletePeakHearRate/TotalCoachedAthletes ELSE 0 END AS CoachedAthletePeakHearRate,
		  CASE WHEN CoachedAthleteTimeInPowerZones IS NOT NULL THEN CoachedAthleteTimeInPowerZones/TotalCoachedAthletes ELSE 0 END AS CoachedAthleteTimeInPowerZones,
		  CASE WHEN CoachedAthleteTimeInPowerZonesByWeek IS NOT NULL THEN CoachedAthleteTimeInPowerZonesByWeek/TotalCoachedAthletes ELSE 0 END AS CoachedAthleteTimeInPowerZonesByWeek,
		  CASE WHEN CoachedAthleteKJPerWeek IS NOT NULL THEN CoachedAthleteKJPerWeek/TotalCoachedAthletes ELSE 0 END AS CoachedAthleteKJPerWeek,
		  CASE WHEN CoachedAthleteRaceReports IS NOT NULL THEN CoachedAthleteRaceReports/TotalCoachedAthletes ELSE 0 END AS CoachedAthleteRaceReports,
		  CASE WHEN CoachedAthleteWeatherPod IS NOT NULL THEN CoachedAthleteWeatherPod/TotalCoachedAthletes ELSE 0 END AS CoachedAthleteWeatherPod,
		  CASE WHEN CoachedAthleteLongestWorkoutDuration IS NOT NULL THEN CoachedAthleteLongestWorkoutDuration/TotalCoachedAthletes ELSE 0 END AS CoachedAthleteLongestWorkoutDuration,
		  CASE WHEN CoachedAthleteLongestWorkoutDistance IS NOT NULL THEN CoachedAthleteLongestWorkoutDistance/TotalCoachedAthletes ELSE 0 END AS CoachedAthleteLongestWorkoutDistance,
		  CASE WHEN CoachedAthletePeakPace IS NOT NULL THEN CoachedAthletePeakPace/TotalCoachedAthletes ELSE 0 END AS CoachedAthletePeakPace,
		  CASE WHEN CoachedAthletePeakSpeed IS NOT NULL THEN CoachedAthletePeakSpeed/TotalCoachedAthletes ELSE 0 END AS CoachedAthletePeakSpeed,
		  CASE WHEN CoachedAthletePeakCadence IS NOT NULL THEN CoachedAthletePeakCadence/TotalCoachedAthletes ELSE 0 END AS CoachedAthletePeakCadence,
		  CASE WHEN CoachedAthleteMicroNutrients IS NOT NULL THEN CoachedAthleteMicroNutrients/TotalCoachedAthletes ELSE 0 END AS CoachedAthleteMicroNutrients,
		  CASE WHEN CoachedAthleteRoutesHistory IS NOT NULL THEN CoachedAthleteRoutesHistory/TotalCoachedAthletes ELSE 0 END AS CoachedAthleteRoutesHistory,
		  CASE WHEN CoachedAthleteTimeInSpeedZonesByWeek IS NOT NULL THEN CoachedAthleteTimeInSpeedZonesByWeek/TotalCoachedAthletes ELSE 0 END AS CoachedAthleteTimeInSpeedZonesByWeek,
		  CASE WHEN CoachedAthleteTimeInSpeedZones IS NOT NULL THEN CoachedAthleteTimeInSpeedZones/TotalCoachedAthletes ELSE 0 END AS CoachedAthleteTimeInSpeedZones,
		  CASE WHEN CoachedAthletePeakPaceByDistance IS NOT NULL THEN CoachedAthletePeakPaceByDistance/TotalCoachedAthletes ELSE 0 END AS CoachedAthletePeakPaceByDistance,
		  CASE WHEN CoachedAthleteHealthVaultSync IS NOT NULL THEN CoachedAthleteHealthVaultSync/TotalCoachedAthletes ELSE 0 END AS CoachedAthleteHealthVaultSync,
		  CASE WHEN CoachedAthleteHasCustomizedDashboard IS NOT NULL THEN CoachedAthleteHasCustomizedDashboard/TotalCoachedAthletes ELSE 0 END AS CoachedAthleteHasCustomizedDashboard,
		  CoachedAthleteLtsSubscription,
		  CoachedAthleteLtsTrainingPlan,
		  CoachedAthleteLtsSoftware,
		  CoachedAthleteLtsLibrary,
		  CoachedAthleteLtsTotal,
		  CASE WHEN UserPlannedNotCompletedWorkoutCount IS NOT NULL THEN UserPlannedNotCompletedWorkoutCount/TotalCoachedAthletes ELSE 0 END AS UserPlannedNotCompletedWorkoutCount,
		  CASE WHEN UserUsedPlannedFieldsWorkoutCount IS NOT NULL THEN UserUsedPlannedFieldsWorkoutCount/TotalCoachedAthletes ELSE 0 END AS UserUsedPlannedFieldsWorkoutCount,
		  CASE WHEN TrainingPlanWorkoutCount IS NOT NULL THEN TrainingPlanWorkoutCount/TotalCoachedAthletes ELSE 0 END AS TrainingPlanWorkoutCount,
		  CASE WHEN CompletedWorkouts IS NOT NULL THEN CompletedWorkouts/TotalCoachedAthletes ELSE 0 END AS CompletedWorkouts,
		  CASE WHEN WorkoutsWithTitle IS NOT NULL THEN WorkoutsWithTitle/TotalCoachedAthletes ELSE 0 END AS WorkoutsWithTitle,
		  CASE WHEN WorkoutsWithDescriptionNotTrainingPlan IS NOT NULL THEN WorkoutsWithDescriptionNotTrainingPlan/TotalCoachedAthletes ELSE 0 END AS WorkoutsWithDescriptionNotTrainingPlan,
		  CASE WHEN WorkoutsWithTSS IS NOT NULL THEN WorkoutsWithTSS/TotalCoachedAthletes ELSE 0 END AS WorkoutsWithTSS,
		  CASE WHEN SwimWorkouts IS NOT NULL THEN SwimWorkouts/TotalCoachedAthletes ELSE 0 END AS SwimWorkouts,
		  CASE WHEN BikeWorkouts IS NOT NULL THEN BikeWorkouts/TotalCoachedAthletes ELSE 0 END AS BikeWorkouts,
		  CASE WHEN RunWorkouts IS NOT NULL THEN RunWorkouts/TotalCoachedAthletes ELSE 0 END AS RunWorkouts,
		  CASE WHEN MTBWorkouts IS NOT NULL THEN MTBWorkouts/TotalCoachedAthletes ELSE 0 END AS MTBWorkouts,
		  CASE WHEN Races IS NOT NULL THEN Races/TotalCoachedAthletes ELSE 0 END AS Races,
		  CASE WHEN WorkoutsWithPower IS NOT NULL THEN WorkoutsWithPower/TotalCoachedAthletes ELSE 0 END AS WorkoutsWithPower,
		  CASE WHEN TotalWorkoutCount IS NOT NULL THEN TotalWorkoutCount/TotalCoachedAthletes ELSE 0 END AS TotalWorkoutCount,
		  DateAdded
  FROM [Reporting]..[CpapCoach] As c Inner Join [Reporting].[dbo].CpapCoachWorkoutInfo As w On c.CoachId=w.CoachId







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
', 'SCHEMA', N'dbo', 'VIEW', N'v_CPAPCoach_NormalizedPerAthlete', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=1
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'dbo', 'VIEW', N'v_CPAPCoach_NormalizedPerAthlete', NULL, NULL
GO
