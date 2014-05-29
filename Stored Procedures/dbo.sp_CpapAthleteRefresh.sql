SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CpapAthleteRefresh] 
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @return_value int  
	DECLARE @SourceDbName Varchar (25)
	DECLARE @DestinationDbName Varchar (25)

	SET @SourceDbName = 'Ultrafit_live'
	SET @DestinationDbName = 'Reporting'
	SET NOCOUNT ON;

	TRUNCATE TABLE Reporting.dbo.CpapAthlete;

	EXEC    @return_value = [dbo].[sp_CpapMain] @SourceDbName, @DestinationDbName 
END
GO
