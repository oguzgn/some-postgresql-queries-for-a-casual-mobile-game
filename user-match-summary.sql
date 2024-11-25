select
	mu."MatchId" as Id,
	au."Id" as UserId,
	au."CountryCode" as CountryCode,
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
	au."IsDeleted" as IsDeleted,
	nsa."Email" as Email,
	m."CreationTime" as event_time,
	au."CreationTime" as Registration_time,
	extract(EPOCH from (m."CreationTime" - au."CreationTime")) / 3600 as hour_time_diff,
	extract(EPOCH from (m."CreationTime" - au."CreationTime")) / 60 as min_time_diff,
	m."MatchTime" as matchdur,
	case when m."WinnerTeamColor" = mu."TeamColor" then 'win' else 'lose' end as is_won,
	case when mu."QuitMatchTime" is not null then 'exit' else 'complete' end as exit_match,
	mu."QuitMatchTime" as QuitMatchTime
from
	"MatchUser" mu
left join
    "AbpUsers" au
  on
	au."Id" = mu."UserId"
left join
    "Match" m
  on
	mu."MatchId" = m."Id"
left join 
	"SocialAccount" nsa 
	on
	mu."UserId" = nsa."UserId"
where  mu."UserId" is not null
