SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_Cpap2010AthleteWorkoutRevisedRefresh] 
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE	@return_value int
	DECLARE @SourceDbName Varchar(25) = 'Ultrafit'
	DECLARE @DestinationDbName Varchar(25) = 'Reporting'
	DECLARE @WhereCondition Varchar(100) = N'p.Usertype in (1,4,6) And p.PersonId Not In (349077, 114420)'
	DECLARE	@WhereConditionYear Varchar(4) = N'2010'

	EXEC    @return_value = [dbo].[sp_Cpap2010WorkoutRevisedInfo] @SourceDbName, @DestinationDbName, @WhereCondition, @WhereConditionYear 
END

GO
