SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE VIEW [dbo].[v_CPAP2010Athlete_Normalized_NoNulls]
AS

SELECT CpapAthleteId
      ,PersonId
      ,AccountCreationDate
      ,LastLogon
      ,IsNull(LTSTotal,0) As LTSTotal
      ,IsNull(IsTopDecile,0) As IsTopDecile
      ,IsNull(UserType,0) As UserType
      ,IsNull(TrialPremiumSubCouponUsed,0) As TrialPremiumSubCouponUsed
      ,IsNull(IsCoached,0) As IsCoached
      ,IsNull(AthleteSubscribesToDailyWoEmail,0) As AthleteSubscribesToDailyWoEmail
      ,IsNull(IsHeartRateZoneDefaultCleaned,0) As IsHeartRateZoneDefaultCleaned
      ,IsNull(IsPowerZoneDefaultCleaned,0) As IsPowerZoneDefaultCleaned
      ,IsNull(IsSpeedZoneDefaultCleaned,0) As IsSpeedZoneDefaultCleaned
      ,IsNull(FitnessSummary,0) As FitnessSummary
      ,IsNull(DailyCalories,0) As DailyCalories
      ,IsNull(Macronutrients,0) As Macronutrients
      ,IsNull(GettingStarted,0) As GettingStarted
      ,IsNull(DailyMetrics,0) As DailyMetrics
      ,IsNull(DistanceByWeek_Day,0) As DistanceByWeek_Day
      ,IsNull(DurationByWeek_Day,0) As DurationByWeek_Day
      ,IsNull(PMC,0) As PMC
      ,IsNull(PeakPower,0) As PeakPower
      ,IsNull(TimeinHRZones,0) As TimeinHRZones
      ,IsNull(FitnessHistory,0) As FitnessHistory
      ,IsNull(TSSbyWeekDay,0) As TSSbyWeekDay
      ,IsNull(PowerProfile,0) As PowerProfile
      ,IsNull(TimeInHRZonesByWeek,0) As TimeInHRZonesByWeek
      ,IsNull(GroceryList,0) As GroceryList
      ,IsNull(PeakHearRate,0) As PeakHearRate
      ,IsNull(TimeInPowerZones,0) As TimeInPowerZones
      ,IsNull(TimeInPowerZonesByWeek,0) As TimeInPowerZonesByWeek
      ,IsNull(KJPerWeek,0) As KJPerWeek
      ,IsNull(RaceReports,0) As RaceReports
      ,IsNull(WeatherPod,0) As WeatherPod
      ,IsNull(LongestWorkoutDuration,0) As LongestWorkoutDuration
      ,IsNull(LongestWorkoutDistance,0) As LongestWorkoutDistance
      ,IsNull(PeakPace,0) As PeakPace
      ,IsNull(PeakSpeed,0) As PeakSpeed
      ,IsNull(PeakCadence,0) As PeakCadence
      ,IsNull(MicroNutrients,0) As MicroNutrients
      ,IsNull(RoutesHistory,0) As RoutesHistory
      ,IsNull(TimeInSpeedZonesByWeek,0) As TimeInSpeedZonesByWeek
      ,IsNull(TimeInSpeedZones,0) As TimeInSpeedZones
      ,IsNull(PeakPaceByDistance,0) As PeakPaceByDistance
      ,IsNull(HasCustomizedDashboard,0) As HasCustomizedDashboard
      ,IsNull(MonthsOnSystem,0) As MonthsOnSystem
      ,IsNull(MonthsOnSystemSince2010,0) As MonthsOnSystemSince2010
      ,IsNull(MonthsActiveOnSystemSince2010,0) As MonthsActiveOnSystemSince2010
      ,IsNull(MonthsActiveOnSystem,0) As MonthsActiveOnSystem
      ,IsNull(PercentOfMonthsActiveOnSystem,0) As PercentOfMonthsActiveOnSystem
      ,IsNull(PercentOfMonthsActiveOnSystemSince2010,0) As PercentOfMonthsActiveOnSystemSince2010
      ,IsNull(WorkoutsInLibraryCount,0) As WorkoutsInLibraryCount
      ,IsNull(MealsCreatedByUserCount,0) As MealsCreatedByUserCount
      ,MonthsSinceUserType1
      ,IsNull(NumberOfVisitsNormalized,0) As NumberOfVisitsNormalized
      ,IsNull(ATPYearsWithGoalsNormalized,0) As ATPYearsWithGoalsNormalized
      ,IsNull(ATPYearsWithObjectivesNormalized,0) As ATPYearsWithObjectivesNormalized
      ,IsNull(ATPTotalRaceCountNormalized,0) As ATPTotalRaceCountNormalized
      ,IsNull(PlannedMealCountNormalized,0) As PlannedMealCountNormalized
      ,IsNull(PlannedUnLoggedMealCountNormalized,0) As PlannedUnLoggedMealCountNormalized
      ,IsNull(PlannedLoggedMealCountNormalized,0) As PlannedLoggedMealCountNormalized
      ,IsNull(UnPlannedLoggedMealCountNormalized,0) As UnPlannedLoggedMealCountNormalized
      ,IsNull(UserPlannedNotCompletedWorkoutCountNormalized,0) As UserPlannedNotCompletedWorkoutCountNormalized
      ,IsNull(TrainingPlanWorkoutCountNormalized,0) As TrainingPlanWorkoutCountNormalized
      ,IsNull(UserUsedPlannedFieldsWorkoutCountNormalized,0) As UserUsedPlannedFieldsWorkoutCountNormalized
      ,IsNull(CompletedWorkoutsNormalized,0) As CompletedWorkoutsNormalized
      ,IsNull(WorkoutsWithTitleNormalized,0) As WorkoutsWithTitleNormalized
      ,IsNull(WorkoutsWithDescriptionNotTrainingPlanNormalized,0) As WorkoutsWithDescriptionNotTrainingPlanNormalized
      ,IsNull(WorkoutsWithTSSNormalized,0) As WorkoutsWithTSSNormalized
      ,IsNull(SwimWorkoutsNormalized,0) As SwimWorkoutsNormalized
      ,IsNull(BikeWorkoutsNormalized,0) As BikeWorkoutsNormalized
      ,IsNull(RunWorkoutsNormalized,0) As RunWorkoutsNormalized
      ,IsNull(MTBWorkoutsNormalized,0) As MTBWorkoutsNormalized
      ,IsNull(RacesNormalized,0) As RacesNormalized
      ,IsNull(TotalWorkoutCountNormalized,0) As TotalWorkoutCountNormalized
      ,IsNull(WorkoutsWithAthleteCommentsNormalized,0) As WorkoutsWithAthleteCommentsNormalized
      ,IsNull(WorkoutsWithCoachCommentsNormalized,0) As WorkoutsWithCoachCommentsNormalized
      ,IsNull(TotalUploadsNormalized,0) As TotalUploadsNormalized
      ,IsNull(WorkoutsWithPowerNormalized,0) As WorkoutsWithPowerNormalized
      ,IsNull(AvgHoursPerWeek,0) As AvgHoursPerWeek
      ,IsNull(UsedATP,0) As UsedATP
      ,IsNull(AthleteType,0) As AthleteType
      ,IsNull(AffiliateId,0) As AffiliateId
      ,IsNull(IsTPAffiliate,0) As IsTPAffiliate
      ,IsNull(ARR,0) As ARR
      ,IsNull(LtsSubscription,0) As LtsSubscription
      ,IsNull(LtsTrainingPlan,0) As LtsTrainingPlan
      ,IsNull(LtsSoftware,0) As LtsSoftware
      ,IsNull(LtsLibrary,0) As LtsLibrary
      ,IsNull(BoughtWorkoutPlan,0) As BoughtWorkoutPlan
      ,IsNull(BoughtNutritionPlan,0) As BoughtNutritionPlan
      ,IsNull(BoughtNutritionAndWorkoutComboPlan,0) As BoughtNutritionAndWorkoutComboPlan
      ,IsNull(BoughtWorkoutLibrary,0) As BoughtWorkoutLibrary
      ,IsNull(CoachSuppliedWorkoutPlan,0) As CoachSuppliedWorkoutPlan
      ,IsNull(CoachSuppliedMealPlan,0) As CoachSuppliedMealPlan
      ,IsNull(AppliedPlanCount,0) As AppliedPlanCount
      ,IsNull(AtpAvgAnnualHours,0) As AtpAvgAnnualHours
      ,MostPopularDevice
      ,IsNull(NumberOfDevices,0) As NumberOfDevices
      ,AthleteTypeDesc
      ,Age
      ,Sex
      ,DaysSinceLastLogon	
      ,IsNull(EquipmentBikeCount,0) As EquipmentBikeCount
      ,IsNull(EquipmentShoeCount,0) As EquipmentShoeCount
      ,IsNull(MonthsAsUserType1Normalized,0) As MonthsAsUserType1Normalized
      ,IsNull(MonthsAsPaidUserType4Normalized,0) As MonthsAsPaidUserType4Normalized
      ,IsNull(RouteCountNormalized,0) As RouteCountNormalized
      ,IsNull(WeightInKilogramsMetricNormalized,0) As WeightInKilogramsMetricNormalized
      ,IsNull(SleepQualityMetricNormalized,0) As SleepQualityMetricNormalized
      ,IsNull(SleepHoursMetricNormalized,0) As SleepHoursMetricNormalized
      ,IsNull(FatigueMetricNormalized,0) As FatigueMetricNormalized
      ,IsNull(SorenessMetricNormalized,0) As SorenessMetricNormalized
      ,IsNull(StressMetricNormalized,0) As StressMetricNormalized
      ,IsNull(PulseMetricNormalized,0) As PulseMetricNormalized
      ,IsNull(SleepElevationInMetersMetricNormalized,0) As SleepElevationInMetersMetricNormalized
      ,IsNull(OverallFeelingMetricNormalized,0) As OverallFeelingMetricNormalized
      ,IsNull(PercentFatMetricNormalized,0) As PercentFatMetricNormalized
      ,IsNull(LtsTotalNormalized,0) As LtsTotalNormalized
      ,IsNull(LtsSubscriptionNormalized,0) As LtsSubscriptionNormalized
      ,IsNull(LtsTrainingPlanNormalized,0) As LtsTrainingPlanNormalized
      ,IsNull(LtsSoftwareNormalized,0) As LtsSoftwareNormalized
      ,IsNull(LtsLibraryNormalized,0) As LtsLibraryNormalized
      ,IsNull(FavoriteFoodCountNormalized,0) As FavoriteFoodCountNormalized
      ,IsNull(AllowMarketingEmails,0) As AllowMarketingEmails
      ,IsNull(ThresholdsNotifyAthlete,0) As ThresholdsNotifyAthlete
      ,IsNull(ThresholdsAutoApply,0) As ThresholdsAutoApply
      ,IsNull(IsRunnerWorld,0) As IsRunnerWorld
      ,IsNull(IsTimex,0) As IsTimex
      ,IsNull(LapseCount,0) As LapseCount
      ,IsNull(RenewSaleCount,0) As RenewSaleCount
      ,IsNull(RecurSaleCount,0) As RecurSaleCount
      ,DaysSinceLastPremSub
      ,DaysToPremSub
      ,IsNull(FirstPremTerm,0) As FirstPremTerm
      ,IsNull(MarketingPreferenceSharedKey,0) As MarketingPreferenceSharedKey 
      ,IsNull(GaMonthsActiveOnSystem,0) As GaMonthsActiveOnSystem
      ,LastGaVisit   
      ,DaysSinceLastGaVisit
      ,IsNull(UsesMobile,0) As UsesMobile
      ,IsNull(GaNativeAppiOSVisitsNormalized,0) As GaNativeAppiOSVisitsNormalized
      ,IsNull(GaNativeAppAndroidVisitsNormalized,0) As GaNativeAppAndroidVisitsNormalized
      ,IsNull(GaWebAppDesktopVisitsNormalized,0) As GaWebAppDesktopVisitNormalized
      ,IsNull(GaWebAppiOSVisitsNormalized,0) As GaWebAppiOSVisitsNormalized 
      ,IsNull(GaWebAppAndroidVisitsNormalized,0) As GaWebAppAndroidVisitsNormalized
      ,IsNull(GaOtherVisitsNormalized,0) As GaOtherVisitsNormalized
      ,IsNull(DateAdded,0) As DateAdded
  FROM Reporting..v_CPAP2010Athlete_Normalized




GO
