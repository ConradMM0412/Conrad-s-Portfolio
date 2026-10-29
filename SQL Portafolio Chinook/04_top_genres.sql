Select top 10
	g.name as genre,
	SUM (il.UnitPrice * il.Quantity) as totalsales 
from InvoiceLine il 
join Track t 
	on il.TrackId = t.TrackId
join Genre g 
	on t.GenreId = g.GenreId	
group by g.Name
order by totalsales desc;
