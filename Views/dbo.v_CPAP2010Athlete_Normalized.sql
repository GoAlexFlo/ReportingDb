SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO







CREATE VIEW [dbo].[v_CPAP2010Athlete_Normalized]
AS
SELECT                CpapAthleteId, PersonId, AccountCreationDate, LastLogon, LTSTotal, CASE WHEN LTSTotal > 357 THEN 1 ELSE 0 END AS IsTopDecile, 
					  UserType, TrialPremiumSubCouponUsed, 
                      CASE WHEN CoachedByPersonId > 0 THEN 1 ELSE 0 END AS IsCoached, AthleteSubscribesToDailyWoEmail,  
                      CASE WHEN IsHeartRateZoneDefault = 'NotDefault' THEN 1 ELSE 0 END AS IsHeartRateZoneDefaultCleaned, 
                      CASE WHEN IsPowerZoneDefault = 'NotDefault' THEN 1 ELSE 0 END AS IsPowerZoneDefaultCleaned, 
                      CASE WHEN IsSpeedZoneDefault = 'NotDefault' THEN 1 ELSE 0 END AS IsSpeedZoneDefaultCleaned, FitnessSummary, DailyCalories, Macronutrients, GettingStarted, 
                      DailyMetrics, DistanceByWeek_Day, DurationByWeek_Day, PMC, PeakPower, TimeinHRZones, FitnessHistory, TSSbyWeekDay, PowerProfile, 
                      TimeInHRZonesByWeek, GroceryList, PeakHearRate, TimeInPowerZones, TimeInPowerZonesByWeek, KJPerWeek, RaceReports, WeatherPod, 
                      LongestWorkoutDuration, LongestWorkoutDistance, PeakPace, PeakSpeed, PeakCadence, MicroNutrients, RoutesHistory, TimeInSpeedZonesByWeek, 
                      TimeInSpeedZones, PeakPaceByDistance, HasCustomizedDashboard, MonthsOnSystem, MonthsOnSystemSince2010, MonthsActiveOnSystemSince2010, MonthsActiveOnSystem, 
                      PercentOfMonthsActiveOnSystem, PercentOfMonthsActiveOnSystemSince2010, WorkoutsInLibraryCount,  MealsCreatedByUserCount, MonthsSinceUserType1,
                      CASE WHEN MonthsActiveOnSystemSince2010 > 0 THEN Round(Cast(NumberOfVisits As Float) / MonthsActiveOnSystemSince2010, 2) ELSE NumberOfVisits END AS NumberOfVisitsNormalized, 
                      CASE WHEN MonthsActiveOnSystemSince2010 > 0 THEN Round(Cast(ATPYearsWithGoals As Float) / Round(Cast(MonthsActiveOnSystemSince2010 As Float)/12, 1), 1) ELSE ATPYearsWithGoals END AS ATPYearsWithGoalsNormalized, 
                      CASE WHEN MonthsActiveOnSystemSince2010 > 0 THEN Round(Cast(ATPYearsWithObjectives As Float) / Round(Cast(MonthsActiveOnSystemSince2010 As Float)/12, 1), 1) ELSE ATPYearsWithObjectives END AS ATPYearsWithObjectivesNormalized, 
                      CASE WHEN MonthsActiveOnSystemSince2010 > 0 THEN Round(Cast(ATPTotalRaceCount As Float) / Round(Cast(MonthsActiveOnSystemSince2010 As Float)/12, 1), 1) ELSE ATPTotalRaceCount END AS ATPTotalRaceCountNormalized, 
                      CASE WHEN PlannedMealMonths > 0 THEN Round(Cast(PlannedMealCount As Float) / PlannedMealMonths, 2) ELSE PlannedMealCount END AS PlannedMealCountNormalized, 
                      CASE WHEN PlannedUnLoggedMealMonths > 0 THEN Round(Cast(PlannedUnLoggedMealCount As Float) / PlannedMealMonths, 2) ELSE PlannedUnLoggedMealCount END AS PlannedUnLoggedMealCountNormalized, 
                      CASE WHEN PlannedLoggedMealMonths > 0 THEN Round(Cast(PlannedLoggedMealCount As Float) / PlannedMealMonths, 2) ELSE PlannedLoggedMealCount END AS PlannedLoggedMealCountNormalized, 
                      CASE WHEN UnPlannedLoggedMealMonths > 0 THEN Round(Cast(UnPlannedLoggedMealCount As Float) / UnPlannedLoggedMealMonths, 2) ELSE UnPlannedLoggedMealCount END AS UnPlannedLoggedMealCountNormalized,
                      CASE WHEN MonthsActiveOnSystemSince2010 > 0 THEN Round(Cast(UserPlannedNotCompletedWorkoutCount As Float) / MonthsActiveOnSystemSince2010, 2) ELSE UserPlannedNotCompletedWorkoutCount END AS UserPlannedNotCompletedWorkoutCountNormalized,
                      CASE WHEN MonthsActiveOnSystemSince2010 > 0 THEN Round(Cast(TrainingPlanWorkoutCount As Float) / MonthsActiveOnSystemSince2010, 2) ELSE TrainingPlanWorkoutCount END AS TrainingPlanWorkoutCountNormalized,
                      CASE WHEN MonthsActiveOnSystemSince2010 > 0 THEN Round(Cast(UserUsedPlannedFieldsWorkoutCount As Float) / MonthsActiveOnSystemSince2010, 2) ELSE UserUsedPlannedFieldsWorkoutCount END AS UserUsedPlannedFieldsWorkoutCountNormalized,
                      CASE WHEN MonthsActiveOnSystemSince2010 > 0 THEN Round(Cast(CompletedWorkouts As Float) / MonthsActiveOnSystemSince2010, 2) ELSE CompletedWorkouts END AS CompletedWorkoutsNormalized, 
                      CASE WHEN MonthsActiveOnSystemSince2010 > 0 THEN Round(Cast(WorkoutsWithTitle As Float) / MonthsActiveOnSystemSince2010, 2) ELSE WorkoutsWithTitle END AS WorkoutsWithTitleNormalized, 
                      CASE WHEN MonthsActiveOnSystemSince2010 > 0 THEN Round(Cast(WorkoutsWithDescriptionNotTrainingPlan As Float) / MonthsActiveOnSystemSince2010, 2) ELSE WorkoutsWithDescriptionNotTrainingPlan END AS WorkoutsWithDescriptionNotTrainingPlanNormalized,
                      CASE WHEN MonthsActiveOnSystemSince2010 > 0 THEN Round(Cast(WorkoutsWithTSS As Float) / MonthsActiveOnSystemSince2010, 2) ELSE WorkoutsWithTSS END AS WorkoutsWithTSSNormalized, 
                      CASE WHEN MonthsActiveOnSystemSince2010 > 0 THEN Round(Cast(SwimWorkouts As Float) / MonthsActiveOnSystemSince2010, 2) ELSE SwimWorkouts END AS SwimWorkoutsNormalized, 
                      CASE WHEN MonthsActiveOnSystemSince2010 > 0 THEN Round(Cast(BikeWorkouts As Float) / MonthsActiveOnSystemSince2010, 2) ELSE BikeWorkouts END AS BikeWorkoutsNormalized, 
                      CASE WHEN MonthsActiveOnSystemSince2010 > 0 THEN Round(Cast(RunWorkouts As Float) / MonthsActiveOnSystemSince2010, 2) ELSE RunWorkouts END AS RunWorkoutsNormalized, 
                      CASE WHEN MonthsActiveOnSystemSince2010 > 0 THEN Round(Cast(MTBWorkouts As Float) / MonthsActiveOnSystemSince2010, 2) ELSE MTBWorkouts END AS MTBWorkoutsNormalized, 
                      CASE WHEN MonthsActiveOnSystemSince2010 > 0 THEN Round(Cast(Races As Float) / MonthsActiveOnSystemSince2010, 2) ELSE Races END AS RacesNormalized, 
                      CASE WHEN MonthsActiveOnSystemSince2010 > 0 THEN Round(Cast(TotalWorkoutCount As Float) / MonthsActiveOnSystemSince2010, 2) ELSE TotalWorkoutCount END AS TotalWorkoutCountNormalized, 
                      CASE WHEN MonthsActiveOnSystemSince2010 > 0 THEN Round(Cast(WorkoutsWithAthleteComments As Float) / MonthsActiveOnSystemSince2010, 2) ELSE WorkoutsWithAthleteComments END AS WorkoutsWithAthleteCommentsNormalized,
                      CASE WHEN MonthsActiveOnSystemSince2010 > 0 THEN Round(Cast(WorkoutsWithCoachComments As Float) / MonthsActiveOnSystemSince2010, 2) ELSE WorkoutsWithCoachComments END AS WorkoutsWithCoachCommentsNormalized,
                      CASE WHEN MonthsActiveOnSystemSince2010 > 0 THEN Round(Cast(TotalUploads As Float) / MonthsActiveOnSystemSince2010, 2) ELSE TotalUploads END AS TotalUploadsNormalized, 
                      CASE WHEN MonthsActiveOnSystemSince2010 > 0 THEN Round(Cast(WorkoutsWithPower As Float) / MonthsActiveOnSystemSince2010, 2) ELSE WorkoutsWithPower END AS WorkoutsWithPowerNormalized, 
                      AvgHoursPerWeek, 
                      CASE WHEN (AtpAvgAnnualHours > 0 OR ATPYearsWithGoals > 0 OR ATPYearsWithObjectives > 0 OR ATPTotalRaceCount > 0) THEN 1 ELSE 0 END AS UsedATP, 
                      AthleteType, AffiliateId, 
                      CASE WHEN affiliateid IN (88, 277, 596, 783, 818, 883) THEN 1 ELSE 0 END AS IsTPAffiliate, ARR, LtsSubscription, LtsTrainingPlan, LtsSoftware, LtsLibrary, BoughtWorkoutPlan, BoughtNutritionPlan, BoughtNutritionAndWorkoutComboPlan, 
                      BoughtWorkoutLibrary, CoachSuppliedWorkoutPlan,CoachSuppliedMealPlan,AppliedPlanCount,AtpAvgAnnualHours, MostPopularDevice, NumberOfDevices, AthleteTypeDesc, Age, Sex, 
                      DATEDIFF(Day, LastLogon, GETDATE()) AS DaysSinceLastLogon, EquipmentBikeCount,EquipmentShoeCount, 
                      CASE WHEN MonthsActiveOnSystemSince2010 > 0 THEN Round(Cast(MonthsAsUserType1 As Float) / MonthsActiveOnSystemSince2010, 2) ELSE MonthsAsUserType1 END AS MonthsAsUserType1Normalized, 
                      CASE WHEN MonthsActiveOnSystemSince2010 > 0 THEN Round(Cast(MonthsAsPaidUserType4 As Float) / MonthsActiveOnSystemSince2010, 2) ELSE MonthsAsPaidUserType4 END AS MonthsAsPaidUserType4Normalized, 
                      CASE WHEN MonthsActiveOnSystemSince2010 > 0 THEN Round(Cast(RouteCount As Float) / MonthsActiveOnSystemSince2010, 2) ELSE RouteCount END AS RouteCountNormalized, 
                      CASE WHEN MonthsActiveOnSystemSince2010 > 0 THEN Round(Cast(WeightInKilogramsMetric As Float) / MonthsActiveOnSystemSince2010, 2) ELSE WeightInKilogramsMetric END AS WeightInKilogramsMetricNormalized, 
                      CASE WHEN MonthsActiveOnSystemSince2010 > 0 THEN Round(Cast(SleepQualityMetric As Float) / MonthsActiveOnSystemSince2010, 2) ELSE SleepQualityMetric END AS SleepQualityMetricNormalized, 
                      CASE WHEN MonthsActiveOnSystemSince2010 > 0 THEN Round(Cast(SleepHoursMetric As Float) / MonthsActiveOnSystemSince2010, 2) ELSE SleepHoursMetric END AS SleepHoursMetricNormalized, 
                      CASE WHEN MonthsActiveOnSystemSince2010 > 0 THEN Round(Cast(FatigueMetric As Float) / MonthsActiveOnSystemSince2010, 2) ELSE FatigueMetric END AS FatigueMetricNormalized, 
                      CASE WHEN MonthsActiveOnSystemSince2010 > 0 THEN Round(Cast(SorenessMetric As Float) / MonthsActiveOnSystemSince2010, 2) ELSE SorenessMetric END AS SorenessMetricNormalized, 
                      CASE WHEN MonthsActiveOnSystemSince2010 > 0 THEN Round(Cast(StressMetric As Float) / MonthsActiveOnSystemSince2010, 2) ELSE StressMetric END AS StressMetricNormalized, 
                      CASE WHEN MonthsActiveOnSystemSince2010 > 0 THEN Round(Cast(PulseMetric As Float) / MonthsActiveOnSystemSince2010, 2) ELSE PulseMetric END AS PulseMetricNormalized, 
                      CASE WHEN MonthsActiveOnSystemSince2010 > 0 THEN Round(Cast(SleepElevationInMetersMetric As Float) / MonthsActiveOnSystemSince2010, 2) ELSE SleepElevationInMetersMetric END AS SleepElevationInMetersMetricNormalized, 
                      CASE WHEN MonthsActiveOnSystemSince2010 > 0 THEN Round(Cast(OverallFeelingMetric As Float) / MonthsActiveOnSystemSince2010, 2) ELSE OverallFeelingMetric END AS OverallFeelingMetricNormalized, 
                      CASE WHEN MonthsActiveOnSystemSince2010 > 0 THEN Round(Cast(PercentFatMetric As Float) / MonthsActiveOnSystemSince2010, 2) ELSE PercentFatMetric END AS PercentFatMetricNormalized, 
                      CASE WHEN MonthsActiveOnSystemSince2010 > 0 THEN Round(Cast(LtsTotal As Float) / MonthsActiveOnSystemSince2010, 2) ELSE LtsTotal END AS LtsTotalNormalized, 
                      CASE WHEN MonthsActiveOnSystemSince2010 > 0 THEN Round(Cast(LtsSubscription As Float) / MonthsActiveOnSystemSince2010, 2) ELSE LtsSubscription END AS LtsSubscriptionNormalized, 
                      CASE WHEN MonthsActiveOnSystemSince2010 > 0 THEN Round(Cast(LtsTrainingPlan As Float) / MonthsActiveOnSystemSince2010, 2) ELSE LtsTrainingPlan END AS LtsTrainingPlanNormalized, 
                      CASE WHEN MonthsActiveOnSystemSince2010 > 0 THEN Round(Cast(LtsSoftware As Float) / MonthsActiveOnSystemSince2010, 2) ELSE LtsSoftware END AS LtsSoftwareNormalized, 
                      CASE WHEN MonthsActiveOnSystemSince2010 > 0 THEN Round(Cast(LtsLibrary As Float) / MonthsActiveOnSystemSince2010, 2) ELSE LtsLibrary END AS LtsLibraryNormalized, 
                      CASE WHEN MonthsActiveOnSystemSince2010 > 0 THEN Round(Cast(FavoriteFoodCount As Float) / MonthsActiveOnSystemSince2010, 2) ELSE FavoriteFoodCount END AS FavoriteFoodCountNormalized, 
					  AllowMarketingEmails, ThresholdsNotifyAthlete, ThresholdsAutoApply,
                      Case When AffiliateId = 723 Then 1 Else 0 End As IsRunnerWorld,
                      Case When AffiliateId = 450 Then 1 Else 0 End As IsTimex,
                      MarketingPreferenceSharedKey, GaMonthsActiveOnSystem, LastGaVisit,  DaysSinceLastGaVisit, UsesMobile,
                      CASE WHEN GaMonthsActiveOnSystem > 0 THEN Round(Cast(GaNativeAppiOSVisits As Float) / GaMonthsActiveOnSystem, 2) ELSE GaNativeAppiOSVisits END AS GaNativeAppiOSVisitsNormalized, 
                      CASE WHEN GaMonthsActiveOnSystem > 0 THEN Round(Cast(GaNativeAppAndroidVisits As Float) / GaMonthsActiveOnSystem, 2) ELSE GaNativeAppAndroidVisits END AS GaNativeAppAndroidVisitsNormalized, 
                      CASE WHEN GaMonthsActiveOnSystem > 0 THEN Round(Cast(GaWebAppDesktopVisits As Float) / GaMonthsActiveOnSystem, 2) ELSE GaWebAppDesktopVisits END AS GaWebAppDesktopVisitsNormalized, 
                      CASE WHEN GaMonthsActiveOnSystem > 0 THEN Round(Cast(GaWebAppiOSVisits As Float) / GaMonthsActiveOnSystem, 2) ELSE GaWebAppiOSVisits END AS GaWebAppiOSVisitsNormalized, 
                      CASE WHEN GaMonthsActiveOnSystem > 0 THEN Round(Cast(GaWebAppAndroidVisits As Float) / GaMonthsActiveOnSystem, 2) ELSE GaWebAppAndroidVisits END AS GaWebAppAndroidVisitsNormalized, 
                      CASE WHEN GaMonthsActiveOnSystem > 0 THEN Round(Cast(GaOtherVisits As Float) / GaMonthsActiveOnSystem, 2) ELSE GaOtherVisits END AS GaOtherVisitsNormalized, 
                      LapseCount, RenewSaleCount, RecurSaleCount, DaysSinceLastPremSub, DaysToPremSub, FirstPremTerm, DateAdded
FROM         dbo.v_CPAP2010Athlete







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
         Begin Table = "v_CPAP2010Athlete"
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
', 'SCHEMA', N'dbo', 'VIEW', N'v_CPAP2010Athlete_Normalized', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=1
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'dbo', 'VIEW', N'v_CPAP2010Athlete_Normalized', NULL, NULL
GO
