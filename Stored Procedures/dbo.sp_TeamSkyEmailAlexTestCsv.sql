SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_TeamSkyEmailAlexTestCsv]
AS
BEGIN
SET NOCOUNT ON;

DECLARE @query VARCHAR(5000);

set @query =
'With Info As
(
    SELECT PersonId, Fullname, Username 
    FROM Person 
    WHERE Username in (''boassonhagen'',''boswell'',''dariocataldo1'',''philipdei'',''jdombro1'',''nathanearle'',''joshedmondson'',''bernieeisel'',''chrisfroome'',
                       ''sergiohenao'',''sebhenao'',''petekennaugh'',''kiryienka'',''cknees'',''lopezdavid'',''mikelnieve1'',''dannypate'',''rporte'',''salvatorepuccio'',
                       ''rasch'',''lukerowe'',''ksiutsou'',''stannard'',''cjsutton'',''benswift'',''geraintthomas'',''jonlocke'',''bradwiggins'',''xabierzandio'',''timkerrison_client'')
  ), prepInfo As
    (
		SELECT '' FullName'' AS FullName, ''WorkoutDayDD/MM/YYYY'' AS [WorkoutDayDD/MM/YYYY], ''WorkoutDayYYYY-MM-DD'' AS [WorkoutDayYYYY-MM-DD], ''Title'' AS Title, ''StartTime'' AS StartTime, 
			   ''TotalDurationInMinutes'' AS TotalDurationInMinutes, ''DistanceInMeters'' AS DistanceInMeters, ''TotalElevationGain'' AS TotalElevationGain,
			   ''TotalTSS'' TotalTSS, ''PowerMM5Seconds'' PowerMM5Seconds, ''PowerMM10Seconds'' PowerMM10Seconds, ''PowerMM12Seconds'' PowerMM12Seconds, 
			   ''PowerMM20Seconds'' AS PowerMM20Seconds, ''PowerMM30Seconds'' AS PowerMM30Seconds, ''PowerMM1Minute'' AS PowerMM1Minute, ''PowerMM2Minutes'' AS PowerMM2Minutes,
			   ''PowerMM5Minutes'' AS PowerMM5Minutes, ''PowerMM6Minutes'' AS PowerMM6Minutes, ''PowerMM10Minutes'' AS PowerMM10Minutes, ''PowerMM12Minutes'' AS PowerMM12Minutes, 
			   ''PowerMM20Minutes'' AS PowerMM20Minutes, ''PowerMM30Minutes'' AS PowerMM30Minutes, ''PowerMM1Hour'' AS PowerMM1Hour, ''PowerMM90Minutes'' AS PowerMM90Minutes, 
			   ''PowerMM3Hours'' AS PowerMM3Hours, ''WeightInKilograms'' AS WeightInKilograms

		UNION ALL
		SELECT i.FullName, 
			   CONVERT(VARCHAR(10), w.WorkoutDay, 103) AS [WorkoutDayDD/MM/YYYY], 
			   CONVERT(VARCHAR(10), w.WorkoutDay, 126) AS [WorkoutDayYYYY-MM-DD],
			   REPLACE(ISNULL(w.Title,'' ''), '','', '' '') AS Title,
			   CONVERT(char(5), w.StartTime, 108) AS StartTime, 
			   CONVERT(VARCHAR(25), Round(w.DurationActual*60,1)) AS TotalDurationInMinutes, 
			   CONVERT(VARCHAR(25), Round(IsNull(w.Distance,0),1)) AS DistanceInMeters, 
			   CONVERT(VARCHAR(25), w.ElevationGain) AS TotalElevationGain, 
			   CONVERT(VARCHAR(25),Round(w.TrainingStressScoreActual,0)) AS TotalTSS, 
			   CONVERT(VARCHAR(25),mmp.MM5Seconds) AS PowerMM5Seconds, 
			   CONVERT(VARCHAR(25),mmp.MM10Seconds) AS PowerMM10Seconds, 
			   CONVERT(VARCHAR(25),mmp.MM12Seconds) AS PowerMM12Seconds, 
			   CONVERT(VARCHAR(25),mmp.MM20Seconds) AS PowerMM20Seconds, 
			   CONVERT(VARCHAR(25),mmp.MM30Seconds) AS PowerMM30Seconds,
			   CONVERT(VARCHAR(25),mmp.MM1Minute) AS PowerMM1Minute, 
			   CONVERT(VARCHAR(25),mmp.MM2Minutes) AS PowerMM2Minutes, 
			   CONVERT(VARCHAR(25),mmp.MM5Minutes) AS PowerMM5Minutes, 
			   CONVERT(VARCHAR(25),mmp.MM6Minutes) AS PowerMM6Minutes, 
			   CONVERT(VARCHAR(25),mmp.MM10Minutes) AS PowerMM10Minutes, 
			   CONVERT(VARCHAR(25),mmp.MM12Minutes) AS PowerMM12Minutes, 
			   CONVERT(VARCHAR(25),mmp.MM20Minutes) AS PowerMM20Minutes, 
			   CONVERT(VARCHAR(25),mmp.MM30Minutes) AS PowerMM30Minutes, 
			   CONVERT(VARCHAR(25),mmp.MM1Hour) AS PowerMM1Hour, 
			   CONVERT(VARCHAR(25),mmp.MM90Minutes) AS PowerMM90Minutes, 
			   CONVERT(VARCHAR(25),mmp.MM3Hours) AS PowerMM3Hours,
			   CONVERT(VARCHAR(25), p.WeightInKilograms)  AS WeightInKilograms
		FROM Info AS i Inner Join Workout AS w on i.PersonId = w.PersonId
					   Left Outer Join MeanMaxPower AS mmp On w.WorkoutId=mmp.WorkoutId
					   Left Outer Join PersonMetric As p On i.PersonId=p.PersonId And CONVERT(Varchar(10),w.WorkoutDay, 111) = CONVERT(Varchar(10),p.[Timestamp], 111)
		WHERE CONVERT(varchar(10), WorkoutDay, 111) >= ''2013/11/01''
	)
	SELECT  FullName, [WorkoutDayDD/MM/YYYY], Title, StartTime, TotalDurationInMinutes, DistanceInMeters, 
	        TotalElevationGain, TotalTSS,  PowerMM5Seconds, PowerMM10Seconds, PowerMM12Seconds, PowerMM20Seconds, 
	        PowerMM30Seconds,  PowerMM1Minute, PowerMM2Minutes, PowerMM5Minutes, PowerMM6Minutes, PowerMM10Minutes, 
			PowerMM12Minutes, PowerMM20Minutes, PowerMM30Minutes, PowerMM1Hour, PowerMM90Minutes, PowerMM3Hours, WeightInKilograms
	FROM prepInfo

	ORDER BY FullName, [WorkoutDayYYYY-MM-DD] DESC'
--PRINT(@query)

DECLARE @emailBodyMsg NVARCHAR(2000);
SET @emailBodyMsg = 'Hello Team Sky,

Attached is the workout activity for your athletes.  If you have questions contact ben@trainingpeaks.com.

Thank You,
TrainingPeaks
';

    -- Email the results in the @returnvalue table --
    EXEC msdb.dbo.sp_send_dbmail
    @execute_query_database='ultrafit_live',
    @recipients=N'aflores@peaksware.com',
 -- @recipients=N'white@teamsky.com',
 -- @copy_recipients =N'AFlores@Peaksware.com',
    @blind_copy_recipients=N'aflores@peaksware.com;goalexflo@yahoo.com',
    @body= @emailBodyMsg,
    @subject ='Trainingpeaks - TeamSky Weekly Report',
    @reply_to =N'aflores@peaksware.com',
    @profile_name ='dbadmins@peaksware.com',
    @query = @query,
    @attach_query_result_as_file = 1,
    @query_result_header = 0,
    @query_attachment_filename ='TeamSky.csv',
    @query_result_no_padding = 1,
    @query_result_separator = ',',
    @query_result_width = 5000

END
GO
