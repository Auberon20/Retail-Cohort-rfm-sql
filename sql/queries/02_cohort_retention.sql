-- Вопрос 2 (когортный ретеншн). Разобьём клиентов на когорты по месяцу первой покупки - и посмотрим, какая доля каждой когорты
-- возвращается и покупает снова в следующие месяцы.
--
-- Смысл в двух словах: для каждого клиента нужно знать месяц его первой покупки (это его когорта), а дальше - в какие месяцы
-- после этого он вообще покупал, пронумеровав месяцы от начала когорты (0, 1, 2...). Дальше - сколько уникальных клиентов
-- было активно на каждом таком номере месяца внутри каждой когорты, и какая это доля от размера самой когорты.

WITH cohort_former AS (
    SELECT
        customer_id,
        EXTRACT(YEAR FROM invoice_ts) * 12 + EXTRACT(MONTH FROM invoice_ts)  AS sales_month,
        MIN(EXTRACT(YEAR FROM invoice_ts) * 12 + EXTRACT(MONTH FROM invoice_ts))
            OVER (PARTITION BY customer_id) AS cohort_number,
        (EXTRACT(YEAR FROM invoice_ts) * 12 + EXTRACT(MONTH FROM invoice_ts)) - MIN(EXTRACT(YEAR FROM invoice_ts) * 12 + EXTRACT(MONTH FROM invoice_ts))
            OVER (PARTITION BY customer_id) AS sales_month_number
    FROM sales
),
cohort_months_count AS (
    SELECT
        cohort_number,
        sales_month_number,
        COUNT(DISTINCT customer_id) AS unique_customer_count
    FROM cohort_former
    GROUP BY cohort_number, sales_month_number
)
SELECT
    cohort_number,
    sales_month_number,
    ROUND(
        100.0 * unique_customer_count
        / FIRST_VALUE(unique_customer_count) OVER (PARTITION BY cohort_number ORDER BY sales_month_number), 1
    ) AS retention_pct
FROM cohort_months_count
ORDER BY cohort_number, sales_month_number;
