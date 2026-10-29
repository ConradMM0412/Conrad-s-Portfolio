WITH CustomerSpending AS (
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
        c.LastName)
SELECT TOP 10
    CustomerId,
    FirstName,
    LastName,
    TotalSpent
FROM CustomerSpending
ORDER BY TotalSpent DESC;