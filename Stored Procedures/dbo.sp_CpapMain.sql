SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_CpapMain] 
	@SourceDbName      Varchar(25),
	@DestinationDbName Varchar(25)
AS
BEGIN
SET NOCOUNT ON;
DECLARE @WhereCondition Varchar(500)
DECLARE @WhereConditionYear Varchar(4)
--Note Bill ask that we remove PersonId = 349077.  This account contains 100s of paypal transactions that are under review/question.
--Note Bill ask that we remove PersonId = 114420.  This account contains a account creation date of 1900-01-01.
SET @WhereCondition = 'p.Usertype in (1,4,6) And p.PersonId Not In (349077, 114420) '
SET @WhereConditionYear = '1901'

       
       CREATE TABLE #AthleteInfo (PersonId INT, AccountCreationDate Datetime, LastLogon datetime, NumberOfVisits INT, UserType INT, AthleteType INT, AthleteTypeDesc varchar(20), Age FLOAT, Sex varchar(2), CoachedByPersonId INT, AffiliateId INT, MonthsOnSystem INT, MonthsActiveOnSystem INT, TrialPremiumSubCouponUsed INT, HasPaypalTrans BIT, AthleteSubscribesToDailyWoEmail BIT)
	   INSERT INTO #AthleteInfo
	   EXEC sp_CpapAthleteInfo @SourceDbName, @DestinationDbName, @WhereCondition   
       
       CREATE TABLE #DeviceInfo (PersonId INT, MostPopularDevice varchar(100),  TotalUploads INT, NumberOfDevices INT)
	   INSERT INTO #DeviceInfo
	   EXEC sp_CpapDeviceInfo @SourceDbName, @WhereCondition, @WhereConditionYear    
    
       CREATE TABLE #PlanInfo (PersonId INT, BoughtWorkoutPlan INT, BoughtMealPlan INT, CoachSuppliedWorkoutPlan INT, CoachSuppliedMealPlan INT, AppliedPlanCount INT)
	   INSERT INTO #PlanInfo
	   EXEC sp_CpapPlanInfo  @SourceDbName, @DestinationDbName, @WhereCondition, @WhereConditionYear 
	   
	   CREATE TABLE #AtpInfo (PersonId INT, AtpYearsWithGoals INT, AtpYearsWithObjectives INT, AtpTotalRaceCount INT, AtpAvgAnnualHours INT)
	   INSERT INTO #AtpInfo
	   EXEC sp_CpapAtpInfo  @SourceDbName, @DestinationDbName, @WhereCondition, @WhereConditionYear 
	   
	   CREATE TABLE #WorkoutLibInfo (PersonId INT, WorkoutLibCount INT)
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

	   CREATE TABLE #MealInfo (PersonId INT, PlannedMealCount INT, PlannedLoggedMealCount INT, UnPlannedLoggedMealCount INT)
	   INSERT INTO #MealInfo
	   EXEC sp_CpapMealInfo @SourceDbName, @DestinationDbName, @WhereCondition, @WhereConditionYear	  
	   
	   CREATE TABLE #PremAthleteInfo (PersonId INT, MonthsAsAPremAthleteCount INT)
	   INSERT INTO #PremAthleteInfo
	   EXEC sp_CpapPremAthleteInfo @SourceDbName, @WhereConditionYear

	   CREATE TABLE #LtsInfo (PersonId INT, ARR INT, LtsSubscription INT, LtsTrainingPlan INT, LtsSoftware INT, LtsTotal INT)
	   INSERT INTO #LtsInfo
	   EXEC sp_CpapLtsInfo @SourceDbName, @DestinationDbName, @WhereCondition, @WhereConditionYear
	   
    INSERT INTO Reporting..CpapAthlete
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
  		  ,[MonthsOnSystem]
  		  ,[MonthsActiveOnSystem]
		  ,[TrialPremiumSubCouponUsed]
		  ,[AthleteSubscribesToDailyWoEmail]
		  ,[CoachedByPersonId]
		  ,[BoughtWorkoutPlan]
		  ,[BoughtMealPlan]
		  ,[CoachSuppliedWorkoutPlan]
		  ,[CoachSuppliedMealPlan]
		  ,[AtpYearsWithGoals]
		  ,[AtpYearsWithObjectives]
		  ,[AtpTotalRaceCount]
		  ,[AtpAvgAnnualHours]
		  ,[WorkoutLibraryCount]
		  ,[MealLibraryCount]
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
		  ,[PlannedLoggedMealCount]
  		  ,[UnPlannedLoggedMealCount]
		  ,[MonthsAsAPremAthleteCount]
	 	  ,[ARR]
		  ,[LtsSubscription]
		  ,[LtsTrainingPlan]
  		  ,[LtsSoftware]
		  ,[LtsTotal]
		  ,[MostPopularDevice]
		  ,[TotalUploads]
		  ,[NumberOfDevices]
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
       	   a.MonthsOnSystem,
       	   a.MonthsActiveOnSystem,
           a.TrialPremiumSubCouponUsed, 
           a.AthleteSubscribesToDailyWoEmail,
           a.CoachedByPersonId, 
           b.BoughtWorkoutPlan,
           b.BoughtMealPlan,
           b.CoachSuppliedWorkoutPlan,
           b.CoachSuppliedMealPlan,
           c.AtpYearsWithGoals,
		   c.AtpYearsWithObjectives,
		   c.AtpTotalRaceCount,
		   c.AtpAvgAnnualHours,
		   d.WorkoutLibCount,
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
		   j.PlannedLoggedMealCount,
		   j.UnPlannedLoggedMealCount,
		   l.MonthsAsAPremAthleteCount,
		   m.ARR,
		   m.LtsSubscription,
		   m.LtsTrainingPlan,
		   m.LtsSoftware,
		   m.LtsTotal,
		   n.MostPopularDevice,
		   n.TotalUploads,
		   n.NumberOfDevices,
		   GETDATE()
    FROM #AthleteInfo As a Left Outer Join #PlanInfo             As b On a.PersonId=b.PersonId
                           Left Outer Join #AtpInfo              As c On a.PersonId=c.PersonId
                           Left Outer Join #WorkoutLibInfo       As d On a.PersonId=d.PersonId
                           Left Outer Join #MealLibInfo          As e On a.PersonId=e.PersonId
                           Left Outer Join #HrZoneThresholdInfo  As f On a.PersonId=f.PersonId
                           Left Outer Join #PwZoneThresholdInfo  As g On a.PersonId=g.PersonId
                           Left Outer Join #SpZoneThresholdInfo  As h On a.PersonId=h.PersonId
                           Left Outer Join #PodInfo              As i On a.PersonId=i.PersonId
                           Left Outer Join #MealInfo             As j On a.PersonId=j.PersonId
                           Left Outer Join #PremAthleteInfo      As l On a.PersonId=l.PersonId
                           Left Outer Join #LtsInfo              As m On a.PersonId=m.PersonId
                           Left Outer Join #DeviceInfo           As n On a.PersonId=n.PersonId

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
