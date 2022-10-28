-- SQL Windows function

SELECT * FROM employee;

-- Find the max salary paid by the company
SELECT
	MAX(e.salary) AS 'Max Salary Paid'
FROM employee e;

-- Find the max salary paid in each branch
SELECT
	MAX(e.salary) AS 'Max Salary Paid',
    b.branch_name
FROM employee e
INNER JOIN branch b
	ON e.branch_id = b.branch_id
GROUP BY
	e.branch_id
ORDER BY
	MAX(e.salary) DESC;

-- Aggregate function as Windows function
-- OVER clause treat the Max function as window function
-- Works like transform in pandas
-- first find the max value in salary column and then paste in all rows 

SELECT
	e.*,
    MAX(salary) OVER() AS 'Max Salary'
FROM employee e;

-- find the max salary in each branch
-- Using Partition by -- it groups all the rows and find max value

SELECT
	e.*,
    b.branch_name,
    b.mgr_id,
    MAX(e.salary) OVER(PARTITION BY b.branch_name) AS 'Max_Salary'
FROM employee e
INNER JOIN branch b
	ON e.branch_id = b.branch_id;

-- ROW_NUMBER
-- finds the row number and paste in new column

SELECT 
	e.*,
	ROW_NUMBER() OVER() AS 'row_number'
FROM
	employee e;
    
-- using partition by branch id
-- first groups all the rows over branch_id and paste the row number

SELECT 
	e.*,
	ROW_NUMBER() OVER(PARTITION BY e.branch_id) AS 'row_number'
FROM
	employee e;

-- Fetch the oldest employee from each branch

SELECT *
FROM(
	SELECT 
		e.*,
		ROW_NUMBER() OVER(PARTITION BY e.branch_id ORDER BY e.birth_day) AS 'row_number'
	FROM
		employee e
) AS o
WHERE
	o.row_number = 1;

-- Fetch the top 2 employee from each branch earning the max salary

SELECT *
FROM(
	SELECT 
		e.*,
		RANK() OVER(PARTITION BY e.branch_id ORDER BY e.salary DESC) AS rnk
	FROM employee e
) AS r
WHERE r.rnk <= 2;

-- DENSE RANK
-- Dense rank does not skip rank
-- 110-1,120-2,120-2,130-3 = Dense Rank
-- 110-1,120-2,120-2,130-4 = Rank
-- 110-1,120-2,120-3,130-4 = Row number

SELECT 
	e.*,
	RANK() OVER(PARTITION BY e.branch_id ORDER BY e.salary DESC) AS rnk,
    DENSE_RANK() OVER(PARTITION BY e.branch_id ORDER BY e.salary DESC) AS d_rnk,
    ROW_NUMBER() OVER(PARTITION BY e.branch_id ORDER BY e.birth_day) AS 'row_number'
FROM employee e;

-- LEAD and LAG

-- LAG works similar to the shift() in pandas
-- By default it return the previous row value
-- LAG(column_name,off-set,what_to_return)
-- Default -- LAG(column_name,1,NULL)
-- LAG(column_name,3,0) -- return values from 3 place behind, returns 0 if not present

-- LEAD(column_name,off-set,what_to_return) -- return 1 place ahead by default
-- LEAD(column_name,3,0) -- return values from 3 place ahead, returns 0 if not present

SELECT
	e.*,
    LAG(e.salary,1,'wth') OVER(PARTITION BY e.branch_id ORDER BY emp_id) AS 'prev_emp_salary',
    LEAD(e.salary,1,'wth') OVER(PARTITION BY e.branch_id ORDER BY emp_id) AS 'next_emp_salary'
FROM
	employee e;

-- Fetch a query to display if the salary of an employee is higher, lower or equal
-- to the previous employee

SELECT
	e.*,
    LAG(e.salary,1,0) OVER(PARTITION BY e.branch_id ORDER BY emp_id) AS 'prev_emp_salary',
	CASE 
		WHEN e.salary > LAG(e.salary,1,0) OVER(PARTITION BY e.branch_id ORDER BY emp_id) THEN 'Higher than previous'
        WHEN e.salary < LAG(e.salary,1,0) OVER(PARTITION BY e.branch_id ORDER BY emp_id) THEN 'Lower than previous'
        WHEN e.salary = LAG(e.salary,1,0) OVER(PARTITION BY e.branch_id ORDER BY emp_id) THEN 'Equal to previous'
        END sal_range
FROM
	employee e;

-- FIRST_VALUE
-- Extract first record within the partition
-- similar to first() in pandas

-- fetch the lowest salary employee from each branch without using min

SELECT
	e.*,
    FIRST_VALUE(e.first_name) OVER(PARTITION BY e.branch_id ORDER BY e.salary) AS 'Lowest_paid'
FROM employee e;

-- LAST_VALUE
-- Extract the last value

-- fetch the highest salary employee from each branch without using max

SELECT
	e.*,
    LAST_VALUE(e.first_name)
		OVER(
			PARTITION BY e.branch_id
			ORDER BY e.salary
            -- RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW -- default frame clause
            RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING -- New frame clause
            -- RANGE BETWEEN 2 PRECEDING AND 3 FOLLOWING -- 
			-- Consider 2 row prior to the current row and 3 rows next to the current row
            -- Range consider everything withing the frame, consider duplicate record also
            -- Row does not consider the duplicate records or rows
            -- ROW BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED ROW
            ) AS 'Highest_paid'
FROM employee e;
-- frame is a subset of partition

-- ALternate way of writing queries
-- When query has multiple over clause, the query is not readable.

SELECT
	e.*,
    FIRST_VALUE(e.first_name) OVER w AS 'Lowest_paid',
    -- Note if the frame clause is different use different
    LAST_VALUE(e.first_name) OVER w AS 'Highest_paid'
FROM employee e
WINDOW w AS (
	PARTITION BY e.branch_id
    ORDER BY e.salary
	RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
);

-- NTH_VALUE
-- Fetch value from particular position
-- Fetch the second lowest paid employee

SELECT
	e.*,
    FIRST_VALUE(e.first_name) OVER w AS 'Lowest_paid',
    -- Note if the frame clause is different use different
    LAST_VALUE(e.first_name) OVER w AS 'Highest_paid',
    NTH_VALUE(e.first_name, 2) OVER w AS 'Second_lowest_paid'
FROM employee e
WINDOW w AS (
	PARTITION BY e.branch_id
    ORDER BY e.salary
	RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
);

-- NTILE
-- Used to group together by bins

-- Create a bucket of highest paid and lowest paid
SELECT
	*,
    CASE
		WHEN x.buck = 1 THEN 'Highest Paid'
        WHEN x.buck = 2 THEN 'Lowest Paid'
        END Employee_Cat
FROM(
SELECT
	e.*,
    NTILE(2) OVER(ORDER BY e.salary DESC) AS buck
FROM employee e
) x;

-- CUME_DIST (cumulative distribution)
/* Value --> 1 <= CUME_DIST > 0 */
/* Formula = Current Row no (or Row No with value same as current row) / Total no of row */

-- Fetech the employee how takes 30 percent of salary
SELECT
	*
FROM(
	SELECT 
		e.*,
		CUME_DIST() OVER(ORDER BY e.salary DESC) AS cumulative,
		ROUND(CUME_DIST() OVER(ORDER BY e.salary DESC) * 100,2) AS cume_dist_percent
	FROM
		employee e
) x
WHERE
	x.cume_dist_percent <= 30;

-- PERCENT_RANK
/* Formula = Current Row no - 1 / Total no of row - 1 */

-- How expensive is Jan salary compared to others
SELECT
	*
FROM(
	SELECT 
		*,
		PERCENT_RANK() OVER(ORDER BY salary) AS percentage_rank,
		ROUND(PERCENT_RANK() OVER(ORDER BY salary) * 100,2) AS per_rank
	FROM employee
) x
WHERE
	x.first_name = 'Jan';