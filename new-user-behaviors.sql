WITH
  match_activity AS (
    SELECT
      mu.MatchId AS Id,
      au.Id AS UserId,
      au.CountryCode AS CountryCode,
      au.DeviceName AS DeviceName,
      au.DeviceModel AS DeviceModel,
      au.DeviceType AS DeviceType,
      au.IsDeleted AS IsDeleted,
      au.EmailAddress AS Email,
      au.TenantId AS TenantId,
      m.CreationTime AS event_time,
      au.CreationTime AS Registration_time,
      CAST(ROUND((TIMESTAMP_DIFF(m.CreationTime, au.CreationTime, SECOND) / 3600), 0) AS INT64) AS hour_time_diff,
      CAST(ROUND((TIMESTAMP_DIFF(m.CreationTime, au.CreationTime, SECOND) / 60), 0) AS INT64) AS min_time_diff,
      m.MatchTime AS matchdur,
      CASE
        WHEN m.WinnerTeamColor = mu.TeamColor THEN 'win'
        ELSE 'lose'
      END AS is_won,
      CASE
        WHEN mu.QuitMatchTime IS NOT NULL THEN 'exit'
        ELSE 'complete'
      END AS exit_match,
      mu.QuitMatchTime AS QuitMatchTime,
      0 AS Price,
      '-' AS Product_name,
      99 AS Currencytype,
      'match' AS event_type
    FROM
      `xxx.db.MatchUser` mu
    LEFT JOIN
      `xxx.db.AbpUser` au
    ON
      au.Id = mu.UserId
    LEFT JOIN
      `xxx.db.Match` m
    ON
      mu.MatchId = m.Id
  ),
  order_activity AS (
    SELECT
      o.Id AS Id,
      au.Id AS UserId,
      au.CountryCode AS CountryCode,
      au.DeviceName AS DeviceName,
      au.DeviceModel AS DeviceModel,
      au.DeviceType AS DeviceType,
      au.IsDeleted AS IsDeleted,
      au.EmailAddress AS Email,
      au.TenantId AS TenantId,
      o.CreationTime AS event_time,
      au.CreationTime AS Registration_time,
      CAST(ROUND((TIMESTAMP_DIFF(o.CreationTime, au.CreationTime, SECOND) / 3600), 0) AS INT64) AS hour_time_diff,
      CAST(ROUND((TIMESTAMP_DIFF(o.CreationTime, au.CreationTime, SECOND) / 60), 0) AS INT64) AS min_time_diff,
      0 AS matchdur,
      CAST(NULL AS STRING) AS is_won,
      '-' AS exit_match,
      0 AS QuitMatchTime,
      p.Price AS Price,
      p.Name AS Product_name,
      p.CurrencyType AS Currencytype,
      'order' AS event_type
    FROM
      `xxx.db.Order` o
    LEFT JOIN
      `xxx.db.AbpUser` au
    ON
      au.Id = o.UserId
    LEFT JOIN
      `xxx.db.Product` p
    ON
      p.Id = o.ProductId
  )
SELECT
  Id,
  UserId,
  CountryCode,
  DeviceName,
  DeviceModel,
  DeviceType,
  IsDeleted,
  Email,
  TenantId,
  event_time,
  Registration_time,
  hour_time_diff,
  min_time_diff,
  matchdur,
  is_won,
  exit_match,
  QuitMatchTime,
  Price,
  Product_name,
  Currencytype,
  event_type
FROM
  match_activity
WHERE
  UserId IS NOT NULL
UNION ALL
SELECT
  Id,
  UserId,
  CountryCode,
  DeviceName,
  DeviceModel,
  DeviceType,
  IsDeleted,
  Email,
  TenantId,
  event_time,
  Registration_time,
  hour_time_diff,
  min_time_diff,
  matchdur,
  is_won,
  exit_match,
  QuitMatchTime,
  Price,
  Product_name,
  Currencytype,
  event_type
FROM
  order_activity
ORDER BY
  hour_time_diff DESC;


// This query is designed to understand user behavior trends, such as how many matches were played, how much money was spent, and how much shopping was done within the first few hours of playing the game (for example, during the first 72 and 144 hours). This helps in developing strategies based on those insights.
