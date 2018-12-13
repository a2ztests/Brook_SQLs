select zmani.Points_Id, zmani.age,zmani.gender,  sum(demog.Popluation) as pop
from [BRIUTNT\amir.shaked].tbl_Brook_GIS_Zmani zmani
join [BRIUTNT\amir.shaked].tbl_Demographics demog on zmani.Points_Id = demog.Points_Id
and zmani.age = demog.Age_Range_Desc
and zmani.gender = demog.Gender_Desc
join [BRIUTNT\amir.shaked].tbl_No_Problems_Zmani no_prob on zmani.case_no =no_prob.case_no 
group by zmani.Points_Id, zmani.age,zmani.gender
having sum(demog.Popluation) <3
