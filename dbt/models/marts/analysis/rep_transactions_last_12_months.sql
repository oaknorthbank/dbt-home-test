{{
    config(
        materialized='table'
    )
}}

WITH monthly_transaction_total_amounts AS (
    SELECT
        DATE_TRUNC(transaction_date,MONTH) as transaction_month
        , SUM(transaction_amount) as total_transaction_amount
    FROM {{ ref('trf_transactions_customers') }}
--filter for last 12 complete months for accurate monthly comparison
    WHERE transaction_date >=  DATE_SUB(DATE_TRUNC(CURRENT_DATE,MONTH), INTERVAL 12 MONTH)
        AND transaction_date < DATE_TRUNC(CURRENT_DATE,MONTH)
    GROUP BY 1
)

, customer_spend_per_month AS (
    SELECT
        DATE_TRUNC(transaction_date,MONTH) as transaction_month
        , customer_id
        , SUM(transaction_amount) as total_transaction_amount
    FROM {{ ref('trf_transactions_customers') }}
--filter for last 12 complete months for accurate monthly comparison
    WHERE transaction_date >=  DATE_SUB(DATE_TRUNC(CURRENT_DATE,MONTH), INTERVAL 12 MONTH)
        AND transaction_date < DATE_TRUNC(CURRENT_DATE,MONTH)
    GROUP BY 1,2
)

, customer_highest_spend_per_month AS (
    SELECT
        transaction_month
        , customer_id
        , total_transaction_amount
    FROM customer_spend_per_month
    --qualify to select highest spending customer per month
    QUALIFY ROW_NUMBER() OVER (PARITION BY transaction_month ORDER BY total_transaction_amount DESC) = 1
)

SELECT
    mta.transaction_month
--total transaction amount for each month over the last 12 months
    , mta.total_transaction_amount
-- calculate the percentage change in transaction totals from one month to the next
    , ((mta.total_transaction_amount-lead(mta.total_transaction_amount) OVER (ORDER BY mta.transaction_month DESC))/mta.total_transaction_amount)*100 AS transaction_monthly_percent_change
--- calculate the top customer for each month by selecting the customer with the highest spending
    , chsm.customer_id
FROM monthly_transaction_total_amounts mta
LEFT JOIN customer_highest_spend_per_month chsm
    ON mta.transaction_month = chsm.transaction_month
