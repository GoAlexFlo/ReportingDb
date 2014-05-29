SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_CpapRouteInfo] 
	@SourceDbName      Varchar(25),
	@DestinationDbName Varchar(25),
	@WhereCondition Varchar(500),
	@WhereConditionYear Varchar(4)
	
AS
BEGIN
SET NOCOUNT ON;
DECLARE @Sql Varchar(2000)

Set @Sql =
	   'BEGIN
			With Info As
			( 
				SELECT p.PersonId
				FROM ' + @SourceDbName + '..Person As p Inner Join ' + @SourceDbName + '..Athlete As a On p.PersonId = a.PersonId
				WHERE ' + @WhereCondition + '  
			)
				SELECT i.PersonId, COUNT(*) as RouteCount 
				FROM Info AS i Inner Join ' + @SourceDbName + '..[Route] As r On i.PersonId=r.PersonId
				WHERE YEAR(r.DateModified)>=' + @WhereConditionYear + ' And r.IsDeleted<>1
				GROUP BY i.PersonId
		END'
		EXEC(@Sql)
END

GO
