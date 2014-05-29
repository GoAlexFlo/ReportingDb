SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[sp_Cpap2013AthleteRefresh] 
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @return_value int  
	DECLARE @SourceDbName Varchar (25)
	DECLARE @DestinationDbName Varchar (25)
	DECLARE	@WhereConditionYear Varchar (4)

	SET @SourceDbName = 'Ultrafit'
	SET @DestinationDbName = 'Reporting'
	SET	@WhereConditionYear = N'2013'
	SET NOCOUNT ON;

	TRUNCATE TABLE Reporting.dbo.Cpap2013Athlete;

	EXEC    @return_value = [dbo].[sp_Cpap2013Main] @SourceDbName, @DestinationDbName, @WhereConditionYear 
END


GO
