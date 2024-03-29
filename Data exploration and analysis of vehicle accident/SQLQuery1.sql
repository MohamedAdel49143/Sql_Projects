--HOw many accidents have occurred in urban areas versus rural areas?
select Area,count(Area) as Total_Accident
from [dbo].[accident]
group by Area;

--which day of the week has the highest number of accidents?
select Day,count(AccidentIndex) as Total_Accidents
from [dbo].[accident]
group by Day
order by Total_Accidents desc;

--what is the average age of vehicles involved in accidents based on their type?
select VehicleType,count(AccidentIndex) as Total_Accidents,avg(AgeVehicle) as Avg_Age
from [dbo].[vehicle]
where AgeVehicle is not null
group by VehicleType
order by Total_Accidents desc;

--can we identify any trends in accidents based on the age of vehicles involved?

SELECT AgeGroup, COUNT(AccidentIndex) as Total_Accident, AVG(AgeVehicle) as average_year
FROM (
    SELECT AccidentIndex, AgeVehicle,
        CASE 
            WHEN AgeVehicle BETWEEN 0 AND 5 THEN 'New'
            WHEN AgeVehicle BETWEEN 5 AND 10 THEN 'Regular'
            ELSE 'Old'
        END AS AgeGroup
    FROM dbo.vehicle
) AS v
GROUP BY AgeGroup;
--Are there any specific weather conditions that contribute to servere accidents?
declare @Severity varchar(40)-- Â–« «·„ €Ì— Ì” Œœ„ · Œ“Ì‰ ﬁÌ„ „ƒﬁ‰Â ⁄·ÌÂ Ê«” Œœ«„Â« ›Ï «·√Ê«„— «··«ÕﬁÂ
set	@Severity ='Fatal' 
select WeatherConditions,COUNT(Severity) as Total_Accidents
from [dbo].[accident]
where Severity =  @Severity
group by WeatherConditions
order by Total_Accidents desc;

--Do accidents often involve impacts on the left hand of vehicles?
select LeftHand,count(AccidentIndex) As Total_Accidents
from [dbo].[vehicle]
where LeftHand in ('No','Yes')
group by LeftHand

--Are there any relationships between journey purpose and the severity of accidents?
--«·⁄·«ﬁÂ ÂÏ ŒÿÊ—… ﬂ· —Õ·Â 
select JourneyPurpose,count(Severity) as Total_Accidents,
case when count(Severity) between 0 and 1000 then 'low'
	 when count(Severity) between 1001 and 3000 then 'Moderate'
	 else 'High'
end as 'Level'
from [dbo].[accident]
inner join [dbo].[vehicle]
on [dbo].[accident].AccidentIndex = [dbo].[vehicle].AccidentIndex
group by JourneyPurpose
order by Total_Accidents desc;

--Calculate the average age of vehicles involved in accidents,considering day light and point of impact
select PointImpact,avg(AgeVehicle) as Avg_ages 
from [dbo].[accident]
inner join [dbo].[vehicle]
on [dbo].[accident].AccidentIndex = [dbo].[vehicle].AccidentIndex
where LightConditions = 'Daylight'
group by PointImpact












		
	



