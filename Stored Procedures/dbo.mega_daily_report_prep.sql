SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Dave K.
-- Create date: 9.10.2010
-- Description:	Big daddy for mega summary nightly metric report
-- =============================================
CREATE PROCEDURE [dbo].[mega_daily_report_prep]
	--@queryDate as datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
--///////////////////////////////////////////////////////////////////////////////////////////////////
--// assumes its running in early morning (after DB table update), so "the relevant date" is all day yesterday
--//	below is logic that, if the 'hour' of the day is before noon, use yesterday, otherwise use today
declare @queryDate as datetime
declare @hoursToGoBack int
declare @hour as int
select @hour = DATEPART(hh, getdate())
if(@hour < 12)
	begin
		select @hoursToGoBack = -1 * (@hour + 1) -- go back before midnight of yesterday
		select @queryDate = DATEADD(hh, @hoursToGoBack, getdate()) 
	end
else
	select @queryDate = GETDATE()

--// prep dates ('the morning' of selected date, and first day of the month morning)
declare @m int
declare @y int
declare @d int
declare @first_day_of_month as datetime
declare @this_morning_date as datetime
select @d = DAY(@queryDate)
select @m = MONTH(@queryDate)
select @y = YEAR(@queryDate)

select @this_morning_date = convert(datetime, Convert(varchar,@m) + '-' + Convert(varchar,@d) + '-' + Convert(varchar,@y) )
select @first_day_of_month = convert(datetime, Convert(varchar,@m) + '-' + Convert(varchar,1) + '-' + Convert(varchar,@y) )

--// mega table of results 
--//	two rows, one for day, one for month
--//	done this way so dbxtra can handle all these disperate values
	declare @temp_holder table
	(
		scope tinyint, -- 1= just day, 2=month view (used for updating)
		coached_athlete_tot int null, paid_coach_tot int null,self_coach_tot int null,	demo_coach_tot int null, logon_only_tot int null,
		coached_athlete_logins int null, paid_coach_logins int null,self_coach_logins int null, demo_coach_logins int null,	logon_only_logins int null,
		coached_athlete_new int null, paid_coach_new int null,self_coach_new int null, demo_coach_new int null,	logon_only_new int null,
		tp_plan_sales_total decimal(9,2) null, self_coached_total decimal(9,2) null,self_coached_affil_total decimal(9,2) null, ubc_subs_total decimal(9,2) null,
		coach_billing_tot decimal(9,2) null,
		cpsoftpak3_tot decimal(9,2) null, cpsoftpak3up_tot decimal(9,2) null, crs_tot decimal(9,2) null, erg_tot decimal(9,2) null, 
		procombo3_tot decimal(9,2) null, rd3_tot decimal(9,2) null, wko3_tot decimal(9,2) null, wko3_upgrade_tot decimal(9,2) null
	)
--// insert two rows, one for 'previous day' and one for 'month to date' (then do updates as we progress)
insert into @temp_holder(scope) values(1)
insert into @temp_holder(scope) values(2)

-- //////////////////////////////////////////////////////////////////////////
--// total count per user type (filter for just active ?)
--		store these in first row (only one set of these)
declare @usertype int
declare @count int
DECLARE tot_count_cursor CURSOR FAST_FORWARD READ_ONLY FOR
	select COUNT(personid) as num_per, usertype from ultrafit_live.dbo.person group by usertype order by usertype
	OPEN tot_count_cursor
	FETCH NEXT FROM tot_count_cursor INTO @count, @usertype
		WHILE @@FETCH_STATUS = 0
		BEGIN
			if(@usertype= 1) -- coached athlete
				update @temp_holder set coached_athlete_tot = @count where scope=1
			if(@usertype = 2) -- paid coach
				update @temp_holder set paid_coach_tot = @count where scope=1
			if(@usertype = 4) -- self coached athlete
				update @temp_holder set self_coach_tot = @count where scope=1
			if(@usertype = 5) -- demo coach
				update @temp_holder set demo_coach_tot = @count where scope=1
			if(@usertype = 6) -- log on only - self coached
				update @temp_holder set logon_only_tot = @count where scope=1
		FETCH NEXT FROM tot_count_cursor INTO @count, @usertype
	END

	CLOSE tot_count_cursor
	DEALLOCATE tot_count_cursor

-- //////////////////////////////////////////////////////////////////////////
--// get count of distinct logins per user type
--		a) first for day
DECLARE login_first_cursor CURSOR FAST_FORWARD READ_ONLY FOR
	select count(distinct p.personid) as num_per_type, p.usertype from ultrafit_live.dbo.Person p 
		inner join ultrafit_live.dbo.PersonLoginHistory plh on p.personid=plh.PersonId
		where plh.DateOfLogin >= @this_morning_date and plh.DateOfLogin <= @queryDate
		group by p.usertype order by p.usertype
	OPEN login_first_cursor
	FETCH NEXT FROM login_first_cursor INTO @count, @usertype
		WHILE @@FETCH_STATUS = 0
		BEGIN
			if(@usertype= 1) -- coached athlete
				update @temp_holder set coached_athlete_logins = @count where scope=1
			if(@usertype = 2) -- paid coach
				update @temp_holder set paid_coach_logins = @count where scope=1
			if(@usertype = 4) -- self coached athlete
				update @temp_holder set self_coach_logins = @count where scope=1
			if(@usertype = 5) -- demo coach
				update @temp_holder set demo_coach_logins = @count where scope=1
			if(@usertype = 6) -- log on only - self coached
				update @temp_holder set logon_only_logins = @count where scope=1
		FETCH NEXT FROM login_first_cursor INTO @count, @usertype
	END

	CLOSE login_first_cursor
	DEALLOCATE login_first_cursor
-- //////////////////////////////////////////////////////////////////////////
--// get count of distinct logins per user type
--		b) for month
DECLARE login_second_cursor CURSOR FAST_FORWARD READ_ONLY FOR
	select count(distinct p.personid) as num_per_type, p.usertype from ultrafit_live.dbo.Person p 
		inner join ultrafit_live.dbo.PersonLoginHistory plh on p.personid=plh.PersonId
		where plh.DateOfLogin >= @first_day_of_month and plh.DateOfLogin <= @queryDate
		group by p.usertype order by p.usertype
	OPEN login_second_cursor
	FETCH NEXT FROM login_second_cursor INTO @count, @usertype
		WHILE @@FETCH_STATUS = 0
		BEGIN
			if(@usertype= 1) -- coached athlete
				update @temp_holder set coached_athlete_logins = @count where scope=2
			if(@usertype = 2) -- paid coach
				update @temp_holder set paid_coach_logins = @count where scope=2
			if(@usertype = 4) -- self coached athlete
				update @temp_holder set self_coach_logins = @count where scope=2
			if(@usertype = 5) -- demo coach
				update @temp_holder set demo_coach_logins = @count where scope=2
			if(@usertype = 6) -- log on only - self coached
				update @temp_holder set logon_only_logins = @count where scope=2
		FETCH NEXT FROM login_second_cursor INTO @count, @usertype
	END

	CLOSE login_second_cursor
	DEALLOCATE login_second_cursor

-- //////////////////////////////////////////////////////////////////////////
--// get count of new signups per usertype
--	a) for the day
DECLARE signups_first_cursor CURSOR FAST_FORWARD READ_ONLY FOR
	select COUNT(personid) as num_per, usertype from ultrafit_live.dbo.person 
		where AccountCreationDate >= @this_morning_date and AccountCreationDate <= @queryDate
		group by usertype order by usertype
	OPEN signups_first_cursor
	FETCH NEXT FROM signups_first_cursor INTO @count, @usertype
		WHILE @@FETCH_STATUS = 0
		BEGIN
			if(@usertype= 1) -- coached athlete
				update @temp_holder set coached_athlete_new = @count where scope=1
			if(@usertype = 2) -- paid coach
				update @temp_holder set paid_coach_new = @count where scope=1
			if(@usertype = 4) -- self coached athlete
				update @temp_holder set self_coach_new = @count where scope=1
			if(@usertype = 5) -- demo coach
				update @temp_holder set demo_coach_new = @count where scope=1
			if(@usertype = 6) -- log on only - self coached
				update @temp_holder set logon_only_new = @count where scope=1
		FETCH NEXT FROM signups_first_cursor INTO @count, @usertype
	END

	CLOSE signups_first_cursor
	DEALLOCATE signups_first_cursor
-- //////////////////////////////////////////////////////////////////////////
--// get count of new signups per usertype
--	b) for the month
DECLARE signups_second_cursor CURSOR FAST_FORWARD READ_ONLY FOR
	select COUNT(personid) as num_per, usertype from ultrafit_live.dbo.person 
		where AccountCreationDate >= @first_day_of_month and AccountCreationDate <= @queryDate
		group by usertype order by usertype
	OPEN signups_second_cursor
	FETCH NEXT FROM signups_second_cursor INTO @count, @usertype
		WHILE @@FETCH_STATUS = 0
		BEGIN
			if(@usertype= 1) -- coached athlete
				update @temp_holder set coached_athlete_new = @count where scope=2
			if(@usertype = 2) -- paid coach
				update @temp_holder set paid_coach_new = @count where scope=2
			if(@usertype = 4) -- self coached athlete
				update @temp_holder set self_coach_new = @count where scope=2
			if(@usertype = 5) -- demo coach
				update @temp_holder set demo_coach_new = @count where scope=2
			if(@usertype = 6) -- log on only - self coached
				update @temp_holder set logon_only_new = @count where scope=2
		FETCH NEXT FROM signups_second_cursor INTO @count, @usertype
	END

	CLOSE signups_second_cursor
	DEALLOCATE signups_second_cursor

declare @temp_decimal decimal(9,2)

-- //////////////////////////////////////////////////////////////////////////
--// total plans sales
--//	a) today
select @temp_decimal = Sum(Total /100.0) from  ultrafit_live.dbo.v_ReconciledPaypalImport 
	where Sku like 'tp-%' and TransId Is Not Null
	and PaypalDate >= @this_morning_date and PaypalDate <= @queryDate
update @temp_holder set tp_plan_sales_total=@temp_decimal where scope=1
select @temp_decimal = 0

--	b) this month
select @temp_decimal = Sum(Total /100.0) from  ultrafit_live.dbo.v_ReconciledPaypalImport 
	where Sku like 'tp-%' and TransId Is Not Null
	and PaypalDate >= @first_day_of_month and PaypalDate <= @queryDate
update @temp_holder set tp_plan_sales_total=@temp_decimal where scope=2
select @temp_decimal = 0

-- //////////////////////////////////////////////////////////////////////////
-- // total premium self coached
--		a) for day
SELECT @temp_decimal = SUM(Total)/100.0 FROM  ultrafit_live.dbo.v_ReconciledPaypalImport 
WHERE sku LIKE 'sca%' and TransId Is Not Null
and PaypalDate >= @this_morning_date and PaypalDate <= @queryDate
update @temp_holder set self_coached_total=@temp_decimal where scope=1
select @temp_decimal = 0

--		b) for month
SELECT @temp_decimal = SUM(Total)/100.0 FROM  ultrafit_live.dbo.v_ReconciledPaypalImport 
	WHERE sku LIKE 'sca%' and TransId Is Not Null
	and PaypalDate >= @first_day_of_month and PaypalDate <= @queryDate
update @temp_holder set self_coached_total=@temp_decimal where scope=2
select @temp_decimal = 0

-- //////////////////////////////////////////////////////////////////////////
-- // total premium self coached --> Affiliate IsRevenueShareAffiliate
--//		will subtract 30% of this from above totals to get "TP cut"
--		a) for day
SELECT @temp_decimal = SUM(rpi.Total)/100.0 FROM  ultrafit_live.dbo.v_ReconciledPaypalImport rpi
	inner join ultrafit_live.dbo.Affiliate a on rpi.AffiliateCode = a.Code
WHERE rpi.sku LIKE 'sca%' and rpi.TransId Is Not Null
	and rpi.PaypalDate >= @this_morning_date and rpi.PaypalDate <= @queryDate
	and a.AffiliateId in(select AffiliateId from ultrafit_live.dbo.Affiliate where IsRevenueShareAffiliate=1)
update @temp_holder set self_coached_affil_total=@temp_decimal where scope=1
select @temp_decimal = 0

--		b) for month
SELECT @temp_decimal = SUM(rpi.Total)/100.0 FROM  ultrafit_live.dbo.v_ReconciledPaypalImport rpi
inner join ultrafit_live.dbo.Affiliate a on rpi.AffiliateCode = a.Code
WHERE rpi.sku LIKE 'sca%' and rpi.TransId Is Not Null
	and rpi.PaypalDate >= @first_day_of_month and rpi.PaypalDate <= @queryDate
	and a.AffiliateId in(select AffiliateId from ultrafit_live.dbo.Affiliate where IsRevenueShareAffiliate=1)

update @temp_holder set self_coached_affil_total=@temp_decimal where scope=2
select @temp_decimal = 0
 
-- //////////////////////////////////////////////////////////////////////////
-- // total UBC $$
--		a) for day
SELECT @temp_decimal = SUM(Total)/100.0 FROM  ultrafit_live.dbo.v_ReconciledPaypalImport 
	WHERE (sku LIKE 'cvr%' or Sku like 'cvap%')  and TransId Is Not Null
	and PaypalDate >=@this_morning_date  and PaypalDate <= @queryDate
update @temp_holder set ubc_subs_total=@temp_decimal where scope=1
select @temp_decimal = 0

--		b) for month
SELECT @temp_decimal = SUM(Total)/100.0 FROM  ultrafit_live.dbo.v_ReconciledPaypalImport 
	WHERE (sku LIKE 'cvr%' or Sku like 'cvap%') and TransId Is Not Null
	and PaypalDate >= @first_day_of_month  and PaypalDate <= @queryDate
update @temp_holder set ubc_subs_total=@temp_decimal where scope=2
select @temp_decimal = 0

-- //////////////////////////////////////////////////////////////////////////
-- // average coach income ....
--	a) for the day first 
select @temp_decimal = sum([dbo].[CalcDailyTotalForCoach](cc.coachid, cc.num_clients)) 
	from ultrafit_live.dbo.client_count cc where cc.thedate between @this_morning_date and @queryDate
update @temp_holder set coach_billing_tot=@temp_decimal where scope=1
select @temp_decimal = 0

--	b) for the month
select @temp_decimal = sum([dbo].[CalcDailyTotalForCoach](cc.coachid, cc.num_clients)) 
	from ultrafit_live.dbo.client_count cc where cc.thedate between @first_day_of_month and @queryDate	
update @temp_holder set coach_billing_tot=@temp_decimal where scope=2
select @temp_decimal = 0

-- //////////////////////////////////////////////////////////////////////////
--// software sales by sku
--		a) for day
declare @sku varchar(50)
DECLARE software_one CURSOR FAST_FORWARD READ_ONLY FOR
	SELECT SUM(Total)/100.0 AS total, sku FROM  ultrafit_live.dbo.v_ReconciledPaypalImport 
		WHERE (sku LIKE 'wko%' OR sku LIKE 'procombo%' OR sku LIKE 'cpsoft%' OR sku 
				LIKE 'erg%' OR sku LIKE 'r3d%' OR sku LIKE 'crs%' OR sku LIKE 'computrainer%') 
				and TransId Is Not Null and PaypalDate >= @this_morning_date and PaypalDate <= @queryDate
		group by sku
	OPEN software_one
	FETCH NEXT FROM software_one INTO @temp_decimal, @sku
		WHILE @@FETCH_STATUS = 0
		BEGIN
			if(@sku= 'cpsoftpak3')
				update @temp_holder set cpsoftpak3_tot = @temp_decimal where scope=1
			if(@sku= 'cpsoftpak3up')
				update @temp_holder set cpsoftpak3up_tot = @temp_decimal where scope=1
			if(@sku= 'crs')
				update @temp_holder set crs_tot = @temp_decimal where scope=1
			if(@sku= 'erg')
				update @temp_holder set erg_tot = @temp_decimal where scope=1
			if(@sku= 'procombo3')
				update @temp_holder set procombo3_tot = @temp_decimal where scope=1
			if(@sku= 'rd3')
				update @temp_holder set rd3_tot = @temp_decimal where scope=1
			if(@sku= 'wko3')
				update @temp_holder set wko3_tot = @temp_decimal where scope=1
			if(@sku= 'wko3_upgrade')
				update @temp_holder set wko3_upgrade_tot = @temp_decimal where scope=1						
		FETCH NEXT FROM software_one INTO @temp_decimal, @sku
	END
	CLOSE software_one
	DEALLOCATE software_one

-- //////////////////////////////////////////////////////////////////////////
--// software sales by sku
--		b) for month
select @temp_decimal = 0
select @sku = ''
DECLARE software_two CURSOR FAST_FORWARD READ_ONLY FOR
	SELECT SUM(Total)/100.0 AS total, sku FROM  ultrafit_live.dbo.v_ReconciledPaypalImport 
		WHERE (sku LIKE 'wko%' OR sku LIKE 'procombo%' OR sku LIKE 'cpsoft%' OR sku 
			LIKE 'erg%' OR sku LIKE 'r3d%' OR sku LIKE 'crs%' OR sku LIKE 'computrainer%') 
				and TransId Is Not Null and PaypalDate >= @first_day_of_month and PaypalDate <= @queryDate
		group by sku
	OPEN software_two
	FETCH NEXT FROM software_two INTO @temp_decimal, @sku
		WHILE @@FETCH_STATUS = 0
		BEGIN
			if(@sku= 'cpsoftpak3')
				update @temp_holder set cpsoftpak3_tot = @temp_decimal where scope=2
			if(@sku= 'cpsoftpak3up')
				update @temp_holder set cpsoftpak3up_tot = @temp_decimal where scope=2
			if(@sku= 'crs')
				update @temp_holder set crs_tot = @temp_decimal where scope=2
			if(@sku= 'erg')
				update @temp_holder set erg_tot = @temp_decimal where scope=2
			if(@sku= 'procombo3')
				update @temp_holder set procombo3_tot = @temp_decimal where scope=2
			if(@sku= 'rd3')
				update @temp_holder set rd3_tot = @temp_decimal where scope=2
			if(@sku= 'wko3')
				update @temp_holder set wko3_tot = @temp_decimal where scope=2
			if(@sku= 'wko3_upgrade')
				update @temp_holder set wko3_upgrade_tot = @temp_decimal where scope=2						
		FETCH NEXT FROM software_two INTO @temp_decimal, @sku
	END
	CLOSE software_two
	DEALLOCATE software_two
	--select @this_morning_date, @first_day_of_month, @queryDate
	select * from @temp_holder
END


GO
