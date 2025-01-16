USE gravity_books_DWH
GO
IF EXISTS (SELECT *
           FROM   sys.tables
           WHERE  NAME = 'fact_orders')
	DROP TABLE fact_orders;


CREATE TABLE fact_orders
  (	
	 order_id_sk		INT IDENTITY(1,1),			   -- surrogate key as a primary key

     customer_id_sk		INT NOT NULL,				   -- surrogate key as a forigen key
	 method_id_sk		INT NOT NULL,                  -- surrogate key as a forigen key
     book_id_sk			INT NOT NULL,                  -- surrogate key as a forigen key
     date_id_sk			INT NOT NULL,                  -- surrogate key as a forigen key
	 order_id_bk		INT NOT NULL,
	 line_id_bk			INT NOT NULL,
	 order_status		NVARCHAR(400),
     price				INT,					        -- Measure
     shipping_cost		INT,					        -- Measure

	 CONSTRAINT pk_fact_orders PRIMARY KEY CLUSTERED (order_id_sk),
     
     CONSTRAINT fk_fact_orders_dim_customer FOREIGN KEY (customer_id_sk) REFERENCES dim_customer(customer_id_sk),
     CONSTRAINT fk_fact_orders_dim_book FOREIGN KEY (book_id_sk) REFERENCES dim_book(book_id_sk),
	 CONSTRAINT fk_fact_orders_dim_shipping_methods FOREIGN KEY (method_id_sk) REFERENCES dim_shipping_method(method_id_sk),
     CONSTRAINT fk_fact_orders_dim_date FOREIGN KEY (date_id_sk) REFERENCES dim_date(date_id_sk)
  );


-- Create Indexes on forigen keys

-- Create Indexes for Customer key
IF EXISTS (SELECT *
           FROM   sys.indexes
           WHERE  NAME = 'fact_orders_dim_customer'
                  AND object_id = Object_id('fact_orders'))
	DROP INDEX fact_orders.fact_orders_dim_customer;

CREATE INDEX fact_orders_dim_customer
ON fact_orders(customer_id_sk);

-- Create Indexes for Book key
IF EXISTS (SELECT *
           FROM   sys.indexes
           WHERE  NAME = 'fact_orders_dim_book'
                  AND object_id = Object_id('fact_orders'))
  DROP INDEX fact_orders.fact_orders_dim_book;

CREATE INDEX fact_orders_dim_book
ON fact_orders(book_id_sk);

-- Create Indexes for Order Date key
IF EXISTS (SELECT *
           FROM   sys.indexes
           WHERE  NAME = 'fact_orders_dim_date'
                  AND object_id = Object_id('fact_orders'))
  DROP INDEX fact_orders.fact_orders_dim_date;

CREATE INDEX fact_orders_dim_date
ON fact_orders(date_id_sk); 