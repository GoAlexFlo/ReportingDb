SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CpapWorkoutLibInfo] 
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
		    With AthleteInfo 
			As
			( 
				SELECT Distinct p.PersonId
				FROM ' + @SourceDbName + '..Person As p Inner Join ' + @SourceDbName + '..Athlete As a On p.PersonId = a.PersonId
				WHERE ' + @WhereCondition + '
			),
				WorkoutLibPrepInfo As
			-- Pull Workout Count From Library	 
			   (
				  Select Distinct e.PersonId, e.ExerciseLibraryId 
				  From AthleteInfo As a Inner Join ' + @SourceDbName + '..ExerciseLibraryAccess As e On a.PersonId=e.PersonId
			   ),
				WorkoutLibInfo As
			   (
				  Select w.PersonId, count(*) As WorkoutLibCount
				  From WorkoutLibPrepInfo As w Inner Join ' + @SourceDbName + '..ExerciseLibraryItem As e On w.ExerciseLibraryId=e.ExerciseLibraryId
				  Where YEAR(e.DateCreated)>=' + @WhereConditionYear + ' And e.ExerciseLibraryId<>112352 And e.Isdeleted=0
				  Group By w.PersonId
			   )
				SELECT a.PersonId, b.WorkoutLibCount
			    FROM AthleteInfo As a Left Outer Join WorkoutLibInfo As b On a.PersonId=b.PersonId
			    Order By a.PersonId
			END'
		EXEC(@Sql)
END

GO
