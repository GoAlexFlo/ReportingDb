SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_CpapGenCoachedAthleteInfo] 
	@SourceDbName      Varchar(25),
	@DestinationDbName Varchar(25)
AS
BEGIN
SET NOCOUNT ON;
DECLARE @Sql   Varchar(MAX)
DECLARE @Empty Varchar(2) = ''''''

Set @Sql =      
		'BEGIN
		  IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''' + @DestinationDbName + '..CoachedAthletes'') AND type in (N''U''))
			  DROP TABLE ' + @DestinationDbName + '..CoachedAthletes
		  ELSE
		   -- Fail Safe: When the StoredProc is run multiple times, the intellisense doesnt refresh fast enough to recognize table does exist.
			  BEGIN TRY DROP TABLE ' + @DestinationDbName + '..CoachedAthletes END TRY BEGIN CATCH END CATCH
			  
			  SELECT Row, 
			         PersonId, 
			         CoachId, 
			         CoachingGroupId, 
			         CoachedFromDate, 
			         CoachedToDate,
			         UserType,
			         IsAthleteUserType1, 
					 IsAthleteUserType4, 
					 IsAthleteUserType6,
	                 IsAthleteTriathlete, 
	                 IsAthleteRunner, 
	                 IsAthleteCyclist, 
	                 IsAthleteOther
			  INTO #PreCoachedAthletes
			  FROM
			  (SELECT ROW_NUMBER() OVER (PARTITION BY a.PersonId ORDER BY a.UpdateDate) AS Row,
						 a.PersonId,
						 a.CoachedByPersonId As CoachId,
						 c.CoachingGroupId,
						 a.UpdateDate As CoachedFromDate,
						 ISNULL((SELECT Top 1 UpdateDate FROM ' + @SourceDbName + '..AthleteHistory WHERE PersonId=a.PersonId And UpdateDate>a.UpdateDate ORDER BY UpdateDate), GETDATE()) As CoachedToDate,
						 p.Usertype,
						 Case When p.UserType = 1 Then 1 Else 0 End As IsAthleteUserType1,
						 Case When p.UserType = 4 Then 1 Else 0 End As IsAthleteUserType4,
						 Case When p.UserType = 6 Then 1 Else 0 End As IsAthleteUserType6,
   						 Case When p.AthleteType = ''Triathlete'' Then 1 Else 0 End As IsAthleteTriathlete,
						 Case When p.AthleteType = ''Runner'' Then 1 Else 0 End As IsAthleteRunner,
						 Case When p.AthleteType = ''Cyclist'' Then 1 Else 0 End As IsAthleteCyclist,
						 Case When p.AthleteType Not In  (''Triathlete'',''Runner'',''Cyclist'') Then 1 Else 0 End As IsAthleteOther
 
				  FROM ' + @SourceDbName + '..AthleteHistory As a Inner Join ' + @SourceDbName + '..Person As p On a.PersonId=p.Personid
				                                                  Inner Join ' + @SourceDbName + '..Coach As c On a.CoachedByPersonId=c.PersonId
				  WHERE a.PersonId Not In (349077, 114420) And a.CoachedByPersonId Is Not Null -- And a.personid=1078908 -- Testing
				  
				  UNION ALL  -- ADD Athletes that were created by their coach and then changed coach
				  SELECT Top 1 
					 0 Row, 
					 a.PersonId,
					(SELECT Top 1 CoachedByPersonIdPrevious FROM ' + @SourceDbName + '..AthleteHistory WHERE PersonId=a.PersonId ORDER BY UpdateDate) As CoachId,
					 c.CoachingGroupId,
					 CASE WHEN p.AccountCreationDate >= ''2013-11-14'' Then p.AccountCreationDate Else ''2013-11-14'' END As CoachedFromDate, 
					 a.UpdateDate As CoachedToDate,
					 p.UserType,
					 Case When p.UserType = 1 Then 1 Else 0 End As IsAthleteUserType1,
					 Case When p.UserType = 4 Then 1 Else 0 End As IsAthleteUserType4,
					 Case When p.UserType = 6 Then 1 Else 0 End As IsAthleteUserType6,
   					 Case When p.AthleteType = ''Triathlete'' Then 1 Else 0 End As IsAthleteTriathlete,
					 Case When p.AthleteType = ''Runner'' Then 1 Else 0 End As IsAthleteRunner,
					 Case When p.AthleteType = ''Cyclist'' Then 1 Else 0 End As IsAthleteCyclist,
					 Case When p.AthleteType Not In  (''Triathlete'',''Runner'',''Cyclist'') Then 1 Else 0 End As IsAthleteOther
				  FROM ' + @SourceDbName + '..AthleteHistory As a Inner Join ' + @SourceDbName + '..Person As p On a.PersonId=p.Personid
				                                                  Inner Join ' + @SourceDbName + '..Coach As c On a.CoachedByPersonId=c.PersonId
				  WHERE p.PersonId Not In (349077, 114420) And a.CoachedByPersonIdPrevious Is Not Null -- And a.personid=1078908 -- Testing
				  ) As CoachInfo
			  
			  UNION ALL  -- ADD Athletes that were created by a coach and have never changed coach
			  SELECT Distinct 0 As Row, 
							  p.PersonId, 
							  a.CoachedByPersonId As CoachId,
							  c.CoachingGroupId,
							  CASE WHEN p.AccountCreationDate >= ''2013-11-14'' Then p.AccountCreationDate Else ''2013-11-14'' END As CoachedFromDate,
							  GETDATE() As CoachedToDate,
							  p.UserType,
							  Case When p.UserType = 1 Then 1 Else 0 End As IsAthleteUserType1,
							  Case When p.UserType = 4 Then 1 Else 0 End As IsAthleteUserType4,
							  Case When p.UserType = 6 Then 1 Else 0 End As IsAthleteUserType6,
   							  Case When p.AthleteType = ''Triathlete'' Then 1 Else 0 End As IsAthleteTriathlete,
							  Case When p.AthleteType = ''Runner'' Then 1 Else 0 End As IsAthleteRunner,
							  Case When p.AthleteType = ''Cyclist'' Then 1 Else 0 End As IsAthleteCyclist,
							  Case When p.AthleteType Not In  (''Triathlete'',''Runner'',''Cyclist'') Then 1 Else 0 End As IsAthleteOther
			  FROM ' + @SourceDbName + '..Person As p Inner Join ' + @SourceDbName + '..Athlete As a On p.PersonId = a.PersonId
			                                          Inner Join ' + @SourceDbName + '..Coach As c On a.CoachedByPersonId=c.PersonId
			  WHERE a.CoachedByPersonId Is Not Null And 
					p.Usertype in (1,4,6) And 
					p.PersonId Not In (349077, 114420) And 
					p.PersonId Not In (Select Distinct PersonId From ' + @SourceDbName + '..AthleteHistory);
			
			-- Filter out rows where activity falls on the same date.  If an athlete is coached by 2 coaches on the same day then then the second coach gets credit for the activity 		
			With Info As
			(
				Select ROW_NUMBER() OVER (PARTITION BY c.PersonId,CONVERT(Date,c.CoachedFromDate) ORDER BY c.Row Desc) AS Row, 
				       PersonId, 
				       CoachId,
					   CONVERT(Date,CoachedFromDate) As CoachedFromDate, 
					   CONVERT(Date,CoachedToDate) As CoachedToDate,
					   (Select Top 1 CONVERT(Date,CoachedFromDate) From #PreCoachedAthletes Where PersonId=c.PersonId And Row>c.row Order By Row) As NextCoachedFromDate,
					   CoachingGroupId,
					   UserType,
					   IsAthleteUserType1,
					   IsAthleteUserType4,
					   IsAthleteUserType6,
					   IsAthleteTriathlete,
					   IsAthleteRunner,
					   IsAthleteCyclist,
					   IsAthleteOther
				From #PreCoachedAthletes As c
			)
			Select ROW_NUMBER() OVER (PARTITION BY PersonId ORDER BY CoachedFromDate) AS Row, 
			       PersonId, 
			       CoachId,
			       CoachingGroupId, 
			       CoachedFromDate, 
				   Case 
				   When NextCoachedFromDate Is Null OR CoachedToDate<>NextCoachedFromDate 
				   Then CoachedToDate 
				   Else DATEADD(day, -1,CoachedToDate) End As CoachedToDate,
				   UserType,
				   IsAthleteUserType1,
				   IsAthleteUserType4,
				   IsAthleteUserType6,
				   IsAthleteTriathlete,
				   IsAthleteRunner,
				   IsAthleteCyclist,
				   IsAthleteOther
			INTO ' + @DestinationDbName + '..CoachedAthletes	   
			From Info
			Where Row=1
			Order by PersonId, CoachedFromDate
		 END'
EXEC(@Sql)
END


GO
