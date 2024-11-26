WITH ugs AS
  (SELECT nugs.*,
          upg."TotalUpgrades" AS TotalCardUpgrades
   FROM
     (SELECT nugs.*,
             coalesce(order_activity.ordercount, 0) AS ordercount,
             coalesce(order_activity.Revenue, 0) AS Revenue
      FROM "UserGameState" nugs
      LEFT JOIN
        (SELECT nso."UserId",
                COUNT(nso."Id") AS ordercount,
                ROUND(SUM(np."Price"), 0) AS Revenue
         FROM "Order" nso
         LEFT JOIN "Product" np ON np."Id" = nso."ProductId"
         WHERE np."CurrencyType" = 5
         GROUP BY "UserId") AS order_activity ON nugs."UserId" = order_activity."UserId") nugs
   LEFT JOIN
     (SELECT inv."UserId",
             SUM(inv."Level" - coalesce(card."InitialLevel", 0)) AS "TotalUpgrades"
      FROM "Inventory" inv
      LEFT JOIN "NsCard" card ON card."Id" = inv."CardId"
      WHERE inv."CardId" IS NOT NULL
        AND inv."Level" >= coalesce(card."InitialLevel", 0)
      GROUP BY inv."UserId"
      ORDER BY "TotalUpgrades" DESC) upg ON upg."UserId" = nugs."UserId"),
     au AS
  (SELECT *
   FROM "AbpUsers")
SELECT ugs.*,
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
FROM ugs
LEFT JOIN au ON ugs."UserId" = au."Id"

  
// This query groups certain user-based data and provides insights into total matches, total purchases, total upgrades, and other similar metrics for each user.
