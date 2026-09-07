-- 03_transform_curated.sql - чистим сырые данные и получаем таблицу sales
--
-- Что убираем и почему:
--   1. Строки без customer_id - без него нельзя посчитать когорту или RFM
--   2. Отменённые заказы (invoice_no начинается с 'C') - откладываем
--      отдельно в таблицу returns, в sales они не идут
--   3. Строки с quantity <= 0 или unit_price <= 0 - это не продажи,
--      а технические корректировки/списания
--
-- Сколько строк и по какой причине убрано - считаем ниже, эти цифры
-- потом идут в README.

-- Сколько и почему исключаем - для README
SELECT count(*) FILTER (WHERE customer_id IS NULL)                          AS no_customer_id,
       count(*) FILTER (WHERE invoice_no LIKE 'C%')                          AS cancelled_invoices,
       count(*) FILTER (WHERE customer_id IS NOT NULL
                          AND invoice_no NOT LIKE 'C%'
                          AND (quantity <= 0 OR unit_price <= 0))            AS other_bad_rows,
       count(*)                                                              AS total_rows
FROM retail_raw;

DROP TABLE IF EXISTS returns;
CREATE TABLE returns AS
SELECT
    invoice_no,
    stock_code,
    description,
    quantity,
    to_timestamp(invoice_date, 'FMMM/FMDD/YYYY FMHH24:MI') AS invoice_ts,
    unit_price,
    customer_id::int AS customer_id,
    country
FROM retail_raw
WHERE invoice_no LIKE 'C%';

DROP TABLE IF EXISTS sales;
CREATE TABLE sales AS
SELECT
    invoice_no,
    stock_code,
    description,
    quantity,
    to_timestamp(invoice_date, 'FMMM/FMDD/YYYY FMHH24:MI') AS invoice_ts,
    unit_price,
    customer_id::int AS customer_id,
    country,
    (quantity * unit_price)::numeric(12,2) AS line_amount
FROM retail_raw
WHERE customer_id IS NOT NULL
  AND invoice_no NOT LIKE 'C%'
  AND quantity > 0
  AND unit_price > 0;

ALTER TABLE sales ADD COLUMN sale_id serial PRIMARY KEY;
CREATE INDEX idx_sales_customer ON sales (customer_id);
CREATE INDEX idx_sales_invoice ON sales (invoice_no);
CREATE INDEX idx_sales_ts ON sales (invoice_ts);

-- Проверка результата
SELECT count(*) AS clean_rows,
       count(DISTINCT customer_id) AS distinct_customers,
       count(DISTINCT invoice_no) AS distinct_invoices,
       min(invoice_ts) AS first_sale,
       max(invoice_ts) AS last_sale,
       sum(line_amount) AS total_revenue
FROM sales;
