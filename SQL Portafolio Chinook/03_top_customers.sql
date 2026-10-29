Select top 10
	c.customerid,
	c.FirstName,
	c.LastName,
	Sum (i.Total) as totalspent 
from customer c
join invoice i 
	on c.customerId = i.customerid
group by 
	c.CustomerId,
	c.FirstName,
	c.LastName
Order By totalspent desc;