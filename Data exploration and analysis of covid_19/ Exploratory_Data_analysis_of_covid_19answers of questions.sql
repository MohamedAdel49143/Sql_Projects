--shows likelihood of a person would be died in case of she has been infected
select location,sum(dead) as total_dead,sum(infected) as total_infected,
case when sum(infected) = 0 then 0
	 else round(((sum(dead):: numeric/sum(infected) :: numeric) * 100),3)
end percentage
from info
group by location
order by percentage asc;
----Show likeihood of a person would be died in case of she has been vaccinated---
select location,sum(dead) as Total_dead,sum(vaccinated) as Total_vaccinated,
case when sum(vaccinated) = 0 then 0
	 else round(((sum(dead)::numeric/sum(vaccinated)::numeric) * 100),4)
end percentage
from info
group by location
order by percentage asc
------Shows likelihood of a person would be infected in case of she has been vaccinated?
select location,sum(infected) as Total_infected,sum(vaccinated) as Total_vaccinated,
case when sum(vaccinated) = 0 then 0 
	 else round(((sum(infected)::numeric/sum(vaccinated)::numeric) * 100), 3)
end percentage
from info
group by location
order by percentage desc;
--which country does have the highest death compare to population?
select location,sum(dead) as Total_dead,sum(population) as Total_population,
		round(((sum(dead)::numeric/sum(population)::numeric)* 100),5) as Percentage
from info 
group by location
order by percentage desc;














