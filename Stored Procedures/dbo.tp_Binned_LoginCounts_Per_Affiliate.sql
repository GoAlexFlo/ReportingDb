SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Dave K.
-- Create date: 2.25.2011
-- Description:	Gear wanted way to 'bin' the number of people who login x amount of times......
--			creates bins of 0-25, 26-50, etc..... (per affiliate, per month, for a date range)
-- =============================================
CREATE PROCEDURE [dbo].[tp_Binned_LoginCounts_Per_Affiliate]
	@AffiliateId int,
	@From datetime,
	@To datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

--// ================================================
--// Gears Binned counts
--// ================================================
	declare @my_temp TABLE
	(
		Y int,M int, total_logins int, personid int
	)

	insert into @my_temp
	SELECT Y, M, count(personloginhistoryid)as total_logins, PersonId
	FROM 
	(
		SELECT h.personloginhistoryid, h.PersonId, Year(DateOfLogin) as Y, Month(DateOfLogin) as M --, Day(DateOfLogin) as D
		FROM PersonLoginHistory h join Person p on h.PersonId=p.personid
		WHERE DateOfLogin BETWEEN @From AND @To and p.AffiliateId = @AffiliateId
	) t
	GROUP BY Y, M, PersonId --, D
	order by Y desc, M desc, PersonId

	select Y,M, count(*) as number_people_in_bucket, bucket = case 
		when total_logins between 0 and 25 then '0 - 25'
		when total_logins between 26 and 50 then '26 - 50'
		when total_logins between 51 and 75 then '51 - 75'
		else '75 +'
		end
	 from @my_temp
	group by Y,M, case 
		when total_logins between 0 and 25 then '0 - 25'
		when total_logins between 26 and 50 then '26 - 50'
		when total_logins between 51 and 75 then '51 - 75'
		else '75 +'
		end
	order by Y desc, M desc
	delete @my_temp
END

GO
