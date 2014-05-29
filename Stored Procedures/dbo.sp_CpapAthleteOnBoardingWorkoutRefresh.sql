SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_CpapAthleteOnBoardingWorkoutRefresh] 
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE	@return_value int
	DECLARE @SourceDbName Varchar(25) = 'Ultrafit_live'
	DECLARE @DestinationDbName Varchar(25) = 'Reporting'
	DECLARE @WhereCondition Varchar(100) = N'p.Usertype in (1,4,6) And p.PersonId Not In (349077, 114420)'
	DECLARE	@WhereConditionYear Varchar(4) = N'2014'

	EXEC    @return_value = [dbo].[sp_CpapAthleteOnBoardingWorkout] @SourceDbName, @DestinationDbName, @WhereCondition, @WhereConditionYear 
END

GO
