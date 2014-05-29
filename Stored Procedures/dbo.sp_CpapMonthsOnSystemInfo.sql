SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_CpapMonthsOnSystemInfo] 
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
	    -- Modified StoredProc to calculate all months a user is on system.
	    -- Example: If AccountCreationDate is 2013-11-28 and today is 2014-01-01 then this user 
	    -- has been on the system For 3 months (Nov,Dec,Jan).  Do not use DATEDIFF to calculate  
	    -- months between two dates. DATEDIFF returns 2 months.
	    ----------------------------------------------------------------------------------------
	    BEGIN
			With Info As
		( 
			Select Distinct p.PersonId,
			       Case When p.AccountCreationDate Is Null Or p.AccountCreationDate=''1900-01-01''
		                Then (Select Top 1 AccountCreationDate From ' + @SourceDbName + '..Person Where PersonId<p.PersonId And AccountCreationDate Is Not Null Order By PersonId Desc)
		                Else  p.AccountCreationDate 
		           End AccountCreationDate   
			From ' + @SourceDbName + '..Person As p 
			Where ' + @WhereCondition + '
		), dataPass1 As
		   (
			Select PersonId, 
	                ISNULL((SELECT COUNT(MonthName) 
					  FROM
				  	  (
						SELECT  DATENAME(MONTH, DATEADD(MONTH, x.number, AccountCreationDate)) AS MonthName
						FROM    master.dbo.spt_values x
						WHERE   x.type = ''P'' AND x.number <= DATEDIFF(MONTH, AccountCreationDate, GETDATE())
					  ) As d) ,1) As MonthsOnSystem,
					  ISNULL((SELECT COUNT(MonthName) 
					  FROM
				  	  (
						SELECT  DATENAME(MONTH, DATEADD(MONTH, x.number, AccountCreationDate)) AS MonthName
						FROM    master.dbo.spt_values x
						WHERE   x.type = ''P'' AND x.number <= DATEDIFF(MONTH, Case When YEAR(AccountCreationDate)>=2010 Then AccountCreationDate Else ''2010-01-01'' End, GETDATE())
					  ) As d) ,1) As MonthsOnSystemSince2010  
			From Info), dataPass2 As
		   (
			Select Distinct d.PersonId, Convert(float,d.MonthsOnSystem) As MonthsOnSystem, Convert(float,d.MonthsOnSystemSince2010) As MonthsOnSystemSince2010, Year(DateOfLogin) As YearActiveOnSystem,  Month(DateOfLogin) As MonthActiveOnSystem
				   From dataPass1 As d Left Outer Join ' + @SourceDbName + '..PersonLoginHistory As p On d.PersonId=p.PersonId
			)
			   Select PersonId, MonthsOnSystem, 
			          MonthsOnSystemSince2010,
			          Sum(MonthActiveOnSystem) As MonthsActiveOnSystem, 
			          Sum(Case When YearActiveOnSystem>=2010 Then 1 Else null End) As MonthsActiveOnSystemSince2010,
			          Case When Sum(MonthActiveOnSystem)>0 And MonthsOnSystem>0 
			               Then Round(Sum(MonthActiveOnSystem)/MonthsOnSystem,2) 
			               Else null 
			          End As PercentOfMonthsActiveOnSystem,
			          Case When Sum(Case When YearActiveOnSystem>=2010 Then 1 Else 0 End)>0  And MonthsOnSystemSince2010>0 
			               Then Round(Sum(Case When YearActiveOnSystem>=2010 Then 1 Else 0 End)/MonthsOnSystemSince2010,2) 
			               Else null 
			          End As PercentOfMonthsActiveOnSystemSince2010
			   From dataPass2 
			   Group By PersonId, MonthsOnSystem, MonthsOnSystemSince2010
		END'
	   
		EXEC(@Sql)
		
END





GO
