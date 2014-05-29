SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CpapPwZonesThresholdInfo] 
	@SourceDbName      Varchar(25),
	@DestinationDbName Varchar(25),
	@WhereCondition Varchar(500)

AS
BEGIN
SET NOCOUNT ON;
DECLARE @Sql Varchar(3000)
-- Is the Power Zone/Threshold the System Default?
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
		      Select Distinct a.PersonId, ''NotDefault'' As PowerZoneDefault
			  From AthleteInfo As a Inner Join ' + @SourceDbName + '..PowerZonesForPerson As hr On a.PersonId=hr.PersonId
		      Where (Select Count(*) From ' + @SourceDbName + '..PowerZonesForPerson Where PersonId=a.PersonId And
																						   ThresholdPower>0    And
																						   Zone1Floor>0        And
																						   Zone1Ceiling>0)>1
		      Union All 
		      Select a.PersonId, 
					 Case 
						When WorkoutTypeId = 0 And ThresholdPower=200 
											   And Zone1Floor=100
											   And Zone1Ceiling=132
											   And Zone2Floor=133
											   And Zone2Ceiling=165
											   And Zone3Floor=166
											   And Zone3Ceiling=198
											   And Zone4Floor=199
											   And Zone4Ceiling = 231
											   And Zone5Floor=232
											   And Zone5Ceiling=264
											   And Zone6Floor=265
											   And Zone6Ceiling=300
						Then ''Default''
						Else ''NotDefault''
						End As PowerZoneDefault
			  From AthleteInfo As a Inner Join ' + @SourceDbName + '..PowerZonesForPerson As hr On a.PersonId=hr.PersonId
		      Where ThresholdPower>0 And
				    Zone1Floor>0     And
				    Zone1Ceiling>0   And
		           (Select Count(*) From ' + @SourceDbName + '..PowerZonesForPerson Where PersonId=a.PersonId And
																						  ThresholdPower>0    And
																						  Zone1Floor>0        And
																						  Zone1Ceiling>0)=1
		END'
		EXEC(@Sql)
END
GO
