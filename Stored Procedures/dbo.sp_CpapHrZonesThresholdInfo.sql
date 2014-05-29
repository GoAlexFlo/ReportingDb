SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_CpapHrZonesThresholdInfo] 
	@SourceDbName      Varchar(25),
	@DestinationDbName Varchar(25),
	@WhereCondition Varchar(500)
AS
BEGIN
SET NOCOUNT ON;
DECLARE @Sql Varchar(3000)
-- Is HeartRate Zone Threshold the System Default?
SET @Sql =
		'BEGIN
			With AthleteInfo 
			As
			( 
				SELECT Distinct p.PersonId
				FROM ' + @SourceDbName + '..Person As p Inner Join ' + @SourceDbName + '..Athlete As a On p.PersonId = a.PersonId
				WHERE ' + @WhereCondition + '
			)
			-- Determine Either Default, NotDefault 
		      Select Distinct a.PersonId, ''NotDefault'' As HeartRateZoneDefault
			  From AthleteInfo As a Inner Join ' + @SourceDbName + '..HeartRateZonesForPerson As hr On a.PersonId=hr.PersonId
		      Where (Select Count(*) From ' + @SourceDbName + '..HeartRateZonesForPerson Where PersonId=a.PersonId)>1

		      Union All 
		      Select a.PersonId, 
					 Case 
						When WorkoutTypeId = 0 And MaximumHeartRate=190 
											   And ThresholdHeartRate=150 
											   And Zone1Floor=60
											   And Zone1Ceiling=85
											   And Zone2Floor=86
											   And Zone2Ceiling=111
											   And Zone3Floor=112
											   And Zone3Ceiling=137
											   And Zone4Floor=138
											   And Zone4Ceiling = 163
											   And Zone5Floor=164
											   And Zone5Ceiling=190
											   And RestingHeartRate=60
						Then ''Default''
						Else ''NotDefault''
						End As HeartRateZoneDefault
			  From AthleteInfo As a Inner Join ' + @SourceDbName + '..HeartRateZonesForPerson As hr On a.PersonId=hr.PersonId
		      Where (Select Count(*) From ' + @SourceDbName + '..HeartRateZonesForPerson Where PersonId=a.PersonId)=1
		END'
		EXEC(@Sql)
END

GO
