
-- ============================================================
-- Project 01: Inventory Analysis
-- PT Nusantara Distribution | Dataset Year: 2025
-- File: 01_create_tables.sql
-- Purpose: Reproduce the PostgreSQL database table structure
-- ============================================================
-- Run on a new, empty database before importing CSV files.
-- ============================================================

-- 1. Product master
CREATE TABLE products (
    product_id VARCHAR(10) PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    unit VARCHAR(20) NOT NULL,
    unit_cost NUMERIC(12,2) NOT NULL,
    selling_price NUMERIC(12,2) NOT NULL,
    shelf_life_days INTEGER
);

-- 2. Warehouse master
CREATE TABLE warehouses (
    warehouse_id VARCHAR(10)
        CONSTRAINT warehouse_pkey PRIMARY KEY,
    warehouse_name VARCHAR(100) NOT NULL,
    warehouse_type VARCHAR(50) NOT NULL,
    capacity_units INTEGER NOT NULL
);

-- 3. Opening inventory
CREATE TABLE opening_inventory (
    snapshot_date DATE NOT NULL,
    warehouse_id VARCHAR(10) NOT NULL,
    product_id VARCHAR(10) NOT NULL,
    opening_qty INTEGER NOT NULL,

    CONSTRAINT pk_opening_inventory
        PRIMARY KEY (
            snapshot_date,
            warehouse_id,
            product_id
        ),

    CONSTRAINT fk_opening_warehouse
        FOREIGN KEY (warehouse_id)
        REFERENCES warehouses(warehouse_id),

    CONSTRAINT fk_opening_product
        FOREIGN KEY (product_id)
        REFERENCES products(product_id)
);

-- 4. Inventory movements
CREATE TABLE inventory_transactions (
    transaction_id VARCHAR(15) PRIMARY KEY,
    transaction_date DATE NOT NULL,
    warehouse_id VARCHAR(10) NOT NULL,
    product_id VARCHAR(10) NOT NULL,
    transaction_type VARCHAR(30) NOT NULL,
    quantity INTEGER NOT NULL,
    reference_id VARCHAR(30),
    remarks TEXT,

    CONSTRAINT fk_inventory_warehouse
        FOREIGN KEY (warehouse_id)
        REFERENCES warehouses(warehouse_id),

    CONSTRAINT fk_inventory_product
        FOREIGN KEY (product_id)
        REFERENCES products(product_id)
);

-- 5. Sales transactions
CREATE TABLE sales (
    sales_id VARCHAR(15) PRIMARY KEY,
    sales_date DATE NOT NULL,
    warehouse_id VARCHAR(10) NOT NULL,
    product_id VARCHAR(10) NOT NULL,
    quantity INTEGER NOT NULL,
    unit_price NUMERIC(12,2) NOT NULL,
    discount_pct NUMERIC(5,2) NOT NULL,
    sales_channel VARCHAR(50) NOT NULL,
    customer_type VARCHAR(50) NOT NULL,

    -- Constraint names preserved from the existing database.
    CONSTRAINT fk_sales_product
        FOREIGN KEY (warehouse_id)
        REFERENCES warehouses(warehouse_id),

    CONSTRAINT fk_sales_warehouse
        FOREIGN KEY (product_id)
        REFERENCES products(product_id)
);
