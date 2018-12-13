--Here we update tbl_Distances for all the Points_id to targets distances
-- this bounding-box query has the potential of returning some points that lie more than 50km diagonally from your (latpoint, longpoint): it’s only checking a bounding rectangle, not the diagonal distance.

--INSERT INTO [BRIUTNT\amir.shaked].tbl_Distances (case_no, source_points_id, source_latitude, source_longitude, target_place_desc,  target_latitude,  target_longitude, src_trg_distance)

SELECT gis.case_no, gis.Points_Id, gis.Latitude, gis.Longitude,  loc.Place_Desc, loc.Latitude, loc.Longitude,  distance

,Rank() over (partition by gis.case_no order by distance desc ) As Rnk -- from the further away to the closest location

FROM [BRIUTNT\amir.shaked].tbl_Brook_GIS gis
CROSS JOIN [BRIUTNT\amir.shaked].tbl_Locations loc

CROSS APPLY (SELECT (SIN(PI()*gis.Latitude/180.0)*SIN(PI()*loc.Latitude/180.0)+COS(PI()*gis.Latitude/180.0)*COS(PI()*loc.Latitude/180.0)*COS(PI()*loc.Longitude/180.0-PI() *gis.Longitude/180.0))) T(ACosInput)

cross apply  (SELECT 6371 * acos(CASE WHEN ABS(ACosInput) > 1 THEN SIGN(ACosInput)*1 ELSE ACosInput END)) T2(distance)
 --where gis.case_no=703
 --where Rnk>3 --This doesn't work
 where
   gis.latitude BETWEEN loc.latitude - (25.0 / 111.045)
             AND loc.latitude + (25.0 / 111.045)
             
  and gis.longitude BETWEEN loc.Longitude - (25.0 / (111.045 * COS(RADIANS(loc.Longitude))))
              AND loc.Longitude + (25.0 / (111.045 * COS(RADIANS(loc.Longitude)))) 

 order by case_no, Rnk asc 
--++++++++
SELECT --TOP(10)
gis.case_no, gis.Points_Id, gis.Latitude, gis.Latitude, loc.Latitude As latpoint, loc.Longitude As longpoint,
--25.0 AS radius,  111.045 AS distance_unit,
      111.045* DEGREES(ACOS(COS(RADIANS(loc.Latitude))
                 * COS(RADIANS(gis.Latitude))
                 * COS(RADIANS(loc.Longitude) - RADIANS(gis.Longitude))
                 + SIN(RADIANS(loc.Latitude))
                 * SIN(RADIANS(gis.Latitude)))) As distance_in_km
--,Rank() over (partition by gis.Points_Id order by distance_in_km desc ) As Rnk
--,Rank() over (partition by gis.case_no order by distance_in_km desc ) As Rnk -- from the further away to the closest location
,Rank() over (partition by gis.case_no order by 
111.045* DEGREES(ACOS(COS(RADIANS(loc.Latitude))
                 * COS(RADIANS(gis.Latitude))
                 * COS(RADIANS(loc.Longitude) - RADIANS(gis.Longitude))
                 + SIN(RADIANS(loc.Latitude))
                 * SIN(RADIANS(gis.Latitude))))


 desc ) As Rnk -- from the further away to the closest location


                 
                 
          /*
                 DEGREES(ACOS(COS(RADIANS(lat1)) * COS(RADIANS(lat2)) *
             COS(RADIANS(long1) - RADIANS(long2)) +
             SIN(RADIANS(lat1)) * SIN(RADIANS(lat2))))
        */         
 FROM [BRIUTNT\amir.shaked].tbl_Brook_GIS gis
 CROSS JOIN [BRIUTNT\amir.shaked].tbl_Locations loc
 where 
 --gis.Latitude = 32.8882115200000 and gis.Longitude = 35.2898455400000 and
  --gis.case_no=703 and
  --and Rnk=15
   gis.latitude BETWEEN loc.latitude - (25.0 / 111.045)
             AND loc.latitude + (25.0 / 111.045)
             
  and gis.longitude BETWEEN loc.Longitude - (25.0 / (111.045 * COS(RADIANS(loc.Longitude))))
              AND loc.Longitude + (25.0 / (111.045 * COS(RADIANS(loc.Longitude)))) 
  order by case_no, Rnk asc 
/*
and latitude BETWEEN latpoint - (50.0 / 111.045)
             AND latpoint + (50.0 / 111.045)
and longitude BETWEEN longpoint - (50.0 / (111.045 * COS(RADIANS(latpoint))))
              AND longpoint + (50.0 / (111.045 * COS(RADIANS(latpoint))))
*/