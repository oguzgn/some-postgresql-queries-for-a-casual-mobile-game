SELECT
  sessions.Year,
  sessions.Week,
  sessions.CountryCode,
  CASE
    WHEN sessions.DeviceType = 0 THEN 'None'
    WHEN sessions.DeviceType = 1 THEN 'Ios'
    WHEN sessions.DeviceType = 2 THEN 'Android'
    WHEN sessions.DeviceType = 3 THEN 'Windows'
    WHEN sessions.DeviceType = 4 THEN 'Macos'
    WHEN sessions.DeviceType = 5 THEN 'Linux'
  ELSE
  'Unknown'
END
  AS DeviceType,
  sessions.DeviceModel,
  WeeklySessions,
  UniqueUser,
  COALESCE(NewUser, 0) AS NewUser,
  CASE WHEN (UniqueUser - NewUser IS NULL) THEN UniqueUser ELSE UniqueUser - NewUser END AS ReturnedUser,
  COALESCE(Revenue, 0) AS Revenue,
  COALESCE(OrderCount, 0) AS OrderCount
FROM (
  SELECT
    EXTRACT(YEAR FROM CreationTime) AS Year,
    EXTRACT(ISOWEEK FROM CreationTime) AS Week,
    CountryCode,
    DeviceType,
    DeviceModel,
    COUNT(Id) AS WeeklySessions,
    COUNT(DISTINCT UserId) AS UniqueUser
  FROM (
    SELECT
      nll.*,
      au.CountryCode AS CountryCode,
      au.DeviceType AS DeviceType,
      au.DeviceModel as DeviceModel
    FROM
      `xxx.db.LoginLog` nll
    LEFT JOIN
      `xxx.db.AbpUser` au
    ON
      nll.UserId = au.Id )
  GROUP BY
    Year,
    Week,
    CountryCode,
    DeviceType,
    DeviceModel
  ORDER BY
    Year ASC,
    Week ASC,
    WeeklySessions DESC) AS sessions
LEFT JOIN (
  SELECT
    EXTRACT(YEAR FROM CreationTime) AS Year,
    EXTRACT(ISOWEEK FROM CreationTime) AS Week,
    CountryCode,
    DeviceType,
    DeviceModel,
    COUNT(DISTINCT Id) AS NewUser
  FROM
    `xxx.db.AbpUser`
  WHERE
    CAST(CreationTime AS Date) >="2022-12-09"
  GROUP BY
    Year,
    Week,
    CountryCode,
    DeviceType,
    DeviceModel
  ORDER BY
    Year ASC,
    Week ASC,
    NewUser DESC) AS new_users
ON
  sessions.Year = new_users.Year
  AND sessions.Week = new_users.Week
  AND sessions.CountryCode = new_users.CountryCode
  AND sessions.DeviceType=new_users.DeviceType
  AND sessions.DeviceModel = new_users.DeviceModel
LEFT JOIN (
  SELECT
    EXTRACT(YEAR FROM CreationTime) AS Year,
    EXTRACT(ISOWEEK FROM CreationTime) AS Week,
    au.CountryCode,
    au.DeviceType,
    au.DeviceModel,
    SUM(p.Price) AS Revenue,
    COUNT(o.Id) AS OrderCount
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
  WHERE
    p.CurrencyType = 5
    AND CAST(o.CreationTime AS Date) >="2022-12-09"
  GROUP BY
    Year,
    Week,
    CountryCode,
    DeviceType,
    DeviceModel
  ORDER BY
    Year ASC,
    Week ASC) AS orders
ON
  sessions.Year = orders.Year
  AND sessions.Week = orders.Week
  AND sessions.CountryCode = orders.CountryCode
  AND sessions.DeviceType = orders.DeviceType
  AND sessions.DeviceModel = orders.DeviceModel
ORDER BY
  sessions.Year ASC,
  sessions.Week ASC,
  sessions.WeeklySessions DESC;
