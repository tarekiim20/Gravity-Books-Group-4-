USE gravity_books_DWH
-- Drop foregin Keys if exists
IF EXISTS (SELECT *
           FROM   sys.foreign_keys
           WHERE  NAME = 'fk_fact_orders_dim_books'
                  AND parent_object_id = Object_id('fact_orders'))
  ALTER TABLE fact_orders
  DROP CONSTRAINT fk_fact_orders_dim_books;

-- Drop and create the table
IF EXISTS (SELECT *
           FROM   sys.tables
           WHERE  NAME = 'dim_book')
	DROP TABLE dim_book
go
CREATE TABLE dim_book
  (
     book_id_sk            INT NOT NULL IDENTITY(1, 1),             -- Surrogate key
     book_id_bk            INT NOT NULL,                            -- Business key
	 author_name		NVARCHAR(400),
	 language_code      NVARCHAR(8),
     language_name      NVARCHAR(50),
     title              NVARCHAR(400),
     isBn13             NVARCHAR(50),
     num_pages          INT,
	 publication_date	date,
	 publication_name	NVARCHAR(400),
	 start_date         DATETIME NOT NULL DEFAULT (Getdate()),    -- SCD
     end_date           DATETIME NULL,							  -- SCD
     is_current         TINYINT NOT NULL DEFAULT (1),             -- SCD
     CONSTRAINT pk_dim_book PRIMARY KEY CLUSTERED (book_id_sk)
  );

-- Create Foreign Keys
IF EXISTS (SELECT *
           FROM   sys.tables
           WHERE  NAME = 'fact_orders'
                  AND type = 'u')
  ALTER TABLE fact_orders
    ADD CONSTRAINT fk_fact_orders_dim_books FOREIGN KEY (book_id_sk)
    REFERENCES dim_book(book_id_sk);

-- Create Indexes
IF EXISTS (SELECT *
           FROM   sys.indexes
           WHERE  NAME = 'dim_book_book_id'
                  AND object_id = Object_id('dim_book'))
	DROP INDEX dim_book.dim_book_book_id
go
CREATE INDEX dim_book_book_id
ON dim_book(book_id_sk);

IF EXISTS (SELECT *
           FROM   sys.indexes
           WHERE  NAME = 'dim_book_title'
                  AND object_id = Object_id('dim_book'))
	DROP INDEX dim_book.dim_book_title
go
CREATE INDEX dim_book_title
ON dim_book(title); 