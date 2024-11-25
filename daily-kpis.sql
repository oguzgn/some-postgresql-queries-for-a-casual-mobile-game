SELECT
  sessions.Date,
  sessions.CountryCode,
  sessions.DeviceType,
  DailySessions,
  UniqueUser,
  COALESCE(NewUser, 0) AS NewUser,
  CASE WHEN (UniqueUser - NewUser IS NULL) THEN UniqueUser ELSE UniqueUser - NewUser END AS ReturnedUser,
  COALESCE(Revenue, 0) AS Revenue,
  COALESCE(OrderCount, 0) AS OrderCount
FROM (
  SELECT
    CAST(CreationTime AS DATE) AS Date,
    CountryCode,
    DeviceType,
    COUNT(Id) AS DailySessions,
    COUNT(DISTINCT UserId) AS UniqueUser
  FROM (
    SELECT
      nll.*,
      au.CountryCode AS CountryCode,
      au.DeviceType AS DeviceType,
    FROM
      `xxx.db.LoginLog` nll
    LEFT JOIN
      `xxx.db.AbpUser` au
    ON
      nll.UserId = au.Id )
  GROUP BY
    Date,
    CountryCode,
    DeviceType
  ORDER BY
    Date ASC) AS sessions
LEFT JOIN (
  SELECT
    CAST(CreationTime AS Date) AS RegsDate,
    CountryCode,
    DeviceType,
    COUNT(DISTINCT Id) AS NewUser
  FROM
    `xxx.db.AbpUser`
  WHERE
    CAST(CreationTime AS Date) >="2022-12-09"
  GROUP BY
    RegsDate,
    CountryCode,
    DeviceType
  ORDER BY
    RegsDate ASC ) AS new_users
ON
  sessions.Date = new_users.RegsDate
  AND sessions.CountryCode = new_users.CountryCode
  AND sessions.DeviceType=new_users.DeviceType
LEFT JOIN (
  SELECT
    CAST(o.CreationTime AS Date) AS Date,
    au.CountryCode,
    au.DeviceType,
    SUM(p.Price) AS Revenue,
    COUNT(o.Id) AS OrderCount
  FROM
    `xxx.db.NsOrder` o
  LEFT JOIN
    `xxx.db.AbpUser` au
  ON
    au.Id = o.UserId
  LEFT JOIN
    `xxx.db.NsProduct` p
  ON
    p.Id = o.ProductId
  WHERE
    p.CurrencyType = 5
    AND CAST(o.CreationTime AS Date) >="2022-12-09"
  GROUP BY
    Date,
    CountryCode,
    DeviceType
  ORDER BY
    date ASC ) AS orders
ON
  sessions.Date = orders.Date
  AND sessions.CountryCode = orders.CountryCode
  AND sessions.DeviceType = orders.DeviceType
ORDER BY
  sessions.Date ASC;
