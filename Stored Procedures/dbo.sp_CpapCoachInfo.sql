SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[sp_CpapCoachInfo]
	@SourceDbName Varchar(25),
	@DestinationDbName Varchar(25),
	@WhereCondition Varchar(5000),
	@WhereConditionYear Varchar(4)

AS
BEGIN
SET NOCOUNT ON;
DECLARE @Sql Varchar(5000)
DECLARE @Empty Varchar(2)
SET @Empty = ''''''

Set @Sql = 
    '
    BEGIN
		SELECT Distinct p.PersonId, p.AccountCreationDate, p.LastLogon, 
		      (Select COUNT(Distinct DateOfLogin) From ultrafit..PersonLoginHistory Where PersonId=p.PersonId And YEAR(DateOfLogin)=2013) As NumberOfVisits,
		       p.UserType,
		       Case When p.AthleteType = ''Swimmer'' Then 1
		            When p.AthleteType = ''Runner'' Then 2
		            When p.AthleteType = ''Duathlete'' Then 3
		            When p.AthleteType = ''Triathlete'' Then 4
		            When p.AthleteType = ''Other'' Then 5
		            When p.AthleteType = ''Cyclist'' Then 6
		            When p.AthleteType = ''MTB'' Then 7
		            When p.AthleteType = ''Adventure Racer'' Then 8
		            When p.AthleteType = ''Climber'' Then 9
		            When p.AthleteType = ''Weight Loss'' Then 10
		            Else 0
		            End As AthleteType,
		       p.AthleteType As AthleteTypeDesc, p.Age, p.Sex, a.CoachedByPersonId, p.AffiliateId, 
			   Case 
			   When EXISTS (Select Distinct PersonId from ' + @SourceDbName + '..CouponCodeUsed Where PersonId = p.PersonId And CouponCodeType=0 And daystocompsubscription <30)
			   Then 1
			   Else 0
			   End As TrialPremiumSubCouponUsed,
			   Case 
			   When pp.PersonId Is Not Null
			   Then 1
			   Else 0
			   End As HasPaypalTrans,
			   Case 
			   When a.VirtualCoachEmails = 1
			   Then 1
			   Else 0
			   End As AthleteSubscribesToDailyWoEmail, p.AllowMarketingEmails, a.ThresholdsNotifyAthlete, a.ThresholdsAutoApply,
			   (Select CASE WHEN DATEDIFF(DAY, Min(CASE WHEN YEAR(AccountCreationDate)=1900 Then 0 Else AccountCreationDate End), Min(TransactionDate))>0
 			                THEN DATEDIFF(DAY, Min(CASE WHEN YEAR(AccountCreationDate)=1900 Then 0 Else AccountCreationDate End), Min(TransactionDate))
 			                ELSE 0
 			                END 
			    From ' + @DestinationDbName + '..PayPalProductRevenue 
                Where RowType=''Subscription'' And CreditDesc=' + @Empty + ' And TransDesc=''NewSale'' And PersonId=p.PersonId
                Group By PersonId) As DaysToPremSub,
                (Select Min(SubscriptionMonths ) As SubscriptionMonths 
			    From ' + @DestinationDbName + '..PayPalProductRevenue 
                Where RowType=''Subscription'' And CreditDesc=' + @Empty + ' And TransDesc=''NewSale'' And PersonId=p.PersonId
                Group By PersonId) As FirstPremTerm
		FROM ' + @SourceDbName + '..Person As p Inner Join ' + @SourceDbName + '..Athlete As a On p.PersonId = a.PersonId
						                       Left Outer Join ' + @DestinationDbName + '..PayPalProductRevenue As pp On p.PersonId = pp.PersonId
		WHERE ' + @WhereCondition + '
	END'
	exec(@Sql)
END


GO
