SELECT nigp_description                     AS sector,
       COUNT(*)                             AS order_count,
       SUM(line_total)                      AS total_spend,
       ROUND(SUM(line_total) * 100.0 /
         SUM(SUM(line_total)) OVER (), 2)   AS pct_of_total
FROM eva_procurement_2024
WHERE vendor_address_state = 'VA'
GROUP BY nigp_description
ORDER BY total_spend DESC
LIMIT 10;