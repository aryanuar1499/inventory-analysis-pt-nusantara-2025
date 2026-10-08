
-- ============================================================
-- Project 01: Inventory Analysis
-- PT Nusantara Distribution | Dataset Year: 2025
-- File: 01_database_setup.sql
-- Purpose: Initialize the PostgreSQL project database
-- ============================================================

-- Execute this statement while connected to an existing
-- maintenance database, such as 'postgres'.
--
-- Do not execute it inside an active transaction block.
-- Skip this step if the database already exists.

CREATE DATABASE inventory_analysis;

-- ============================================================
-- NEXT STEPS
-- ============================================================

-- 1. Connect to the inventory_analysis database.
--
-- 2. Execute:
--    sql/01_create_tables.sql
--
-- 3. Import the cleaned CSV datasets into their
--    corresponding tables.
--
-- 4. Execute the data validation queries in:
--    sql/02_data_validation.sql
--
-- Note:
-- PostgreSQL CREATE DATABASE does not automatically
-- switch the active database connection.
-- In pgAdmin, open Query Tool on inventory_analysis.
