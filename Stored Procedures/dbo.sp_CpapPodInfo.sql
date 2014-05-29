SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE PROCEDURE [dbo].[sp_CpapPodInfo] 
	@SourceDbName      Varchar(25),
	@DestinationDbName Varchar(25),
	@WhereCondition    Varchar(500)

AS
BEGIN
SET NOCOUNT ON;
DECLARE @Sql Varchar(3000)

Set @Sql = 
	   'Select *,
			Case When (DistanceByWeek_Day + DurationByWeek_Day + PMC + PeakPower + TimeinHRZones + FitnessHistory + TSSbyWeekDay + PowerProfile + TimeInHRZonesByWeek + GroceryList + PeakHearRate + TimeInPowerZones + TimeInPowerZonesByWeek + KJPerWeek + RaceReports + WeatherPod + LongestWorkoutDuration + LongestWorkoutDistance + PeakPace + PeakSpeed + PeakCadence + MicroNutrients + RoutesHistory + TimeInSpeedZonesByWeek + TimeInSpeedZones + PeakPaceByDistance + HealthVaultSync) > 0 OR FitnessSummary > 1 OR DailyCalories > 1 OR DailyMetrics > 1 
			Then 1 
			Else 0 
			End As HasCustomizedDashboard
		Into #PodsByPersonPlus
		From
			(
				Select PersonId, [3] As FitnessSummary, [2] As DailyCalories, [1] As Macronutrients, [15] As GettingStarted, [13] As DailyMetrics, [11] As DistanceByWeek_Day, 
								[10] As DurationByWeek_Day, [32] As PMC, [8] As PeakPower, [17] As TimeinHRZones, [35] As FitnessHistory, [23] As TSSbyWeekDay, [33] PowerProfile, 
								[18] As TimeInHRZonesByWeek, [14] As GroceryList, [28] As PeakHearRate, [24] As TimeInPowerZones, [25] As TimeInPowerZonesByWeek, [21] As KJPerWeek, [16] As RaceReports, [34] As WeatherPod, [20] As LongestWorkoutDuration, [19] As LongestWorkoutDistance, [31] As PeakPace, [30] As PeakSpeed, [29] As PeakCadence,
								[22] As MicroNutrients, [12] As RoutesHistory, [27] As TimeInSpeedZonesByWeek, [26] As TimeInSpeedZones,  [36] As PeakPaceByDistance, [4] As HealthVaultSync
				From
				(
					Select p.PersonId As PersonId, T.C.value(''(@type)[1]'', ''int'') As DashboardType
					From ' + @SourceDbName + '..PersonExtensionData ped Inner Join ' + @SourceDbName + '..Person p on p.PersonId = ped.PersonId
						Cross Apply Data.nodes(''user/perspective[@isDefaultFor="1" ][1]/pod'') As T(c)
					Where ' + @WhereCondition + ' And DataType = 3 And p.NumberOfVisits > 0
					union all
					select p.personid as personid, T.C.value(''(@type)[1]'', ''int'') as DashboardType
					From ' + @SourceDbName + '..PersonExtensionData ped Inner Join ' + @SourceDbName + '..Person p on p.PersonId = ped.PersonId
					cross apply Data.nodes(''user/perspective[1]/pod'') as T(c)
					Where ' + @WhereCondition + ' And DataType = 3 and p.NumberOfVisits > 0 and data.exist (''user/perspective[@isDefaultFor="1"]'') = 0
			) t
		pivot ( 
			Count(DAshboardType)
			For DAshboardType In ("3", "2", "1", "15", "13", "11", "10", "32", "8", "17",  "35", "23", "33", "18", "14", "28", "24", "25", "21", "16", "34", "20", "19", "31", "30", "29", "22", "12", "27", "26", "36", "4")
		) As pvt
		) As PodsByPerson

		Select * From #PodsByPersonPlus'

	EXEC(@Sql)
END



GO
