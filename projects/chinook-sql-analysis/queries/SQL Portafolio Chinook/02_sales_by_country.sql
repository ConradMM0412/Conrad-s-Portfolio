select
	BillingCountry,
	SUM(total) as totalsales
from Invoice
group by BillingCountry
order by totalsales desc;
