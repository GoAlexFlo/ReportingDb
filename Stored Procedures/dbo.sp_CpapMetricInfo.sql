SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_CpapMetricInfo] 
	@SourceDbName      Varchar(25),
	@DestinationDbName Varchar(25),
	@WhereCondition Varchar(500),
	@WhereConditionYear Varchar(4)
	
AS
BEGIN
SET NOCOUNT ON;
DECLARE @Sql Varchar(2000)

Set @Sql =
	   'BEGIN
			With XMLNAMESPACES 
			(
			''http://www.w3.org/2001/XMLSchema-instance'' As p2
			), PrepInfo As
			 (
				 Select PersonId,
					   v.value(''./@p2:type'', ''varchar(30)'') As Metric,
					   Cast(CASE WHEN (v.exist(''./Systolic'') = 1 and v.exist(''./Diastolic'') = 1) 
							THEN cast(v.query(''./Systolic/text()'') As varchar(25)) + ''/'' +  cast(v.query(''./Diastolic/text()'') As varchar(25))
							ELSE cast(v.query(''./Value/text()'') As varchar(25))
							END As float) As Value
				 From ' + @SourceDbName + '..TimedMetrics 
				 cross apply TimedMetricValues.nodes(''//MetricBase'') TM(v)
				 Where YEAR([TimeStamp])>=' + @WhereConditionYear + ' And  
					   v.value(''./@p2:type'', ''varchar(30)'') In (''WeightInKilogramsMetric'', ''SleepQualityMetric'', ''SleepHoursMetric'', ''FatigueMetric'', ''SorenessMetric'', 
																  ''StressMetric'', ''PulseMetric'', ''SleepElevationInMetersMetric'', ''OverallFeelingMetric'', ''PercentFatMetric'')
			 )
				
				
			   Select [PersonId], IsNull([WeightInKilogramsMetric],0) As ''WeightInKilogramsMetric'', IsNull([SleepQualityMetric],0) As ''SleepQualityMetric'', 
								  IsNull([SleepHoursMetric],0) As ''SleepHoursMetric'', IsNull([FatigueMetric],0) As ''FatigueMetric'', IsNull([SorenessMetric],0) As ''SorenessMetric'', 
								  IsNull([StressMetric],0) As ''StressMetric'', IsNull([PulseMetric],0) As ''PulseMetric'', IsNull([SleepElevationInMetersMetric],0) As ''SleepElevationInMetersMetric'', 
								  IsNull([OverallFeelingMetric],0) As ''OverallFeelingMetric'', IsNull([PercentFatMetric],0) As ''PercentFatMetric'' 
			   From
				(Select PersonId, Metric, Case When Value>0 Then 1 Else 0 End As Value From [PrepInfo]) As d
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
