SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_CpapAthleteOnBoardingRefresh] 
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @return_value int  
	DECLARE @SourceDbName Varchar (25)
	DECLARE @DestinationDbName Varchar (25)
	DECLARE	@WhereConditionYear Varchar (4)

	SET @SourceDbName = 'Ultrafit_live'
	SET @DestinationDbName = 'Reporting'
	SET	@WhereConditionYear = N'2014'
	SET NOCOUNT ON;

	EXEC    @return_value = [dbo].[sp_CpapAthleteOnBoardingMain] @SourceDbName, @DestinationDbName, @WhereConditionYear 
END

GO
