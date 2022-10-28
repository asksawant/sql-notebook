-- Reference
-- https://www.youtube.com/watch?v=7hZYh9qXxe4&ab_channel=techTFQ
-- https://learnsql.com/blog/sql-recursive-cte/

USE companydb;

-- Recursive CTE Syntax

WITH RECURSIVE cte_name AS (
	SELECT _query (non_recursive_query or the base_query)
	UNION ALL
	SELECT _query (recursive_query_using_cte_name (with_a_termination_condition))
)
SELECT * FROM cte_name;

-- Q1-> Display number from 1 to 10 withou using any in-built functions

WITH RECURSIVE numbers AS (
	SELECT 1 AS n
	UNION ALL
	SELECT n + 1
	FROM numbers
	WHERE n < 10 -- termination condition
)
SELECT * FROM numbers;

-- Q2-> Find the hierarchy of employees under a give manager 'David'

WITH RECURSIVE emp_hier AS(
	SELECT
		emp_id,
		first_name,
		last_name,
		super_id,
		1 AS lvl
	FROM employee
	WHERE first_name = 'David'
	UNION ALL
	SELECT
		e.emp_id,
		e.first_name,
		e.last_name,
		e.super_id,
		h.lvl + 1 AS lvl
	FROM emp_hier h
	JOIN employee e
		ON h.emp_id = e.super_id
)
SELECT
	h2.emp_id AS 'Employee Id',
	h2.first_name AS 'First Name',
	h2.last_name AS 'Last Name',
	e2.first_name AS 'Supervisor Name',
	h2.lvl AS 'Hierarchy'
FROM emp_hier h2
LEFT JOIN employee e2
	ON e2.emp_id = h2.super_id;

-- Q3-> Find the hierarchy of managers for a given employee - 'Son'

WITH RECURSIVE emp_hier AS(
	SELECT
		emp_id,
		first_name,
		last_name,
		super_id,
		1 AS lvl
	FROM employee
	WHERE first_name = 'Son'
	UNION ALL
	SELECT
		e.emp_id,
		e.first_name,
		e.last_name,
		e.super_id,
		h.lvl + 1 AS lvl
	FROM emp_hier h
	JOIN employee e
		ON h.super_id = e.emp_id -- Only change
)
SELECT
	h2.emp_id AS 'Employee Id',
	h2.first_name AS 'First Name',
	h2.last_name AS 'Last Name',
	e2.first_name AS 'Supervisor Name',
	h2.lvl AS 'Hierarchy'
FROM emp_hier h2
LEFT JOIN employee e2
	ON e2.emp_id = h2.super_id;
    
-- -----------------------------------------------------
USE mydb;

CREATE TABLE investment (
  invest_id INT PRIMARY KEY,
  investment_amount DECIMAL
);

INSERT INTO investment VALUES (1,9705321);
INSERT INTO investment VALUES (2,5612948);
INSERT INTO investment VALUES (3,5322146);

SELECT * FROM investment;

-- Q4-> These are the amount of the three investment options
-- The investment amount will be divided equal amoung the investors
-- if there are 3 investor and investment is 3000, each invest will pay 1000
-- Calculate the amount per investor depending on their number i.e 0,1,2,3 for each investment_amount

-- WITH RECURSIVE invest_amt AS (
-- 	SELECT 
-- 		0 AS investors_number,
-- 		0.00 AS investment_amount,
--         0.00 AS individual_amount
--     FROM investment    
-- 	UNION ALL
--     SELECT
-- 		investors_number + 1,
--         i.investment_amount,
--         i.investment_amount / (investors_number + 1)
-- 	FROM investment i, invest_amt
--     WHERE investors_number << 3
-- )
-- SELECT *
-- FROM invest_amt
-- ORDER BY  investment_amount, investors_number;
-- -- Question is not solved some error please check afterwords