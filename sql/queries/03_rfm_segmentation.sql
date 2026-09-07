-- Вопрос 3 (RFM-сегментация). Классический способ поделить клиентов на группы по покупательскому поведению - три независимых измерения:
--
-- Recency - сколько дней прошло с последней покупки клиента (считаем от условной "даты среза" - день после самой
-- последней транзакции во всём датасете).
-- Frequency - сколько раз клиент вообще покупал (число уникальных заказов, invoice_no).
-- Monetary - сколько всего потратил (сумма line_amount).
--
-- Три оценки (r_score, f_score, m_score) объединяются в название сегмента через CASE WHEN.
-- Итоговый вывод - по каждому сегменту: сколько клиентов, средние R/F/M, суммарная и доля выручки.

WITH rfm AS (
    SELECT
        customer_id,
        MAX(MAX(invoice_ts)) OVER ()::date - MAX(invoice_ts)::date AS recency,
        COUNT(DISTINCT invoice_no) AS frequency,
        SUM(line_amount) AS monetary
    FROM sales
    GROUP BY customer_id
),
rfm_score AS (
    SELECT
        customer_id,
        recency,
        frequency,
        monetary,
        NTILE(5) OVER (ORDER BY recency DESC) AS r_score,
        NTILE(5) OVER (ORDER BY frequency ASC) AS f_score,
        NTILE(5) OVER (ORDER BY monetary ASC) AS m_score
    FROM rfm
)
SELECT
    CASE
        WHEN r_score + f_score + m_score >= 12 THEN 'champions'
        WHEN r_score + f_score + m_score <= 6 THEN 'lost'
        ELSE 'at_risk'
    END AS segments,
    COUNT(customer_id),
    AVG(recency) AS avg_recency,
    AVG(frequency) AS avg_frequency,
    AVG(monetary) AS avg_monetary,
    SUM(monetary) AS sum_monetary,
    ROUND(100.0 * SUM(monetary) / SUM(SUM(monetary)) OVER (), 1) AS monetary_pct
FROM rfm_score
GROUP BY segments;
