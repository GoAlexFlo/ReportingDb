SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[sp_Cpap2010Main] 
	@SourceDbName      Varchar(25),
	@DestinationDbName Varchar(25),
	@WhereConditionYear Varchar(4)
AS
BEGIN
SET NOCOUNT ON;
DECLARE @WhereCondition Varchar(500)
--Note Bill ask that we remove PersonId = 349077.  This account contains 100s of paypal transactions that are under review/question.
--Note Bill ask that we remove PersonId = 114420.  This account contains a account creation date of 1900-01-01.
SET @WhereCondition = 'p.Usertype in (1,4,6) And p.PersonId Not In (349077, 114420)'
       
       CREATE TABLE #AthleteInfo (PersonId INT, AccountCreationDate Datetime, LastLogon datetime, NumberOfVisits INT, UserType INT, AthleteType INT, 
                                  AthleteTypeDesc varchar(20), Age FLOAT, Sex varchar(2), CoachedByPersonId INT, AffiliateId INT, TrialPremiumSubCouponUsed INT, 
                                  HasPaypalTrans BIT, AthleteSubscribesToDailyWoEmail BIT, AllowMarketingEmails BIT, ThresholdsNotifyAthlete BIT, ThresholdsAutoApply BIT, 
                                  DaysToPremSub INT, FirstPremTerm INT)
	   INSERT INTO #AthleteInfo
	   EXEC sp_CpapAthleteInfo @SourceDbName, @DestinationDbName, @WhereCondition, @WhereConditionYear   
       
       CREATE TABLE #DeviceInfo (PersonId INT, MostPopularDevice varchar(100),  TotalUploads INT, NumberOfDevices INT)
	   INSERT INTO #DeviceInfo
	   EXEC sp_CpapDeviceInfo @SourceDbName, @WhereCondition, @WhereConditionYear    
       
       CREATE TABLE #PlanInfo (PersonId INT, BoughtWorkoutPlan INT, BoughtMealPlan INT, 
                               BoughtNutritionAndWorkoutComboPlan INT, BoughtWorkoutLibrary INT,
                               CoachSuppliedWorkoutPlan INT, CoachSuppliedMealPlan INT, AppliedPlanCount INT)
	   INSERT INTO #PlanInfo
	   EXEC sp_CpapPlanInfo  @SourceDbName, @DestinationDbName, @WhereCondition, @WhereConditionYear 
	   
	   CREATE TABLE #AtpInfo (PersonId INT, AtpYearsWithGoals INT, AtpYearsWithObjectives INT, AtpTotalRaceCount INT, AtpAvgAnnualHours INT)
	   INSERT INTO #AtpInfo
	   EXEC sp_CpapAtpInfo  @SourceDbName, @DestinationDbName, @WhereCondition, @WhereConditionYear 
	   
	   CREATE TABLE #WorkoutLibInfo (PersonId INT, WorkoutsInLibraryCount INT)
	   INSERT INTO #WorkoutLibInfo
	   EXEC sp_CpapWorkoutLibInfo  @SourceDbName, @DestinationDbName, @WhereCondition, @WhereConditionYear
	   
	   CREATE TABLE #MealLibInfo (PersonId INT, MealLibCount INT)
	   INSERT INTO #MealLibInfo
	   EXEC sp_CpapMealLibInfo  @SourceDbName, @DestinationDbName, @WhereCondition, @WhereConditionYear  
	   
	   CREATE TABLE #HrZoneThresholdInfo (PersonId int, HrZoneThresholdDefault varchar(15))
	   INSERT INTO #HrZoneThresholdInfo
	   EXEC sp_CpapHrZonesThresholdInfo @SourceDbName, @DestinationDbName, @WhereCondition
	   
	   CREATE TABLE #PwZoneThresholdInfo (PersonId int, PwZoneThresholdDefault varchar(15))
	   INSERT INTO #PwZoneThresholdInfo
	   EXEC sp_CpapPwZonesThresholdInfo @SourceDbName, @DestinationDbName, @WhereCondition
	   
	   CREATE TABLE #SpZoneThresholdInfo (PersonId int, SpZoneThresholdDefault varchar(15))
	   INSERT INTO #SpZoneThresholdInfo
	   EXEC sp_CpapSpZonesThresholdInfo @SourceDbName, @DestinationDbName, @WhereCondition
		
	   CREATE TABLE #PodInfo (PersonId INT, FitnessSummary  INT, DailyCalories  INT, Macronutrients INT, GettingStarted INT, DailyMetrics INT, DistanceByWeek_Day INT, 
						DurationByWeek_Day INT, PMC INT, PeakPower INT, TimeinHRZones INT, FitnessHistory INT, TSSbyWeekDay INT, PowerProfile INT, 
						TimeInHRZonesByWeek INT, GroceryList INT, PeakHearRate INT, TimeInPowerZones INT, TimeInPowerZonesByWeek INT, KJPerWeek INT, RaceReports INT, WeatherPod INT, 
						LongestWorkoutDuration INT, LongestWorkoutDistance INT, PeakPace INT, PeakSpeed INT,  PeakCadence INT,
						MicroNutrients INT, RoutesHistory INT, TimeInSpeedZonesByWeek INT, TimeInSpeedZones INT,  PeakPaceByDistance INT, HealthVaultSync INT,  HasCustomizedDashboard INT)
	   INSERT INTO #PodInfo
	   EXEC sp_CpapPodInfo @SourceDbName, @DestinationDbName, @WhereCondition
	   
	   CREATE TABLE #MealInfo (PersonId INT, PlannedMealCount INT,  PlannedUnLoggedMealCount INT, PlannedLoggedMealCount INT, UnPlannedLoggedMealCount INT,  
	                           PlannedMealMonths INT, PlannedUnLoggedMealMonths INT, PlannedLoggedMealMonths INT, UnPlannedLoggedMealMonths INT)
	   INSERT INTO #MealInfo
	   EXEC sp_CpapMealInfo @SourceDbName, @DestinationDbName, @WhereCondition, @WhereConditionYear	  
	   
	   CREATE TABLE #MonthsOnSystemInfo (PersonId INT, MonthsOnSystem INT, MonthsOnSystemSince2010 INT, MonthsActiveOnSystem INT, 
	                                     MonthsActiveOnSystemSince2010 INT, PercentOfMonthsActiveOnSystem FLOAT, PercentOfMonthsActiveOnSystemSince2010 FLOAT)
	   INSERT INTO #MonthsOnSystemInfo
	   EXEC sp_CpapMonthsOnSystemInfo @SourceDbName, @DestinationDbName, @WhereCondition, @WhereConditionYear
	   
	   CREATE TABLE #PremAthleteInfo (PersonId INT, MonthsAsUserType1 INT, MonthsSinceUserType1 INT)
	   INSERT INTO #PremAthleteInfo
	   EXEC sp_CpapPremAthleteInfo @SourceDbName, @WhereConditionYear

	   CREATE TABLE #LtsInfo (PersonId INT, ARR INT, LtsSubscription INT, LtsTrainingPlan INT, LtsSoftware INT, LtsLibrary INT, LtsTotal INT)
	   INSERT INTO #LtsInfo
	   EXEC sp_CpapLtsInfo @SourceDbName, @DestinationDbName, @WhereCondition, @WhereConditionYear
	   
	   CREATE TABLE #EquipmentInfo (PersonId INT, EquipmentBikeCount INT, EquipmentShoeCount INT)
	   INSERT INTO #EquipmentInfo
	   EXEC sp_CpapEquipmentInfo @SourceDbName, @DestinationDbName, @WhereCondition, @WhereConditionYear
	   
	   CREATE TABLE #RouteInfo (PersonId INT, RouteCount INT)
	   INSERT INTO #RouteInfo
	   EXEC sp_CpapRouteInfo @SourceDbName, @DestinationDbName, @WhereCondition, @WhereConditionYear
	   
	   CREATE TABLE #MetricInfo (PersonId INT, [WeightInKilogramsMetric] INT, [SleepQualityMetric] INT, [SleepHoursMetric] INT, [FatigueMetric] INT, [SorenessMetric] INT, 
				                               [StressMetric] INT, [PulseMetric] INT, [SleepElevationInMetersMetric] INT, [OverallFeelingMetric] INT, [PercentFatMetric] INT)
	   INSERT INTO #MetricInfo
	   EXEC sp_CpapMetricInfo @SourceDbName, @DestinationDbName, @WhereCondition, @WhereConditionYear
	   
	   CREATE TABLE #UserType4Info (PersonId INT, MonthsAsPaidUserType4 INT)
	   INSERT INTO #UserType4Info
	   EXEC sp_CpapUserType4Info @SourceDbName, @DestinationDbName, @WhereCondition, @WhereConditionYear
	   
	   CREATE TABLE #SubTransDescInfo (PersonId INT, LapseCount INT, RenewSaleCount INT, RecurSaleCount INT, DaysSinceLastPremSub INT)
	   INSERT INTO #SubTransDescInfo
	   EXEC sp_CpapSubTransInfo @SourceDbName, @DestinationDbName, @WhereCondition, @WhereConditionYear

	   CREATE TABLE #FavoriteFoodInfo (PersonId INT, FavoriteFoodCount INT)
	   INSERT INTO #FavoriteFoodInfo
	   EXEC sp_CpapFavoriteFoodlInfo @SourceDbName, @DestinationDbName, @WhereCondition, @WhereConditionYear
	   
	   CREATE TABLE #GaVisitsInfo (PersonId INT, MarketingPreferenceSharedKey varchar(50), GaMonthsActiveOnSystem INT, 
	                               LastGaVisit Datetime, DaysSinceLastGaVisit INT, UsesMobile INT, GaNativeAppiOSVisits INT, 
	                               GaNativeAppAndroidVisits INT, GaWebAppDesktopVisits INT, GaWebAppiOSVisits INT, GaWebAppAndroidVisits INT, GAOtherVisits INT)
	   INSERT INTO #GaVisitsInfo
	   EXEC sp_CpapGoogleAnalyticsInfo @SourceDbName, @DestinationDbName, @WhereCondition, @WhereConditionYear
	   
    INSERT INTO Reporting..Cpap2010Athlete
		  ([PersonId]
		  ,[AccountCreationDate]
		  ,[LastLogon]
		  ,[NumberOfVisits]
		  ,[UserType]
		  ,[AthleteType]
		  ,[AthleteTypeDesc]
		  ,[Age]
		  ,[Sex]
		  ,[AffiliateId]
		  ,[TrialPremiumSubCouponUsed]
		  ,[AthleteSubscribesToDailyWoEmail]
		  ,[CoachedByPersonId]
  		  ,[AllowMarketingEmails] 
	      ,[ThresholdsNotifyAthlete] 
	      ,[ThresholdsAutoApply] 
		  ,[DaysToPremSub]
		  ,[FirstPremTerm]
		  ,[BoughtWorkoutPlan]
		  ,[BoughtNutritionPlan]
		  ,[BoughtNutritionAndWorkoutComboPlan]
		  ,[BoughtWorkoutLibrary]
		  ,[CoachSuppliedWorkoutPlan]
		  ,[CoachSuppliedMealPlan]
		  ,[AppliedPlanCount]
		  ,[AtpYearsWithGoals]
		  ,[AtpYearsWithObjectives]
		  ,[AtpTotalRaceCount]
		  ,[AtpAvgAnnualHours]
		  ,[WorkoutsInLibraryCount]
		  ,[MealsCreatedByUserCount]
		  ,[IsHeartRateZoneDefault]
		  ,[IsPowerZoneDefault]
		  ,[IsSpeedZoneDefault]
		  ,[FitnessSummary]
		  ,[DailyCalories] 
		  ,[Macronutrients]
		  ,[GettingStarted]
		  ,[DailyMetrics]
		  ,[DistanceByWeek_Day]
		  ,[DurationByWeek_Day]
		  ,[PMC]
		  ,[PeakPower]
		  ,[TimeinHRZones]
		  ,[FitnessHistory]
		  ,[TSSbyWeekDay]
		  ,[PowerProfile]
		  ,[TimeInHRZonesByWeek]
		  ,[GroceryList]
		  ,[PeakHearRate]
		  ,[TimeInPowerZones]
		  ,[TimeInPowerZonesByWeek]
		  ,[KJPerWeek]
		  ,[RaceReports]
		  ,[WeatherPod]
		  ,[LongestWorkoutDuration]
		  ,[LongestWorkoutDistance]
		  ,[PeakPace]
		  ,[PeakSpeed]
		  ,[PeakCadence]
		  ,[MicroNutrients]
		  ,[RoutesHistory]
		  ,[TimeInSpeedZonesByWeek]
		  ,[TimeInSpeedZones]
		  ,[PeakPaceByDistance]
		  ,[HealthVaultSync]
		  ,[HasCustomizedDashboard]
		  ,[PlannedMealCount]  
		  ,[PlannedUnLoggedMealCount] 
		  ,[PlannedLoggedMealCount] 
		  ,[UnPlannedLoggedMealCount]  
	      ,[PlannedMealMonths] 
	      ,[PlannedUnLoggedMealMonths] 
	      ,[PlannedLoggedMealMonths] 
	      ,[UnPlannedLoggedMealMonths]
  		  ,[MonthsOnSystem]
       	  ,[MonthsOnSystemSince2010]
       	  ,[MonthsActiveOnSystem]
       	  ,[MonthsActiveOnSystemSince2010]
       	  ,[PercentOfMonthsActiveOnSystem]
       	  ,[PercentOfMonthsActiveOnSystemSince2010]
		  ,[MonthsAsUserType1]
		  ,[MonthsSinceUserType1]
		  ,[MonthsAsPaidUserType4]
	 	  ,[ARR]
		  ,[LtsSubscription]
		  ,[LtsTrainingPlan]
  		  ,[LtsSoftware]
  		  ,[LtsLibrary]
		  ,[LtsTotal]
		  ,[MostPopularDevice]
		  ,[TotalUploads]
		  ,[NumberOfDevices]
		  ,[EquipmentBikeCount]
		  ,[EquipmentShoeCount]
		  ,[RouteCount]
		  ,[WeightInKilogramsMetric] 
		  ,[SleepQualityMetric] 
		  ,[SleepHoursMetric] 
		  ,[FatigueMetric] 
		  ,[SorenessMetric] 
		  ,[StressMetric] 
		  ,[PulseMetric] 
		  ,[SleepElevationInMetersMetric] 
		  ,[OverallFeelingMetric] 
		  ,[PercentFatMetric]
		  ,[LapseCount]
		  ,[RenewSaleCount]
		  ,[RecurSaleCount]
		  ,[DaysSinceLastPremSub]
		  ,[FavoriteFoodCount]
		  ,[MarketingPreferenceSharedKey] 
		  ,[GaMonthsActiveOnSystem]
		  ,[LastGaVisit] 
		  ,[DaysSinceLastGaVisit] 
		  ,[UsesMobile]
		  ,[GaNativeAppiOSVisits] 
		  ,[GaNativeAppAndroidVisits] 
		  ,[GaWebAppDesktopVisits] 
		  ,[GaWebAppiOSVisits] 
		  ,[GaWebAppAndroidVisits] 
		  ,[GaOtherVisits] 
		  ,[DateAdded]
		  )
    SELECT a.PersonId, 
           a.AccountCreationDate, 
           a.LastLogon, 
           a.NumberOfVisits,
           a.UserType,
           a.AthleteType,
           a.AthleteTypeDesc,
           a.Age,
           a.Sex,
           a.AffiliateId,
           a.TrialPremiumSubCouponUsed, 
           a.AthleteSubscribesToDailyWoEmail,
           a.CoachedByPersonId,
   		   a.AllowMarketingEmails, 
	       a.ThresholdsNotifyAthlete, 
	       a.ThresholdsAutoApply, 
	       a.DaysToPremSub,
	       a.[FirstPremTerm],
           b.BoughtWorkoutPlan,
           b.BoughtMealPlan,
           b.BoughtNutritionAndWorkoutComboPlan,
           b.BoughtWorkoutLibrary,
           b.CoachSuppliedWorkoutPlan,
           b.CoachSuppliedMealPlan,
           b.AppliedPlanCount,
           c.AtpYearsWithGoals,
		   c.AtpYearsWithObjectives,
		   c.AtpTotalRaceCount,
		   c.AtpAvgAnnualHours,
		   d.WorkoutsInLibraryCount,
		   e.MealLibCount,
		   f.HrZoneThresholdDefault,
		   g.PwZoneThresholdDefault,
		   h.SpZoneThresholdDefault,
		   i.FitnessSummary,
		   i.DailyCalories, 
		   i.Macronutrients,
		   i.GettingStarted,
		   i.DailyMetrics,
		   i.DistanceByWeek_Day,
		   i.DurationByWeek_Day,
		   i.PMC,
		   i.PeakPower,
		   i.TimeinHRZones,
		   i.FitnessHistory,
		   i.TSSbyWeekDay,
		   i.PowerProfile,
		   i.TimeInHRZonesByWeek,
		   i.GroceryList,
		   i.PeakHearRate,
		   i.TimeInPowerZones,
		   i.TimeInPowerZonesByWeek,
		   i.KJPerWeek,
		   i.RaceReports,
		   i.WeatherPod,
		   i.LongestWorkoutDuration,
		   i.LongestWorkoutDistance,
		   i.PeakPace,
		   i.PeakSpeed,
		   i.PeakCadence,
		   i.MicroNutrients,
		   i.RoutesHistory,
		   i.TimeInSpeedZonesByWeek,
		   i.TimeInSpeedZones,
		   i.PeakPaceByDistance,
		   i.HealthVaultSync,
		   i.HasCustomizedDashboard,
		   j.PlannedMealCount,  
		   j.PlannedUnLoggedMealCount, 
		   j.PlannedLoggedMealCount, 
		   j.UnPlannedLoggedMealCount,  
	       j.PlannedMealMonths, 
	       j.PlannedUnLoggedMealMonths, 
	       j.PlannedLoggedMealMonths, 
	       j.UnPlannedLoggedMealMonths,
       	   k.MonthsOnSystem,
       	   k.MonthsOnSystemSince2010,
       	   k.MonthsActiveOnSystem,
       	   k.MonthsActiveOnSystemSince2010,
       	   k.PercentOfMonthsActiveOnSystem,
       	   k.PercentOfMonthsActiveOnSystemSince2010,
		   l.MonthsAsUserType1,
		   l.MonthsSinceUserType1,
		   r.MonthsAsPaidUserType4,
		   m.ARR,
		   m.LtsSubscription,
		   m.LtsTrainingPlan,
		   m.LtsSoftware,
		   m.LtsLibrary,
		   m.LtsTotal,
		   n.MostPopularDevice,
		   n.TotalUploads,
		   n.NumberOfDevices,
		   o.EquipmentBikeCount,
		   o.EquipmentShoeCount,
		   p.RouteCount,
		   q.WeightInKilogramsMetric, 
		   q.SleepQualityMetric, 
		   q.SleepHoursMetric, 
		   q.FatigueMetric, 
		   q.SorenessMetric, 
		   q.StressMetric, 
		   q.PulseMetric, 
		   q.SleepElevationInMetersMetric, 
		   q.OverallFeelingMetric,
		   q.PercentFatMetric,
		   s.LapseCount, 
		   s.RenewSaleCount,
		   s.RecurSaleCount,
		   s.DaysSinceLastPremSub,
		   t.FavoriteFoodCount,
		   u.MarketingPreferenceSharedKey, 
		   u.GaMonthsActiveOnSystem,
		   u.LastGaVisit, 
		   u.DaysSinceLastGaVisit, 
		   u.UsesMobile,
		   u.GaNativeAppiOSVisits, 
		   u.GaNativeAppAndroidVisits, 
		   u.GaWebAppDesktopVisits, 
		   u.GaWebAppiOSVisits, 
		   u.GaWebAppAndroidVisits, 
		   u.GAOtherVisits, 
		   GETDATE()
    FROM #AthleteInfo As a Left Outer Join #PlanInfo            As b On a.PersonId=b.PersonId
                           Left Outer Join #AtpInfo             As c On a.PersonId=c.PersonId
                           Left Outer Join #WorkoutLibInfo      As d On a.PersonId=d.PersonId
                           Left Outer Join #MealLibInfo         As e On a.PersonId=e.PersonId
                           Left Outer Join #HrZoneThresholdInfo As f On a.PersonId=f.PersonId
                           Left Outer Join #PwZoneThresholdInfo As g On a.PersonId=g.PersonId
                           Left Outer Join #SpZoneThresholdInfo As h On a.PersonId=h.PersonId
                           Left Outer Join #PodInfo             As i On a.PersonId=i.PersonId
                           Left Outer Join #MealInfo            As j On a.PersonId=j.PersonId
                           LEFT Outer Join #MonthsOnSystemInfo  As k On a.PersonId=k.PersonId
                           Left Outer Join #PremAthleteInfo     As l On a.PersonId=l.PersonId
                           Left Outer Join #LtsInfo             As m On a.PersonId=m.PersonId
                           Left Outer Join #DeviceInfo          As n On a.PersonId=n.PersonId
                           Left Outer Join #EquipmentInfo       As o On a.PersonId=o.PersonId
                           Left Outer Join #RouteInfo           As p On a.PersonId=p.PersonId
                           Left Outer Join #MetricInfo          As q On a.PersonId=q.PersonId
                           Left Outer Join #UserType4Info       As r On a.PersonId=r.PersonId
                           Left Outer Join #SubTransDescInfo    As s On a.PersonId=s.PersonId
                           Left Outer Join #FavoriteFoodInfo    As t On a.PersonId=t.PersonId
                           Left Outer Join #GaVisitsInfo        As u On a.PersonId=u.PersonId

END

--#Execute the following to refresh Reporting.dao.CpapAthlete:            
--DECLARE @return_value int  
--DECLARE @SourceDbName Varchar (25)
--DECLARE @DestinationDbName Varchar (25)

--SET @SourceDbName = 'Ultrafit_live'
--SET @DestinationDbName = 'Reporting'
--SET NOCOUNT ON;

--Truncate table Reporting.dbo.CpapAthlete;

--EXEC    @return_value = [dbo].[sp_CpapMain] @SourceDbName, @DestinationDbName 
GO
