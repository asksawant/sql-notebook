-- What is View?
-- View is database object created over an SQL Query.
-- View does not store any data
-- When we call view it just executes the underline SQL Query
-- View does not improve performance
-- Materialized View can improve the performance

-- Why we require?
-- When we have to share the SQL query with client
-- View helps to avoid sharing the database structure with the client
-- We create new user and only give access to view
-- Helps in sharing complex SQL queries to any non tech person

-- Why we use View?
-- For security
-- For simplify the complex SQL queries
-- Avoid re writing complex queries

-- CREATING THE VIEW
-- Fetch the employee total_sales summary

CREATE VIEW emp_total_sales_summary
AS
SELECT
	w.emp_id AS 'Employee Id',
    CAST(AVG(w.total_sales) AS DECIMAL(10,2)) AS 'Total Sales'
FROM works_with w
GROUP BY emp_id;

SELECT * FROM emp_total_sales_summary; -- Call the View

-- ------ CREATE NEW USER AND GRANTING PERMISSION -------
-- Creating the New User for the client
-- CREATE ROLE James
-- login
-- PASSWORD 'james';

-- Granting permission to the user
-- GRANT SELECT ON emp_total_sales_summary to James;

-- -----------------------------------------------------
-- Overwritting the view if present
-- Using CREATE OR REPLACE -> We can not change the name,datatype, or order of the columns.

CREATE OR REPLACE VIEW emp_total_sales_summary
AS
SELECT
	w.emp_id AS 'Employee Id',
    CAST(AVG(w.total_sales) AS DECIMAL(10,2)) AS 'Total Sales'
FROM works_with w
GROUP BY emp_id;

-- CREATE OR REPLACE VIEW emp_total_sales_summary
-- AS
-- SELECT
-- 	CAST(AVG(w.total_sales) AS DECIMAL(10,2)) AS 'Total Sales',
-- 	w.emp_id AS 'Employee Id'
-- FROM works_with w
-- GROUP BY emp_id;
-- -- the code is not throwing error when I changed the order of columns

-- Changing the Structure of View
-- When the View is created it stores the structure
-- added new columns, will not be display when calling view
-- first we have to run CREATE OR REPLACE view, in order to display new added column
-- Even when added new record we have to refresh the view

-- Rename Column Name
-- ALTER VIEW View_name RENAME COLUMN old_column_name TO new_column_name

-- ALTER
-- 	ALGORITHM = MERGE
-- VIEW emp_total_sales_summary AS
-- 	SELECT
-- 		w.emp_id AS 'New_Employee_Id',
--         CAST(AVG(w.total_sales) AS DECIMAL(10,2)) AS 'Total Sales'
-- 	FROM works_with w
--     GROUP BY emp_id;


-- Deleting the View
DROP VIEW emp_total_sales_summary;
		
-- Updatable View
-- 1. Views should be created using 1 table/view only -> NO JOINS PRESENT
-- 2. Can not have DISTINCT clause, if present we can not update
-- 3. if query contains GROUP BY clause, then we can not update
-- 4. if query contains WITH clause, then we can not update
-- 5. if query contains WINDOWs functions, then we can not update

UPDATE emp_total_sales_summary
SET emp_id = 200
WHERE emp_id = 108;



-- WITH CHECK OPTION

CREATE OR REPLACE VIEW female_emp_summary
AS
SELECT * FROM employee WHERE Sex = 'F'
WITH CHECK OPTION;

INSERT INTO employee VALUES(114, 'April', 'Levinson', '1961-04-26', 'F', 11000, 102, 1);
INSERT INTO employee VALUES(115, 'Kakashi', 'Hatake', '1951-04-26', 'M', 11000, 103, 1);
INSERT INTO employee VALUES(116, 'Sakura', 'Uchiha', '1961-09-26', 'F', 30000, 104, 3);
INSERT INTO employee VALUES(117, 'Kaka', 'Hans', '1956-01-26', 'M', 17000, 103, 1);

SELECT * FROM female_emp_summary;
SELECT * FROM employee;