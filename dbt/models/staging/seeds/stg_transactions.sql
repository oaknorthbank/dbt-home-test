{{
    config(
        materialized='view'
    )
}}

SELECT
    CAST(transaction_id AS STRING) AS transaction_id 
    , CAST(customer_id AS STRING) as customer_id
    , CAST(transaction_date AS DATE) as transaction_date
    , CAST(amount AS NUMERIC) as transaction_amount 
FROM {{ ref('transactions') }}
