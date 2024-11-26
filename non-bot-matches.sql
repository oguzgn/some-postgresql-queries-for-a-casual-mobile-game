WITH RealUserCounts AS (
SELECT
"MatchId",
"UserId",
"TrophyCount",
"TeamColor",
"QuitMatchTime",
"IsBot",
"Id",
"DestroyTowerCount",
"CrownCount",
"BotSkillRange",
"AliveTowerCount",
SUM(CASE WHEN "UserId" IS NOT NULL THEN 1 ELSE 0 END) AS real_user
FROM "MatchUser"
GROUP BY
"MatchId",
"UserId",
"TrophyCount",
"TeamColor",
"QuitMatchTime",
"IsBot",
"Id",
"DestroyTowerCount",
"CrownCount",
"BotSkillRange",
"AliveTowerCount"
)
SELECT
ru."MatchId",
ru."UserId",
ru."TrophyCount",
ru."TeamColor",
ru."QuitMatchTime",
ru."IsBot",
ru."Id",
ru."DestroyTowerCount",
ru."CrownCount",
ru."BotSkillRange",
ru."AliveTowerCount",
ru.real_user,
CASE WHEN m.is_real_match_count = 1 THEN 1 ELSE 0 END AS is_real_match ,
nm."MatchTime"
FROM RealUserCounts ru
JOIN (
SELECT
"MatchId",
CASE WHEN SUM(real_user) = 2 THEN 1 ELSE 0 END AS is_real_match_count
FROM RealUserCounts
GROUP BY "MatchId"
) m ON ru."MatchId" = m."MatchId"
LEFT JOIN "Match" nm ON ru."MatchId" = nm."Id"
ORDER BY "is_real_match" DESC;


// This query was created to capture only player-versus-player (PvP) matches played between users.
