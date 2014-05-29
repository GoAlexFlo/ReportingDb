SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CpapGoogleAnalyticsInfo] 
	@SourceDbName       Varchar(25),
	@DestinationDbName  Varchar(25),
	@WhereCondition     Varchar(500),
	@WhereConditionYear Varchar(4)
AS
BEGIN
SET NOCOUNT ON;

    DECLARE @Sql Varchar(3000)
    DECLARE @Empty Varchar(2)
    SET @Empty = ''''''

Set @Sql =
		'BEGIN
		With Info 
			As
			( 
				SELECT Distinct p.PersonId
				FROM ' + @SourceDbName + '..Person As p 
				WHERE ' + @WhereCondition + '
			)
				Select PersonId, MarketingPreferenceSharedKey, GaMonthsActiveOnSystem, LastGaVisit, DaysSinceLastGaVisit, 
				                 CASE WHEN (AppiOS>0 OR  AppAndroid>0 OR WebiOS>0 OR WebAndroid>0) THEN 1 ELSE 0 END As UsesMobile,
				                 IsNull(AppiOS,0) AS ''GaNativeAppiOSVisits'', IsNull(AppAndroid,0) As ''GaNativeAppAndroidVisits'', IsNull(WebDesktop,0) As ''GaWebAppDesktopVisits'' ,
								 IsNull(WebiOS,0) As ''GaWebAppiOSVisits'', IsNull(WebAndroid,0) As ''GaWebAppAndroidVisits'' , IsNull(Other,0) As ''GaOtherVisits''
				FROM
				(
				SELECT p.[PersonId], MarketingPreferenceSharedKey,
				      (SELECT COUNT(DISTINCT CONVERT(VARCHAR(7),VisitDate,111)) FROM ' + @DestinationDbName + '..[PersonVisitsHistory] WHERE PersonId=p.PersonId) As GaMonthsActiveOnSystem,
				      (SELECT MAX(VisitDate) FROM ' + @DestinationDbName + '..[PersonVisitsHistory] WHERE PersonId=p.PersonId) As LastGaVisit,
				      (SELECT DATEDIFF(DAY,MAX(VisitDate),GETDATE()) FROM ' + @DestinationDbName + '..[PersonVisitsHistory] WHERE PersonId=p.PersonId) As DaysSinceLastGaVisit,
					  Case 
						  When GaProfileId = 68366620 And DeviceType=''Mobile''
						  Then ''AppiOS''
						  When GaProfileId = 68366620 And DeviceType=''Tablet''
						  Then ''AppiOS''
						  When GaProfileId = 74607074  And DeviceType=''Mobile''
						  Then ''AppAndroid''
						  When GaProfileId = 74607074  And DeviceType=''Tablet''
						  Then ''AppAndroid'' 
						  When GaProfileId = 74976021 And DeviceInfo = ''Desktop'' 
						  Then ''WebDesktop'' 
						  When GaProfileId = 74976021 And DeviceInfo like ''Apple%''
						  Then ''WebiOS'' 
						  When GaProfileId = 74976021 And DeviceInfo Not like ''Apple%'' 
						  Then ''WebAndroid'' 
						  Else ''Other'' 
						  End As DeviceType 
					  ,[NumberOfVisits]
				  FROM Info As i Inner Join ' + @DestinationDbName + '..[PersonVisitsHistory] As p On i.PersonId=p.PersonId
				  ) AS SourceTable
				PIVOT
				(
				SUM(NumberOfVisits)
				FOR DeviceType IN ([AppiOS], [AppAndroid], [WebDesktop], [WebiOS], [WebAndroid], [Other])
				) AS PivotTable  
				Order by personid
			END '
		EXEC(@Sql)
END

GO
