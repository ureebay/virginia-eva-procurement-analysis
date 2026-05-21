SELECT vendor_name,
       vendor_address_city,
       COUNT(order_num)                     AS contracts_won,
       SUM(line_total)                      AS total_revenue,
       COUNT(DISTINCT entity_description)   AS agencies_served
FROM eva_procurement_2024
WHERE vendor_address_state = 'VA'
  AND order_status = 'Ordered'
GROUP BY vendor_name, vendor_address_city
ORDER BY total_revenue DESC
LIMIT 20;