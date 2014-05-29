SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[sp_Cpap2013MonthsOnSystemInfo] 
	@SourceDbName   Varchar(25),
	@DestinationDbName Varchar(25),
	@WhereCondition Varchar(500),
	@WhereConditionYear Varchar(4)
AS
BEGIN
SET NOCOUNT ON;
DECLARE @Sql Varchar(5000)

Set @Sql =
	   '--------------------------------------------------------------------------------------- 
	    --
	    --             NOTE THIS IS A ONE-OFF FOR 2013
	    --
	    -- Modified StoredProc to calculate all months a user is on system.
	    -- Example: If AccountCreationDate is 2013-11-28 and today is 2014-01-01 then this user 
	    -- has been on the system For 3 months (Nov,Dec,Jan).  Do not use DATEDIFF to calculate  
	    -- months between two dates. DATEDIFF returns 2 months.
	    ----------------------------------------------------------------------------------------
	    BEGIN
		With Info As
		( 
			Select Distinct p.PersonId, 
			                ISNULL((SELECT COUNT(MonthName) 
							  FROM
						  	  (
								SELECT  DATENAME(MONTH, DATEADD(MONTH, x.number, p.AccountCreationDate)) AS MonthName
								FROM    master.dbo.spt_values x
								WHERE   x.type = ''P'' AND x.number <= DATEDIFF(MONTH, p.AccountCreationDate, GETDATE())
							  ) As d) ,1) As MonthsOnSystem,
							  ISNULL((SELECT COUNT(MonthName) 
							  FROM
						  	  (
								SELECT  DATENAME(MONTH, DATEADD(MONTH, x.number, p.AccountCreationDate)) AS MonthName
								FROM    master.dbo.spt_values x
								WHERE   x.type = ''P'' AND x.number <= DATEDIFF(MONTH, Case When YEAR(p.AccountCreationDate)=2013 
								                                                          Then p.AccountCreationDate 
								                                                          When YEAR(p.AccountCreationDate)<2013 
								                                                          Then ''2013-01-01''
								                                                          Else null End, ''2013-12-31'')
							  ) As d) ,1) As MonthsOnSystemIn2013    
			From ' + @SourceDbName + '..Person As p Inner Join ' + @SourceDbName + '..Athlete As a On p.PersonId = a.PersonId
			Where ' + @WhereCondition + '
			
		), PrepInfo As
		   (
			Select Distinct i.PersonId, Convert(float,i.MonthsOnSystem) As MonthsOnSystem, 
			                Convert(float,i.MonthsOnSystemIn2013) As MonthsOnSystemIn2013, 
			                Year(DateOfLogin) As YearActiveOnSystem,  Convert(VarChar(7),DateOfLogin, 111) As MonthActiveOnSystem
				   From Info As i Left Outer Join ' + @SourceDbName + '..PersonLoginHistory As p On i.PersonId=p.PersonId
			)
			   Select PersonId, MonthsOnSystem, 
			          MonthsOnSystemIn2013,
			          Count(Distinct MonthActiveOnSystem) As MonthsActiveOnSystem, 
			          Sum(Case When YearActiveOnSystem=2013 Then 1 Else null End) As MonthsActiveOnSystemIn2013,
			          Case When Count(Distinct MonthActiveOnSystem)>0 And MonthsOnSystem>0 
			               Then Round(Count(Distinct MonthActiveOnSystem)/MonthsOnSystem,2) 
			               Else null 
			          End As PercentOfMonthsActiveOnSystem,
			          Case When MonthsOnSystemIn2013>0 
			               Then Round(Sum(Case When YearActiveOnSystem=2013 Then 1 Else null End)/MonthsOnSystemIn2013,2) 
			               Else null 
			          End As PercentOfMonthsActiveOnSystemIn2013
			   From PrepInfo As p
			   Group By PersonId, MonthsOnSystem, MonthsOnSystemIn2013
		END'
	   
		EXEC(@Sql)
		
END






GO
