
-- Business Problems

-- Q 1
-- For each payment method, find the number of transactions and the total quantity sold.

SELECT
	 payment_method,
	 COUNT(*) as no_payments,
	 SUM(quantity) as no_qty_sold
FROM walmart
GROUP BY payment_method


-- Q 2
-- Identify the highest-rated category in each branch, displaying the branch name, category, and average rating.


SELECT *
FROM
(	SELECT
		branch,
		category,
		AVG(rating) as avg_rating,
		RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) as rank
	FROM walmart
	GROUP BY 1, 2
)
WHERE rank = 1

-- Q 3
-- Identify the busiest day for each branch based on the number of transactions.


SELECT *
FROM
	(SELECT
		branch,
		TO_CHAR(TO_DATE(date, 'DD/MM/YY'), 'Day') as day_name,
		COUNT(*) as no_transactions,
		RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) as rank
	FROM walmart
	GROUP BY 1, 2
	)
WHERE rank = 1

-- Q 4
-- Calculate the total quantity of items sold per payment method. List the payment method and total quantity.


SELECT
	 payment_method,
	 -- COUNT(*) as no_payments,
	 SUM(quantity) as no_qty_sold
FROM walmart
GROUP BY payment_method

-- Q.5
-- Determine the average, minimum, and maximum rating of each category for every city.

SELECT
	city,
	category,
	MIN(rating) as min_rating,
	MAX(rating) as max_rating,
	AVG(rating) as avg_rating
FROM walmart
GROUP BY 1, 2


-- Q.6
-- Calculate the total profit for each category by considering total profit as (unit_price × quantity × profit_margin).

SELECT
	category,
	SUM(total_price) as total_revenue,
	SUM(total * profit_margin) as profit
FROM walmart
GROUP BY 1


-- Q.7
-- Determine the most common payment method for each branch. Display the branch and the preferred payment method.


WITH cte
AS
(SELECT
	branch,
	payment_method,
	COUNT(*) as total_trans,
	RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) as rank
FROM walmart
GROUP BY 1, 2
)
SELECT *
FROM cte
WHERE rank = 1


-- Q.8
-- Categorize sales into three groups: MORNING, AFTERNOON, and EVENING. Find the number of invoices in each shift.

SELECT
	branch,
CASE
		WHEN EXTRACT(HOUR FROM(time::time)) < 12 THEN 'Morning'
		WHEN EXTRACT(HOUR FROM(time::time)) BETWEEN 12 AND 17 THEN 'Afternoon'
		ELSE 'Evening'
	END day_time,
	COUNT(*)
FROM walmart
GROUP BY 1, 2
ORDER BY 1, 3 DESC

-- Q 9
-- Identify the five branches with the highest decrease ratio in revenue compared to last year (current year: 2023 and last year: 2022).

SELECT *,
EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) as formated_date
FROM walmart

-- 2022 sales
WITH revenue_2022
AS
(
	SELECT
		branch,
		SUM(total_price) as revenue
	FROM walmart
	WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2022 -- psql
	-- WHERE YEAR(TO_DATE(date, 'DD/MM/YY')) = 2022 -- mysql
	GROUP BY 1
),

revenue_2023
AS
(

	SELECT
		branch,
		SUM(total_price) as revenue
	FROM walmart
	WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2023
	GROUP BY 1
)

SELECT
	ls.branch,
	ls.revenue as last_year_revenue,
	cs.revenue as cr_year_revenue,
	ROUND(
		(ls.revenue - cs.revenue)::numeric/
		ls.revenue::numeric * 100,
		2) as rev_dec_ratio
FROM revenue_2022 as ls
JOIN
revenue_2023 as cs
ON ls.branch = cs.branch
WHERE
	ls.revenue > cs.revenue
ORDER BY 4 DESC
LIMIT 5
