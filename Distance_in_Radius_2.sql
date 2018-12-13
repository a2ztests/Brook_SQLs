--Here we update tbl_Distances for all the Points_id to targets distances
-- this bounding-box query has the potential of returning some points that lie more than 50km diagonally from your (latpoint, longpoint): it’s only checking a bounding rectangle, not the diagonal distance.

--INSERT INTO [BRIUTNT\amir.shaked].tbl_Distances (case_no, source_points_id, source_latitude, source_longitude, target_place_desc,  target_latitude,  target_longitude, src_trg_distance)

SELECT gis.case_no, gis.Points_Id, gis.Latitude, gis.Longitude,  loc.Place_Desc, loc.Latitude, loc.Longitude,  distance
FROM [BRIUTNT\amir.shaked].tbl_Brook_GIS gis
CROSS JOIN [BRIUTNT\amir.shaked].tbl_Locations loc

CROSS APPLY (SELECT (SIN(PI()*gis.Latitude/180.0)*SIN(PI()*loc.Latitude/180.0)+COS(PI()*gis.Latitude/180.0)*COS(PI()*loc.Latitude/180.0)*COS(PI()*loc.Longitude/180.0-PI() *gis.Longitude/180.0))) T(ACosInput)

cross apply  (SELECT 6371 * acos(CASE WHEN ABS(ACosInput) > 1 THEN SIGN(ACosInput)*1 ELSE ACosInput END)) T2(distance)
 where 
 --gis.Latitude = 32.8882115200000 and gis.Longitude = 35.2898455400000 and
 
  gis.latitude BETWEEN loc.latitude - (25.0 / 111.045)
             AND loc.latitude + (25.0 / 111.045)
             
  and gis.longitude BETWEEN loc.Longitude - (25.0 / (111.045 * COS(RADIANS(loc.Longitude))))
              AND loc.Longitude + (25.0 / (111.045 * COS(RADIANS(loc.Longitude)))) 
order by distance desc
--++++++++
SELECT gis.case_no, gis.Points_Id, gis.Latitude, gis.Latitude, loc.Latitude as latpoint, loc.Longitude as longpoint,
--25.0 AS radius,  111.045 AS distance_unit,
      111.045* DEGREES(ACOS(COS(RADIANS(loc.Latitude))
                 * COS(RADIANS(gis.Latitude))
                 * COS(RADIANS(loc.Longitude) - RADIANS(gis.Longitude))
                 + SIN(RADIANS(loc.Latitude))
                 * SIN(RADIANS(gis.Latitude)))) AS distance_in_km
                 
                 
          /*
                 DEGREES(ACOS(COS(RADIANS(lat1)) * COS(RADIANS(lat2)) *
             COS(RADIANS(long1) - RADIANS(long2)) +
             SIN(RADIANS(lat1)) * SIN(RADIANS(lat2))))
        */         
 FROM [BRIUTNT\amir.shaked].tbl_Brook_GIS gis
 CROSS JOIN [BRIUTNT\amir.shaked].tbl_Locations loc
 where 
 --gis.Latitude = 32.8882115200000 and gis.Longitude = 35.2898455400000 and
 
  gis.latitude BETWEEN loc.latitude - (25.0 / 111.045)
             AND loc.latitude + (25.0 / 111.045)
             
  and gis.longitude BETWEEN loc.Longitude - (25.0 / (111.045 * COS(RADIANS(loc.Longitude))))
              AND loc.Longitude + (25.0 / (111.045 * COS(RADIANS(loc.Longitude)))) 
order by distance_in_km desc
/*
and latitude BETWEEN latpoint - (50.0 / 111.045)
             AND latpoint + (50.0 / 111.045)
and longitude BETWEEN longpoint - (50.0 / (111.045 * COS(RADIANS(latpoint))))
              AND longpoint + (50.0 / (111.045 * COS(RADIANS(latpoint))))