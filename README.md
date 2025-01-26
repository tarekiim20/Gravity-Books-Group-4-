# **End-to-End Data Warehouse Solution Documentation**

## **1. Project Overview**

### **1.1 Business Problem**
Gravity Books needed a robust system to track customer orders, manage book details, and analyze sales performance. The goal was to build a centralized data warehouse that could integrate data from various operational systems, provide historical tracking, and support analytical queries for business intelligence.

### **1.2 Solution Architecture**
The solution consists of three main components:
1. **ETL Process (SSIS):** Extracts data from the operational database (OLTP), transforms it based on business rules, and loads it into the data warehouse.
2. **Dimensional Modeling (SSAS):** Creates a star schema for efficient querying and analysis.
3. **Reporting and Visualization (Power BI):** Provides interactive dashboards and reports for business users.

---

## **2. Database Design**

![ERD](https://github.com/user-attachments/assets/e38b5133-1883-49ae-8f0e-be976d9835cd)

### **2.1 Operational Database (OLTP)**
The operational database for Gravity Books tracks customers, books, orders, and shipping details. The database consists of the following tables:

- **address_status**: Tracks the status of addresses (e.g., active, inactive).
- **customer_address**: Links customers to their addresses.
- **address**: Stores address details (street, city, country).
- **country**: Contains country names.
- **customer**: Stores customer details (name, email).
- **cust_order**: Tracks orders placed by customers.
- **book**: Contains book details (title, ISBN, author, publisher).
- **book_author**: Links books to authors.
- **author**: Stores author details.
- **book_language**: Tracks the language of books.
- **publisher**: Contains publisher details.
- **order_line**: Tracks individual items within an order.
- **order_history**: Tracks the status history of orders.
- **order_status**: Contains order status values (e.g., shipped, delivered).
- **shipping_method**: Tracks shipping methods and their costs.

### **2.2 Relationships**
- **Customer and Customer Address:** One-to-Many (a customer can have multiple addresses).
- **Address and Country:** Many-to-One (each address belongs to one country).
- **Cust_Order and Customer:** Many-to-One (each order is placed by one customer).
- **Cust_Order and Order_Line:** One-to-Many (each order can have multiple line items).
- **Book and Publisher:** Many-to-One (each book is published by one publisher).
- **Book and Book_Author:** One-to-Many (a book can have multiple authors).

---

## **3. Dimensional Modeling**


![DWH_Schema](https://github.com/user-attachments/assets/dc82d737-6a3e-42c7-a63b-162b414acc95)

### **3.1 Star Schema Design**
The data warehouse uses a **star schema** for efficient querying and analysis. The schema consists of the following dimensions and fact tables:

#### **Dimensions:**
- **Dim_Book:** Contains book details (Book_ID, Author_Name, Language_Name, Publisher_Name, Title, ISBN_13, Num_Pages, Publication_Date).
- **Dim_ShippingMethod:** Contains shipping method details (Method_ID, Method_Name).
- **Dim_Customer:** Contains customer details (Customer_ID, First_Name, Last_Name, Email, Country_Name, Street_Name, Street_Number, City, Address_Status).
- **Dim_Date:** Contains date-related attributes (Date, Day, Month, Year, Quarter, Fiscal Year, etc.).

#### **Fact Table:**
- **Fact_Orders:** Tracks order details (Order_ID, Customer_ID, Book_ID, Shipping_Method_ID, Order_Date, Price, Shipping_Cost).

### **3.2 Advantages of Star Schema**
- **Ease of Querying:** Simplified structure for BI tools like SSAS.
- **Performance:** Denormalized dimensions reduce the need for complex joins.
- **Suitability for Analysis:** Designed for OLAP systems with frequent analytical queries.
- **Flexibility:** Adapts well to changes in business requirements.

### **3.3 Disadvantages of Star Schema**
- **Data Redundancy:** Denormalization can lead to data duplication.
- **Increased Storage Costs:** Redundant data increases storage requirements.
- **Limited Flexibility:** Less robust for complex queries involving multiple joins.

---

## **4. ETL Process (SSIS)**

### **4.1 ETL Overview**
The ETL process extracts data from the operational database, transforms it based on business rules, and loads it into the data warehouse. The process is implemented using **SQL Server Integration Services (SSIS)** and consists of four packages:
1. **Customer Dimension ETL**
2. **Book Dimension ETL**
3. **Shipping Dimension ETL**
4. **Fact Table ETL**

### **4.2 Data Extraction**
Data is extracted from the OLTP database using **OLE DB Source** components. The following SQL queries are used to retrieve data:

#### **Customer Dimension:**
```sql
SELECT customer.customer_id, customer.first_name, customer.last_name, customer.email, 
       country.country_name, address.street_name, address.street_number, address.city, 
       address_status.address_status
FROM address
INNER JOIN country ON address.country_id = country.country_id
INNER JOIN customer_address ON address.address_id = customer_address.address_id
INNER JOIN address_status ON customer_address.status_id = address_status.status_id
INNER JOIN customer ON customer_address.customer_id = customer.customer_id;
```

**Control Flow**

![control flow cust_dim](https://github.com/user-attachments/assets/e377e65e-d892-47eb-a0d4-6ab2b0ffca0e)


**Data Flow**

![data flow book_dim](https://github.com/user-attachments/assets/4cecfde7-d8cd-43c5-9e02-abd80634908e)


#### **Book Dimension:**
```sql
SELECT book.book_id, author.author_name, book_language.language_code, 
       book_language.language_name, book.title, book.isbn13, book.num_pages, 
       book.publication_date, publisher.publisher_name
FROM author
INNER JOIN book_author ON author.author_id = book_author.author_id
INNER JOIN book ON book_author.book_id = book.book_id
INNER JOIN book_language ON book.language_id = book_language.language_id
INNER JOIN publisher ON book.publisher_id = publisher.publisher_id;
```

**Control Flow**

![control flow book_dim](https://github.com/user-attachments/assets/4a5d3d12-8ff0-4014-9b8d-4a20c320b45a)

**Data Flow**

![data flow book_dim](https://github.com/user-attachments/assets/a3904c19-a1d4-41b4-87fd-583472e255da)


#### **Shipping Dimension:**
```sql
SELECT method_id, method_name
FROM shipping_method;
```

**Control Flow**

![control flow shipping_dim](https://github.com/user-attachments/assets/a6016974-74a7-4927-861b-1b8345ab871f)

**Data Flow**

![data flow shipping_dim](https://github.com/user-attachments/assets/22c78316-b05c-4688-b500-343abf6cc7d1)


#### **Fact Table:**
```sql
SELECT co.customer_id, b.book_id, co.shipping_method_id, 
       CAST(FORMAT(co.order_date, 'yyyy-MM-dd 00:00:00.000') AS Datetime) AS order_date, 
       co.order_id, ol.line_id, status_value, ol.price, s.cost
FROM cust_order AS co
LEFT OUTER JOIN order_line AS ol ON co.order_id = ol.order_id
LEFT OUTER JOIN book AS b ON ol.book_id = b.book_id
LEFT OUTER JOIN shipping_method AS s ON s.method_id = co.shipping_method_id
LEFT OUTER JOIN order_history AS oh ON co.order_id = oh.order_id
LEFT OUTER JOIN order_status AS os ON oh.status_id = os.status_id;
```


**Control Flow**

![control flow fact_order](https://github.com/user-attachments/assets/d78906bd-1db5-4776-9ed0-49ca27199a20)

**Data Flow**

![data flow fact_order](https://github.com/user-attachments/assets/0e589138-ce15-46f6-b578-0395f4930c50)


### **4.3 Data Transformation**
Key transformations include:
- **Slowly Changing Dimension (SCD):** Tracks historical changes for attributes like customer address and book title.
- **Data Type Conversion:** Ensures compatibility between source and target systems.
- **Derived Columns:** Adds calculated fields like start and end dates for historical tracking.

### **4.4 Data Loading**
Transformed data is loaded into the data warehouse using **OLE DB Destination** components.

---

## **5. Cube Creation (SSAS)**

### **5.1 Cube Structure**
The **Gravity Books Cube** is built using SQL Server Analysis Services (SSAS) and includes the following measures and dimensions:

#### **Measures:**
- **Total Revenue:** Sum of the price column in fact_orders.
- **Total Shipping Cost:** Sum of the shipping_cost column in fact_orders.
- **Number of Orders:** Count of order_id_sk.

#### **Dimensions:**
- **Customer Dimension:** Attributes include Country, City, Customer Name, and Is Current.
- **Book Dimension:** Attributes include Author Name, Title, Language, and Publication Year.
- **Date Dimension:** Attributes include Year, Month, Fiscal Quarter, and Fiscal Year.
- **Shipping Method Dimension:** Attributes include Method Name.

### **5.2 Types of Analysis Supported**
- **Shipping Cost Analysis:** Total shipping cost by method.
- **Sales Analysis:** Total revenue by time (day, month, fiscal quarter).
- **Order Analysis:** Number of orders by shipping method and order volume trends.
- **Customer Demographics Analysis:** Sales by country or city, shipping preferences by region.

---

## **6. Reporting and Visualization (Power BI)**

![Screenshot 2025-01-26 084358](https://github.com/user-attachments/assets/32b7db62-d362-4223-bc7c-f7f50b4515a4)
![Screenshot 2025-01-26 084414](https://github.com/user-attachments/assets/101959d2-8c78-456b-a2cd-98ea5eaf6886)
![Screenshot 2025-01-26 084406](https://github.com/user-attachments/assets/0774c694-cb88-4513-9425-6ef18c0d800e)


### **6.1 Dashboards and Reports**
Power BI is used to create interactive dashboards and reports for business users. Key reports include:
- **Sales Performance:** Total revenue and order trends over time.
- **Shipping Cost Analysis:** Breakdown of shipping costs by method.
- **Customer Demographics:** Sales by country, city, and customer preferences.

### **6.2 Key Features**
- **Interactive Filters:** Users can filter data by date, customer, book, and shipping method.
- **Drill-Down Capabilities:** Allows users to explore data at different levels of granularity.
- **Visualizations:** Includes bar charts, line charts, pie charts, and maps for data exploration.

### **6.3 Insights from Power BI Dashboards**

#### **6.3.1 Customer Analysis**
- **Top Countries by Orders:**
  - **China** leads with the highest number of orders, followed by **Indonesia**, **Russia**, and **Philippines**.
  - **Poland**, **Brazil**, and **France** also contribute significantly to the order volume.
  
- **Customer Distribution:**
  - Customers are spread across diverse regions, including **Canada**, **Nigeria**, **Serbia**, and **Ireland**.
  - Smaller markets like **Tajikistan**, **Azerbaijan**, and **Norway** also show activity, indicating a global customer base.

#### **6.3.2 Sales Analysis**
- **Orders by Language:**
  - **English** is the most popular language for books, accounting for **17.18%** of total orders.
  - **Spanish** follows with **15.31%** of orders, indicating a strong demand for Spanish-language books.
  
- **Orders by Author:**
  - **Agatha Christie** is the most popular author, contributing **10.71%** of total orders.
  - Other top authors include **James Patterson**, **Sandra Brown**, and **P.G. Wodehouse**.
  
- **Orders by Book Title:**
  - Books like **"Animals: Go Down"**, **"To Mien"**, and **"After the Funeral"** are among the top-selling titles.
  
- **Monthly Order Trends:**
  - Orders peak in **February (02)**, **April (04)**, and **May (05)**, indicating seasonal trends in book purchases.
  - The lowest order volumes are observed in **July (07)** and **October (10)**.

#### **6.3.3 Shipping Cost Analysis**
- **Shipping Methods:**
  - **Standard Shipping** is the most commonly used method, accounting for **44.67%** of orders.
  - **Express Shipping** and **Priority Shipping** are also popular, with **11.79%** and **10.71%** of orders, respectively.
  
- **Top Authors by Shipping Cost:**
  - **Agatha Christie** and **P.G. Wodehouse** are among the top authors with the highest shipping costs, likely due to their high order volumes.
  - **Sandra Brown** and **James Patterson** also contribute significantly to shipping costs.

- **Total Shipping Cost:**
  - The total shipping cost across all orders is **224K**, with **Standard Shipping** contributing the most due to its high usage.

#### **6.3.4 Key Observations**
- **Global Reach:** Gravity Books has a diverse customer base, with significant contributions from both large and small markets.
- **Language Preferences:** English and Spanish are the most popular languages, reflecting the company's focus on these markets.
- **Seasonal Trends:** Order volumes fluctuate throughout the year, with peaks in early spring and dips in mid-year.
- **Shipping Preferences:** Customers prefer **Standard Shipping**, likely due to its cost-effectiveness, but **Express** and **Priority** options are also widely used.


### **6.3.5 Recommendations**
1. **Target High-Volume Markets:** Focus marketing efforts on countries like **China**, **Indonesia**, and **Russia** to further boost sales.
2. **Expand Language Offerings:** Increase the availability of books in **Spanish** and other popular languages to cater to diverse customer preferences.
3. **Optimize Shipping Costs:** Analyze the cost structure of **Standard Shipping** to identify potential savings without compromising service quality.
4. **Seasonal Promotions:** Launch targeted promotions during low-order months (e.g., **July** and **October**) to drive sales during off-peak periods.

---

## **7. Conclusion**

The end-to-end data warehouse solution for Gravity Books successfully integrates data from multiple sources, provides historical tracking, and supports advanced analytical queries. The use of SSIS for ETL, SSAS for cube creation, and Power BI for reporting ensures a robust and scalable solution for business intelligence needs.

---

### **Appendix: Team Contributions**
- **Task 1: Database Design** – [Eng. Asmaa Moayed]
- **Task 2: Dimensional Modeling** – [Eng. Roaa Ayman]
- **Task 3: SQL Physical Schema** – [Eng. Abdelrahman Shear]
- **Task 4: ETL Process (SSIS)** – [Eng. Mohamed Alsamabdoni]
- **Task 5: Cube Creation (SSAS)** – [Eng. Asmaa Moayed]
- **Task 6: Power BI Reporting** – [Eng. Ahmed Ayman]
- **Task 7: Documentation** – [Collective Team Effort]

---
