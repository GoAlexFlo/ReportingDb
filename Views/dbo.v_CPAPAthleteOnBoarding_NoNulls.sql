SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO










CREATE VIEW [dbo].[v_CPAPAthleteOnBoarding_NoNulls]
AS

SELECT CpapAthleteId
      ,PersonId
      ,CoachedByPersonId
      ,AccountCreationDate
      ,LastLogon
      ,IsNull(UserType,0) As UserType
      ,IsNull(TrialPremiumSubCouponUsed,0) As TrialPremiumSubCouponUsed
      ,IsNull(AthleteSubscribesToDailyWoEmail,0) As AthleteSubscribesToDailyWoEmail
      ,FitnessSummary
      ,DailyCalories
      ,Macronutrients
      ,GettingStarted
      ,DailyMetrics
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
      ,IsNull(HealthVaultSync,0) As HealthVaultSync 
      ,IsNull(HasCustomizedDashboard,0) As HasCustomizedDashboard
      ,IsNull(MonthsOnSystem,0) As MonthsOnSystem
      ,IsNull(MonthsOnSystemSince2010,0) As MonthsOnSystemSince2010
      ,IsNull(MonthsActiveOnSystemSince2010,0) As MonthsActiveOnSystemSince2010
      ,IsNull(MonthsActiveOnSystem,0) As MonthsActiveOnSystem
      ,IsNull(PercentOfMonthsActiveOnSystem,0) As PercentOfMonthsActiveOnSystem
      ,IsNull(PercentOfMonthsActiveOnSystemSince2010,0) As PercentOfMonthsActiveOnSystemSince2010
      ,IsNull(WorkoutsInLibraryCount,0) As WorkoutsInLibraryCount
      ,IsNull(MealsCreatedByUserCount,0) As MealsCreatedByUserCount
      ,IsHeartRateZoneDefault
      ,IsPowerZoneDefault
      ,IsSpeedZoneDefault
      ,MonthsSinceUserType1
      ,IsNull(NumberOfVisits,0) As NumberOfVisits
      ,IsNull(ATPYearsWithGoals,0) As ATPYearsWithGoals
      ,IsNull(ATPYearsWithObjectives,0) As ATPYearsWithObjectives
      ,IsNull(ATPTotalRaceCount,0) As ATPTotalRaceCount
      ,IsNull(PlannedMealCount,0) As PlannedMealCount
      ,IsNull(PlannedUnLoggedMealCount,0) As PlannedUnLoggedMealCount
      ,IsNull(PlannedLoggedMealCount,0) As PlannedLoggedMealCount
      ,IsNull(UnPlannedLoggedMealCount,0) As UnPlannedLoggedMealCount
      ,IsNull(PlannedMealMonths,0) As PlannedMealMonths
      ,IsNull(PlannedUnLoggedMealMonths,0) As PlannedUnLoggedMealMonths
      ,IsNull(PlannedLoggedMealMonths,0) As PlannedLoggedMealMonths
      ,IsNull(UnPlannedLoggedMealMonths,0) As UnPlannedLoggedMealMonths
      ,IsNull(UserPlannedNotCompletedWorkoutCount,0) As UserPlannedNotCompletedWorkoutCount
      ,IsNull(TrainingPlanWorkoutCount,0) As TrainingPlanWorkoutCount
      ,IsNull(UserUsedPlannedFieldsWorkoutCount,0) As UserUsedPlannedFieldsWorkoutCount
      ,IsNull(CompletedWorkouts,0) As CompletedWorkouts
      ,IsNull(WorkoutsWithTitle,0) As WorkoutsWithTitle
      ,IsNull(WorkoutsWithDescriptionNotTrainingPlan,0) As WorkoutsWithDescriptionNotTrainingPlan
      ,IsNull(WorkoutsWithTSS,0) As WorkoutsWithTSS
      ,IsNull(SwimWorkouts,0) As SwimWorkouts
      ,IsNull(BikeWorkouts,0) As BikeWorkouts
      ,IsNull(RunWorkouts,0) As RunWorkouts
      ,IsNull(MTBWorkouts,0) As MTBWorkouts
      ,IsNull(Races,0) As Races
      ,IsNull(TotalWorkoutCount,0) As TotalWorkoutCount
      ,IsNull(WorkoutsWithAthleteComments,0) As WorkoutsWithAthleteComments
      ,IsNull(WorkoutsWithCoachComments,0) As WorkoutsWithCoachComments
      ,IsNull(TotalUploads,0) As TotalUploads
      ,IsNull(WorkoutsWithPower,0) As WorkoutsWithPower
      ,IsNull(AvgHoursPerWeek,0) As AvgHoursPerWeek
      ,IsNull(AthleteType,0) As AthleteType
      ,IsNull(AffiliateId,0) As AffiliateId
      ,IsNull(ARR,0) As ARR
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
      ,IsNull(EquipmentBikeCount,0) As EquipmentBikeCount
      ,IsNull(EquipmentShoeCount,0) As EquipmentShoeCount
      ,IsNull(MonthsAsUserType1,0) As MonthsAsUserType1
      ,IsNull(MonthsAsPaidUserType4,0) As MonthsAsPaidUserType4
      ,IsNull(RouteCount,0) As RouteCount
      ,IsNull(WeightInKilogramsMetric,0) As WeightInKilogramsMetric
      ,IsNull(SleepQualityMetric,0) As SleepQualityMetric
      ,IsNull(SleepHoursMetric,0) As SleepHoursMetric
      ,IsNull(FatigueMetric,0) As FatigueMetric
      ,IsNull(SorenessMetric,0) As SorenessMetric
      ,IsNull(StressMetric,0) As StressMetric
      ,IsNull(PulseMetric,0) As PulseMetric
      ,IsNull(SleepElevationInMetersMetric,0) As SleepElevationInMetersMetric
      ,IsNull(OverallFeelingMetric,0) As OverallFeelingMetric
      ,IsNull(PercentFatMetric,0) As PercentFatMetric
      ,IsNull(LtsTotal,0) As LtsTotal
      ,IsNull(LtsSubscription,0) As LtsSubscription
      ,IsNull(LtsTrainingPlan,0) As LtsTrainingPlan
      ,IsNull(LtsSoftware,0) As LtsSoftware
      ,IsNull(LtsLibrary,0) As LtsLibrary
      ,IsNull(FavoriteFoodCount,0) As FavoriteFoodCount
      ,IsNull(AllowMarketingEmails,0) As AllowMarketingEmails
      ,IsNull(ThresholdsNotifyAthlete,0) As ThresholdsNotifyAthlete
      ,IsNull(ThresholdsAutoApply,0) As ThresholdsAutoApply
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
      ,IsNull(GaNativeAppiOSVisits,0) As GaNativeAppiOSVisits
      ,IsNull(GaNativeAppAndroidVisits,0) As GaNativeAppAndroidVisits
      ,IsNull(GaWebAppDesktopVisits,0) As GaWebAppDesktopVisit
      ,IsNull(GaWebAppiOSVisits,0) As GaWebAppiOSVisits 
      ,IsNull(GaWebAppAndroidVisits,0) As GaWebAppAndroidVisits
      ,IsNull(GaOtherVisits,0) As GaOtherVisits
      ,CASE WHEN CoachedByPersonId > 0 THEN 1 ELSE 0 END AS IsCoached   
      ,CASE WHEN IsHeartRateZoneDefault = 'NotDefault' THEN 1 ELSE 0 END AS IsHeartRateZoneDefaultCleaned 
      ,CASE WHEN IsPowerZoneDefault = 'NotDefault' THEN 1 ELSE 0 END AS IsPowerZoneDefaultCleaned 
      ,CASE WHEN IsSpeedZoneDefault = 'NotDefault' THEN 1 ELSE 0 END AS IsSpeedZoneDefaultCleaned
      ,CASE WHEN (AtpAvgAnnualHours > 0 OR ATPYearsWithGoals > 0 OR ATPYearsWithObjectives > 0 OR ATPTotalRaceCount > 0) THEN 1 ELSE 0 END AS UsedATP 
      ,CASE WHEN affiliateid IN (88, 277, 596, 783, 818, 883) THEN 1 ELSE 0 END AS IsTPAffiliate
      ,DATEDIFF(DAY, LastLogon, GETDATE()) AS DaysSinceLastLogon
      ,CASE WHEN AffiliateId = 723 THEN 1 ELSE 0 END AS IsRunnerWorld
      ,CASE WHEN AffiliateId = 450 THEN 1 ELSE 0 END AS IsTimex
      ,CASE 
			   WHEN NumberOfVisits <= 2 THEN 0
			   WHEN NumberOfVisits >= 9 THEN 4
			   WHEN NumberOfVisits >= 3 AND NumberOfVisits <= 4 THEN 1
			   WHEN NumberOfVisits >= 5 AND NumberOfVisits <= 6 THEN 2
			   WHEN NumberOfVisits >= 7 AND NumberOfVisits <= 8 THEN 3
			   ELSE 0 END As VisitPoints
	  ,CASE 
			   WHEN DATEDIFF(DAY, AccountCreationDate, LastLogon) < 1 THEN 0
			   WHEN DATEDIFF(DAY, AccountCreationDate, LastLogon) IN (1,2) THEN DATEDIFF(DAY, AccountCreationDate, LastLogon) 
			   WHEN DATEDIFF(DAY, AccountCreationDate, LastLogon) >= 3 THEN 3
			   ELSE 0 END AS ElapsedDaysPoints
	  ,CASE WHEN TotalWorkoutCount>0 THEN 1 ELSE 0 END AS WorkoutPoints
	  ,CASE WHEN TotalUploads>0 THEN 1 ELSE 0 END AS UploadPoints
   	  ,CASE WHEN Age>0 And Sex IS NOT NULL And AthleteType>0 THEN 1 ELSE 0 END AS ProfilePoints
      ,(CASE 
			   WHEN NumberOfVisits <= 2 THEN 0
			   WHEN NumberOfVisits >= 9 THEN 4
			   WHEN NumberOfVisits >= 3 AND NumberOfVisits <= 4 THEN 1
			   WHEN NumberOfVisits >= 5 AND NumberOfVisits <= 6 THEN 2
			   WHEN NumberOfVisits >= 7 AND NumberOfVisits <= 8 THEN 3
			   ELSE 0 END +
		 CASE 
			   WHEN DATEDIFF(DAY, AccountCreationDate, LastLogon) < 1 THEN 0
			   WHEN DATEDIFF(DAY, AccountCreationDate, LastLogon) IN (1,2) THEN DATEDIFF(DAY, AccountCreationDate, LastLogon) 
			   WHEN DATEDIFF(DAY, AccountCreationDate, LastLogon) >= 3 THEN 3
			   ELSE 0
			END +
	    CASE WHEN TotalWorkoutCount>0 THEN 1 ELSE 0 END +
	    CASE WHEN TotalUploads>0 THEN 1 ELSE 0 END +
   	    CASE WHEN Age>0 And Sex IS NOT NULL And AthleteType>0 THEN 1 ELSE 0 END) As OnBoardingHealthScore
   	    
   	    
   	   ,(CASE 
			   WHEN NumberOfVisits <= 2 THEN 0
			   WHEN NumberOfVisits >= 9 THEN 4
			   WHEN NumberOfVisits >= 3 AND NumberOfVisits <= 4 THEN 1
			   WHEN NumberOfVisits >= 5 AND NumberOfVisits <= 6 THEN 2
			   WHEN NumberOfVisits >= 7 AND NumberOfVisits <= 8 THEN 3
			   ELSE 0 END +
		 CASE 
			   WHEN DATEDIFF(DAY, AccountCreationDate, LastLogon) < 1 THEN 0
			   WHEN DATEDIFF(DAY, AccountCreationDate, LastLogon) IN (1,2) THEN DATEDIFF(DAY, AccountCreationDate, LastLogon) 
			   WHEN DATEDIFF(DAY, AccountCreationDate, LastLogon) >= 3 THEN 3
			   ELSE 0
			END +
	    CASE WHEN TotalWorkoutCount>0 THEN 1 ELSE 0 END +
	    CASE WHEN TotalUploads>0 THEN 1 ELSE 0 END +
   	    CASE WHEN Age>0 And Sex IS NOT NULL And AthleteType>0 THEN 1 ELSE 0 END) - 
   	    (Select Top 1 OnBoardingHealthScore From Reporting..v_CPAPAthleteOnBoarding Where PersonId=c.PersonId And DateAdded<c.DateAdded Order By DateAdded desc) AS HealthScoreChange 
      ,DATEDIFF(DAY, AccountCreationDate, LastLogon) As ElapseLoginDays
      ,IsNull(DateAdded,0) As DateAdded
  FROM Reporting..v_CPAPAthleteOnBoarding As c











GO
