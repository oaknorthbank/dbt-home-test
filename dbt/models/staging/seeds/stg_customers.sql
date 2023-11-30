{{
    config(
        materialized='view'
    )
}}

SELECT
    CAST(customer_id AS STRING) AS customer_id 
    , CAST(name AS STRING) as customer_name
    , CAST(date_of_birth AS DATE) as customer_date_of_birth
    , CAST(joined_date AS DATE) as customer_joined_date
FROM {{ ref('customers') }}
--qualify to ensure unique customers
QUALIFY ROW_NUMBER() OVER (PARITION BY customer_id ORDER BY customer_joined_date DESC) = 1
