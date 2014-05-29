SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CpapCoachUserTypeMain] 
	@SourceDbName      Varchar(25),
	@DestinationDbName Varchar(25),
	@WhereConditionYear Varchar(4)
AS
BEGIN
		SET NOCOUNT ON;
		DECLARE @WhereCondition Varchar(100) = 'p.Usertype in (1,4,6) And p.PersonId Not In (349077, 114420)'

			   EXEC sp_CpapGenCoachedAthleteInfo @SourceDbName, @DestinationDbName
			   CREATE TABLE #CoachedAthleteInfo (CoachId INT, CoachingGroupId INT, AthleteUserType VARCHAR(10), TotalTriathletes INT, TotalRunners INT, TotalCyclists INT,   
			                                     TotalOtherSports INT, TotalNumberOfLogins INT, NumberOfDaysSinceLastLogon INT, TotalCoachedAthletes INT)
			   INSERT Into #CoachedAthleteInfo
			   EXEC sp_CpapCoachedUserTypeAthleteInfo  @SourceDbName, @DestinationDbName

			   CREATE TABLE #PlanInfo (CoachId INT, AthleteUserType VARCHAR(10), BoughtWorkoutPlan INT, BoughtMealPlan INT, 
									   BoughtNutritionAndWorkoutComboPlan INT, BoughtWorkoutLibrary INT,
									   CoachSuppliedWorkoutPlan INT, CoachSuppliedMealPlan INT, AppliedPlanCount INT)
			   INSERT Into #PlanInfo
			   EXEC sp_CpapCoachUserTypePlanInfo  @SourceDbName, @DestinationDbName, @WhereConditionYear 
	   
			   CREATE TABLE #CoachedAthleteMealInfo (CoachId INT, AthleteUserType VARCHAR(10), 
			                                         TotalAthletesPlannedMealCount INT,  TotalAthletesPlannedUnLoggedMealCount INT, 
			                                         TotalAthletesPlannedLoggedMealCount INT, TotalAthletesUnPlannedLoggedMealCount INT,  
	                                                 TotalAthletesPlannedMealMonths INT, TotalAthletesPlannedUnLoggedMealMonths INT, 
	                                                 TotalAthletesPlannedLoggedMealMonths INT, TotalAthletesUnPlannedLoggedMealMonths INT)
			   INSERT Into #CoachedAthleteMealInfo
			   EXEC dbo.sp_CpapCoachMealInfo @SourceDbName, @DestinationDbName
	   
			  CREATE TABLE #CoachedAthleteRouteInfo (CoachId INT, AthleteUserType VARCHAR(10), TotalAthletesRouteCount INT)
			  INSERT Into #CoachedAthleteRouteInfo
			  EXEC sp_CpapCoachRouteInfo @SourceDbName, @DestinationDbName
	  
		     
		     
		      CREATE TABLE #CoachedAthleteMetricInfo (CoachId INT, AthleteUserType VARCHAR(10), 
		                                WeightInKilogramsMetric INT, SleepQualityMetric INT, SleepHoursMetric INT, FatigueMetric INT, SorenessMetric INT, 
				                        StressMetric INT, PulseMetric INT, SleepElevationInMetersMetric INT, OverallFeelingMetric INT, PercentFatMetric INT)
			  INSERT Into #CoachedAthleteMetricInfo
			  EXEC sp_CpapCoachedAthleteUserTypeMetricInfo @SourceDbName, @DestinationDbName

   			 
   			 
   			 CREATE TABLE #SubTransDescInfo (CoachId INT, PersonId INT, CoachedFromDate DATE, CoachedToDate DATE, LapseCount INT, NewSaleCount INT, 
   			                                 RenewSaleCount INT, RecurSaleCount INT, TermOfNew INT, DaysSinceLastPremSub INT)
			 INSERT Into #SubTransDescInfo
			 EXEC sp_CpapCoachSubTransInfo @SourceDbName, @DestinationDbName
			 
			 Select * Into #CoachedAthleteSubTransDescInfo From 
			 (Select CoachId
			   		,Sum(Case When LapseCount>0 Then 1 Else 0 End) As TotalAthleteThatHaveLapse
					,Sum(Case When RenewSaleCount>0 Then 1 Else 0 End) As TotalAthleteThatHaveRenewSale
					,Sum(Case When RecurSaleCount>0 Then 1 Else 0 End) As TotalAthleteThatHaveRecurSale
					,Sum(NewSaleCount) As TotalAthleteThatHaveNewSale
					,Sum(TermOfNew) As TotalTermOfNewSale
		      From #SubTransDescInfo As s 
		      Group By CoachId
		      ) As d;
	
	  CREATE TABLE #AthleteInfo (PersonId INT, AccountCreationDate Datetime, LastLogon datetime, NumberOfVisits INT, UserType INT, AthleteType INT, 
                                  AthleteTypeDesc varchar(20), Age FLOAT, Sex varchar(2), CoachedByPersonId INT, AffiliateId INT, TrialPremiumSubCouponUsed INT, 
                                  HasPaypalTrans FLOAT, AthleteSubscribesToDailyWoEmail FLOAT, AllowMarketingEmails FLOAT, ThresholdsNotifyAthlete FLOAT, ThresholdsAutoApply FLOAT, 
                                  DaysToPremSub INT, FirstPremTerm INT)
	   INSERT INTO #AthleteInfo
	   EXEC sp_CpapAthleteInfo @SourceDbName, @DestinationDbName, @WhereCondition, @WhereConditionYear 
	   Select * Into #CoachedAthleteIndicatorInfo From 
			 (Select a.CoachedByPersonId As CoachId
			   		,Sum(Convert(float, a.AthleteSubscribesToDailyWoEmail))/COUNT(*) As CoachedAthleteSubscribesToDailyWoEmail
			   		,Sum(Convert(float, a.AllowMarketingEmails))/COUNT(*) As CoachedAthleteAllowMarketingEmails
			   		,Sum(Convert(float, a.ThresholdsNotifyAthlete))/COUNT(*) As CoachedAthleteThresholdsNotify
			   		,Sum(Convert(float, a.ThresholdsAutoApply))/COUNT(*) As CoachedAthleteThresholdsAutoApply
		      From #AthleteInfo As a 
		--    Where a.AccountCreationDate>='2013-11-14' -- Bill Asked that we include all activity given that the columns selected do not have a datetimestamp associated
		      Group By a.CoachedByPersonId
		      ) As d1;	
	      
	   CREATE TABLE #HrZoneThresholdInfo (PersonId int, HrZoneThresholdDefault varchar(15))
	   INSERT INTO #HrZoneThresholdInfo
	   EXEC sp_CpapHrZonesThresholdInfo @SourceDbName, @DestinationDbName, @WhereCondition
	   
	   Select * Into #CoachedAthleteHrZoneThresholdInfo From 
			 (Select a.CoachedByPersonId As CoachId
			   		,Sum(Case When HrZoneThresholdDefault ='Default' Then 0 Else 1 End)/Count(*) As CoachedAthletesWithHrZoneThreshold
		      From #HrZoneThresholdInfo As h Inner Join ultrafit_live..Athlete As a On h.PersonId=a.PersonId
		                                     Inner Join ultrafit_live..Person As p On h.PersonId=p.PersonId
		--    Where a.AccountCreationDate>='2013-11-14' -- Bill Asked that we include all activity given that the columns selected do not have a datetimestamp associated
		      Group By a.CoachedByPersonId
		      ) As d2;	

	   CREATE TABLE #PwZoneThresholdInfo (PersonId int, PwZoneThresholdDefault varchar(15))
	   INSERT INTO #PwZoneThresholdInfo
	   EXEC sp_CpapPwZonesThresholdInfo @SourceDbName, @DestinationDbName, @WhereCondition
	   Select * Into #CoachedAthletePwZoneThresholdInfo From 
			 (Select a.CoachedByPersonId As CoachId
			   		,Sum(Case When PwZoneThresholdDefault ='Default' Then 0 Else 1 End)/Count(*) As CoachedAthletesWithPwZoneThreshold
		      From #PwZoneThresholdInfo As h Inner Join ultrafit_live..Athlete As a On h.PersonId=a.PersonId
		                                     Inner Join ultrafit_live..Person As p On h.PersonId=p.PersonId
		--    Where a.AccountCreationDate>='2013-11-14' -- Bill Asked that we include all activity given that the columns selected do not have a datetimestamp associated
		      Group By a.CoachedByPersonId
		      ) As d3;	

	   CREATE TABLE #SpZoneThresholdInfo (PersonId int, SpZoneThresholdDefault varchar(15))
	   INSERT INTO #SpZoneThresholdInfo
	   EXEC sp_CpapSpZonesThresholdInfo @SourceDbName, @DestinationDbName, @WhereCondition
	   Select * Into #CoachedAthleteSpZoneThresholdInfo From 
			 (Select a.CoachedByPersonId As CoachId
			   		,Sum(Case When SpZoneThresholdDefault ='Default' Then 0 Else 1 End)/Count(*) As CoachedAthletesWithSpZoneThreshold
		      From #SpZoneThresholdInfo As h Inner Join ultrafit_live..Athlete As a On h.PersonId=a.PersonId
		                                     Inner Join ultrafit_live..Person As p On h.PersonId=p.PersonId
		--    Where a.AccountCreationDate>='2013-11-14' -- Bill Asked that we include all activity given that the columns selected do not have a datetimestamp associated
		      Group By a.CoachedByPersonId
		      ) As d4;

	   CREATE TABLE #PodInfo (PersonId INT, FitnessSummary  INT, DailyCalories  INT, Macronutrients INT, GettingStarted INT, DailyMetrics INT, DistanceByWeek_Day INT, 
					DurationByWeek_Day INT, PMC INT, PeakPower INT, TimeinHRZones INT, FitnessHistory INT, TSSbyWeekDay INT, PowerProfile INT, 
					TimeInHRZonesByWeek INT, GroceryList INT, PeakHearRate INT, TimeInPowerZones INT, TimeInPowerZonesByWeek INT, KJPerWeek INT, RaceReports INT, WeatherPod INT, 
					LongestWorkoutDuration INT, LongestWorkoutDistance INT, PeakPace INT, PeakSpeed INT,  PeakCadence INT,
					MicroNutrients INT, RoutesHistory INT, TimeInSpeedZonesByWeek INT, TimeInSpeedZones INT,  PeakPaceByDistance INT, HealthVaultSync INT,  HasCustomizedDashboard INT)
	   INSERT INTO #PodInfo
	   EXEC sp_CpapPodInfo @SourceDbName, @DestinationDbName, @WhereCondition 
	   
	   Select * Into #CoachedAthletePodInfo From 
			 (Select a.CoachedByPersonId As CoachId,
			   		Sum(FitnessSummary)/Count(*) As CoachedAthleteFitnessSummary, 
					Sum(DailyCalories)/Count(*) As CoachedAthleteDailyCalories,
					Sum(Macronutrients)/Count(*) As CoachedAthleteMacronutrients,
					Sum(GettingStarted)/Count(*) As CoachedAthleteGettingStarted,
					Sum(DailyMetrics)/Count(*) As CoachedAthleteDailyMetrics,
					Sum(DistanceByWeek_Day)/Count(*) As CoachedAthleteDistanceByWeek_Day,
					Sum(DurationByWeek_Day)/Count(*) As CoachedAthleteDurationByWeek_Day,
					Sum(PMC)/Count(*) As CoachedAthletePMC,
					Sum(PeakPower)/Count(*) As CoachedAthletePeakPower,
					Sum(TimeinHRZones)/Count(*) As CoachedAthleteTimeinHRZones,
					Sum(FitnessHistory)/Count(*) As CoachedAthleteFitnessHistory,
					Sum(TSSbyWeekDay)/Count(*) As CoachedAthleteTSSbyWeekDay,
					Sum(PowerProfile)/Count(*) As CoachedAthletePowerProfile,
					Sum(TimeInHRZonesByWeek)/Count(*) As CoachedAthleteTimeInHRZonesByWeek,
					Sum(GroceryList)/Count(*) As CoachedAthleteGroceryList,
					Sum(PeakHearRate)/Count(*) As CoachedAthletePeakHearRate,
					Sum(TimeInPowerZones)/Count(*) As CoachedAthleteTimeInPowerZones,
					Sum(TimeInPowerZonesByWeek)/Count(*) As CoachedAthleteTimeInPowerZonesByWeek,
					Sum(KJPerWeek)/Count(*) As CoachedAthleteKJPerWeek,
					Sum(RaceReports)/Count(*) As CoachedAthleteRaceReports,
					Sum(WeatherPod)/Count(*) As CoachedAthleteWeatherPod,
					Sum(LongestWorkoutDuration)/Count(*) As CoachedAthleteLongestWorkoutDuration,
					Sum(LongestWorkoutDistance)/Count(*) As CoachedAthleteLongestWorkoutDistance,
					Sum(PeakPace)/Count(*) As CoachedAthletePeakPace,
					Sum(PeakSpeed)/Count(*) As CoachedAthletePeakSpeed,
					Sum(PeakCadence)/Count(*) As CoachedAthletePeakCadence,
					Sum(MicroNutrients)/Count(*) As CoachedAthleteMicroNutrients,
					Sum(RoutesHistory)/Count(*) As CoachedAthleteRoutesHistory,
					Sum(TimeInSpeedZonesByWeek)/Count(*) As CoachedAthleteTimeInSpeedZonesByWeek,
					Sum(TimeInSpeedZones)/Count(*) As CoachedAthleteTimeInSpeedZones,
					Sum(PeakPaceByDistance)/Count(*) As CoachedAthletePeakPaceByDistance,
					Sum(HealthVaultSync)/Count(*) As CoachedAthleteHealthVaultSync,
					Sum(HasCustomizedDashboard)/Count(*) As CoachedAthleteHasCustomizedDashboard 
		      From #PodInfo As h Inner Join ultrafit_live..Athlete As a On h.PersonId=a.PersonId
		                         Inner Join ultrafit_live..Person As p On h.PersonId=p.PersonId
		--    Where a.AccountCreationDate>='2013-11-14' -- Bill Asked that we include all activity given that the columns selected do not have a datetimestamp associated
		      Group By a.CoachedByPersonId
		      ) As d5;  
		      
		    CREATE TABLE #CoachLtsInfo (CoachId int, TotalCoachedAthletes int, LtsSubscription float, LtsTrainingPlan float, LtsSoftware float, LtsLibrary float, LtsTotal float)
			INSERT INTO #CoachLtsInfo
			EXEC sp_CpapCoachLtsInfo @SourceDbName, @DestinationDbName
            
          --DROP TABLE [Reporting].[dbo].[CpapCoach]
            TRUNCATE TABLE [Reporting]..[CpapCoach];
			INSERT INTO [Reporting].[dbo].[CpapCoach]
           ([CoachId]
           ,[CoachingGroupId]
           ,[AccountCreationDate]
           ,[LastLogon]
           ,[NumberOfVisits]
           ,[UserType]
           ,[TotalTriathletes]
           ,[TotalRunners]
           ,[TotalCyclists]
           ,[TotalOtherSports]
           ,[TotalUserType1]
           ,[TotalUserType4]
           ,[TotalUserType6]
           ,[TotalNumberOfLogins]
           ,[NumberOfDaysSinceLastLogon]
           ,[TotalCoachedAthletes]
           ,[BoughtWorkoutPlan]
           ,[BoughtMealPlan]
           ,[BoughtNutritionAndWorkoutComboPlan]
           ,[BoughtWorkoutLibrary]
           ,[CoachSuppliedWorkoutPlan]
           ,[CoachSuppliedMealPlan]
           ,[AppliedPlanCount]
           ,[TotalAthletesPlannedMealCount]
           ,[TotalAthletesPlannedUnLoggedMealCount]
           ,[TotalAthletesPlannedLoggedMealCount]
           ,[TotalAthletesUnPlannedLoggedMealCount]
           ,[TotalAthletesPlannedMealMonths]
           ,[TotalAthletesPlannedUnLoggedMealMonths]
           ,[TotalAthletesPlannedLoggedMealMonths]
           ,[TotalAthletesUnPlannedLoggedMealMonths]
           ,[TotalAthletesRouteCount]
           ,[TotalAthleteWeightInKilogramsMetric]
           ,[TotalAthleteWithSleepQualityMetric]
           ,[TotalAthleteWithSleepHoursMetric]
           ,[TotalAthleteWithFatigueMetric]
           ,[TotalAthleteWithSorenessMetric]
           ,[TotalAthleteWithStressMetric]
           ,[TotalAthleteWithPulseMetric]
           ,[TotalAthleteWithSleepElevationInMetersMetric]
           ,[TotalAthleteWithOverallFeelingMetric]
           ,[TotalAthleteWithPercentFatMetric]
           ,[TotalAthleteThatHaveLapse]
           ,[TotalAthleteThatHaveNewSale]
           ,[TotalAthleteThatHaveRenewSale]
           ,[TotalAthleteThatHaveRecurSale]
           ,[TotalTermOfNewSale]
           ,[CoachedAthleteSubscribesToDailyWoEmail]
           ,[CoachedAthleteAllowMarketingEmails]
           ,[CoachedAthleteThresholdsNotify]
           ,[CoachedAthleteThresholdsAutoApply]
           ,[CoachedAthletesWithHrZoneThreshold]
           ,[CoachedAthletesWithPwZoneThreshold]
           ,[CoachedAthletesWithSpZoneThreshold]
           ,[CoachedAthleteFitnessSummary]
           ,[CoachedAthleteDailyCalories]
           ,[CoachedAthleteMacronutrients]
           ,[CoachedAthleteGettingStarted]
           ,[CoachedAthleteDailyMetrics]
           ,[CoachedAthleteDistanceByWeek_Day]
           ,[CoachedAthleteDurationByWeek_Day]
           ,[CoachedAthletePMC]
           ,[CoachedAthletePeakPower]
           ,[CoachedAthleteTimeinHRZones]
           ,[CoachedAthleteFitnessHistory]
           ,[CoachedAthleteTSSbyWeekDay]
           ,[CoachedAthletePowerProfile]
           ,[CoachedAthleteTimeInHRZonesByWeek]
           ,[CoachedAthleteGroceryList]
           ,[CoachedAthletePeakHearRate]
           ,[CoachedAthleteTimeInPowerZones]
           ,[CoachedAthleteTimeInPowerZonesByWeek]
           ,[CoachedAthleteKJPerWeek]
           ,[CoachedAthleteRaceReports]
           ,[CoachedAthleteWeatherPod]
           ,[CoachedAthleteLongestWorkoutDuration]
           ,[CoachedAthleteLongestWorkoutDistance]
           ,[CoachedAthletePeakPace]
           ,[CoachedAthletePeakSpeed]
           ,[CoachedAthletePeakCadence]
           ,[CoachedAthleteMicroNutrients]
           ,[CoachedAthleteRoutesHistory]
           ,[CoachedAthleteTimeInSpeedZonesByWeek]
           ,[CoachedAthleteTimeInSpeedZones]
           ,[CoachedAthletePeakPaceByDistance]
           ,[CoachedAthleteHealthVaultSync]
           ,[CoachedAthleteHasCustomizedDashboard]
           ,[CoachedAthleteLtsSubscription]
           ,[CoachedAthleteLtsTrainingPlan]
           ,[CoachedAthleteLtsSoftware]
           ,[CoachedAthleteLtsLibrary]
           ,[CoachedAthleteLtsTotal]
           ,[DateAdded])
			SELECT a.PersonId As CoachId,
			       b.CoachingGroupId, 
				   a.AccountCreationDate,
				   a.LastLogon,
				   a.NumberOfVisits,
				   a.UserType,
				   b.TotalTriathletes,  
				   b.TotalRunners,  
				   b.TotalCyclists,  
				   b.TotalOtherSports, 
				   b.TotalUserType1,  
				   b.TotalUserType4, 
				   b.TotalUserType6,
				   b.TotalNumberOfLogins,
				   b.NumberOfDaysSinceLastLogon,
				   b.TotalCoachedAthletes,
				   c.BoughtWorkoutPlan,
				   c.BoughtMealPlan,
				   c.BoughtNutritionAndWorkoutComboPlan,
				   c.BoughtWorkoutLibrary,
				   c.CoachSuppliedWorkoutPlan,
				   c.CoachSuppliedMealPlan,
				   c.AppliedPlanCount,
				   d.TotalAthletesPlannedMealCount,
				   d.TotalAthletesPlannedUnLoggedMealCount,
				   d.TotalAthletesPlannedLoggedMealCount,
				   d.TotalAthletesUnPlannedLoggedMealCount,
				   d.TotalAthletesPlannedMealMonths,
				   d.TotalAthletesPlannedUnLoggedMealMonths,
				   d.TotalAthletesPlannedLoggedMealMonths,
				   d.TotalAthletesUnPlannedLoggedMealMonths,
				   e.TotalAthletesRouteCount,
				   f.TotalAthleteWeightInKilogramsMetric,
				   f.TotalAthleteWithSleepQualityMetric,
				   f.TotalAthleteWithSleepHoursMetric,
				   f.TotalAthleteWithFatigueMetric,
				   f.TotalAthleteWithSorenessMetric,
				   f.TotalAthleteWithStressMetric,
				   f.TotalAthleteWithPulseMetric,
				   f.TotalAthleteWithSleepElevationInMetersMetric,
				   f.TotalAthleteWithOverallFeelingMetric,
				   f.TotalAthleteWithPercentFatMetric,
				   g.TotalAthleteThatHaveLapse,
				   g.TotalAthleteThatHaveNewSale,
				   g.TotalAthleteThatHaveRenewSale,
				   g.TotalAthleteThatHaveRecurSale,
				   g.TotalTermOfNewSale,
				   h.CoachedAthleteSubscribesToDailyWoEmail,
				   h.CoachedAthleteAllowMarketingEmails,
				   h.CoachedAthleteThresholdsNotify,
				   h.CoachedAthleteThresholdsAutoApply,
				   i.CoachedAthletesWithHrZoneThreshold,
				   j.CoachedAthletesWithPwZoneThreshold,
				   k.CoachedAthletesWithSpZoneThreshold,
				   l.CoachedAthleteFitnessSummary, 
				   l.CoachedAthleteDailyCalories,
				   l.CoachedAthleteMacronutrients,
				   l.CoachedAthleteGettingStarted,
			       l.CoachedAthleteDailyMetrics,
				   l.CoachedAthleteDistanceByWeek_Day,
				   l.CoachedAthleteDurationByWeek_Day,
				   l.CoachedAthletePMC,
				   l.CoachedAthletePeakPower,
				   l.CoachedAthleteTimeinHRZones,
				   l.CoachedAthleteFitnessHistory,
				   l.CoachedAthleteTSSbyWeekDay,
				   l.CoachedAthletePowerProfile,
				   l.CoachedAthleteTimeInHRZonesByWeek,
				   l.CoachedAthleteGroceryList,
				   l.CoachedAthletePeakHearRate,
				   l.CoachedAthleteTimeInPowerZones,
				   l.CoachedAthleteTimeInPowerZonesByWeek,
				   l.CoachedAthleteKJPerWeek,
				   l.CoachedAthleteRaceReports,
				   l.CoachedAthleteWeatherPod,
				   l.CoachedAthleteLongestWorkoutDuration,
				   l.CoachedAthleteLongestWorkoutDistance,
				   l.CoachedAthletePeakPace,
				   l.CoachedAthletePeakSpeed,
				   l.CoachedAthletePeakCadence,
				   l.CoachedAthleteMicroNutrients,
				   l.CoachedAthleteRoutesHistory,
				   l.CoachedAthleteTimeInSpeedZonesByWeek,
				   l.CoachedAthleteTimeInSpeedZones,
				   l.CoachedAthletePeakPaceByDistance,
				   l.CoachedAthleteHealthVaultSync,
				   l.CoachedAthleteHasCustomizedDashboard,
				   CASE WHEN m.LtsTotal > 0 THEN m.LtsSubscription/m.TotalCoachedAthletes ELSE Null END, 
				   CASE WHEN m.LtsTotal > 0 THEN m.LtsTrainingPlan/m.TotalCoachedAthletes ELSE Null END, 
				   CASE WHEN m.LtsTotal > 0 THEN m.LtsSoftware/m.TotalCoachedAthletes ELSE Null END,
				   CASE WHEN m.LtsTotal > 0 THEN m.LtsLibrary/m.TotalCoachedAthletes ELSE Null END, 
				   CASE WHEN m.LtsTotal > 0 THEN m.LtsTotal/m.TotalCoachedAthletes ELSE Null END, 
				   GETDATE() As DateAdded
			FROM  #CoachedAthleteInfo As b Left Outer Join ultrafit_Live..Person		      As a On b.coachId=a.PersonId
										   Left Outer Join #PlanInfo					      As c On b.CoachId=c.CoachId  
										   Left Outer Join #CoachedAthleteMealInfo		      As d On b.CoachId=d.CoachId  
										   Left Outer Join #CoachedAthleteRouteInfo		      As e On b.CoachId=e.CoachId
										   Left Outer Join #CoachedAthleteMetricInfo	      As f On b.CoachId=f.CoachId 
										   Left Outer Join #CoachedAthleteSubTransDescInfo    As g On b.CoachId=g.CoachId 
										   Left Outer Join #CoachedAthleteIndicatorInfo       As h On b.CoachId=h.CoachId 
										   Left Outer Join #CoachedAthleteHrZoneThresholdInfo As i On b.CoachId=i.CoachId
										   Left Outer Join #CoachedAthletePwZoneThresholdInfo As j On b.CoachId=j.CoachId
										   Left Outer Join #CoachedAthleteSpZoneThresholdInfo As k On b.CoachId=k.CoachId
										   Left Outer Join #CoachedAthletePodInfo             As l On b.CoachId=l.CoachId
										   Left Outer Join #CoachLtsInfo                      As m On b.CoachId=m.CoachId
END



GO
