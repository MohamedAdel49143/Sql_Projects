use [VehicleMakesDB];
---------------------------------------------------------------------------------------------------------------
create view VehicleMasterDetails 
with encryption 
as
select VehicleDetails.*,Makes.Make,MakeModels.ModelName,SubModels.SubModelName,DriveTypes.DriveTypeName,
	   FuelTypes.FuelTypeName,Bodies.BodyName
from  dbo.FuelTypes INNER JOIN
      dbo.Bodies INNER JOIN
      dbo.Makes INNER JOIN
      dbo.MakeModels ON dbo.Makes.MakeID = dbo.MakeModels.MakeID INNER JOIN
      dbo.SubModels ON dbo.MakeModels.ModelID = dbo.SubModels.ModelID INNER JOIN
      dbo.VehicleDetails ON dbo.Makes.MakeID = dbo.VehicleDetails.MakeID 
	  AND dbo.MakeModels.ModelID = dbo.VehicleDetails.ModelID 
	  AND dbo.SubModels.SubModelID = dbo.VehicleDetails.SubModelID ON 
      dbo.Bodies.BodyID = dbo.VehicleDetails.BodyID INNER JOIN
      dbo.DriveTypes ON dbo.VehicleDetails.DriveTypeID = dbo.DriveTypes.DriveTypeID ON dbo.FuelTypes.FuelTypeID = dbo.VehicleDetails.FuelTypeID


Select *
from [dbo].[VehicleMasterDetails]
---------------------------------------------------------------------------------------------------------------
-- Get all vehicles made between 1950 and 2000
Select VehicleDetails.year,SubModelName
from VehicleDetails inner join SubModels on VehicleDetails.SubModelID = SubModels.SubModelID
where VehicleDetails.Year between 1950 and 2000

----------------------------------------------------------------------------------------------------------------
--Get number vehicles made between 1950 and 2000
Select count(SubModelName) as Num_Vehicle
from VehicleDetails inner join SubModels on VehicleDetails.SubModelID = SubModels.SubModelID
where VehicleDetails.Year between 1950 and 2000
----------------------------------------------------------------------------------------------------------------
-- Get number vehicles made between 1950 and 2000 per make and order them by Number Of Vehicles Descending
Select Makes.Make,count(VehicleDetails.SubModelID) as Num_Vehicles
From VehicleDetails inner join Makes on VehicleDetails.MakeID = Makes.MakeID
where VehicleDetails.Year between 1950 and 2000
group by Makes.Make
order by Num_Vehicles desc
----------------------------------------------------------------------------------------------------------------
-- Get All Makes that have manufactured more than 12000 Vehicles in years 1950 to 2000
Select Makes.Make,count(VehicleDetails.SubModelID) as Num_Vehicles
From VehicleDetails inner join Makes on VehicleDetails.MakeID = Makes.MakeID
where VehicleDetails.Year between 1950 and 2000
group by Makes.Make
Having count(VehicleDetails.SubModelID) > 12000
order by Num_Vehicles desc

-- Another Solving without Having and using CTE
with NumberVehicle as (
Select Makes.Make,count(VehicleDetails.SubModelID) as Num_Vehicles
From VehicleDetails inner join Makes on VehicleDetails.MakeID = Makes.MakeID
where VehicleDetails.Year between 1950 and 2000
group by Makes.Make
)

select *
from NumberVehicle
where Num_Vehicles > 12000
order by Num_Vehicles desc

-- Another solving using Subquery Next to FROM
Select *
from (
Select Makes.Make,count(VehicleDetails.SubModelID) as Num_Vehicles
From VehicleDetails inner join Makes on VehicleDetails.MakeID = Makes.MakeID
where VehicleDetails.Year between 1950 and 2000
group by Makes.Make
) as R1
where Num_Vehicles > 12000

-------------------------------------------------------------------------------------------------------------------
-- Get number of vehicles made between 1950 and 2000 per make and add total vehicles column beside

-- The soultion using Subquery
Select Makes.Make,COUNT(VehicleDetails.SubModelID) as Num_vehicles,
	   (select COUNT(VehicleDetails.SubModelID) from VehicleDetails)  as Total_vehicles
from VehicleDetails inner join Makes on VehicleDetails.MakeID = Makes.MakeID
where VehicleDetails.Year between 1950 and 2000
group by Makes.Make
order by Num_vehicles desc


--The Solution using CTE
with Num as (
Select Makes.Make,COUNT(VehicleDetails.SubModelID) as Num_vehicles
from VehicleDetails inner join Makes on VehicleDetails.MakeID = Makes.MakeID
where VehicleDetails.Year between 1950 and 2000
group by Makes.Make
)
select *,(select COUNT(VehicleDetails.SubModelID) from VehicleDetails)  as Total_vehicles
from Num
order by Num.Num_vehicles desc

--The Solution using Scalar Function
alter function dbo.NumbersVehicles()
returns int
as
begin
	Declare @Total_Vehicles int;

	select @Total_Vehicles = COUNT(VehicleDetails.SubModelID) 
	from VehicleDetails 

	return @Total_Vehicles
end;


Select Makes.Make,count(VehicleDetails.SubModelID) as Num_vehicles ,dbo.NumbersVehicles() AS Total_Vehicles
from VehicleDetails inner join Makes on VehicleDetails.MakeID = Makes.MakeID
where VehicleDetails.Year between 1950 and 2000
group by Makes.Make
order by Num_vehicles desc
-----------------------------------------------------------------------------------------------------------------------------------
--Problem 7: Get number of vehicles made between 1950 and 2000 per make and add total vehicles column beside it, then calculate it's percentage
select makes.Make,COUNT(vehicleDetails.SubModelID) as Num_Vehicles,
	   (Select COUNT(vehicleDetails.SubModelID) from VehicleDetails) as Total_Vehicles,
	   (COUNT(vehicleDetails.SubModelID)*100.0)/Nullif((Select COUNT(vehicleDetails.SubModelID) from VehicleDetails),0) as Percentage
from VehicleDetails inner join Makes on VehicleDetails.MakeID = Makes.MakeID
where VehicleDetails.Year between 1950 and 2000 
group by Makes.Make;

--Another Solution using Case statement
select makes.Make,COUNT(vehicleDetails.SubModelID) as Num_Vehicles,
	   (Select COUNT(vehicleDetails.SubModelID) from VehicleDetails) as Total_Vehicles,
	   case
			when (select count(VehicleDetails.SubModelID) from VehicleDetails) = 0 then 0
			else round(cast((COUNT(vehicleDetails.SubModelID)*100.0) as float)/(Select COUNT(vehicleDetails.SubModelID) from VehicleDetails),2)
	   end  as Percentage
from VehicleDetails inner join Makes on VehicleDetails.MakeID = Makes.MakeID
where VehicleDetails.Year between 1950 and 2000 
group by Makes.Make;

---Common Use Cases of CAST()
--1- Arithmetic Operations
--2- Formatting Data
--3- Date Manipulations
--4- Ensuring Compatibility


-- Another solution using CTE 
--áæ ÃäÇ ÈÍÊÇÌ ÇáßæÏ ÃßËÑ ãä ãÑå æÈÇáÊÇáì ßá ãÇ ÇÍÊÇÌå ÃßÊÈå ãä ÌÏíÏ ØÈ ãÇ ÃäÊ ÊßÊÈå ÈÏÇÎá Çá Óì Êì Çì æÊÓÊÏÚíå ÝÞØ Ýì ßá ãÑå ÃäÊ ÈÊÍÊÇÌå ÝíåÇ 
with Percentage_of_Makes as (
select makes.Make,COUNT(vehicleDetails.SubModelID) as Num_Vehicles,
	   (Select COUNT(vehicleDetails.SubModelID) from VehicleDetails) as Total_Vehicles,
	   case
			when (select count(VehicleDetails.SubModelID) from VehicleDetails) = 0 then 0
			else round(cast((COUNT(vehicleDetails.SubModelID)*100.0) as float)/(Select COUNT(vehicleDetails.SubModelID) from VehicleDetails),2)
	   end  as Percentage
from VehicleDetails inner join Makes on VehicleDetails.MakeID = Makes.MakeID
where VehicleDetails.Year between 1950 and 2000 
group by Makes.Make
)

select *
from Percentage_of_Makes
order by Num_Vehicles desc

--ØÈ ÃÍäÇ ããßä äÞáá ÇáÚß Çáì ÝæÞ ÈÏÇÎá Çá select
--ÃíæÇ
Create function dbo.GetNumVehicles()
Returns table
as
return
(
select makes.Make,COUNT(vehicleDetails.SubModelID) as Num_Vehicles,
	   (Select COUNT(vehicleDetails.SubModelID) from VehicleDetails) as Total_Vehicles
from VehicleDetails inner join Makes on VehicleDetails.MakeID = Makes.MakeID
where VehicleDetails.Year between 1950 and 2000 
group by Makes.Make
)


with Get_Percentage_of_Makes as (
	select vc.Make as Make_Name,
		   vc.Num_Vehicles as Num_Vehicles,
		   vc.Total_Vehicles as Total_Vehicles,
		   Round(CAST((Vc.Num_Vehicles*100.0) as float) / Nullif(CAST((Vc.Total_Vehicles) as float),0),2) as percentage
	from  dbo.GetNumVehicles() as vc
)

select *
from Get_Percentage_of_Makes
order by Num_Vehicles desc

----------------------------------------------------------------------------------------------------------------------------------------
-- Problem 8: Get Make, FuelTypeName and Number of Vehicles per FuelType per Make
select Makes.Make,FuelTypes.FuelTypeName,COUNT(VehicleDetails.SubModelID) as Num_Vehicles
from Makes inner join VehicleDetails on Makes.MakeID = VehicleDetails.MakeID
	 inner join FuelTypes on VehicleDetails.FuelTypeID = FuelTypes.FuelTypeID
where VehicleDetails.Year between 1950 and 2000
group by Makes.Make,FuelTypes.FuelTypeName
order by Makes.Make asc
-----------------------------------------------------------------------------------------------------------------------------------------
--Problem 9: Get all vehicles that runs with GAS
select distinct SubModels.SubModelName,FuelTypes.FuelTypeName
from SubModels inner join VehicleDetails on SubModels.SubModelID = VehicleDetails.SubModelID
	 inner join FuelTypes on VehicleDetails.FuelTypeID = FuelTypes.FuelTypeID
where FuelTypes.FuelTypeName = N'GAS';
--------------------------------------------------------------------------------------------------------------------------------------
-- Problem 10: Get all Makes that runs with GAS
select distinct Makes.Make,FuelTypes.FuelTypeName
from Makes inner join VehicleDetails on Makes.MakeID = VehicleDetails.MakeID
	 inner join FuelTypes on VehicleDetails.FuelTypeID = FuelTypes.FuelTypeID
where FuelTypes.FuelTypeName = N'GAS';
-----------------------------------------------------------------------------------------------------------------------------------
--Problem 11: Get Total Makes that runs with GAS
select COUNT(distinct Makes.Make) as Total_Makes
from Makes inner join VehicleDetails on Makes.MakeID = VehicleDetails.MakeID
	 inner join FuelTypes on VehicleDetails.FuelTypeID = FuelTypes.FuelTypeID
where FuelTypes.FuelTypeName = N'GAS';
----another solution using subquery next to from
select COUNT(*) as Total_Makes
from(
select distinct Makes.Make
from Makes inner join VehicleDetails on Makes.MakeID = VehicleDetails.MakeID
	 inner join FuelTypes on VehicleDetails.FuelTypeID = FuelTypes.FuelTypeID
where FuelTypes.FuelTypeName = N'GAS'
) R1
-----------------------------------------------------------------------------------------------------------------------------------
--Problem 12: Count Vehicles by make and order them by NumberOfVehicles from high to low.
select makes.Make,COUNT(vehicledetails.SubModelID) as Num_Vehicles
from VehicleDetails inner join Makes on VehicleDetails.MakeID = makes.MakeID
group by Make
order by Num_Vehicles desc
-----------------------------------------------------------------------------------------------------------------------------------
-- Problem 13: Get all Makes/Count Of Vehicles that manufactures more than 20K Vehicles
select makes.Make,COUNT(vehicledetails.SubModelID) as Num_Vehicles
from VehicleDetails inner join Makes on VehicleDetails.MakeID = makes.MakeID
group by Make
having COUNT(vehicledetails.SubModelID) > 20000
order by Num_Vehicles desc

---the solution using subquery next to FROM
select *
from (
select makes.Make,COUNT(vehicledetails.SubModelID) as Num_Vehicles
from VehicleDetails inner join Makes on VehicleDetails.MakeID = makes.MakeID
group by Make) R1

where Num_Vehicles > 20000
order by Num_Vehicles desc
--------------------------------------------------------------------------------------------------------------------------------------
---Problem 14: Get all Makes with make starts with 'B'
select Make
from Makes
where Make like 'B%';
--------------------------------------------------------------------------------------------------------------------------------------
--- Problem 15: Get all Makes with make ends with 'W'
select Make
from Makes
where Make like '%W';
-------------------------------------------------------------------------------------------------------------------------------------
---Problem 16:Get all Makes that manufactures DriveTypeName = FWD
select distinct Makes.Make,DriveTypes.DriveTypeName
from Makes inner join VehicleDetails on Makes.MakeID = VehicleDetails.MakeID
	 inner join DriveTypes on VehicleDetails.DriveTypeID = DriveTypes.DriveTypeID
where DriveTypes.DriveTypeName= 'FWD';

----------------------------------------------------------------------------------------------------------------------------------------
-- Problem 17: Get total Makes that Mantufactures DriveTypeName=FWD
select count(distinct Makes.Make) as Total_Makes
from Makes inner join VehicleDetails on Makes.MakeID = VehicleDetails.MakeID
	 inner join DriveTypes on VehicleDetails.DriveTypeID = DriveTypes.DriveTypeID
where DriveTypes.DriveTypeName= 'FWD';

--Another Solution

select count(*) as Total_Makes
from(
select distinct Makes.Make
from Makes inner join VehicleDetails on Makes.MakeID = VehicleDetails.MakeID
	 inner join DriveTypes on VehicleDetails.DriveTypeID = DriveTypes.DriveTypeID
where DriveTypes.DriveTypeName= 'FWD'
) R1

-----------------------------------------------------------------------------------------------------------------------------------------
--  Problem 18: Get total vehicles per DriveTypeName Per Make and order them per make asc then per total Desc
Select Makes.Make,DriveTypes.DriveTypeName,COUNT(VehicleDetails.SubModelID) as Total_vehicles
from DriveTypes inner join VehicleDetails on DriveTypes.DriveTypeID = VehicleDetails.DriveTypeID
	 inner join Makes on VehicleDetails.MakeID = Makes.MakeID
group by Makes.Make,DriveTypes.DriveTypeName
order by makes.Make asc,Total_vehicles desc
----------------------------------------------------------------------------------------------------------------------------------------
-- Problem 19: Get total vehicles per DriveTypeName Per Make then filter only results with total > 10,000
select Makes.Make,DriveTypes.DriveTypeName,COUNT(VehicleDetails.SubModelID) as Total_vehicles
from DriveTypes inner join VehicleDetails on DriveTypes.DriveTypeID = VehicleDetails.DriveTypeID
	 inner join Makes on VehicleDetails.MakeID = Makes.MakeID
group by Makes.Make,DriveTypes.DriveTypeName
having COUNT(VehicleDetails.SubModelID) > 10000
order by makes.Make asc,Total_vehicles desc

-- Another Solution without Having
select *
from (
select Makes.Make,DriveTypes.DriveTypeName,COUNT(VehicleDetails.SubModelID) as Total_vehicles
from DriveTypes inner join VehicleDetails on DriveTypes.DriveTypeID = VehicleDetails.DriveTypeID
	 inner join Makes on VehicleDetails.MakeID = Makes.MakeID
group by Makes.Make,DriveTypes.DriveTypeName
)R1

where Total_vehicles > 10000
order by Make asc,Total_vehicles desc
-------------------------------------------------------------------------------------------------------------------------------------------
--Problem 20: Get all Vehicles that number of doors is not specified
select NumDoors
from VehicleDetails 
where NumDoors is null
----------------------------------------------------------------------------------------------------------------------------------------------
-- Problem 21: Get Total Vehicles that number of doors is not specified
-- ÇÓÊÎÏãÊ ÇáäÌãå ÈÏÇÎá ÇáßæäÊ æáíÓ ÇÓã ÇáÚãæÏ ÚÔÇä ÇáÏÇáå ãÔ ÈÊÚÏ Çá Null
select count(*) as Num_Doors
from VehicleDetails
where NumDoors is null
-----------------------------------------------------------------------------------------------------------------------------------------------
-- Problem 22: Get percentage of vehicles that has no doors specified
select concat((count(*) * 100) / nullif((select count(*) from VehicleDetails),0),' %') as Percentage_of_vehicles
from VehicleDetails
where NumDoors is null

-- The solution using Stored Procedure
-- ÃäÇ åäÇ ÚÇíÒ ÇÚãá Sp inside Sp

create or alter procedure Total_Vehicles
as
begin
select count(*) as Total_vehicles from VehicleDetails	
end

exec Total_Vehicles


create or alter procedure Num_Vehicles_has_no_doors
as
begin
select count(*) as Num_vehicles_has_no_doors
from VehicleDetails
where NumDoors is null
end

exec Num_Vehicles_has_no_doors

--SP Inside SP--
create or alter procedure percentage_of_vehicles_has_no_Doors
as
begin
    declare @Total_Vehicles int;
    declare @Num_Vehicles_has_no_doors int;
    declare @Percentage varchar(10);

    -- Get total vehicles
    exec @Total_Vehicles = Total_Vehicles ;

    -- Get number of vehicles with no doors
    exec @Num_Vehicles_has_no_doors =  Num_Vehicles_has_no_doors ;

    -- Calculate percentage
    set @Percentage =(concat((select count(*) * 100 from VehicleDetails where NumDoors is null ) / nullif((select count(*) from VehicleDetails),0),' %'))
-- Return the result
    select @Percentage AS Percentage;
end;


exec percentage_of_vehicles_has_no_Doors

-----------------------------------------------------------------------------------------------------------------------------------------------
--  Problem 23: Get MakeID , Make, SubModelName for all vehicles that have SubModelName 'Elite'
select distinct VehicleDetails.MakeID,Makes.Make,SubModels.SubModelName
from Makes inner join VehicleDetails on Makes.MakeID = VehicleDetails.MakeID
	 inner join SubModels on VehicleDetails.SubModelID = SubModels.SubModelID
where SubModels.SubModelName = 'Elite'
-----------------------------------------------------------------------------------------------------------------------------------------------
-- Problem 24: Get all vehicles that have Engines > 3 Liters and have only 2 doors
select *
from VehicleDetails
where Engine_Liter_Display > 3 and NumDoors = 2
---------------------------------------------------------------------------------------------------------------------------------------------
--Problem 25: Get make and vehicles that the engine contains 'OHV' and have Cylinders = 4
select  makes.Make,VehicleDetails.*
from VehicleDetails inner join Makes on VehicleDetails.MakeID = Makes.MakeID
where (VehicleDetails.Engine like '%OHV%') and (VehicleDetails.Engine_Cylinders = 4)
----------------------------------------------------------------------------------------------------------------------------------------------
-- Problem 26: Get all vehicles that their body is 'Sport Utility' and Year > 2020
select VehicleDetails.*,Bodies.BodyName
from VehicleDetails inner join Bodies on VehicleDetails.BodyID = Bodies.BodyID
where Bodies.BodyName = 'Sport Utility' and VehicleDetails.Year > 2020
-----------------------------------------------------------------------------------------------------------------------------------------------
-- Problem 27: Get all vehicles that their Body is 'Coupe' or 'Hatchback' or 'Sedan'
select VehicleDetails.*,Bodies.BodyName
from VehicleDetails inner join Bodies on VehicleDetails.BodyID = Bodies.BodyID
where Bodies.BodyName in( 'Coupe','Hatchback','Sedan')
-----------------------------------------------------------------------------------------------------------------------------------------------
-- Problem 28: Get all vehicles that their body is 'Coupe' or 'Hatchback' or 'Sedan' and manufactured in year 2008 or 2020 or 2021
select VehicleDetails.*,Bodies.BodyName
from VehicleDetails inner join Bodies on VehicleDetails.BodyID = Bodies.BodyID
where Bodies.BodyName in( 'Coupe','Hatchback','Sedan') and VehicleDetails.Year in (2008,2020,2021)
-----------------------------------------------------------------------------------------------------------------------------------------------
-- Problem 29: Return found=1 if there is any vehicle made in year 1950
select found = 1
where exists (select top 1 * from VehicleDetails where VehicleDetails.Year = 1950)
----------------------------------------------------------------------------------------------------------------------------------------------
-- Problem 30: Get all Vehicle_Display_Name, NumDoors and add extra column to describe number of doors by words, and if door is null display 'Not Set'
select Vehicle_Display_Name,NumDoors,case
										when NumDoors = 0 then 'Zero Doors'
										when NumDoors = 2 then 'Two Doors'
										when NumDoors = 3 then 'Three Doors'
										when NumDoors = 4 then 'Four Doors'
										when NumDoors = 5 then 'Five Doors'
										when NumDoors = 6 then 'Six Doors'
										when NumDoors = 8 then 'Eight Doors'
										when NumDoors is null then 'Not Set'
										else 'Unknown'
									 end as DoorDescription
from VehicleDetails
---------------------------------------------------------------------------------------------------------------------------------------------------
--  Problem 31: Get all Vehicle_Display_Name, year and add extra column to calculate the age of the car then sort the results by age desc.

select VehicleDetails.Vehicle_Display_Name,
	   VehicleDetails.Year,
	   Age = Year(getdate())-Year 
from VehicleDetails
order by Age desc

--Another solution 
select 
    VehicleDetails.Vehicle_Display_Name,
    VehicleDetails.Year,
    case 
        when VehicleDetails.Year IS NOT NULL then DATEDIFF(YEAR, CAST(CONCAT(VehicleDetails.Year, '-01-01') AS DATE), GETDATE())
        when VehicleDetails.Year IS NULL then 'Not Specific'
        else 'unknown'
    end as Age
from VehicleDetails
order by age desc;

-----------------------------------------------------------------------------------------------------------------------------------------------
--Problem 32: Get all Vehicle_Display_Name, year, Age for vehicles that their age between 15 and 25 years old
select *
from(
select Vehicle_Display_Name, Year, Age = Year(getdate()) - Year
from VehicleDetails
) R1
where age between 15 and 25 

-- Another solution using CTE

with AgeForvehicles as (
select Vehicle_Display_Name, Year, Age = Year(getdate()) - Year
from VehicleDetails
)

select *
from AgeForvehicles
where age between 15 and 25
---------------------------------------------------------------------------------------------------------------------------------------------
--Problem 33: Get Minimum Engine CC , Maximum Engine CC , and Average Engine CC of all Vehicles
select MIN(VehicleDetails.Engine_CC) as Minimum_Engine_CC ,
	   MAX(VehicleDetails.Engine_CC) as Maximum_Engine_CC,
	   AVG(VehicleDetails.Engine_CC) as average_Engine_CC
from VehicleDetails
--------------------------------------------------------------------------------------------------------------------------------------------
-- Problem 34: Get all vehicles that have the minimum Engine_CC
select *
from VehicleDetails
where Engine_CC = (select MIN(Engine_CC) as minimum from VehicleDetails)
--------------------------------------------------------------------------------------------------------------------------------------------
-- Problem 34: Get all vehicles that have the minimum Engine_CC
select *
from VehicleDetails
where Engine_CC = (select Max(VehicleDetails.Engine_CC) as maximum from VehicleDetails)
-------------------------------------------------------------------------------------------------------------------------------------------
--   Problem 36: Get all vehicles that have Engin_CC below average
select *
from VehicleDetails
where Engine_CC < (select avg (VehicleDetails.Engine_CC) as avg from VehicleDetails)
-------------------------------------------------------------------------------------------------------------------------------------------
--Problem 37: Get total vehicles that have Engin_CC above average
select COUNT(*) as Total_vehicles
from VehicleDetails
where Engine_CC > (select avg (VehicleDetails.Engine_CC) as avg from VehicleDetails)


-- Another Solution
select Count(*) as Total_vehicles from
(
 
	Select ID,VehicleDetails.Vehicle_Display_Name from VehicleDetails
	where Engine_CC > ( select  Avg(Engine_CC) as MinEngineCC  from VehicleDetails )

) R1

-------------------------------------------------------------------------------------------------------------------------------------------
-- Problem 38: Get all unique Engin_CC and sort them Desc
select distinct Engine_CC
from VehicleDetails
order by Engine_CC desc
-------------------------------------------------------------------------------------------------------------------------------------------
--  Problem 39: Get the maximum 3 Engine CC
select top 3 Engine_CC
from VehicleDetails
order by Engine_CC desc
-------------------------------------------------------------------------------------------------------------------------------------------
-- Problem 40: Get all vehicles that has one of the Max 3 Engine CC
-- æåÐÇ ÇáÍá íÓÊÎÏã ÃíÖÇ áãÚÑÝÉ ÇáÇæÇÆá 
select *
from VehicleDetails
where Engine_CC in (select  distinct top 3  Engine_CC from VehicleDetails order by Engine_CC desc)
------------------------------------------------------------------------------------------------------------------------------------------
--Problem 41: Get all Makes that manufactures one of the Max 3 Engine CC
select distinct Makes.Make
from Makes inner join VehicleDetails on Makes.MakeID = VehicleDetails.MakeID
where Engine_CC in ( select distinct top 3 Engine_CC from VehicleDetails order by Engine_CC desc)
order by Make
-----------------------------------------------------------------------------------------------------------------------------------------
-- Problem 42: Get a table of unique Engine_CC and calculate tax per Engine CC
select distinct Engine_CC,
	   case 
		 when Engine_CC between 0 and 1000 then 100
		 when Engine_CC between 1001 and 2000 then 200
		 when Engine_CC between 2001 and 4000 then 300
		 when Engine_CC between 4001 and 6000 then 400
		 when Engine_CC between 6000 and 8000 then 500
		 when Engine_CC > 8000 then 600
		 else 0
	   end as Tax
from VehicleDetails
order by Engine_CC

-------------------------------------------------------------------------------------------------------------------------------------------
-- Problem 43: Get Make and Total Number Of Doors Manufactured Per Make
select Makes.Make,Sum(VehicleDetails.NumDoors) as Total_Doors
from VehicleDetails inner join Makes on VehicleDetails.MakeID = Makes.MakeID
group by makes.Make
order by Total_Doors desc
-------------------------------------------------------------------------------------------------------------------------------------------
-- Problem 44: Get Total Number Of Doors Manufactured by 'Ford'
select Makes.Make,Sum(VehicleDetails.NumDoors) as Total_Doors
from VehicleDetails inner join Makes on VehicleDetails.MakeID = Makes.MakeID
where makes.Make = 'Ford'
group by makes.Make
order by Total_Doors desc

---another solution using having instead of where
select Makes.Make,Sum(VehicleDetails.NumDoors) as Total_Doors
from VehicleDetails inner join Makes on VehicleDetails.MakeID = Makes.MakeID
group by makes.Make
having Makes.Make ='Ford'
order by Total_Doors desc
-------------------------------------------------------------------------------------------------------------------------------------------
--  Problem 45: Get Number of Models Per Make
select makes.Make,count(MakeModels.ModelID) as Num_Models
from Makes inner join MakeModels on Makes.MakeID = MakeModels.MakeID
group by Makes.Make
order by Num_Models desc
-------------------------------------------------------------------------------------------------------------------------------------------
--Problem 46: Get the highest 3 manufacturers that make the highest number of models
select  top 3 Makes.Make,COUNT(MakeModels.ModelID) as Num_models
from makes inner join MakeModels on Makes.MakeID = MakeModels.MakeID
group by Makes.Make
order by Num_models desc
------------------------------------------------------------------------------------------------------------------------------------------
-- Problem 47: Get the highest number of models manufactured
select max(Num_models) as Num_models
from(
select Makes.Make,COUNT(MakeModels.ModelID) as Num_models
from makes inner join MakeModels on Makes.MakeID = MakeModels.MakeID
group by Makes.Make
) R1

-----------------------------------------------------------------------------------------------------------------------------------------
--  Problem 48: Get the highest Manufacturers manufactured the highest number of models
select top 1 Makes.Make,COUNT(MakeModels.ModelID) as Num_models
from makes inner join MakeModels on Makes.MakeID = MakeModels.MakeID
group by Makes.Make
order by Num_models desc

--Another solution using Having and creating supquery next to it

select Makes.Make,COUNT(MakeModels.ModelID) as Num_models
from makes inner join MakeModels on Makes.MakeID = MakeModels.MakeID
group by Makes.Make
having count(MakeModels.ModelID) = (
	select MAX(num_models) as Num_Models
	from(
	select MakeID,COUNT(MakeModels.ModelID) num_models
	from MakeModels
	group by MakeID
	) R1
)
---------------------------------------------------------------------------------------------------------------------------------------
--  Problem 49: Get the Lowest Manufacturers manufactured the lowest number of models
select top 1 Makes.Make,count(MakeModels.ModelID) as num_models
from Makes inner join MakeModels on Makes.MakeID = MakeModels.MakeID
group by Makes.make
order by num_models asc

-- Another Solution
select Makes.Make,count(MakeModels.ModelID) as num_models
from Makes inner join MakeModels on Makes.MakeID = MakeModels.MakeID
group by Makes.make
having count(MakeModels.ModelID) = (
			select min(R1.num_models)
			from(
			select MakeID,count(MakeModels.ModelID) as num_models
			from MakeModels 
			group by MakeID
			) R1
)


------------------------------------------------------------------------------------------------------------------------------------------
-- Problem 50: Get all Fuel Types , each time the result should be showed in random order
select *
from FuelTypes
order by NeWID()














