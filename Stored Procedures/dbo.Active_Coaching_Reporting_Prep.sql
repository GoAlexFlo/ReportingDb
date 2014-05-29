SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[Active_Coaching_Reporting_Prep]
	@QDate smalldatetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	declare @temp_holder table
	(
		personid int, 
		usertype int,
		bucket varchar(25),
		isactive bit,
		haspaid bit
	)

	insert into @temp_holder(personid, usertype, bucket, isactive, haspaid)
	select personid, usertype, 
	bucket = 
		case 
			when DateDiff(d,AccountCreationDate, @QDate)between 0 and 30 then 'a'
			when DateDiff(d,AccountCreationDate, @QDate) between 31 and 90 then 'b'
			when DateDiff(d,AccountCreationDate, @QDate) between 91 and 180 then 'c'
			when DateDiff(d,AccountCreationDate, @QDate) between 181 and 360 then 'd'
			when DateDiff(d,AccountCreationDate, @QDate) between 361 and 720 then 'e'
			--when DateDiff(d,AccountCreationDate, @QDate) > 721 then 'b'
			else 'f'
			end,
		 IsActive = 
			case when  DATEDIFF(d, lastlogon, @QDate)<= 7 then 1
			else 0 end,
		HasPaid = 
		  case when
		(select count(PaypalImportId) 
			from PaypalImport where Sku like 'cv%' and personid=person.personid)>0 then 1
		  else 0 end
	from Person
	where usertype in(2,5) and not AccountCreationDate is null and not lastlogon is null
	and DateDiff(d,AccountCreationDate, @QDate)>=0
	--and DATEDIFF(d, lastlogon, @QDate)<= 7
	
	select COUNT(personid) as num_per_bucket, bucket, usertype, isactive, haspaid as coach_pmt from @temp_holder
	group by bucket, usertype, isactive, haspaid
	order by bucket, usertype, isactive, haspaid
END


GO
