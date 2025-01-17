
/* On my honor, as an Aggie, I have neither given nor received unauthorized assistance on this assignment. I
further affirm that I have not and will not provide this code to any person, platform, or repository,
without the express written permission of Dr. Gomillion. I understand that any violation of these
standards will have serious repercussions. */

source proc.sql

/* Calling Stored Procedures */

CALL proc_FillUnitPrice();
CALL proc_FillOrderTotal();
CALL proc_RefreshMV();

/* Creating Sales Tax Table */

create table SalesTax(

        Zip Decimal(5) ZEROFILL PRIMARY KEY,
        TaxRate Float

) ENGINE = InnoDB;

/* Creating a Temporary table to load the data into columns*/

Create table SalesTax_TMP (

        State Varchar(128),
        ZipCode Varchar(128) PRIMARY KEY,
        TaxRegionName Varchar(128),
        EstimatedCombinedRate Varchar(128),
        StateRate Varchar(128),
        EstimatedCountyRate Varchar(128),
        EstimatedCityRate Varchar(128),
        EstimatedSpecialRate Varchar(128),
        RiskLevel Varchar(128)

) ENGINE = InnoDB;

/* Loading data Into the SalesTax Temporary table - SalesTax_TMP */

LOAD DATA LOCAL INFILE '/home/dgomillion/TAXRATES.csv' INTO TABLE SalesTax_TMP
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

/* Doing manipulation and deleting text lines */
DELETE FROM SalesTax_TMP
WHERE ZipCode = 'ZipCode';

/*Inserting data into the SalesTax table  from the SalesTax_TMP temporary table */

INSERT INTO SalesTax
SELECT ZipCode, EstimatedCombinedRate FROM SalesTax_TMP;

/* Dropping Temporary Table */
DROP TABLE SalesTax_TMP;

/* Altering the PriceHistory Table - Modifying ChangeID, TS Columns */

ALTER TABLE PriceHistory
MODIFY COLUMN ChangeID BIGINT UNSIGNED AUTO_INCREMENT;

ALTER TABLE PriceHistory
MODIFY COLUMN TS Timestamp DEFAULT CURRENT_TIMESTAMP;

/* Altering the Order Table - Changing column name and creating new columns */

ALTER TABLE `Order`
CHANGE COLUMN OrderTotal OrderSubtotal DECIMAL(8,2);

ALTER TABLE `Order`
ADD COLUMN SalesTax DECIMAL(5,2) DEFAULT '0.00';

ALTER TABLE `Order`
ADD COLUMN OrderTotal DECIMAL(8,2)
GENERATED ALWAYS AS (OrderSubtotal + SalesTax) VIRTUAL;

/* Creating a trigger on Product Table - To insert a row to Pricehistory table whenever the price of the product changes */

DELIMITER //
CREATE OR REPLACE TRIGGER currentPriceUpdate_Product AFTER UPDATE
ON Product FOR EACH ROW
BEGIN
        IF NEW.CurrentPrice != OLD.CurrentPrice THEN
                INSERT INTO PriceHistory(OldPrice, NewPrice, ProductID)
                VALUES(OLD.CurrentPrice, NEW.CurrentPrice, NEW.ProductID);
        END IF;

END; //
DELIMITER ;

/* Creating a trigger for Orderline table - set the UnitPrice in OrderLine to be
whatever is in the product table as CurrentPrice each time a new OrderLine is created */

DELIMITER //
CREATE OR REPLACE TRIGGER setUnitPrice_OrderLine BEFORE INSERT
ON OrderLine FOR EACH ROW
BEGIN

        DECLARE prdQty INT;

       SET NEW.UnitPrice = (SELECT CurrentPrice FROM Product WHERE Product.ProductID = NEW.ProductID);

       /* if I try to create a new OrderLine with a NULL quantity, set the quantity to 1*/
       IF NEW.Quantity = 0 OR NEW.Quantity IS NULL THEN
        SET NEW.Quantity = 1;
       END IF;

       SET prdQty = (SELECT QtyOnHand FROM Product WHERE ProductID = NEW.ProductID);

       /* If the quantity is greater than Product's QtyOnHand value then throw an error */
        IF NEW.Quantity > prdQty THEN
         SIGNAL SQLSTATE '45000'
         SET MESSAGE_TEXT = 'Requested Quantity not available for this product';
        END IF;

        /* Updating QtyOnHand on Product Table */
         UPDATE Product
         SET QtyOnHand = QtyOnHand - NEW.Quantity
         WHERE ProductID = NEW.ProductID;

END; //
DELIMITER ;

DELIMITER //
CREATE OR REPLACE TRIGGER updateQtyOnHand AFTER INSERT
ON OrderLine FOR EACH ROW
BEGIN
        DECLARE zipCode DECIMAL(5);
        DECLARE pID INT;
        DECLARE pName Varchar(128);
        DECLARE cust LONG;

        /* updating order subtotal in order table */
         UPDATE `Order`
         SET OrderSubtotal = (SELECT SUM(OrderLine.LineTotal) FROM OrderLine WHERE OrderLine.OrderID = `Order`.OrderID)
         WHERE `Order`.OrderID = NEW.OrderID;

        /* Calculate and update the sales tax for all orders that have any products added or removed */
          /* Get the zip code of the customer */

          SET zipCode = (SELECT Zip FROM Customer WHERE CustomerID = (SELECT CustomerID FROM `Order` WHERE `Order`.OrderID = NEW.OrderID));

          /* Update sales tax field in order table */
          Update `Order`
          SET SalesTax = OrderSubtotal * (SELECT TaxRate FROM SalesTax WHERE Zip = zipCode)
          WHERE `Order`.OrderID = NEW.OrderID;

         /* Calling a stored procedure */
        CALL updateMVProductBuyers(NEW.ProductID);

END; //
DELIMITER ;

/* Creating a Before update trigger for Orderline to throw an error message */

DELIMITER //
CREATE OR REPLACE TRIGGER beforeUpdate_OrderLine BEFORE UPDATE
ON OrderLine FOR EACH ROW
BEGIN
        DECLARE prdQty INT;

        SELECT QtyOnHand INTO prdQty FROM Product WHERE ProductID = NEW.ProductID;

        /* If the quantity is greater than Product's QtyOnHand value then throw an error */
        IF NEW.Quantity > prdQty THEN
           SIGNAL SQLSTATE '45000'
           SET MESSAGE_TEXT = 'Requested Quantity not available for this product';
        END IF;

        /* Updating QtyOnHand on Product Table */
        IF NEW.Quantity != OLD.Quantity THEN
         UPDATE Product
         SET QtyOnHand = QtyOnHand + OLD.Quantity - NEW.Quantity
         WHERE Product.ProductID = NEW.ProductID;
        END IF;


END; //
DELIMITER ;

/* Creating a trigger for OrderLine Table - to keep track of line total changes and making sure order subtotal is uptodate in Order Table */

DELIMITER //
CREATE OR REPLACE TRIGGER calc_OrderSubTotalUptodate AFTER UPDATE
ON OrderLine FOR EACH ROW
BEGIN
        DECLARE zipCode DECIMAL(5);
        UPDATE `Order`
        SET OrderSubtotal = (SELECT SUM(LineTotal) FROM OrderLine WHERE OrderLine.OrderID = `Order`.OrderID)
        WHERE `Order`.OrderID = NEW.OrderID;

         /* Calculate and update the sales tax for all orders that have any products added or removed */
        /* Get the zip code of the customer */

         SET zipCode = (SELECT Zip FROM Customer WHERE CustomerID = (SELECT CustomerID FROM `Order` WHERE `Order`.OrderID = NEW.OrderID));

          /* Update sales tax field in order table */
          Update `Order`
          SET SalesTax = OrderSubtotal * (SELECT TaxRate FROM SalesTax WHERE Zip = zipCode)
          WHERE `Order`.OrderID = NEW.OrderID;


END; //
DELIMITER ;

/* Creating a before update trigger for orderline to update QtyOnHand value for product after orderline deletion */

DELIMITER //
CREATE OR REPLACE TRIGGER afterdelete_OrderLine AFTER DELETE
ON OrderLine FOR EACH ROW
BEGIN
        DECLARE zipCode DECIMAL(5);
        /* updating order subtotal in order table */
          UPDATE `Order`
          SET OrderSubtotal = (SELECT SUM(LineTotal) FROM OrderLine WHERE OrderLine.OrderID = `Order`.OrderID)
          WHERE `Order`.OrderID = OLD.OrderID;

        /* Updating QtyOnHand on Product Table */

          UPDATE Product
          SET QtyOnHand = QtyOnHand + OLD.Quantity
          WHERE ProductID = OLD.ProductID;

        /* Calculate and update the sales tax for all orders that have any products added or removed */
        /* Get the zip code of the customer */

         SET zipCode = (SELECT Zip FROM Customer WHERE CustomerID = (SELECT CustomerID FROM `Order` WHERE `Order`.OrderID = OLD.OrderID));

          /* Update sales tax field in order table */
          Update `Order`
          SET SalesTax = OrderSubtotal * (SELECT TaxRate FROM SalesTax WHERE Zip = zipCode)
          WHERE `Order`.OrderID = OLD.OrderID;

END; //
DELIMITER ;

/* Creating a stored procedure to update materialized view */
DELIMITER //
CREATE OR REPLACE PROCEDURE updateMVProductBuyers (pID INT)
BEGIN
        /* Deleting the old record if any exists */
        DELETE FROM mv_ProductBuyers WHERE productID = pID;

        /* Inserting the new record */
        INSERT INTO mv_ProductBuyers(ProductID, ProductName, Customers)
        SELECT P.ProductID,
        P.Name,
        GROUP_CONCAT(DISTINCT CONCAT(C.CustomerID,' ',C.FirstName,' ',C.LastName) ORDER BY C.CustomerID SEPARATOR ',') AS Customers
        FROM Product P
        LEFT JOIN OrderLine ol
        ON P.ProductID = ol.ProductID
        LEFT JOIN `Order` ORD
        ON ol.OrderID = ORD.OrderID
        LEFT JOIN Customer C
        ON ORD.CustomerID = C.CustomerID
        WHERE p.ProductID = pID
        GROUP BY P.ProductID, P.Name;

END //
DELIMITER ;



