{{
    config(
        materialized='table'
    )
}}

WITH customer_transactions AS (
    SELECT
        customer_id
        , customer_joined_date
        , SUM(transaction_amount) as total_transaction_amount
        , COUNT(DISTINCT DATE_TRUNC(transaction_date,month)) as count_distinct_transaction_months
        , MIN(transaction_date) as first_customer_transaction_date
    FROM {{ ref('trf_transactions_customers') }}
    GROUP BY 1,2
)

, customer_interval AS (
    SELECT
        customer_id
        , customer_joined_date
        , MIN(transaction_date) as first_customer_transaction_date
    FROM {{ ref('trf_transactions_customers') }}
    GROUP BY 1,2
)

, customer_interval_join_to_transaction_dates AS (
    SELECT
        customer_id
        DATE_DIFF(customer_joined_date, first_customer_transaction_date, DAY) AS duration_customer_join_to_transaction_days
    FROM customer_interval
)

SELECT
    ctrx.customer_id
-- total transactions made by each customer
    , ctrx.total_transaction_amount
-- their average monthly spending
    , (ctrx.total_transaction_amount/ctrx.count_distinct_transaction_months) AS customer_average_monthly_transaction_amount
-- the average customer spending interval
    , ctd.duration_customer_join_to_transaction_days
-- average calculated over the entire customer dataset
    , AVG(ctd.duration_customer_join_to_transaction_days) OVER () AS mean_duration_customer_join_to_transaction_days
FROM customer_transactions ctrx
LEFT JOIN customer_interval_join_to_transaction_dates ctd
    ON ctrx.customer_id ctd.customer_id
