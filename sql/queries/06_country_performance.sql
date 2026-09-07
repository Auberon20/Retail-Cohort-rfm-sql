-- Вопрос 6 (страны, Парето-анализ). Как распределена выручка по странам, и сколько стран
-- обеспечивают 80% оборота?

WITH country_revenue AS (
    SELECT
        country,
        SUM(line_amount) AS line_amount_sum
    FROM sales
    GROUP BY country
)
SELECT
    country,
    line_amount_sum,
    SUM(line_amount_sum) OVER (ORDER BY line_amount_sum DESC) AS running_revenue,
    ROUND(100.0 * SUM(line_amount_sum) OVER (ORDER BY line_amount_sum DESC) / SUM(line_amount_sum) OVER (), 1) AS cumulative_pct
FROM country_revenue
ORDER BY line_amount_sum DESC;
