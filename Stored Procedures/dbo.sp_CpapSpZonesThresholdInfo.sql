SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CpapSpZonesThresholdInfo] 
	@SourceDbName      Varchar(25),
	@DestinationDbName Varchar(25),
	@WhereCondition Varchar(500)

AS
BEGIN
SET NOCOUNT ON;
DECLARE @Sql Varchar(3000)
-- Is the Speed Zone/Threshold the System Default?
SET @Sql =
		'BEGIN
			With AthleteInfo 
			As
			( 
				SELECT Distinct p.PersonId
				FROM ' + @SourceDbName + '..Person As p Inner Join ' + @SourceDbName + '..Athlete As a On p.PersonId = a.PersonId
				WHERE ' + @WhereCondition + '
			)
			-- Determine Either Default or NotDefault 
		      Select Distinct a.PersonId, ''NotDefault'' As SpeedZoneDefault
			  From AthleteInfo As a Inner Join ' + @SourceDbName + '..SpeedZonesForPerson As hr On a.PersonId=hr.PersonId
		      Where (Select Count(*) From ' + @SourceDbName + '..SpeedZonesForPerson Where PersonId=a.PersonId  And
																						   ThresholdSpeed>0     And
																						   Zone1Floor>0         And
																						   Zone1Ceiling>0)>1

		      Union All 
		      Select a.PersonId, 
					 Case 
						When WorkoutTypeId = 0 And ThresholdSpeed=3.57
											   And Zone1Floor=0.447
											   And Zone1Ceiling=0.9383
											   And Zone2Floor=0.9383
											   And Zone2Ceiling=1.4296
											   And Zone3Floor=1.4296
											   And Zone3Ceiling=1.9209
											   And Zone4Floor=1.9209
											   And Zone4Ceiling = 2.4122
											   And Zone5Floor=2.4122
											   And Zone5Ceiling=2.9035
											   And Zone6Floor=2.9035
											   And Zone6Ceiling=3.3948
											   And Zone7Floor=3.3948
						Then ''Default''
						Else ''NotDefault''
						End As SpeedZoneDefault
			  From AthleteInfo As a Inner Join ' + @SourceDbName + '..SpeedZonesForPerson As hr On a.PersonId=hr.PersonId
		      Where ThresholdSpeed>0 And
				    Zone1Floor>0     And
				    Zone1Ceiling>0   And
		           (Select Count(*) From ' + @SourceDbName + '..SpeedZonesForPerson Where PersonId=a.PersonId And
																						  ThresholdSpeed>0    And
																						  Zone1Floor>0        And
																						  Zone1Ceiling>0)=1
		END'
		EXEC(@Sql)
END
GO
