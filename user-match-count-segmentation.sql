WITH ms AS (
    SELECT
        mu."UserId" AS UserId,
        COUNT(mu."MatchId") AS TotalMatch,
        SUM(CASE WHEN m."WinnerTeamColor" = mu."TeamColor" THEN 1 ELSE 0 END) AS TotalWin,
        SUM(CASE WHEN m."WinnerTeamColor" != mu."TeamColor" THEN 1 ELSE 0 END) AS TotalLose,
        SUM(CASE WHEN mu."QuitMatchTime" IS NOT NULL THEN 1 ELSE 0 END) AS TotalExit,
        SUM(CASE WHEN mu."QuitMatchTime" IS NULL THEN 1 ELSE 0 END) AS TotalComplete,
        CASE
            WHEN COUNT(mu."MatchId") >= 500 THEN 'h: 500+'
            WHEN COUNT(mu."MatchId") >= 250 THEN 'g: 250-500'
            WHEN COUNT(mu."MatchId") >= 100 THEN 'f: 100-250'
            WHEN COUNT(mu."MatchId") >= 50 THEN 'e: 50-100'
            WHEN COUNT(mu."MatchId") >= 10 THEN 'd: 10-50'
            WHEN COUNT(mu."MatchId") >= 5 THEN 'c: 5-10'
            WHEN COUNT(mu."MatchId") >= 2 THEN 'b: 2-5'
            WHEN COUNT(mu."MatchId") = 1 THEN 'a: 1'
            ELSE '0'
        END AS MatchSegment
    FROM
        "MatchUser" mu
    LEFT JOIN
        "Match" m ON mu."MatchId" = m."Id" AND m."CreationTime" >= '2023-01-01'
    WHERE
        mu."UserId" IS NOT NULL
    GROUP BY
        mu."UserId"
    ORDER BY
        TotalMatch DESC
),
au AS (
    SELECT * FROM "AbpUsers" au
)
SELECT
    ms.*,
    au."CountryCode",
    CASE
        WHEN au."DeviceType" = 0 THEN 'None'
        WHEN au."DeviceType" = 1 THEN 'Ios'
        WHEN au."DeviceType" = 2 THEN 'Android'
        WHEN au."DeviceType" = 3 THEN 'Windows'
        WHEN au."DeviceType" = 4 THEN 'Macos'
        WHEN au."DeviceType" = 5 THEN 'Linux'
        ELSE 'Unknown'
    END AS DeviceType,
    au."DeviceModel"
FROM
    ms
LEFT JOIN
    au ON ms.UserId = au."Id";

// With this code, players are grouped based on various match segmenters, and the general characteristics of users within each group are analyzed. It also allows us to observe the impact of players' match-playing habits on other in-game factors.
