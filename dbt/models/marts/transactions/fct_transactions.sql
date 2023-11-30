{{
    config(
        materialized='table',
        description='Transaction events data for reporting analysis'
    )
}}

SELECT
    transaction_id
    , transaction_date
    , transaction_amount
    , customer_id
    , customer_joined_date
FROM {{ ref('trf_transactions_customers') }}
