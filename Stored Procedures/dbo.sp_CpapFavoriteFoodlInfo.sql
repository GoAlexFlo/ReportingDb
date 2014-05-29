SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE PROCEDURE [dbo].[sp_CpapFavoriteFoodlInfo] 
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
				SELECT Distinct p.PersonId
				FROM ' + @SourceDbName + '..Person As p Inner Join ' + @SourceDbName + '..Athlete As a On p.PersonId = a.PersonId
				WHERE ' + @WhereCondition + '  
			)
				Select i.PersonId,COUNT(*) As FavoriteFoodCount 
				From Info AS i Inner Join ' + @SourceDbName + '..FoodFavorite As f On i.PersonId=f.PersonId
				Where YEAR(CreationDate)>=' + @WhereConditionYear + ' 
				Group By i.PersonId 
		END'
		
		EXEC(@Sql)
END





GO
