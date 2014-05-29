SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_CpapCoachUserTypeRouteInfo] 
	@SourceDbName      Varchar(25),
	@DestinationDbName Varchar(25)
	
AS
BEGIN
SET NOCOUNT ON;
DECLARE @Sql Varchar(2000)

Set @Sql =
	   'BEGIN
			With Info As
			(
				Select c.CoachId, CONVERT(Varchar(10),c.UserType) As AthleteUserType, Count(*) As TotalAthletesRouteCount
							From ' + @DestinationDbName + '..CoachedAthletes As c Inner Join ' + @SourceDbName + '..[Route] As r 
							  On c.PersonId=r.PersonId And CONVERT(Date,r.DateModified) Between c.CoachedFromDate And c.CoachedToDate
							  Group By CoachId, c.UserType
			)
			Select * 
			From Info

			Union All 
			Select CoachId, ''Combo'' AS AthleteUserType, SUM(TotalAthletesRouteCount) As TotalAthletesRouteCount
			From Info
			Group By CoachId
			Having COUNT(*)>1
			Order by CoachId, AthleteUserType
		END'
		EXEC(@Sql)
END

GO
