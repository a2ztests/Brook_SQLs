--Here we update Points_Id_Calc  = Points_Id_Neighbor for the GOOD demographic records found against POINTS

--http://sqlity.net/en/2867/update-from-select/
/* For testing purposes only
UPDATE  src_1
SET 
    src_1.Points_Id_Calc  = null,
  src_1.Popluation = 0
  FROM [BRIUTNT\amir.shaked].tbl_Brook_GIS_Zmani src_1
  
  
select case_no, Points_Id, Points_Id_Calc,Age, Gender, Popluation, update_cycle
from [BRIUTNT\amir.shaked].tbl_Brook_GIS_Zmani src_1 --tbl_Brook_GIS src_1
where 
--Points_Id_Calc is not null --and
 update_cycle=4
order by Points_Id --case_no
*/

UPDATE  src_1
SET 
  src_1.Points_Id_Calc  = sql_pnimi_b.Points_Id_Neighbor
  --,src_1.Popluation  = sql_pnimi_b.max_population
  ,src_1.update_cycle = 4 
  FROM [BRIUTNT\amir.shaked].tbl_Brook_GIS_Zmani src_1
  join 
  (
    --we find the BEST Points_ID (with the population size larger then K AND from those we take the one with min distance from the original points_id) nei.points_id relevant to the group by,  against the demog table
    select src.case_no, nei.Points_Id,  demog.Age_Range_Desc, demog.Gender_Desc, nei.Points_Id_Neighbor, min(nei.Distance) as min_dist
    --max(demog.Popluation) as max_population
  -- ,Rank() over (partition by src.case_no, demog.Age_Range_Desc, demog.Gender_Desc order by min(nei.Distance) asc ) As Rnk -- from the further away to the closest location
   ,ROW_NUMBER() over (partition by src.case_no, demog.Age_Range_Desc, demog.Gender_Desc order by min(nei.Distance) asc ) AS Row_Num
  
    FROM [BRIUTNT\amir.shaked].tbl_Yes_Problems_Zmani problems
    join [BRIUTNT\amir.shaked].tbl_Brook_GIS_Zmani src on src.case_no = problems.case_no
  --join [BRIUTNT\amir.shaked].tbl_Brook_GIS gis on src.case_no = gis.case_no
    join [BRIUTNT\amir.shaked].tbl_Ez_Stat_Points_Center center on src.Points_Id = center.Points_Id    join [BRIUTNT\amir.shaked].tbl_Points_Neighbors nei on nei.Points_Id = src.Points_Id
    join [BRIUTNT\amir.shaked].tbl_Demographics demog on demog.Points_Id = nei.Points_id_Neighbor

    /*where nei.Points_id in 
        ( 
        --We take the problematic points_id's and look for there neighbor point_id's (Points_Id_Neighbor)
        --We Identify the problematic points_id's using tbl_Yes_Problems_Zmani
        select  src.Points_Id
        FROM [BRIUTNT\amir.shaked].tbl_Brook_GIS_Zmani src
        join [BRIUTNT\amir.shaked].tbl_Yes_Problems_Zmani problems on src.case_no = problems.case_no
         ) sql_pnimi_a
    */
    
    where -- define a rectengle border for the most further allowed neighbor in km's - this is a 35 km radius sqrt(25^2*2)
   center.Lat BETWEEN nei.latitude - (25.0 / 111.045)
             AND nei.latitude + (25.0 / 111.045)
             
  and center.Lon BETWEEN nei.Longitude - (25.0 / (111.045 * COS(RADIANS(nei.Longitude))))
              AND nei.Longitude + (25.0 / (111.045 * COS(RADIANS(nei.Longitude)))) 
    
    group by src.case_no, nei.Points_Id, demog.Age_Range_Desc, demog.Gender_Desc, nei.Points_Id_Neighbor
    having sum(demog.Popluation)>=3 --? --k = parameter
  --order by min_dist asc
     
  ) sql_pnimi_b
  on src_1.case_no = sql_pnimi_b.case_no
  and src_1.age = sql_pnimi_b.Age_Range_Desc
  and src_1.gender = sql_pnimi_b.Gender_Desc
  and  sql_pnimi_b.Row_Num=1
        