-- WITH clause is sometimes referred as CTE or Sub-Query Factoring
-- WITH clause is helps to avoid writting the sub query multiple times
-- Reference
-- https://www.youtube.com/watch?v=QNfnuK-1YYY&ab_channel=techTFQ

USE companydb;

-- Fetch employees who earn more than average salary of all employees

WITH average_salary (avg_salary) AS
	(SELECT AVG(salary) FROM employee)
    -- first runs the query which is associated with WITH clause
    -- will first find the average salary from employee table and stores in average_salary table
SELECT *
FROM employee e, average_salary av
WHERE e.salary > av.avg_salary;

SELECT * FROM works_with;
SELECT * FROM client;

-- Find the employee whose sales where better than the average sales accross all employee

-- 1. We have to find the total sales of each employee -- emp_tsales
SELECT
	w.emp_id,
	SUM(total_sales) AS 'total_sales_per_emp'
FROM works_with w
GROUP BY w.emp_id;

-- 2. Find the average sales -- avg_tsales
SELECT
	CAST(AVG(total_sales_per_emp) AS DECIMAL(15,2)) AS avg_tsales
FROM(
	SELECT
		w.emp_id,
		SUM(total_sales) AS 'total_sales_per_emp'
	FROM works_with w
	GROUP BY w.emp_id
) x;
-- 3. Find the employee where emp_tsales > avg_tsales
SELECT *
FROM(
	SELECT
		w.emp_id,
		SUM(total_sales) AS 'total_sales_per_emp'
	FROM works_with w
	GROUP BY w.emp_id) emp_total_sales
JOIN (
	SELECT
		CAST(AVG(total_sales_per_emp) AS DECIMAL(15,2)) AS avg_tsales
	FROM(
		SELECT
			w.emp_id,
			SUM(total_sales) AS 'total_sales_per_emp'
		FROM works_with w
		GROUP BY w.emp_id
	) x ) emp_avg_total_sales
    ON
		emp_total_sales.total_sales_per_emp > emp_avg_total_sales.avg_tsales;

-- The problem with this query it is too messy. hard to read

-- Solving the problem using with WITH clause

WITH emp_total_sales (emp_id,total_sales_per_emp) AS
	(
	SELECT
		w.emp_id,
		SUM(total_sales) AS 'total_sales_per_emp'
	FROM works_with w
	GROUP BY w.emp_id    
    ),
    emp_avg_total_sales (avg_tsales) AS
    (
	SELECT
		CAST(AVG(total_sales_per_emp) AS DECIMAL(15,2)) AS avg_tsales
	FROM emp_total_sales
    )
SELECT *
FROM emp_total_sales ts
JOIN emp_avg_total_sales avts
	ON ts.total_sales_per_emp > avts.avg_tsales;