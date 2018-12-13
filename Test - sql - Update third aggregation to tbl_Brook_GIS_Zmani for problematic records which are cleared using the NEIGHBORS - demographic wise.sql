select 
src.case_no, nei.Points_Id, demog.Age_Range_Desc, demog.Gender_Desc, nei.Points_Id_Neighbor
, min(nei.Distance) as min_dist 
  -- ,Rank() over (partition by src.case_no order by min(nei.Distance) asc ) As Rnk -- from the further away to the closest location
   ,Rank() over (partition by src.case_no, demog.Age_Range_Desc, demog.Gender_Desc order by min(nei.Distance) asc ) As Rnk -- from the further away to the closest location
  -- ,Rank() over (partition by src.case_no, demog.Age_Range_Desc, demog.Gender_Desc order by nei.Distance asc ) As Rnk -- from the further away to the closest location
   ,ROW_NUMBER() over (partition by src.case_no, demog.Age_Range_Desc, demog.Gender_Desc order by min(nei.Distance) asc ) AS "Row Number"
    -- ,ROW_NUMBER() OVER (ORDER BY a.PostalCode) AS "Row Number"
    FROM [BRIUTNT\amir.shaked].tbl_Yes_Problems_Zmani problems
    join [BRIUTNT\amir.shaked].tbl_Brook_GIS_Zmani src on src.case_no = problems.case_no
    --join [BRIUTNT\amir.shaked].tbl_Brook_GIS gis on src.case_no = gis.case_no
    join [BRIUTNT\amir.shaked].tbl_Ez_Stat_Points_Center center on src.Points_Id = center.Points_Id
    join [BRIUTNT\amir.shaked].tbl_Points_Neighbors nei on nei.Points_Id = src.Points_Id
    join [BRIUTNT\amir.shaked].tbl_Demographics demog on demog.Points_Id = nei.Points_id_Neighbor
   
    
    where -- define a rectengle border for the most further allowed neighbor in km's - this is a 35 km radius sqrt(25^2*2)
   center.Lat BETWEEN nei.latitude - (25.0 / 111.045)
             AND nei.latitude + (25.0 / 111.045)
             
  and center.Lon BETWEEN nei.Longitude - (25.0 / (111.045 * COS(RADIANS(nei.Longitude))))
              AND nei.Longitude + (25.0 / (111.045 * COS(RADIANS(nei.Longitude)))) 
    
    --and src.case_no=5
    and src.Points_Id=5
    and demog.Age_Range_Desc = '65-69'
    and demog.Gender_Desc = 'Male'
    --and Rnk=1
    --and src.gender = 'Male'
    --and src.age = '65-69'
    --and 65-69
    group by src.case_no, nei.Points_Id, nei.Points_Id_Neighbor, demog.Age_Range_Desc, demog.Gender_Desc
    having sum(demog.Popluation)>=3 
    
      order by  Rnk asc