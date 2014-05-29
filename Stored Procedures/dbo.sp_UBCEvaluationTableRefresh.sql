SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_UBCEvaluationTableRefresh] 
	
AS
BEGIN
	SET NOCOUNT ON;
        IF  EXISTS (Select * From sys.objects Where object_id = OBJECT_ID(N'Reporting..[UBCEvaluation]') And type in (N'U'))
			DROP TABLE Reporting..[UBCEvaluation]
		  ELSE
		   -- Fail Safe: When the StoredProc is run multiple times, the intellisense doesnt refresh fast enough to recognize table does exist.
			  BEGIN TRY DROP TABLE Reporting..UBCEvaluation END TRY BEGIN CATCH END CATCH;
	With Info As
    (
      Select Row, PersonId, UserTypePrevious ,UserType, UpdateDate As BeganAsA4On,
  	  ISNull((Select Top 1 UpdateDate From ultrafit_live..PersonHistory Where PersonId=d.PersonId And UpdateDate>d.UpdateDate Order By UpdateDate),GETDATE()) As EndedAsA4,
   	  DATEDIFF(DAY, UpdateDate, ISNull((Select Top 1 UpdateDate From ultrafit_live..PersonHistory Where PersonId=d.PersonId And UpdateDate>d.UpdateDate Order By UpdateDate),GETDATE())) As DayDiff
   	  From
	  (
	  Select ROW_NUMBER() OVER (PARTITION BY ph.PersonId ORDER BY ph.PersonId, ph.UpdateDate) AS Row, ph.PersonId, ph.userTypePrevious, ph.UserType, ph.UpdateDate
	  From   ultrafit_live..PersonHistory As ph Inner Join ultrafit_live..Person As p On ph.PersonId=p.PersonId
	  Where ph.AccountCreationDate>='2013-11-14' And (p.FullName Not Like '%Example%' And p.FullName NOT Like '%test%')
	  ) As d
	  
	  Union All
	  Select 1 AS Row, p.PersonId, Null As UserTypePrevious, 99 As UserType, Null As BeganAsA4On, Null As EndedAsA4, DATEDIFF(DAY,p.AccountCreationDate,GETDATE()) As DayDiff 
      From [ultrafit_live]..[Person] as p left outer join ultrafit_live..PersonHistory as ph on p.PersonId=Ph.personid
      Where p.UserType = 6 And p.AccountCreationDate>='2013-11-14' And ph.UserTypePrevious is null And (p.FullName Not Like '%Example%' And p.FullName NOT Like '%test%')
     ), UserTypeChange As
     (
		 Select  PersonId, Max(UserType) AS FirstUserType, Min(Usertype) AS SecondUserType, COUNT(Distinct UserType) As UserTypeCount
		 From Info 
		 Where DayDiff>0 And UserType IN (1,4,6,99) 
		 Group By PersonId
    ), Prep As
     ( 
		 Select u.*,
				p.AccountCreationDate,
				(Select MIN(CoachedFromDate) From Reporting..CoachedAthletes Where PersonId=u.PersonId) As BecameCoachedOn,
				DATEDIFF(DAY, p.AccountCreationDate, (Select MIN(CoachedFromDate) From Reporting..CoachedAthletes Where PersonId=u.PersonId)) As DayDiff
		 From UserTypeChange As u Inner Join ultrafit_live..Person AS p On u.PersonId=p.PersonId
	 ), PayPalInfo As
	 (
	   Select pp.PersonId,
	       SUM(Case 
	          When RowType='Subscription' And TransDesc like'%sale%'
	          Then total
	          End) As SubRevenue,
	       SUM(Case 
	          When RowType='TrainingPlan' And TransDesc like'TrainingPlan'
	          Then total
	          End) As TrainingPlanRevenue,
	      SUM(Case 
	          When RowType='Software' And TransDesc like'Software'
	          Then total
	          End) As WKORevenue
	   From Prep As p Inner Join Reporting..PayPalProductRevenue As pp On p.PersonId=pp.PersonId
	   Group By pp.PersonId
	 )
      Select p.PersonId,
             p.FirstUserType,
             p.SecondUserType,
             p.UserTypeCount,
             p.AccountCreationDate,
             p.BecameCoachedOn,
             p.DayDiff As DaysToBecomeCoached, 
             c.CoachId, 
             c.CoachingGroupId,
             Case 
				 When DayDiff <=7  
				 Then 1 
				 Else 0 
				 End AS CoachInfluencedAccountCreation,
             Case 
				    When FirstUserType=99  
					Then 'NoUserTypeChange'	
					When UserTypeCount=1 And FirstUserType=6  
					Then 'Transient'
					When SecondUserType=4
					Then 'ConvertedToUserType4'
					When SecondUserType=1
					Then 'ConvertedToUserType1' 
					Else 'UnKnownCase'
					End AS UserType6sThat,
              i.SubRevenue,
              i.TrainingPlanRevenue,
              i.WKORevenue
      Into Reporting..UBCEvaluation
      From Prep As p Left Outer Join Reporting..CoachedAthletes As c On p.PersonId=c.PersonId And p.BecameCoachedOn=c.CoachedFromDate 
                     Left Outer Join PayPalInfo As i On p.PersonId=i.PersonId
END

GO
