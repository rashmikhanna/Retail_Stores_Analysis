-- Create tables
DROP TABLE IF EXISTS stores;
CREATE TABLE Stores (
    Store_ID VARCHAR(20) PRIMARY KEY,
    Store_Name VARCHAR(100),
    City VARCHAR(50),
    State VARCHAR(50),
    Region VARCHAR(50),
    Store_Type VARCHAR(50)
);

DROP TABLE IF EXISTS customers;
CREATE TABLE Customers_2 (
    Customer_ID VARCHAR(20) PRIMARY KEY,
    Customer_Name VARCHAR(100),
    Gender VARCHAR(10),
    Age INT,
    City VARCHAR(50),
    State VARCHAR(50),
    Region VARCHAR(50),
    Membership_Type VARCHAR(50),
    Segment VARCHAR(50)
);

DROP TABLE IF EXISTS products;
CREATE TABLE Products (
    Product_ID VARCHAR(20) PRIMARY KEY,
    Product_Name VARCHAR(150),
    Brand VARCHAR(100),
    Category VARCHAR(100),
    Subcategory VARCHAR(100),
    Selling_Price NUMERIC(10,2)
);

DROP TABLE IF EXISTS sales;
CREATE TABLE Sales (
    Sales_ID VARCHAR(20) PRIMARY KEY,
    Order_Date DATE,
    Product_ID VARCHAR(20),
    Customer_ID VARCHAR(20),
    Store_ID VARCHAR(20),
    Quantity INT,
    Sales_Amount NUMERIC(12,2),
    Discount NUMERIC(10,2),
    Net_Sales NUMERIC(12,2),
    Cost NUMERIC(12,2),
    Profit NUMERIC(12,2),
    Payment_Mode VARCHAR(50),

    FOREIGN KEY (Product_ID) REFERENCES Products(Product_ID),
    FOREIGN KEY (Customer_ID) REFERENCES Customers_2(Customer_ID),
    FOREIGN KEY (Store_ID) REFERENCES Stores(Store_ID)
);

SELECT * FROM stores;
SELECT * FROM customers_2;
SELECT * FROM products;
SELECT * FROM sales;

COPY stores
FROM '/Users/Shared/stores.csv' 
WITH (FORMAT csv, HEADER true, DELIMITER ',');

COPY customers_2
FROM '/Users/Shared/customers_2.csv' 
WITH (FORMAT csv, HEADER true, DELIMITER ',');

COPY products
FROM '/Users/Shared/products.csv' 
WITH (FORMAT csv, HEADER true, DELIMITER ',');

COPY sales
FROM '/Users/Shared/sales.csv' 
WITH (FORMAT csv, HEADER true, DELIMITER ',');


--Basic Questions
--1.What are the total sales, net sales, total cost, total profit, and total quantity sold?
SELECT SUM(sales_amount) AS total_sales,
    SUM(net_sales) AS total_net_sales,
    SUM(cost) AS total_cost,
    SUM(profit) AS total_profit,
    SUM(quantity) AS total_quantity
FROM sales;

--2.How many unique customers, products, and stores are there?
SELECT COUNT(DISTINCT customer_id) AS no_of_customers,
    COUNT(DISTINCT product_id) AS no_of_products,
    COUNT(DISTINCT store_id) AS no_of_stores
FROM sales;

--3.Which region generates the highest total net sales?
SELECT st.region, SUM(s.net_sales) AS total_sales
FROM sales s
JOIN stores st ON st.store_id=s.store_id
GROUP BY st.region
ORDER BY total_sales DESC;

--4.Which product has generated the highest total sales amount?
SELECT p.product_name, SUM(s.net_sales) AS total_sales
FROM sales s
JOIN products p ON p.product_id=s.product_id
GROUP BY p.product_name
ORDER BY total_sales DESC
LIMIT 1;

--5.Which product category generates the highest total profit?
SELECT p.category, SUM(s.profit) AS total_profit
FROM sales s
JOIN products p ON p.product_id=s.product_id
GROUP BY p.category
ORDER BY total_profit DESC
LIMIT 1;

--6.Which store has generated the highest total net sales?
SELECT st.store_name, SUM(s.net_sales) AS total_net_sales
FROM sales s
JOIN stores st ON st.store_id=s.store_id
GROUP BY st.store_name
ORDER BY total_net_sales DESC
LIMIT 1;

--7.Which payment mode is used most frequently?
SELECT payment_mode, COUNT(*) AS total_transactions
FROM sales
GROUP BY payment_mode
ORDER BY total_transactions DESC
LIMIT 1;

--8.Which membership type has the highest average customer spending?
SELECT c.membership_type, AVG(s.net_sales) AS avg_customer_spending
FROM customers_2 c
JOIN sales s ON c.customer_id=s.customer_id
GROUP BY c.membership_type
ORDER BY avg_customer_spending DESC;

--9.What is the average discount given across all sales?
SELECT AVG(discount) AS avg_discount
FROM sales;

--10.How do total sales, net sales, and profit vary by year?
SELECT EXTRACT(YEAR FROM order_date) AS year,
    SUM(sales_amount) AS total_sales,
    SUM(net_sales) AS total_net_sales,
    SUM(profit) AS total_profit
FROM sales
GROUP BY EXTRACT(YEAR FROM order_date)
ORDER BY year;

--Advanced Questions
--11.What are the top 5 products based on total net sales?
SELECT p.product_name, SUM(s.net_sales) AS total_net_sales
FROM sales s
JOIN products p ON s.product_id=p.product_id
GROUP BY p.product_name
ORDER BY total_net_sales DESC
LIMIT 5;

--12.Which 5 products generate the highest total profit?
SELECT p.product_name, SUM(s.profit) AS total_profit
FROM sales s
JOIN products p ON s.product_id=p.product_id
GROUP BY p.product_name
ORDER BY total_profit DESC
LIMIT 5;

--13.Which customer segment has the highest total net sales and total profit?
SELECT c.segment, SUM(s.profit) AS total_profit,
				SUM(s.net_sales) AS total_net_sales
FROM sales s
JOIN customers_2 c ON c.customer_id=s.customer_id
GROUP BY c.segment
ORDER BY total_profit DESC, total_net_sales DESC;

--14.Which membership type has the highest total net sales?
SELECT c.membership_type, SUM(s.net_sales) AS total_net_sales
FROM sales s
JOIN customers_2 c ON c.customer_id=s.customer_id
GROUP BY c.membership_type
ORDER BY total_net_sales DESC;

--15.Which region has the highest number of customers and total net sales?
SELECT c.region, COUNT(DISTINCT c.customer_id) AS total_customers,
    			SUM(s.net_sales) AS total_net_sales
FROM customers_2 c
JOIN sales s ON c.customer_id = s.customer_id
GROUP BY c.region
ORDER BY total_net_sales DESC;

--16.Which product category has the highest quantity sold and total profit?
SELECT p.category, SUM(s.quantity) AS total_quantity_sold,
    				SUM(s.profit) AS total_profit
FROM sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY p.category
ORDER BY total_profit DESC;

--17.Which customers have placed more than 3 orders, and what is their total net sales?
SELECT c.customer_name, COUNT(s.sales_id) AS total_orders,
    					SUM(s.net_sales) AS total_net_sales
FROM sales s
JOIN customers_2 c ON c.customer_id = s.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(s.sales_id) > 3
ORDER BY total_orders DESC;

