-- Вопрос 1. Как менялась выручка и число заказов по месяцам, и в какие месяцы был рост или спад к предыдущему месяцу (месяц к месяцу, MoM)?
-- Что нужно в выводе: месяц, число уникальных заказов (invoice_no), суммарная выручка (line_amount), и изменение выручки
-- к предыдущему месяцу в процентах.

WITH agg_by_months AS (
    SELECT
        date_trunc('month', invoice_ts) AS months,
        COUNT(DISTINCT invoice_no) AS unique_invoice_count,
        SUM(line_amount) AS line_amount_sum
    FROM sales
    GROUP BY date_trunc('month', invoice_ts)
)
SELECT
    months,
    unique_invoice_count,
    line_amount_sum,
    ROUND(
        (line_amount_sum - LAG(line_amount_sum) OVER (ORDER BY months)) * 100.0
        / LAG(line_amount_sum) OVER (ORDER BY months),
        1
    ) AS percent_change_amount_sum
FROM agg_by_months
ORDER BY months;
