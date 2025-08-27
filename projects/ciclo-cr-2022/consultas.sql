--Conrad Murillo Marin
--1.Total Sales by Year: A chart representing total sales for each year, using amounts for representation.
SELECT 
    YEAR(soh.OrderDate) AS Anio,
    SUM(sod.LineTotal) AS VentasTotales
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
GROUP BY YEAR(soh.OrderDate)
ORDER BY Anio

--2.Sales Distribution by Region: A chart that represents total sales by region or country, showing which areas are generating the most sales and where growth opportunities may exist.
SELECT 
    cr.Name AS Pais,
    sp.Name AS Region,
    SUM(sod.LineTotal) AS VentasTotales
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Person.Address a ON soh.ShipToAddressID = a.AddressID
JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
JOIN Person.CountryRegion cr ON sp.CountryRegionCode = cr.CountryRegionCode
GROUP BY cr.Name, sp.Name
ORDER BY VentasTotales DESC

--3.Salesperson Comparison Chart A chart that compares each salesperson's sales performance, helping to identify the most effective salespeople and those who may need additional training.
SELECT 
    p.FirstName + ' ' + p.LastName AS NombreVendedor,
    SUM(sod.LineTotal) AS VentasTotales
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Sales.SalesPerson sp ON soh.SalesPersonID = sp.BusinessEntityID
JOIN Person.Person p ON sp.BusinessEntityID = p.BusinessEntityID
GROUP BY p.FirstName, p.LastName
ORDER BY VentasTotales DESC

--4.Sales by Product Category: A chart representing sales by year based on product category, using product quantities for representation. The category is found in the [Production].[ProductCategory] table.
SELECT 
    YEAR(soh.OrderDate) AS Anio,
    pc.Name AS CategoriaProducto,
    SUM(sod.OrderQty) AS TotalProductosVendidos
FROM Sales.SalesOrderDetail sod
JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
JOIN Production.Product p ON sod.ProductID = p.ProductID
JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
JOIN Production.ProductCategory pc ON ps.ProductCategoryID = pc.ProductCategoryID
GROUP BY YEAR(soh.OrderDate), pc.Name
ORDER BY Anio, TotalProductosVendidos DESC

--5, Sales variations for all products depending on the area and its corresponding climate, so that it can be seen whether hot areas buy products corresponding to their climate and vice versa for cold areas.

--I'm going to start by looking at the quantity of product, product type, and province of the product to see if I can segregate the respective trends. 
SELECT 
    a.StateProvinceID,
    sp.Name AS Provincia,
    p.Name AS Producto,
    SUM(sod.OrderQty) AS TotalVendido
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product p ON sod.ProductID = p.ProductID
JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID
JOIN Person.Address a ON c.CustomerID = a.AddressID
JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
WHERE p.Name LIKE '%gloves%' 
   OR p.Name LIKE '%vest%' 
   OR p.Name LIKE '%water%' 
   OR p.Name LIKE '%light%' 
GROUP BY a.StateProvinceID, sp.Name, p.Name
ORDER BY Provincia, TotalVendido DESC

-- After creating that table with which I was able to identify trends, I now know that I can sort them by hot or cold climate to graph and see sales trends for certain products.
SELECT 
    sp.Name AS Region,
    CASE 
        WHEN sp.Name IN (
            'California', 'New South Wales', 'Queensland', 'Washington',
            'Oregon', 'Victoria', 'South Australia', 'Texas', 'Arizona',
            'Florida', 'Maryland', 'Ohio', 'South Carolina', 'Kentucky',
            'Illinois', 'Tasmania', 'Utah'
        ) THEN 'Cálido'
        
        WHEN sp.Name IN (
            'British Columbia', 'Bayern', 'Brandenburg', 'Charente-Maritime', 'Saarland',
            'England', 'Ontario', 'Massachusetts', 'Minnesota', 'Hessen', 'Hamburg',
            'Seine (Paris)', 'Hauts de Seine', 'Seine Saint Denis', 'Seine et Marne',
            'Loiret', 'Loir et Cher', 'Essonne', 'Val de Marne', 'Val d''Oise',
            'Yveline', 'Nord', 'Moselle', 'Pas de Calais', 'Wyoming',
            'Nordrhein-Westfalen', 'Garonne (Haute)', 'New York', 'Somme',
            'Alberta'  
        ) THEN 'Frío'
        
        ELSE 'Desconocido'
    END AS Clima,
    p.Name AS Producto,
    SUM(sod.OrderQty) AS CantidadVendida
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product p ON sod.ProductID = p.ProductID
JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID
JOIN Person.Address a ON c.CustomerID = a.AddressID
JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
WHERE p.Name IN (
    'Water Bottle - 30 oz.',
    'Full-Finger Gloves, L', 'Full-Finger Gloves, M', 'Full-Finger Gloves, S',
    'Half-Finger Gloves, L', 'Half-Finger Gloves, M', 'Half-Finger Gloves, S',
    'Classic Vest, S', 'Classic Vest, M', 'Classic Vest, L'
)
GROUP BY sp.Name, p.Name
ORDER BY Region, Producto


-- It seems my original query is excluding several locations due to climate, so I keep updating until all locations are assigned their correct climate type.

UPDATE dbo.VentasPorClima
SET Clima = CASE 
    -- Warm Regions
    WHEN Region IN (
        'California', 'New South Wales', 'Queensland', 'Washington',
        'Oregon', 'Victoria', 'South Australia', 'Texas', 'Arizona', 'Florida'
    ) THEN 'Cálido'

    -- Cold Regions
    WHEN Region IN (
        'Bayern', 'Saarland', 'Brandenburg', 'British Columbia', 'England',
        'Ontario', 'Massachusetts', 'Minnesota', 'Hessen', 'Hamburg',
        'Paris', 'Seine', 'Seine Saint Denis', 'Seine et Marne',
        'Loiret', 'Loir et Cher', 'Essonne', 'Charente-Maritime',
        'Val de Marne', 'Val d''Oise', 'Yveline', 'Nord', 'Moselle'
    ) THEN 'Frío'

    ELSE 'Desconocido'
END;

UPDATE dbo.VentasPorClima
SET Clima = CASE 
    WHEN Region = 'Seine (Paris)' THEN 'Frío'
    WHEN Region = 'Hauts de Seine' THEN 'Frío'
    WHEN Region = 'Maryland' THEN 'Cálido'
    WHEN Region = 'Ohio' THEN 'Cálido'
    WHEN Region = 'South Carolina' THEN 'Cálido'
    WHEN Region = 'Kentucky' THEN 'Cálido'
    WHEN Region = 'Alberta' THEN 'Frío'
    WHEN Region = 'Illinois' THEN 'Cálido'
    WHEN Region = 'Pas de Calais' THEN 'Frío'
    WHEN Region = 'Wyoming' THEN 'Frío'
    WHEN Region = 'Nordrhein-Westfalen' THEN 'Frío'
    WHEN Region = 'Tasmania' THEN 'Cálido'
    WHEN Region = 'Garonne (Haute)' THEN 'Frío'
    WHEN Region = 'New York' THEN 'Frío'
    WHEN Region = 'Somme' THEN 'Frío'
    WHEN Region = 'Utah' THEN 'Cálido'
END
WHERE Clima = 'Desconocido';
-- Now if you run the original sales query by climate, it will give all the regions with their respective climate.

SELECT 
    sp.Name AS Region,
    CASE 
        WHEN sp.Name IN (
            'California', 'New South Wales', 'Queensland', 'Washington',
            'Oregon', 'Victoria', 'South Australia', 'Texas', 'Arizona',
            'Florida', 'Maryland', 'Ohio', 'South Carolina', 'Kentucky',
            'Illinois', 'Tasmania', 'Utah'
        ) THEN 'Cálido'
        
        WHEN sp.Name IN (
            'British Columbia', 'Bayern', 'Brandenburg', 'Charente-Maritime', 'Saarland',
            'England', 'Ontario', 'Massachusetts', 'Minnesota', 'Hessen', 'Hamburg',
            'Seine (Paris)', 'Hauts de Seine', 'Seine Saint Denis', 'Seine et Marne',
            'Loiret', 'Loir et Cher', 'Essonne', 'Val de Marne', 'Val d''Oise',
            'Yveline', 'Nord', 'Moselle', 'Pas de Calais', 'Wyoming',
            'Nordrhein-Westfalen', 'Garonne (Haute)', 'New York', 'Somme',
            'Alberta'  
        ) THEN 'Frío'
        
        ELSE 'Desconocido'
    END AS Clima,
    p.Name AS Producto,
    SUM(sod.OrderQty) AS CantidadVendida
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product p ON sod.ProductID = p.ProductID
JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID
JOIN Person.Address a ON c.CustomerID = a.AddressID
JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
WHERE p.Name IN (
    'Water Bottle - 30 oz.',
    'Full-Finger Gloves, L', 'Full-Finger Gloves, M', 'Full-Finger Gloves, S',
    'Half-Finger Gloves, L', 'Half-Finger Gloves, M', 'Half-Finger Gloves, S',
    'Classic Vest, S', 'Classic Vest, M', 'Classic Vest, L'
)
GROUP BY sp.Name, p.Name
ORDER BY Region, Producto
--I understand that it should be understood by people who only speak Spanish, so I am updating it for this.
UPDATE dbo.VentasPorClimaPorProducto
SET Producto = 
    CASE 
        WHEN Producto = 'Water Bottle - 30 oz.' THEN 'Botella de Agua - 30 oz'
        WHEN Producto = 'Full-Finger Gloves, L' THEN 'Guantes Completos, Talla L'
        WHEN Producto = 'Full-Finger Gloves, M' THEN 'Guantes Completos, Talla M'
        WHEN Producto = 'Full-Finger Gloves, S' THEN 'Guantes Completos, Talla S'
        WHEN Producto = 'Half-Finger Gloves, L' THEN 'Guantes Medio Dedo, Talla L'
        WHEN Producto = 'Half-Finger Gloves, M' THEN 'Guantes Medio Dedo, Talla M'
        WHEN Producto = 'Half-Finger Gloves, S' THEN 'Guantes Medio Dedo, Talla S'
        WHEN Producto = 'Classic Vest, S' THEN 'Chaleco Clásico, Talla S'
        WHEN Producto = 'Classic Vest, M' THEN 'Chaleco Clásico, Talla M'
        WHEN Producto = 'Classic Vest, L' THEN 'Chaleco Clásico, Talla L'
        ELSE Producto
    END
-- This would be the final query
SELECT 
    sp.Name AS Provincia,
    CASE 
        WHEN sp.Name IN (
            'California', 'New South Wales', 'Queensland', 'Washington',
            'Oregon', 'Victoria', 'South Australia', 'Texas', 'Arizona',
            'Florida', 'Maryland', 'Ohio', 'South Carolina', 'Kentucky',
            'Illinois', 'Tasmania', 'Utah'
        ) THEN 'Cálido'
        
        WHEN sp.Name IN (
            'British Columbia', 'Bayern', 'Brandenburg', 'Charente-Maritime', 'Saarland',
            'England', 'Ontario', 'Massachusetts', 'Minnesota', 'Hessen', 'Hamburg',
            'Seine (Paris)', 'Hauts de Seine', 'Seine Saint Denis', 'Seine et Marne',
            'Loiret', 'Loir et Cher', 'Essonne', 'Val de Marne', 'Val d''Oise',
            'Yveline', 'Nord', 'Moselle', 'Pas de Calais', 'Wyoming',
            'Nordrhein-Westfalen', 'Garonne (Haute)', 'New York', 'Somme',
            'Alberta'
        ) THEN 'Frío'
        
        ELSE 'Desconocido'
    END AS Clima,
    CASE 
        WHEN p.Name = 'Water Bottle - 30 oz.' THEN 'Botella de Agua - 30 oz'
        WHEN p.Name = 'Full-Finger Gloves, L' THEN 'Guantes Completos, Talla L'
        WHEN p.Name = 'Full-Finger Gloves, M' THEN 'Guantes Completos, Talla M'
        WHEN p.Name = 'Full-Finger Gloves, S' THEN 'Guantes Completos, Talla S'
        WHEN p.Name = 'Half-Finger Gloves, L' THEN 'Guantes Medio Dedo, Talla L'
        WHEN p.Name = 'Half-Finger Gloves, M' THEN 'Guantes Medio Dedo, Talla M'
        WHEN p.Name = 'Half-Finger Gloves, S' THEN 'Guantes Medio Dedo, Talla S'
        WHEN p.Name = 'Classic Vest, S' THEN 'Chaleco Clásico, Talla S'
        WHEN p.Name = 'Classic Vest, M' THEN 'Chaleco Clásico, Talla M'
        WHEN p.Name = 'Classic Vest, L' THEN 'Chaleco Clásico, Talla L'
        ELSE p.Name
    END AS Producto,
    SUM(sod.OrderQty) AS CantidadVendida
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product p ON sod.ProductID = p.ProductID
JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID
JOIN Person.Address a ON c.CustomerID = a.AddressID
JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
WHERE p.Name IN (
    'Water Bottle - 30 oz.',
    'Full-Finger Gloves, L', 'Full-Finger Gloves, M', 'Full-Finger Gloves, S',
    'Half-Finger Gloves, L', 'Half-Finger Gloves, M', 'Half-Finger Gloves, S',
    'Classic Vest, S', 'Classic Vest, M', 'Classic Vest, L'
)
GROUP BY sp.Name, p.Name
ORDER BY Provincia, Producto
