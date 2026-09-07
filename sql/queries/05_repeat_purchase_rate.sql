-- Вопрос 5 (повторные покупки). Два подвопроса:
-- 5.1 - как распределены клиенты по числу заказов? Бакеты: "1 заказ", "2-3 заказа", "4-10 заказов", "10+ заказов".
-- 5.2 - какая доля клиентов вообще делает повторную покупку (больше одного заказа) - одним числом.

-- 5.1
WITH orders_per_customer AS (
    SELECT
        customer_id,
        COUNT(DISTINCT invoice_no) AS orders_count
    FROM sales
    GROUP BY customer_id
)
SELECT
    CASE
        WHEN orders_count = 1 THEN '1 заказ'
        WHEN orders_count <= 3 THEN '2-3 заказа'
        WHEN orders_count <= 10 THEN '4-10 заказов'
        ELSE '10+ заказов'
    END AS bucket,
    COUNT(*) AS customer_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct_of_customers
FROM orders_per_customer
GROUP BY bucket;

-- 5.2
WITH orders_per_customer AS (
    SELECT
        customer_id,
        COUNT(DISTINCT invoice_no) AS orders_count
    FROM sales
    GROUP BY customer_id
)
SELECT
    ROUND(
        100.0 * SUM(
            CASE
                WHEN orders_count > 1 THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        1
    ) AS repeat_customer_rate_pct
FROM orders_per_customer;
