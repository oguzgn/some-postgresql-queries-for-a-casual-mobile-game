with main as(with main as ( with adj as (with ed as (
select 
	isp,
	city,
	gclid,
	store,
	app_id,
	region,
	country,
	os_name,
	revenue,
	currency,
	"language",
	platform,
	referrer,
	timezone,
	cost_type,
	att_status,
	click_time,
	created_at,
	event_name,
	is_organic,
	time_spent,
	app_version,
	cost_amount,
	cost_id_md5,
	device_name,
	device_type,
	revenue_cny,
	revenue_usd,
	sdk_version,
	search_term,
	adgroup_name,
	device_model,
	installed_at,
	network_name,
	activity_kind,
	campaign_name,
	click_referer,
	cost_currency,
	creative_name,
	event_cost_id,
	revenue_float,
	session_count,
	sk_attributed,
	sk_network_id,
	sk_redownload,
	reporting_cost,
	sk_campaign_id,
	attribution_ttl,
	engagement_time,
	impression_time,
	is_engaged_view,
	is_reattributed,
	proxy_ip_address,
	rejection_reason,
	app_version_short,
	upper(external_device_id_md5) as external_device_id_md5
from
	public."data" ed
where
	created_at is not null
	and installed_at is not null),		
fld as (
select
	UPPER(external_device_id_md5) as external_device_id_md5,
	MIN("created_at") as first_event_date,
	MIN("installed_at") as installed_date
from
	data ed
group by
	external_device_id_md5
    )
select
	ed.*,
	fld.installed_date,
	fld.first_event_date,
	cast(ed.created_at as DATE) - cast(fld.installed_date as DATE) as Datediff,
	CONCAT('Day ',
	cast(ed.created_at as DATE) - cast(fld.installed_date as DATE)) as DayLabel
from
	ed
left join fld on
	ed."external_device_id_md5" = fld."external_device_id_md5"
order by
	created_at asc),
  au as (
select
	*
from
	"AbpUsers" au)
select
	adj.*,
	au."Id" as "UserId",
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
 	au."DeviceModel"
from
	adj
left join au on
	adj."external_device_id_md5" = au."DeviceIdMD5"),
temp1 as(
select
	count("UserId"),
	"external_device_id_md5",
	"UserId",
	cast("created_at" as date) as created_at
from
	main
group by
	"UserId",
	"external_device_id_md5",
	cast("created_at" as date)),
temp2 as (
select
	distinct "UserId",
	"external_device_id_md5",
	cast("installed_date" as date) as installed_date,
	main.Datediff as datediff,
	main.DayLabel as daylabel,
	country,
	city,
	app_version_short,
	device_name,
	os_name
from
	main)
select
	temp1.*,
	temp2."installed_date",
	temp2.datediff,
	temp2.dayLabel,
	temp2.country,
	temp2.city,
	temp2.app_version_short,
	temp2.device_name,
	temp2.os_name
from
	temp1
left join temp2 on
	temp1."external_device_id_md5" = temp2."external_device_id_md5"
where
	temp1."UserId" is not null),
camp as (
select
	distinct lower(external_device_id_md5) as external_device_id_md5,
	campaign_name,
	adgroup_name ,
	creative_name ,
	network_name ,
	os_name,
	device_name ,
	country ,
	city ,
	app_version_short
from
	"data" d
where
	campaign_name <> '' )
	select
	main.*,
	camp.campaign_name,
	camp.adgroup_name ,
	camp.creative_name 
from
	main
left join camp on
	main.external_device_id_md5 = camp.external_device_id_md5
	
	
	
// Here, you can see the model I built to track users who joined our game through specific campaigns. This helps us identify which campaign has a higher retention rate.
