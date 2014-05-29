SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Dave K.
-- =============================================
CREATE PROCEDURE [dbo].[AffiliateSnapShotPerWeek]
	-- Add the parameters for the stored procedure here
	@fromDate as DateTime,
	@toDate as DateTime,
	@affiliateId as int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- // number of signups per week
    SELECT DATEADD(wk, DATEDIFF(wk, 6, l.DateOfLogin), 6) as week_starting
	, count(l.PersonLoginHistoryId) as num_logins
	, p.usertype
	into #table
	FROM personloginhistory l
	inner join Person p on l.PersonId=p.personid
	where l.DateOfLogin between @fromDate and @toDate and p.usertype in(1,2,4,5,6) and p.AffiliateId=@affiliateId
	GROUP BY DATEADD(wk, DATEDIFF(wk, 6, l.DateOfLogin), 6)
	, usertype
	ORDER BY DATEADD(wk, DATEDIFF(wk, 6, l.DateOfLogin), 6)

	SELECT DATEADD(wk, DATEDIFF(wk, 6, l.DateOfLogin), 6) as week_starting
	, count(distinct l .Personid) as num_distinct_people
	, p.usertype
	into #table2
	FROM personloginhistory l
	inner join Person p on l.PersonId=p.personid
	where l.DateOfLogin between @fromDate and @toDate and p.usertype in(1,2,4,5,6) and p.AffiliateId=@affiliateId
	GROUP BY DATEADD(wk, DATEDIFF(wk, 6, l.DateOfLogin), 6)
	, usertype
	ORDER BY DATEADD(wk, DATEDIFF(wk, 6, l.DateOfLogin), 6)
	
	select t.week_starting, t.usertype, t.num_logins,t2.num_distinct_people
	from #table t
	left join #table2 t2 on t.week_starting = t2.week_starting and t.usertype=t2.usertype order by t.week_starting, t.usertype
END

GO
