CREATE TABLE [dbo].[CpapCoach]
(
[CoachId] [int] NULL,
[CoachingGroupId] [int] NULL,
[AccountCreationDate] [smalldatetime] NULL,
[LastLogon] [datetime] NULL,
[NumberOfVisits] [int] NULL,
[UserType] [int] NULL,
[TotalTriathletes] [int] NULL,
[TotalRunners] [int] NULL,
[TotalCyclists] [int] NULL,
[TotalOtherSports] [int] NULL,
[TotalUserType1] [int] NULL,
[TotalUserType4] [int] NULL,
[TotalUserType6] [int] NULL,
[TotalNumberOfLogins] [int] NULL,
[NumberOfDaysSinceLastLogon] [int] NULL,
[TotalCoachedAthletes] [int] NULL,
[BoughtWorkoutPlan] [int] NULL,
[BoughtMealPlan] [int] NULL,
[BoughtNutritionAndWorkoutComboPlan] [int] NULL,
[BoughtWorkoutLibrary] [int] NULL,
[CoachSuppliedWorkoutPlan] [int] NULL,
[CoachSuppliedMealPlan] [int] NULL,
[AppliedPlanCount] [int] NULL,
[TotalAthletesPlannedMealCount] [int] NULL,
[TotalAthletesPlannedUnLoggedMealCount] [int] NULL,
[TotalAthletesPlannedLoggedMealCount] [int] NULL,
[TotalAthletesUnPlannedLoggedMealCount] [int] NULL,
[TotalAthletesPlannedMealMonths] [int] NULL,
[TotalAthletesPlannedUnLoggedMealMonths] [int] NULL,
[TotalAthletesPlannedLoggedMealMonths] [int] NULL,
[TotalAthletesUnPlannedLoggedMealMonths] [int] NULL,
[TotalAthletesRouteCount] [int] NULL,
[TotalAthleteWeightInKilogramsMetric] [int] NULL,
[TotalAthleteWithSleepQualityMetric] [int] NULL,
[TotalAthleteWithSleepHoursMetric] [int] NULL,
[TotalAthleteWithFatigueMetric] [int] NULL,
[TotalAthleteWithSorenessMetric] [int] NULL,
[TotalAthleteWithStressMetric] [int] NULL,
[TotalAthleteWithPulseMetric] [int] NULL,
[TotalAthleteWithSleepElevationInMetersMetric] [int] NULL,
[TotalAthleteWithOverallFeelingMetric] [int] NULL,
[TotalAthleteWithPercentFatMetric] [int] NULL,
[TotalAthleteThatHaveLapse] [int] NULL,
[TotalAthleteThatHaveNewSale] [int] NULL,
[TotalAthleteThatHaveRenewSale] [int] NULL,
[TotalAthleteThatHaveRecurSale] [int] NULL,
[TotalTermOfNewSale] [int] NULL,
[CoachedAthleteSubscribesToDailyWoEmail] [float] NULL,
[CoachedAthleteAllowMarketingEmails] [float] NULL,
[CoachedAthleteThresholdsNotify] [float] NULL,
[CoachedAthleteThresholdsAutoApply] [float] NULL,
[CoachedAthletesWithHrZoneThreshold] [int] NULL,
[CoachedAthletesWithPwZoneThreshold] [int] NULL,
[CoachedAthletesWithSpZoneThreshold] [int] NULL,
[CoachedAthleteFitnessSummary] [float] NULL,
[CoachedAthleteDailyCalories] [float] NULL,
[CoachedAthleteMacronutrients] [float] NULL,
[CoachedAthleteGettingStarted] [float] NULL,
[CoachedAthleteDailyMetrics] [float] NULL,
[CoachedAthleteDistanceByWeek_Day] [float] NULL,
[CoachedAthleteDurationByWeek_Day] [float] NULL,
[CoachedAthletePMC] [float] NULL,
[CoachedAthletePeakPower] [float] NULL,
[CoachedAthleteTimeinHRZones] [float] NULL,
[CoachedAthleteFitnessHistory] [float] NULL,
[CoachedAthleteTSSbyWeekDay] [float] NULL,
[CoachedAthletePowerProfile] [float] NULL,
[CoachedAthleteTimeInHRZonesByWeek] [float] NULL,
[CoachedAthleteGroceryList] [float] NULL,
[CoachedAthletePeakHearRate] [float] NULL,
[CoachedAthleteTimeInPowerZones] [float] NULL,
[CoachedAthleteTimeInPowerZonesByWeek] [float] NULL,
[CoachedAthleteKJPerWeek] [float] NULL,
[CoachedAthleteRaceReports] [float] NULL,
[CoachedAthleteWeatherPod] [float] NULL,
[CoachedAthleteLongestWorkoutDuration] [float] NULL,
[CoachedAthleteLongestWorkoutDistance] [float] NULL,
[CoachedAthletePeakPace] [float] NULL,
[CoachedAthletePeakSpeed] [float] NULL,
[CoachedAthletePeakCadence] [float] NULL,
[CoachedAthleteMicroNutrients] [float] NULL,
[CoachedAthleteRoutesHistory] [float] NULL,
[CoachedAthleteTimeInSpeedZonesByWeek] [float] NULL,
[CoachedAthleteTimeInSpeedZones] [float] NULL,
[CoachedAthletePeakPaceByDistance] [float] NULL,
[CoachedAthleteHealthVaultSync] [float] NULL,
[CoachedAthleteHasCustomizedDashboard] [float] NULL,
[CoachedAthleteLtsSubscription] [float] NULL,
[CoachedAthleteLtsTrainingPlan] [float] NULL,
[CoachedAthleteLtsSoftware] [float] NULL,
[CoachedAthleteLtsLibrary] [float] NULL,
[CoachedAthleteLtsTotal] [float] NULL,
[DateAdded] [datetime] NOT NULL
) ON [PRIMARY]
GO
