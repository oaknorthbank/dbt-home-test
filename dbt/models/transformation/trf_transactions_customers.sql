{{
    config(
        materialized='table'
    )
}}

WITH transactions AS (
    SELECT
        transaction_id
        , customer_id
        , transaction_date
        , transaction_amount
    FROM {{ ref('stg_transactions') }}
)

, customers AS (
    SELECT
        customer_id
        , customer_joined_date
    FROM {{ ref('stg_customers') }}
)
SELECT
    trx.transaction_id
    , trx.transaction_date
    , trx.transaction_amount
    , trx.customer_id
    , cs.customer_joined_date
FROM transactions trx
LEFT JOIN customers cs
    ON trx.customer_id = cs.customer_id
