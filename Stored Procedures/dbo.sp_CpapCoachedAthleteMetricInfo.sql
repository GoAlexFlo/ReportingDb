SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_CpapCoachedAthleteMetricInfo] 
	@SourceDbName      Varchar(25),
	@DestinationDbName Varchar(25)
	
AS
BEGIN
SET NOCOUNT ON;
DECLARE @Sql Varchar(3000)

Set @Sql =
	   'BEGIN
			With XMLNAMESPACES 
			(
			''http://www.w3.org/2001/XMLSchema-instance'' As p2
			), PrepInfo As
			 (
				 Select c.PersonId, c.CoachId, c.CoachedFromDate, c.CoachedToDate,
					   v.value(''./@p2:type'', ''varchar(30)'') As Metric,
					   Cast(CASE WHEN (v.exist(''./Systolic'') = 1 and v.exist(''./Diastolic'') = 1) 
							THEN cast(v.query(''./Systolic/text()'') As varchar(25)) + ''/'' +  cast(v.query(''./Diastolic/text()'') As varchar(25))
							ELSE cast(v.query(''./Value/text()'') As varchar(25))
							END As float) As Value
				 From ' + @DestinationDbName + '..CoachedAthletes As c Inner Join ' + @SourceDbName + '..TimedMetrics As t 
				      on c.PersonId=t.PersonId And Convert(Date,DateCreated) Between c.CoachedFromDate And  c.CoachedToDate
				 cross apply TimedMetricValues.nodes(''//MetricBase'') TM(v)
				 Where v.value(''./@p2:type'', ''varchar(30)'') In (''WeightInKilogramsMetric'', ''SleepQualityMetric'', ''SleepHoursMetric'', ''FatigueMetric'', ''SorenessMetric'', 
																  ''StressMetric'', ''PulseMetric'', ''SleepElevationInMetersMetric'', ''OverallFeelingMetric'', ''PercentFatMetric'')
			 )
				
				
			   Select [CoachId], [PersonId], [CoachedFromDate], [CoachedToDate], IsNull([WeightInKilogramsMetric],0) As ''WeightInKilogramsMetric'', IsNull([SleepQualityMetric],0) As ''SleepQualityMetric'', 
								  IsNull([SleepHoursMetric],0) As ''SleepHoursMetric'', IsNull([FatigueMetric],0) As ''FatigueMetric'', IsNull([SorenessMetric],0) As ''SorenessMetric'', 
								  IsNull([StressMetric],0) As ''StressMetric'', IsNull([PulseMetric],0) As ''PulseMetric'', IsNull([SleepElevationInMetersMetric],0) As ''SleepElevationInMetersMetric'', 
								  IsNull([OverallFeelingMetric],0) As ''OverallFeelingMetric'', IsNull([PercentFatMetric],0) As ''PercentFatMetric'' 
			   From
				(Select CoachId, PersonId, CoachedFromDate, CoachedToDate, Metric, Case When Value>0 Then 1 Else 0 End As Value From [PrepInfo]) As d
			PIVOT
			(
				Sum(Value)
				For Metric IN ([WeightInKilogramsMetric], [SleepQualityMetric], [SleepHoursMetric], [FatigueMetric], [SorenessMetric], 
							   [StressMetric], [PulseMetric], [SleepElevationInMetersMetric], [OverallFeelingMetric], [PercentFatMetric])
			) As PivotTable
		END'
		EXEC(@Sql)
END



GO
