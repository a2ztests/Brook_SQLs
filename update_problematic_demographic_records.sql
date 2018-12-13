UPDATE  [BRIUTNT\amir.shaked].[tbl_Brook_GIS_Zmani]
SET 
  [BRIUTNT\amir.shaked].[tbl_Brook_GIS_Zmani].Points_Id_Calc  =

--select src.Points_Id, src.Auto_Point_Id, (points.Auto_Id)+1 as plus_one, (points.Auto_Id)-1 as minus_one,
--We use the fact that point_id of adjucent point areas are sequencial (though point_id is not consecutive)
--If the value for (tbl_Brook_GIS src.Auto_Id )+1 exists (-so we are not at the last point_id on the list) in tbl_points, we'll take this value
--select
CASE
  WHEN ((points.Auto_Id)+1 is not null)
   ---(points.Auto_Id)+1
   --Then 9999
   THEN (select points_1.Point_Id from [BRIUTNT\amir.shaked].tbl_Points points_1 where points_1.Auto_ID = (points.Auto_Id)+1)
--   THEN (select points.Point_Id from [BRIUTNT\amir.shaked].tbl_Points points join src on (src.Auto_Point_id)+1 = points.Auto_Id) 
--   THEN (select points.Point_Id from [BRIUTNT\amir.shaked].tbl_Points points join [BRIUTNT\amir.shaked].tbl_Brook_GIS_Zmani on ([BRIUTNT\amir.shaked].tbl_Brook_GIS_Zmani.Auto_Point_id)+1 = points.Auto_Id) 
   -- This will bring the next existing point_id in respect to the problematic one found in the previous stage

/*CASE
 WHEN 
 src.Auto_Id+1 < select max(points.Auto_Id) from [BRIUTNT\amir.shaked].tbl_Points points
   
   THEN select points.Point_Id  join src on src.Auto_Id+1 = points.Auto_Id -- will bring the next existing point_id in respect to the problematic one found in the previous stage
 */
 ELSE
    (select points_1.Point_Id from [BRIUTNT\amir.shaked].tbl_Points points_1 where points_1.Auto_ID = (points.Auto_Id)-1)
    --(points.Auto_Id)-1
    
    -- -9999
    --(select points_2.Point_Id from [BRIUTNT\amir.shaked].tbl_Points points_2 join [BRIUTNT\amir.shaked].tbl_Brook_GIS_Zmani on ([BRIUTNT\amir.shaked].tbl_Brook_GIS_Zmani.Auto_Point_id)-1 = points_2.Auto_Id)  
    -- This will bring the previous existing point_id in respect to the problematic one found in the previous stage
END 
       
,[BRIUTNT\amir.shaked].[tbl_Brook_GIS_Zmani].update_cycle = 3 

FROM [BRIUTNT\amir.shaked].tbl_Brook_GIS_Zmani src
join [BRIUTNT\amir.shaked].tbl_Yes_Problems_Zmani problems on src.case_no = problems.case_no
join [BRIUTNT\amir.shaked].tbl_Points points on points.Points_Id = src.Points_Id