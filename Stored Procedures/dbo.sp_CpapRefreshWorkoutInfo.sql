SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_CpapRefreshWorkoutInfo] 
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @WhereCondition Varchar(500)
	SET @WhereCondition = 'p.PersonId Not In (349077, 114420) And p.Usertype in (1,4,6)'  

	exec [sp_CpapWorkoutInfo] 'ultrafit','Reporting', @WhereCondition		 
	
END
GO
