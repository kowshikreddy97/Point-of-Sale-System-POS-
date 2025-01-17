ETL and Data Aggregation Project
This project demonstrates an ETL (Extract, Transform, Load) pipeline deployed on an AWS EC2 instance. The pipeline processes raw customer, order, and product data stored in MariaDB, performs data cleansing, and generates insightful JSON-based nested aggregates. These aggregates are then integrated into MongoDB for scalable storage and advanced querying.

Features
ETL Pipeline: Processes and transforms raw data across multiple tables into meaningful insights.
AWS EC2 Deployment: The entire pipeline is hosted on a cloud instance to ensure scalability and reliability.
MariaDB: Used for relational data storage, schema design, and generating complex nested JSON aggregates.
MongoDB Integration: Provides scalable and flexible storage for querying aggregated data.
JSON Aggregates: Generates nested JSON documents for:
Customer order history with order details and purchased items.
Product purchase details, including buyers and order quantities.
Schema Overview
Tables
Product

id: Product ID
name: Product Name
currentPrice: Current Price
availableQuantity: Quantity in Stock
City

zip: ZIP Code
city: City Name
state: State Name
Customer

id: Customer ID
firstName: First Name
lastName: Last Name
email: Email Address
address1: Primary Address
address2: Secondary Address (optional)
phone: Phone Number
birthdate: Birthdate
zip: ZIP Code (linked to City)
Order

id: Order ID
datePlaced: Date the order was placed
dateShipped: Shipping Date
customer_id: Linked Customer ID
Orderline

order_id: Linked Order ID
product_id: Linked Product ID
quantity: Quantity ordered
erd
Aggregates
Customer Order History: Combines customer information with an array of orders and order details.
Product Purchase Details: Lists products with an array of customers who purchased them.
Tools and Technologies
AWS EC2: Hosted the project for cloud scalability.
MariaDB: Managed relational data and performed ETL transformations.
MongoDB: Used for storing and querying aggregated JSON documents.
SQL: Wrote complex queries for data extraction and aggregation.
Linux: Configured the server environment and automated tasks.
