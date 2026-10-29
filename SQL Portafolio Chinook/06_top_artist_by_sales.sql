select top 10
	ar.name as artist, 
	SUM(il.UnitPrice * il.Quantity) as totalsales
from InvoiceLine il
join track t
	on il.TrackId = t.TrackId
join Album al
	on t.AlbumId = al.AlbumId
join Artist ar
	on al.ArtistId = ar.ArtistId
group by ar.Name
order by totalsales desc;