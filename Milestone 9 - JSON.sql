/* On my honor, as an Aggie, I have neither given nor received unauthorized assistance on this assignment. I
further affirm that I have not and will not provide this code to any person, platform, or repository,
without the express written permission of Dr. Gomillion. I understand that any violation of these
standards will have serious repercussions. */

source trig.sql

/* Creating an aggregate - Focuses on Customers, Includes all address information. Does not include Address2 if it is NULL. Combines Address1, Address2, City, State, and Zip into a single line with \n between
lines. Combines First and Last Name and provides it as “Customer Name”. */

SELECT 
    json_object(
        'CustomerName', CONCAT(c.FirstName, ' ', c.LastName),
        'Address',  CONCAT( c.Address1, IFNULL(CONCAT('\n', c.Address2), ''),'\n', ct.City,' ',ct.State,' ',ct.Zip)
               )  
INTO OUTFILE '/var/lib/mysql/pos/cust1.json'
FROM Customer c
JOIN City ct ON c.Zip = ct.Zip
GROUP BY c.CustomerID, c.FirstName, c.LastName;

/* second aggregate for products */
SELECT json_object( 'ProductID', p.ProductID, 'Current Price', p.CurrentPrice, 'Product Name', p.Name,
                    'Customers', JSON_ARRAYAGG( json_object( 'CustomerID', c.CustomerID, 'Customer Name', CONCAT(c.FirstName, ' ', c.LastName) ) )
    ) AS ProductInfo
INTO OUTFILE '/var/lib/mysql/pos/prod.json'
FROM Product p
LEFT JOIN OrderLine ol ON p.ProductID = ol.ProductID
LEFT JOIN `Order` o ON ol.OrderID = o.OrderID
LEFT JOIN Customer c ON o.CustomerID = c.CustomerID
GROUP BY p.ProductID, p.Name, p.CurrentPrice;

/* Third aggregate */

SELECT
    json_object( 'OrderID', o.OrderID, 'CustomerID', c.CustomerID, 'Customer Name', CONCAT(c.FirstName, ' ', c.LastName),
        'Products', JSON_ARRAYAGG( json_object( 'Product ID', p.ProductID, 'Product Name', p.Name, 'Quantity', ol.Quantity ))
    ) AS OrderInfo
INTO OUTFILE '/var/lib/mysql/pos/ord.json'
FROM `Order` o
JOIN Customer c ON o.CustomerID = c.CustomerID
JOIN OrderLine ol ON o.OrderID = ol.OrderID
JOIN Product p ON ol.ProductID = p.ProductID;

/* fourth aggregate */

SELECT json_object( 'Customer Name', CONCAT(c.FirstName, ' ', c.LastName), 'Address', CONCAT(c.Address1, IFNULL(CONCAT('\n', c.Address2), ''),'\n', ct.City,' ',ct.State,' ',ct.Zip), 
	'Orders', SELECT JSON_ARRAYAGG(json_object('OrderID', o.OrderID, 'DatePlaced', o.datePlaced, 'DateShipped', o.dateShipped, 'OrderTotal', o.OrderTotal,
                'Items', (SELECT JSON_ARRAYAGG(json_object('ProductID', p.ProductID, 'Quantity', ol.Quantity, 'Product Name', p.Name))
	       	FROM OrderLine ol JOIN Product p ON ol.ProductID = p.ProductID WHERE ol.OrderID = o.OrderID ) )) FROM Order o WHERE o.custmerID = c.customerID
    ) AS CustomerInfo
INTO OUTFILE '/var/lib/mysql/pos/cust2.json'
FROM Customer c
JOIN City ct ON c.Zip = ct.Zip
GROUP BY c.CustomerID, c.FirstName, c.LastName;
