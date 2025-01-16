USE gravity_books_DWH
-- Drop foregin Keys if exists
IF EXISTS (SELECT *
           FROM   sys.foreign_keys
           WHERE  NAME = 'fk_fact_orders_dim_shipping_methods'
                  AND parent_object_id = Object_id('fact_orders'))
  ALTER TABLE fact_orders
  DROP CONSTRAINT fk_fact_orders_dim_shipping_methods;

-- Drop and create the table
IF EXISTS (SELECT *
           FROM   sys.tables
           WHERE  NAME = 'dim_shipping_method')
	DROP TABLE dim_shipping_method
go
CREATE TABLE dim_shipping_method
  (
     method_id_sk            INT NOT NULL IDENTITY(1, 1),             -- Surrogate key
     method_id_bk            INT NOT NULL,                            -- Business key
     method_name			NVARCHAR(100) NULL,
	 start_date             DATETIME NOT NULL DEFAULT (Getdate()),    -- SCD
     end_date               DATETIME NULL,							  -- SCD
     is_current             TINYINT NOT NULL DEFAULT (1),             -- SCD
     CONSTRAINT pk_dim_shipping PRIMARY KEY CLUSTERED (method_id_sk)
  );

-- Create Foreign Keys
IF EXISTS (SELECT *
           FROM   sys.tables
           WHERE  NAME = 'fact_orders'
                  AND type = 'u')
  ALTER TABLE fact_orders
    ADD CONSTRAINT fk_fact_orders_dim_shipping_methods FOREIGN KEY (method_id_sk)
    REFERENCES dim_shipping_method(method_id_sk);

-- Create Indexes
IF EXISTS (SELECT *
           FROM   sys.indexes
           WHERE  NAME = 'dim_shipping_method_id_bk'
                  AND object_id = Object_id('dim_shipping_method'))
	DROP INDEX dim_shipping_method.dim_shipping_method_id_bk
go
CREATE INDEX dim_shipping_method_id_bk
ON dim_shipping_method(method_id_bk);

IF EXISTS (SELECT *
           FROM   sys.indexes
           WHERE  NAME = 'dim_shipping_method'
                  AND object_id = Object_id('dim_shipping'))
	DROP INDEX dim_shipping_method.dim_shipping_method
go
CREATE INDEX dim_shipping_method
ON dim_shipping_method(method_name); 