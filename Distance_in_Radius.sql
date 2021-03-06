--https://www.plumislandmedia.net/mysql/haversine-mysql-nearest-loc/
SELECT top 15 Place_Desc, latitude, longitude,
      distance_unit* DEGREES(ACOS(COS(RADIANS(latpoint))
                 * COS(RADIANS(latitude))
                 * COS(RADIANS(longpoint) - RADIANS(longitude))
                 + SIN(RADIANS(latpoint))
                 * SIN(RADIANS(latitude)))) AS distance_in_km
 FROM [BRIUTNT\amir.shaked].tbl_Ishuving_Israel
 JOIN (
     SELECT 32.6173083364942  AS latpoint,  35.3026787426098 AS longpoint, 
     --מרחק נמדד בקילומטרים מעפולה ברדיוס של 50 קילומטר עבור 15 הישובים הקרובים ביותר בבסיס הנתונים
     50.0 AS radius,  111.045 AS distance_unit
   ) AS p ON 1=1
   
 where latitude BETWEEN latpoint - (radius / distance_unit)
             AND latpoint + (radius / distance_unit)
             
  and longitude BETWEEN longpoint - (radius / (distance_unit * COS(RADIANS(latpoint))))
              AND longpoint + (radius / (distance_unit * COS(RADIANS(latpoint)))) 
   
 ORDER BY distance_in_km
 