SELECT
    c.CustomerId,
    c.FirstName,
    c.LastName,
    SUM(i.Total) AS TotalSpent
FROM Customer c
JOIN Invoice i
    ON c.CustomerId = i.CustomerId
GROUP BY
    c.CustomerId,
    c.FirstName,
    c.LastName
HAVING SUM(i.Total) > (
    SELECT AVG(CustomerTotal)
    FROM (
        SELECT
            CustomerId,
            SUM(Total) AS CustomerTotal
        FROM Invoice
        GROUP BY CustomerId
    ) AS CustomerSpending
)
ORDER BY TotalSpent DESC;