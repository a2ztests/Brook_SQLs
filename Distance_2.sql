--Here we update tbl_Distances for all the Points_id to targets distances


INSERT INTO [BRIUTNT\amir.shaked].tbl_Distances (case_no, source_points_id, source_latitude, source_longitude, target_place_desc,  target_latitude,  target_longitude, src_trg_distance)

SELECT gis.case_no, gis.Points_Id, gis.Latitude, gis.Longitude,  loc.Place_Desc, loc.Latitude, loc.Longitude,  distance
FROM [BRIUTNT\amir.shaked].tbl_Brook_GIS gis
CROSS JOIN [BRIUTNT\amir.shaked].tbl_Locations loc

CROSS APPLY (SELECT (SIN(PI()*gis.Latitude/180.0)*SIN(PI()*loc.Latitude/180.0)+COS(PI()*gis.Latitude/180.0)*COS(PI()*loc.Latitude/180.0)*COS(PI()*loc.Longitude/180.0-PI() *gis.Longitude/180.0))) T(ACosInput)

cross apply  (SELECT 6371 * acos(CASE WHEN ABS(ACosInput) > 1 THEN SIGN(ACosInput)*1 ELSE ACosInput END)) T2(distance)

/*
Explenations:
Formula: http://www.mapanet.eu/en/resources/Script-Distance.htm

https://blog.sqlauthority.com/2012/06/28/sql-server-fix-error-3623-an-invalid-floating-point-operation-occurred/

https://stackoverflow.com/questions/8837060/an-invalid-floating-point-operation-occurred-sql-server-2008
https://www.mssqltips.com/sqlservertip/1958/sql-server-cross-apply-and-outer-apply/

Test: https://www.movable-type.co.uk/scripts/latlong.html
SELECT gis.case_no, gis.Points_Id, gis.Latitude as lat_1,gis.Longitude as lon_1, loc.Latitude as lat_2, loc.Longitude as lon_2, loc.Place_Desc,
distance

FROM [BRIUTNT\amir.shaked].tbl_Brook_GIS gis
CROSS JOIN [BRIUTNT\amir.shaked].tbl_Locations loc

CROSS APPLY (SELECT (SIN(PI()*gis.Latitude/180.0)*SIN(PI()*loc.Latitude/180.0)+COS(PI()*gis.Latitude/180.0)*COS(PI()*loc.Latitude/180.0)*COS(PI()*loc.Longitude/180.0-PI() *gis.Longitude/180.0))) T(ACosInput)

cross apply  (SELECT 6371 * acos(CASE WHEN ABS(ACosInput) > 1 THEN SIGN(ACosInput)*1 ELSE ACosInput END)) T2(distance)

*/

