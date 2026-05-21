SELECT DATE_TRUNC('month', ordered_date::date)   AS order_month,
       entity_description,
       SUM(line_total)                            AS monthly_spend,
       COUNT(DISTINCT vendor_name)                AS unique_vendors
FROM eva_procurement_2024
WHERE vendor_address_state = 'VA'
  AND ordered_date IS NOT NULL
GROUP BY order_month, entity_description
ORDER BY order_month, monthly_spend DESC;
