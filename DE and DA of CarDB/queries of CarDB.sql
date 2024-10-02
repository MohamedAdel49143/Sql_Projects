use Car_DB;
-- Dim_Makes
Insert into Dim_Makes (Make)
Select distinct Make From Cars
order by Make asc

select *
from Dim_Makes

update Cars
set MakeID =(select MakeID from Dim_Makes
			 where Dim_Makes.Make = Cars.Make)

select *
from Cars

-----------------------------------------------------------------------------------------------------------
-- Dim_Aspiration
select count(distinct Aspiration)
from Cars

insert into Dim_Aspiration (AspirationName)
select Distinct Aspiration from Cars

select *
from Dim_Aspiration

update Cars
set AspirationID = (Select AspirationID from Dim_Aspiration
					where Cars.Aspiration = Dim_Aspiration.AspirationName)

select *
from Cars
--------------------------------------------------------------------------------------------------------------
select count(distinct Fuel_Type_Name) as Fuel_Name from Cars

create table Dim_FuelNames(
	FuelID int not null identity(1,1),
	FuelName nvarchar(100) not null 
)

alter table Dim_FuelNames add constraint Pk_Dim_FuelNames primary key (FuelID);

insert into Dim_FuelNames (FuelName)
select distinct Fuel_Type_Name from Cars

select * from Dim_FuelNames

alter table cars add FuelID int null;

update Cars
set FuelID = (select FuelID 
			  from Dim_FuelNames
			  where Cars.Fuel_Type_Name = Dim_FuelNames.FuelName)

Alter table cars drop column Fuel_Type_Name

select * from cars

alter table cars 
add constraint FK_Cars_Dim_FuelNames 
foreign Key(FuelID) references Dim_FuelNames(FuelID);

