-- Вопрос 4 (топ товаров, первый JOIN в проекте). Два подвопроса:
-- 4.1 - какие товары (stock_code) в принципе приносят больше всего выручки по всей базе?
-- 4.2 - топ-3 товара по выручке в каждой из топ-5 стран по обороту (не считая UK - он вне конкуренции по объёму)?

-- 4.1
SELECT
    stock_code,
    SUM(line_amount),
    MAX(description)
FROM sales
GROUP BY stock_code
ORDER BY SUM(line_amount) DESC
LIMIT 10;

-- 4.2
WITH top_countries AS (
    SELECT
        country,
        SUM(line_amount) AS line_amount_sum
    FROM sales
    WHERE country != 'United Kingdom'
    GROUP BY country
    ORDER BY SUM(line_amount) DESC
    LIMIT 5
),
rank_country_stock AS (
    SELECT
        s.country,
        s.stock_code,
        SUM(line_amount) AS country_stock_revenue_sum,
        RANK() OVER (PARTITION BY s.country ORDER BY SUM(line_amount) DESC) AS rank_number
    FROM sales s JOIN top_countries tc ON s.country = tc.country
    GROUP BY s.country, s.stock_code
)
SELECT
    country,
    stock_code,
    country_stock_revenue_sum,
    rank_number
FROM rank_country_stock
WHERE rank_number <= 3
ORDER BY country, rank_number;
