-- Q1-> Fetch the employees who's salary is more than the average employee salary

SELECT
	*
FROM employee
WHERE
	salary > (
    	SELECT
			AVG(e.salary) AS avg_salary
		FROM employee e
    );
    
-- --------- DIFFERENT TYPES OF SUB QUERIES -----------
-- 1. Scalar Sub query
-- Sub query that return single row and single column

-- Scalar Sub query in where clause
SELECT
	*
FROM employee
WHERE
	salary > (
    	SELECT
			AVG(e.salary) AS avg_salary
		FROM employee e
    );
    
-- scalar sub query in from clause
SELECT
	*
FROM employee e
INNER JOIN (
	SELECT
		AVG(e.salary) AS avg_salary
	FROM employee e) avg_sal
    ON e.salary > avg_sal.avg_salary;

-- 2. Multiple row Sub query
-- 2.a Sub query which return multiple column and multiple row

-- Fetch the employees who earns the highest salary in each department

SELECT
	e.*
FROM employee e
WHERE (e.branch_id, e.salary) in (SELECT e.branch_id,MAX(e.salary) AS max_sal
									FROM employee e
									GROUP BY e.branch_id);

-- 2.b Sub query which return only 1 column and multiple row

-- Fetch employees who does not have clients

SELECT *
FROM employee
WHERE emp_id NOT IN (SELECT DISTINCT w.emp_id FROM works_with w);

-- 3. Correlated Sub query
-- A subquery which is related to the outer query

-- Fetch the employees in each branch who earn more than the average salary in that branch

SELECT *
FROM employee e1
WHERE e1.salary > (
				SELECT
					AVG(e2.salary) AS 'avg_salary'
				FROM employee e2
				WHERE e2.branch_id = e1.branch_id
                );

-- Fetch employee hows does not have clients
SELECT *
FROM employee e
WHERE NOT EXISTS (
				SELECT 1
                FROM works_with w
                WHERE w.emp_id = e.emp_id
);

-- ------------- NESTED QUERY ----------------

-- Fetch employees whos sales where better than the average sales across all employees

SELECT w.emp_id, SUM(w.total_sales) AS total_sales
FROM works_with w
GROUP BY emp_id;

SELECT
	AVG(x.total_sales) AS avg_sales
FROM(
	SELECT w.emp_id, SUM(w.total_sales) AS total_sales
	FROM works_with w
	GROUP BY emp_id
) x;

SELECT *
FROM (
	SELECT w.emp_id, SUM(w.total_sales) AS total_sales
	FROM works_with w
	GROUP BY emp_id
) emp
INNER JOIN
	(SELECT
		AVG(x.total_sales) AS avg_sales
	FROM(
		SELECT w.emp_id, SUM(w.total_sales) AS total_sales
		FROM works_with w
		GROUP BY emp_id
	) x ) av
	ON
		emp.total_sales > av.avg_sales;

-- Nested Sub query with WITH Clause

WITH emp AS
	(
    SELECT w.emp_id, SUM(w.total_sales) AS total_sales
	FROM works_with w
	GROUP BY emp_id
    )
SELECT *
FROM emp
INNER JOIN
	(SELECT
		AVG(emp.total_sales) AS avg_sales
	FROM emp) av
	ON
		emp.total_sales > av.avg_sales;
        
-- ----------WHERE WE CAN USE SUBQUERIES ----------

-- SELECT
-- FROM
-- WHERE
-- HAVING

-- ------------------------------------------------
-- Using Sub query in SELECT Clause
-- When using subquery in select, the sub query should be scalar sub query
-- Not recommeded to use sub query in the select clause

-- Fetch all the employee details and add remarks to those employees who earn more than the average pay

SELECT
	e.*,
    (CASE WHEN salary > ( SELECT AVG(salary) FROM employee)
			THEN 'Higher than average'
		ELSE NULL
	END) AS Remark
FROM employee e;

-- alternative

SELECT
	e.*,
    (CASE WHEN salary > avg_sal.sal
			THEN 'Higher than average'
		ELSE NULL
	END) AS Remark
FROM employee e
CROSS JOIN ( SELECT AVG(salary) AS sal FROM employee) avg_sal;

-- Sub query in HAVING CLAUSE

-- Fetch employees whos sales where better than the average sales of all employees

SELECT
	*,
    SUM(w.total_sales) AS sales
FROM works_with w
GROUP BY w.emp_id
HAVING SUM(w.total_sales) > (SELECT AVG(total_sales) FROM works_with);

-- SQL Command where we can use subqueries

-- INSERT
-- UPDATE
-- DELETE

-- Insert data into employee table. Make sure not insert duplicate records

-- CREATE TABLE employee_hist (
--   emp_id INT PRIMARY KEY,
--   first_name VARCHAR(40),
--   last_name VARCHAR(40),
--   birth_day DATE,
--   sex VARCHAR(1),
--   salary INT,
--   super_id INT,
--   branch_id INT
--   );

SELECT * FROM employee__hist;

