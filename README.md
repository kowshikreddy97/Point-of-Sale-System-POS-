Database Schema: ERD 

![image](https://github.com/user-attachments/assets/9bf15c43-2804-4004-9ed2-7dc94ede6b8a)

Created SQL scripts for each milestone to perform various operations mentioned below.

Milestone 1: In this milestone, I have setup the infrastructure on AWS EC2 instance. Installed MariaDB database on Linux. After that I have created tables and relationships between them according the ERD diagram. I created tables such as - Customer, City, Product, Order, Order Line, Price history. We have tables and now we have to load the data.

Milestone 2: I have performed ETL Process to load the data into MariaDB relational database. Extraction part was done by the instructor and provided 4 csv files. First step I have transferred files from his server to mine. After that loaded data into temporary tables (normal tables. Haven’t used temp tables because they will get deleted after the completion of session in MariaDB). Performed all kinds of transformations using SQL such as Removing unwanted characters from Name fields, Standardizing the ZIP column and current price in Product Table, replacing some irrelevant characters, removing duplicates etc. After that loaded data into main tables created in Milestone 1, normalized the data and deleted temp tables.

Milestone 3: After loading the data into the database, I created views (virtual tables) to show only relevant information to the users. Created indexes to retrieve the specific information quickly. Materialized views to improve the read performance of the database. 

Milestone 4: Transactions are one of the key features of the relational database. As part of this milestone, I created a few transactions and explored how COMMIT, Implicit COMMIT and ROLLBACK statements can work. Transactions are used to maintain ACID compliance while performing the operations in the database. I understood how we can leverage transactions in production database. Along with that I implemented prepared statements to prevent SQL injections.

Milestone 5: As part of this milestone, I created stored procedures which are similar to functions in programming languages. These are used to perform particular tasks repeatedly just by calling whenever needed. 

Milestone 6: As part of this milestone, I have created triggers which are used to perform automation or automate tasks based on the insert/update/delete commands. Triggers are attached to a particular table and whenever insert/update/delete events occur then triggers will execute automatically. We created automations like inserting a new record into price history whenever product price changes, set the UnitPrice in OrderLine to be whatever is in the product table as CurrentPrice each time a new OrderLine is created etc.

Milestone 7: Cluster is a collection of servers that work together to accomplish a certain task. I have set up a simple replication. I spun up 3 instances - kept one node as master node or primary node which is responsible for all write operations, other 2 nodes are responsible for handling the read requests. With this clustering, we have improved the read performance of the database. But writes are still slow. 

Milestone 8: To write the write/read operations of the database simultaneously, we have implemented peer-to-peer clustering. As part of this, I spin up 3 nodes - all nodes are responsible for handling both read and write operations. This eliminated the replication delay and network latency. The main key behind this replication is Virtually Synchronous Replication which makes sure that all updates happen to all nodes at the same time. To perform analytics further, relational databases won’t be useful and effective.

Milestone 9: As part of this milestone, I converted data into JSON format using JSON and JSON Arryagg objects. Retrieved the JSON files with the help of WinSCP. 

Milestone 10: As part of this milestone, I Installed MongoDB onto an AWS EC2 instance running on Amazon Linux 2023. created a new NOSQL document database - MONGODB. After setting it up, I perfromed ETL operation - migrated data from the relational database to NOSQL using the JSON files. Loaded data into collections of the document database. Utilized these collections to run analytics and solve some business problems. Such as finding out which product was bought mostly by the customers. 

  - Who are my customers that live in Texas?
  - Who is my best customer?
  - What is my best product?
  - Which product should I no longer consider carrying?
  - Do any of these orders look fraudulent? 

Having duplicate data in multiple collections can occupy / take more space on disk but it really improves the Query performance. Due to this de-normalization, I’m able to create queries or solve multiple business related problems easily by uncovering valuable insights. 

