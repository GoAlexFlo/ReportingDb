SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_CpapCoachRouteInfo] 
	@SourceDbName      Varchar(25),
	@DestinationDbName Varchar(25)
	
AS
BEGIN
SET NOCOUNT ON;
DECLARE @Sql Varchar(2000)

Set @Sql =
	   'BEGIN
			Select c.CoachId, c.PersonId, c.CoachedFromDate, c.CoachedToDate, RouteName
			From ' + @DestinationDbName + '..CoachedAthletes As c Inner Join ' + @SourceDbName + '..[Route] As r 
			  On c.PersonId=r.PersonId And CONVERT(Date,r.DateModified) Between c.CoachedFromDate And c.CoachedToDate
		END'
		EXEC(@Sql)
END

GO
