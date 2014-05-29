SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CpapCoachedAthleteInfo] 
	@SourceDbName Varchar(25),
	@DestinationDbName Varchar(25)
	
AS
BEGIN
SET NOCOUNT ON;
DECLARE @Sql   Varchar(3000)

Set @Sql =      
		'BEGIN
			With Info AS
			(
				Select 
				   ROW_NUMBER() OVER (PARTITION BY c.CoachId,c.PersonId ORDER BY c.row) AS Row
   				  ,ROUND(DATEDIFF(DAY,CASE WHEN CONVERT(DATE,p.AccountCreationDate)>=''2013-11-14'' THEN CONVERT(DATE,p.AccountCreationDate) ELSE CONVERT(DATE,''2013-11-14'') END, GETDATE()),2) AS DaysOnSystem
				  ,DATEDIFF(DAY,CoachedFromDate,CoachedToDate) As DaysCoached 
  				  ,CONVERT(FLOAT,DATEDIFF(DAY,CoachedFromDate,CoachedToDate))/DATEDIFF(DAY,CASE WHEN CONVERT(DATE,p.AccountCreationDate)>=''2013-11-14'' THEN CONVERT(DATE,p.AccountCreationDate) ELSE CONVERT(DATE,''2013-11-14'') END, GETDATE()) AS AttachedToCoachPercent
				  ,c.[PersonId]
				  ,c.[CoachId]
				  ,c.[CoachingGroupId]
				  ,c.[CoachedFromDate]
				  ,c.[CoachedToDate]
				  ,c.[IsAthleteTriathlete]
				  ,c.[IsAthleteRunner]
				  ,c.[IsAthleteCyclist]
				  ,c.[IsAthleteOther]
				  ,c.[IsAthleteUserType1]
				  ,c.[IsAthleteUserType4]
				  ,c.[IsAthleteUserType6]
				  ,(SELECT Count(Distinct [DateOfLogin]) 
				    FROM ' + @SourceDbName + '..[PersonLoginHistory] 
				    WHERE Personid=c.PersonId And CONVERT(DATE,DateOfLogin) Between c.CoachedFromDate And c.CoachedToDate) As NumberOfLogins
				  ,Case When p.[LastLogon]<''2013-11-14'' Then Null Else DATEDIFF(DAY, p.[LastLogon],GETDATE()) End AS NumberOfDaysSinceLastLogon
				FROM ' + @DestinationDbName + '..CoachedAthletes As c Inner Join ' + @SourceDbName + '..Person As p On c.PersonId=p.PersonId
				                                                      Inner Join ' + @SourceDbName + '..Person As p1 On c.CoachId=p1.PersonId
				Where p1.usertype=2 And DATEDIFF(DAY,p1.LastLogon,GETDATE())<=45 And CONVERT(DATE,p.AccountCreationDate) <= CONVERT(DATE,GETDATE()-136)
			), PullAthletes AS
			(
			   Select Personid, SUM(AttachedToCoachPercent) As AttachedToCoachPercent
			   From Info
			   Group By PersonId
			   Having SUM(AttachedToCoachPercent)>=.8
			)
			SELECT CoachId
					,CoachingGroupId
					,Sum(IsAthleteTriathlete) TotalTriathletes
					,Sum(IsAthleteRunner)     TotalRunners
					,Sum(IsAthleteCyclist)    TotalCyclists
					,Sum(IsAthleteOther)      TotalOtherSports
					,Sum(IsAthleteUserType1)  TotalUserType1
					,Sum(IsAthleteUserType4)  TotalUserType4
					,Sum(IsAthleteUserType6)  TotalUserType6
					,Sum(NumberOfLogins)      TotalNumberOfLogins
					,Sum(NumberOfDaysSinceLastLogon) NumberOfDaysSinceLastLogon
					,COUNT(*) As TotalCoachedAthletes
  			  FROM PullAthletes As p Inner Join Info As i On p.PersonId=i.PersonId
			  Where Row=1
			  Group By CoachId, CoachingGroupId
		 END'
EXEC(@Sql)
END

GO
