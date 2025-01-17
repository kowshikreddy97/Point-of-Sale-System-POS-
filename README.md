![image](https://github.com/user-attachments/assets/9bf15c43-2804-4004-9ed2-7dc94ede6b8a)


Milestone 1: I have setup the infrastructure on AWS EC2 instance. Installed MariaDB database. After that I have created tables and relationships between them according the ERD diagram. I created tables such as - Customer, City, Product, Order, Order Line, Price history. We have tables and now we have to load the data.

As part of the milestone 2: I have performed ETL Processes. Extraction part was done by the instructor and provided 4 csv files. First step I have transferred files from his server to mine. After that loaded data into temporary tables (normal tables. Haven’t used temp tables because they will get deleted after the completion of session). Performed all kind of transformations using SQL. such as modifying the ZIP code, replacing some irrelevant characters, removing duplicates etc. After that loaded data in main tables, normalized the data and deleted temp tables.

Milestone 3: After loading the data into the database, I created views (virtual tables) to show only relevant information to the users. Created indexes to retrieve the specific information quickly. Materialized views to improve the read performance of the database. 

Milestone 4: Transactions are one of the key features of the relational database. As part of this milestone, I created a few transactions and explored how COMMIT, Implicit commit and ROLLBACK statements can work. Transactions are used to maintain ACID compliance while performing the operations in the database. I understood how we can leverage transactions in production database. Along with that I implemented prepared statements to prevent SQL injections.

Milestone 5: As of this milestone, I created stored procedures which are similar to functions in programming languages. These are used to perform particular tasks repeatedly just by calling whenever needed. 

Milestone 6: As part of this milestone, I have created triggers which are used to perform automation based on the insert/update/delete commands. Triggers are attached to a particular table and whenever that kind of event occurs triggers will execute automatically. We created automations like inserting a new record into price history whenever product price changes etc.

Milestone 7: Cluster is a collection of servers that work together to accomplish a certain task. I have set up a simple replication. I spun up 3 instances - kept one node as master node or primary node which is responsible for all write operations, other 2 nodes are responsible for handling the read requests. With this clustering, we have improved the read performance of the database. But writes are still slow. 
