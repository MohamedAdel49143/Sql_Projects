-- print details of sales where amount are > 2,000 and boxes are < 100
select *
from sales
where amount > 2000 and boxes < 100;

-- How many sales did each of the salespersons have in january 2022?
select salesperson, sum(amount)
from people
left outer join sales
on people.spid = sales.spid
where Extract(Year from saledate) = 2022 and Extract(Month from saledate) = 01
group by salesperson ;

--which product sells more boxes?
select product,sum(boxes) as Total_boxes
from sales
inner join products
on sales.pid = products.pid
group by product
order by Total_boxes desc;

--which product sold more boxes in the first 7 days of february 2022?
select product,sum(boxes) as Total_boxes
from products
inner join sales
on products.pid = sales.pid
where extract(year from saledate) = 2022 and extract(Month from saledate) = 02 and
	  extract(day from saledate) between 01 and 07
group by product
order by Total_boxes desc;

--which sales had under 100 customers & 100 boxes? Did any of them occur on wednesday?
select *,
case when  customers < 100 and boxes < 100 and extract(dow from saledate) = 3 then 'Ok'
else 'Not Ok'
end as "result"
from sales
order by result desc;

















 









