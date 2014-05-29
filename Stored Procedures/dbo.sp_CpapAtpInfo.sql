SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_CpapAtpInfo] 
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
		    With AthleteInfo 
			As
			( 
				SELECT Distinct p.PersonId
				FROM ' + @SourceDbName + '..Person As p Inner Join ' + @SourceDbName + '..Athlete As a On p.PersonId = a.PersonId
								                        Left Outer Join ' + @DestinationDbName + '..PayPalProductRevenue As pp On p.PersonId = pp.PersonId
				WHERE ' + @WhereCondition + '
			),
			AtpGoalsAndObjectivesInfo As
		-- Pull ATP Goals And Objectives 	 
		   (
			 Select a.PersonId, 
					SUM(Case
						 When ([seasongoal1] Is Not Null And [seasongoal1] <>' + @Empty + ') Or 
							  ([seasongoal2] Is Not Null And [seasongoal2] <>' + @Empty + ') Or
							  ([seasongoal3] Is Not Null And [seasongoal3] <>' + @Empty + ') 
						 Then 1 
						 Else 0
						 End) As AtpYearsWithGoals,
					SUM(Case
						 When ([objective1] Is Not Null And [objective1] <>' + @Empty + ') Or 
							  ([objective2] Is Not Null And [objective2] <>' + @Empty + ') Or
							  ([objective3] Is Not Null And [objective3] <>' + @Empty + ') Or
							  ([objective4] Is Not Null And [objective4] <>' + @Empty + ') Or
							  ([objective5] Is Not Null And [objective5] <>' + @Empty + ')
						 Then 1 
						 Else 0
						 End) As AtpYearsWithObjectives,
						 Sum(annual_hours)/ Count([year]) As AtpAvgAnnualHours
			 From AthleteInfo As a Inner Join ' + @SourceDbName + '..atp As b On a.PersonId = b.PersonId
			 Where b.[year] >= ''' + @WhereConditionYear + '''
			 Group by a.PersonId
			 Having (Sum(annual_hours)/ Count([year]))<= 2100 
			),
			AtpRaceInfo As
		-- Pull ATP Goals And Objectives 	 
		   (
			 Select a.PersonId, 
					SUM(Case
						 When ([priority] Is Not Null And [priority] <>' + @Empty + ')  
						 Then 1 
						 Else 0
						 End) As AtpTotalRaceCount
			 From AtpGoalsAndObjectivesInfo As a Inner Join ' + @SourceDbName + '..atp_weekly As b On a.PersonId = b.PersonId
			 Where ([priority] Is Not Null And [priority] <>' + @Empty + ') And YEAR(b.week)>= ''' + @WhereConditionYear + '''

			 Group by a.PersonId
			 )
			 SELECT a.[PersonId]
				   ,c.[AtpYearsWithGoals]
				   ,c.[AtpYearsWithObjectives]
				   ,d.[AtpTotalRaceCount]
				   ,c.[AtpAvgAnnualHours]
			  FROM AthleteInfo As a Inner Join AtpGoalsAndObjectivesInfo As c On a.PersonId=c.PersonId
									Inner Join AtpRaceInfo As d               On a.PersonId=d.PersonId
			  Order By a.PersonId
		END'
		EXEC(@Sql)
END


GO
