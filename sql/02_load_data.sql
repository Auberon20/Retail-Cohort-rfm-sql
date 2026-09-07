-- 02_load_data.sql - загрузка csv в таблицу retail_raw
-- Запуск из корня проекта: psql -d retail_analytics -f sql/02_load_data.sql
--
-- У файла кодировка WIN1252 (в описаниях товаров встречается знак фунта),
-- поэтому указываем ее явно в COPY.

\copy retail_raw FROM 'data/online_retail.csv' WITH (FORMAT csv, HEADER true, ENCODING 'WIN1252', NULL '');

SELECT count(*) AS rows_loaded FROM retail_raw;
