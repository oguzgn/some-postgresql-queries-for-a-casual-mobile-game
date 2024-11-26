with gem as (with coinreward as (
select
	nrl."UserId",
	SUM(nrl."Amount") as "TotalReward"
from
	"RewardLog" nrl
where
	nrl."UserId" <> 0
	and nrl."ItemType" = 3
group by
	nrl."UserId"
),
gemreward as (
select
	nrl."UserId",
	SUM(nrl."Amount") as "TotalReward"
from
	"RewardLog" nrl
where
	nrl."UserId" <> 0
	and nrl."ItemType" = 2
group by
	nrl."UserId"
),
orderedcoin as (
select
	nso."UserId",
	SUM(np."Amount") as "TotalOrdered"
from
	"Order" nso
left join "Product" np on
	nso."ProductId" = np."Id"
where
	np."ItemType" = 3
group by
	nso."UserId"
),
orderedgem as (
select
	nso."UserId",
	SUM(np."Amount") as "TotalOrdered"
from
	"Order" nso
left join "Product" np on
	nso."ProductId" = np."Id"
where
	np."ItemType" = 2
group by
	nso."UserId"
),
spentcoin as (
select
	nso."UserId",
	SUM(np."Price") as "TotalSpent"
from
	"Order" nso
left join "Product" np on
	nso."ProductId" = np."Id"
where
	np."CurrencyType" = 3
group by
	nso."UserId"
),
spentgem as (
select
	nso."UserId",
	SUM(np."Price") as "TotalSpent"
from
	"Order" nso
left join "Product" np on
	nso."ProductId" = np."Id"
where
	np."CurrencyType" = 2
group by
	nso."UserId"
),
upgcoinspent as (
with upg as (
select
	inv."UserId",
	inv."CardId",
	SUM(inv."Level" - coalesce(card."InitialLevel", 0)) as "TotalUpgrades"
from
	"Inventory" inv
left join "Card" card on
	card."Id" = inv."CardId"
where
	inv."CardId" is not null
	and inv."Level" >= coalesce(card."InitialLevel",
	0)
group by
	inv."UserId",
	inv."CardId"
),
upreq as (
select
	c.*
from
	cardupgreq c
),
user_spending as (
select
	upg."UserId",
	sum(coalesce(upreq."cumulativecoincount", 0)) as "TotalUpgSpent"
from
	upg
left join upreq on
	upg."CardId" = upreq."CardId"
	and upg."TotalUpgrades" = upreq."Level"
group by
	upg."UserId"
)
select
	u."UserId",
	u."TotalUpgSpent"
from
	user_spending u
order by
	u."TotalUpgSpent" desc
)
select
	coalesce(cr."UserId",
	gr."UserId",
	oc."UserId",
	og."UserId",
	sc."UserId",
	sg."UserId",
	ug."UserId") as "UserId",
	coalesce(cr."TotalReward",0) as "CoinReward",
	coalesce(oc."TotalOrdered",0) as "CoinOrdered",
	coalesce(sc."TotalSpent",0) as "CoinSpent",
	coalesce(ug."TotalUpgSpent",0) as "CoinUpgSpent", coalesce(cr."TotalReward",0) + coalesce(oc."TotalOrdered",0) - coalesce(sc."TotalSpent",0)  - coalesce(ug."TotalUpgSpent",	0) as "TotalCoin",
	coalesce(gr."TotalReward",0) as "GemReward",
	coalesce(og."TotalOrdered",0) as "GemOrdered",
	coalesce(sg."TotalSpent",0) as "GemSpent",
	coalesce(gr."TotalReward",0) + coalesce(og."TotalOrdered",0) - coalesce(sg."TotalSpent",0) as "TotalGem"
from
	coinreward cr
full outer join 
    gemreward gr on
	cr."UserId" = gr."UserId"
full outer join 
    orderedcoin oc on
	cr."UserId" = oc."UserId"
full outer join 
    orderedgem og on
	gr."UserId" = og."UserId"
full outer join 
    spentcoin sc on
	cr."UserId" = sc."UserId"
full outer join 
    spentgem sg on
	gr."UserId" = sg."UserId"
full outer join 
    upgcoinspent ug on
	cr."UserId" = ug."UserId"
order by
	"UserId" desc),
 au as (
with temp2 as (with temp1 as (
select
	distinct 
        mu."MatchId" as id,
	au."Id" as userid,
	au."CountryCode" as countrycode,
	case
		when au."DeviceType" = 0 then 'None'
		when au."DeviceType" = 1 then 'Ios'
		when au."DeviceType" = 2 then 'Android'
		when au."DeviceType" = 3 then 'Windows'
		when au."DeviceType" = 4 then 'Macos'
		when au."DeviceType" = 5 then 'Linux'
		else 'Unknown'
	end as devicetype,
	au."DeviceModel",
	au."chipset_score",
	au."Tier",
	au."IsDeleted" as isdeleted,
	nsa."Email" as email,
	m."CreationTime" as event_time,
	au."CreationTime" as registration_time,
	extract(EPOCH
from
	(m."CreationTime" - au."CreationTime")) / 3600 as hour_time_diff,
	extract(EPOCH
from
	(m."CreationTime" - au."CreationTime")) / 60 as min_time_diff,
	m."MatchTime" as matchdur,
	case
		when m."WinnerTeamColor" = mu."TeamColor" then 'win'
		else 'lose'
	end as is_won,
	case
		when mu."QuitMatchTime" is not null then 'exit'
		else 'complete'
	end as exit_match,
	mu."QuitMatchTime" as quitmatchtime
from
	"MatchUser" mu
left join (
	select
		au.*,
		c."AVERAGE of CHIPSET_GRADE" as chipset_score,
		case
			when c."tier" in ('A', 'A+') then 'High'
			when c."tier" = 'B' then 'Mid'
			when c."tier" in ('C', 'D') then 'Low'
			when au."DeviceType" = '1' then 'High'
			else 'unknown'
		end as "Tier"
	from
		"AbpUsers" au
	left join chipsetss c on
		au."DeviceModel" = c."DB_NAME"
    ) au on
	au."Id" = mu."UserId"
left join "Match" m on
	mu."MatchId" = m."Id"
left join "SocialAccount" nsa on
	mu."UserId" = nsa."UserId"
where
	mu."UserId" is not null
)
select
	temp1.*,
	row_number() over (partition by temp1.userid
order by
	temp1.event_time asc) as matchnumber
from
	temp1)
select
	userid,
	countrycode,
	devicetype,
	"DeviceModel" ,
	chipset_score,
	"Tier",
	max(matchnumber) as matchnumber
from
	temp2
	where userid is not null
group by
	userid,
	countrycode,
	devicetype,
	"DeviceModel" ,
	chipset_score,
	"Tier"
order by
	userid desc)
select
    gem.*, 
    au.countrycode,
    CASE
        WHEN au."devicetype" = '0' THEN 'None'
        WHEN au."devicetype" = '1' THEN 'Ios'
        WHEN au."devicetype" = '2' THEN 'Android'
        WHEN au."devicetype" = '3' THEN 'Windows'
        WHEN au."devicetype" = '4' THEN 'Macos'
        WHEN au."devicetype" = '5' THEN 'Linux'
        ELSE 'Unknown'
    END AS "DeviceType",
    au."DeviceModel",
    au."chipset_score",
    au."Tier",
    au."matchnumber"
from
    gem
left join au on
    gem."UserId" = au."userid"

// As the name suggests, this code was created to monitor the in-game economy and its trends. Many updates are made within the game, but how do these changes impact the game economy? All assets flowing in and out, from different sources and with varying exchange rates, are collected and grouped to provide a comprehensive view.
