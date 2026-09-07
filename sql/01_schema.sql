-- 01_schema.sql - таблица под сырые данные
--
-- Источник: UCI Online Retail - транзакции интернет-магазина подарков
-- за 01.12.2010-09.12.2011. https://archive.ics.uci.edu/dataset/352/online+retail
--
-- Таблица повторяет структуру csv как есть, без изменений.
-- Дату (invoice_date) пока оставляем текстом - распарсим в следующем файле.

DROP TABLE IF EXISTS retail_raw;

CREATE TABLE retail_raw (
    invoice_no    text,
    stock_code    text,
    description   text,
    quantity      integer,
    invoice_date  text,
    unit_price    numeric,
    customer_id   numeric,
    country       text
);
