with ds as (with
  lg as (
select
	COUNT("Id") as SessionCount,
	"UserId",
	cast("CreationTime" as date) as LoginDate
from
	"LoginLog"
group by
	"UserId",
	LoginDate ),
  fd as (
select
	"UserId",
	cast(MIN("CreationTime") as date) as FirstLoginTime
from
	"LoginLog"
group by
	"UserId" )
select
	lg.*,
	fd.FirstLoginTime
from
	lg
left join
  fd
on
	lg."UserId" = fd."UserId"
order by
	SessionCount desc),
  au as (
select
	*
from
	"AbpUsers" au)
  select
	ds.*,
	au."CountryCode",
		case
		when au."DeviceType" = 0 then 'None'
		when au."DeviceType" = 1 then 'Ios'
		when au."DeviceType" = 2 then 'Android'
		when au."DeviceType" = 3 then 'Windows'
		when au."DeviceType" = 4 then 'Macos'
		when au."DeviceType" = 5 then 'Linux'
		else
  'Unknown'
	end
  as DeviceType,
au."DeviceModel",
from
	ds
left join au on
	ds."UserId" = au."Id"
