select	
	YEAR(invoicedate) as salesyear,
	SUM(total) as totalsales
from invoice
group by YEAR(invoicedate)
order by salesyear;