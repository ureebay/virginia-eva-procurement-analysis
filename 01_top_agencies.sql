SELECT entity_description,
       COUNT(DISTINCT order_num)        AS total_orders,
       SUM(line_total)                  AS total_spend,
       ROUND(AVG(line_total), 2)        AS avg_order_value
FROM eva_procurement_2024
WHERE vendor_address_city IN ('Arlington','Alexandria','Fairfax',
                               'McLean','Reston','Herndon',
                               'Tysons','Manassas','Woodbridge')
  AND vendor_address_state = 'VA'
GROUP BY entity_description
ORDER BY total_spend DESC
LIMIT 15;