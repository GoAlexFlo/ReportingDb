SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CpapMealLibInfo] 
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
			With Info 
			As
			( 
				SELECT Distinct p.PersonId
				FROM ' + @SourceDbName + '..Person As p Inner Join ' + @SourceDbName + '..Athlete As a On p.PersonId = a.PersonId
				WHERE ' + @WhereCondition + '
			),
				MealLibInfo As
			-- Pull Meal Count From Library	 
			   (
				  Select PersonId,COUNT(*) As MealLibCount
				  From ' + @SourceDbName + '..MealTemplate 
				  Where YEAR(CreationDate)>=' + @WhereConditionYear + ' And PersonId Is Not Null
				  Group By PersonId
			   )
				SELECT i.PersonId, m.MealLibCount
			    FROM Info As i Left Outer Join MealLibInfo As m On i.PersonId=m.PersonId
			  Order By i.PersonId
			END'
		EXEC(@Sql)
END
GO
