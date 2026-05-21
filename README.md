# Virginia eVA Procurement Analytics — NoVA Spending Dashboard

**Tools:** SQL · Power BI · PostgreSQL  
**Data Source:** [Virginia eVA Procurement Data 2024](https://data.virginia.gov/dataset/eva-procurement-data-2024) — Virginia Open Data Portal  
**Domain:** Public Sector · Government Procurement · Business Intelligence  
**Dataset Size:** 1.9 million rows

---

## Project Overview

This project analyzes **real Virginia state procurement data** from the eVA system — 1.9 million purchase order records — to answer:

- Which Virginia agencies spent the most with NoVA vendors in 2024?
- Which contractors and vendors captured the most contract value?
- What sectors dominated procurement spending?
- How did spending trend month-over-month from July 2023 through June 2024?

The final deliverable is a **4-page interactive Power BI dashboard** surfacing insights directly relevant to the DC Metro government contracting market.

---

## Key Findings

- **Top agency:** Virginia Department of Transportation (VDOT) — $678M in NoVA vendor spend, accounting for ~33% of total procurement
- **Top contractor:** Allan Myers VA Inc — $4.8B across 2,730 contracts
- **Dominant sector:** Construction Services — 25.31% of all procurement spend
- **Biggest spend month:** May 2024 — $6B+ in total procurement
- **Notable:** George Mason University ranked #8 at $66M across 3,885 orders
- **VDOT identified as outlier** — excluded from monthly trend analysis to surface patterns across remaining agencies

---

## Dashboard Pages

| Page | Title | Key Visuals |
|---|---|---|
| 1 | Executive Overview | KPI cards · Top 15 agencies bar chart · Agency slicer |
| 2 | Vendor & Contractor Breakdown | Top 20 vendors by revenue · KPI cards |
| 3 | Sector Dominance | Top 10 sectors bar chart · % of total spend labels |
| 4 | Monthly Spend Trend | Line chart Jul 2023–Jun 2024 · VDOT excluded as outlier |

---

## Dataset

| Field | Value |
|---|---|
| Source | Virginia Open Data Portal — Dept of General Services |
| URL | https://data.virginia.gov/dataset/eva-procurement-data-2024 |
| Format | CSV (direct download) |
| Update Frequency | Daily |
| Rows loaded | 1,922,754 |
| Each row represents | One purchase order line item |

### Key columns used

| Column | Description |
|---|---|
| `entity_description` | Virginia agency that placed the order |
| `vendor_name` | Contractor or supplier receiving payment |
| `line_total` | Dollar value of the line item |
| `nigp_description` | Sector / category of goods or services |
| `ordered_date` | Date the purchase order was issued |
| `vendor_address_city` | City where the vendor is located |
| `vendor_address_state` | Vendor state — filtered to VA for NoVA focus |
| `order_status` | Order status (Ordered, Cancelled, Amended, Denied) |

---

## SQL Queries

### 1. Top agencies by total spend (NoVA filter)

```sql
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
```

### 2. Top vendors by revenue

```sql
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
```

### 3. Spending by sector with window function

```sql
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
```

### 4. Monthly spend trend

```sql
SELECT DATE_TRUNC('month', ordered_date::date)   AS order_month,
       entity_description,
       SUM(line_total)                            AS monthly_spend,
       COUNT(DISTINCT vendor_name)                AS unique_vendors
FROM eva_procurement_2024
WHERE vendor_address_state = 'VA'
  AND ordered_date IS NOT NULL
GROUP BY order_month, entity_description
ORDER BY order_month, monthly_spend DESC;
```

---

## How to Reproduce

### Step 1 — Download the data
Go to [data.virginia.gov/dataset/eva-procurement-data-2024](https://data.virginia.gov/dataset/eva-procurement-data-2024) and click Download next to `eVA_Procurement_Data_2024 (CSV)`.

### Step 2 — Load into PostgreSQL
```sql
CREATE TABLE eva_procurement_2024 (
  entity_code                   TEXT,
  entity_description            TEXT,
  nigp_num                      TEXT,
  nigp_description              TEXT,
  item_description              TEXT,
  order_num                     TEXT,
  order_line_number             TEXT,
  quantity_ordered              NUMERIC,
  unit_price                    NUMERIC,
  unit_of_measure               TEXT,
  line_total                    NUMERIC,
  line_total_change             NUMERIC,
  manufacturer_part_num         TEXT,
  order_status                  TEXT,
  shipping_name                 TEXT,
  shipping_lines                TEXT,
  shipping_city                 TEXT,
  shipping_state                TEXT,
  shipping_postal               TEXT,
  requisition_submitted_date    TEXT,
  requisition_approved_date     TEXT,
  ordered_date                  TEXT,
  most_recent_receiving_date    TEXT,
  swam_minority                 TEXT,
  swam_woman                    TEXT,
  swam_small                    TEXT,
  swam_micro_business           TEXT,
  po_category_description       TEXT,
  po_category                   TEXT,
  procurement_transaction_type  TEXT,
  procurement_transaction_desc  TEXT,
  order_type                    TEXT,
  contract_number               TEXT,
  contract_type                 TEXT,
  registration_type             TEXT,
  vlin_id                       TEXT,
  eva_id                        TEXT,
  vendor_name                   TEXT,
  vendor_location_name          TEXT,
  vendor_address_lines          TEXT,
  vendor_address_city           TEXT,
  vendor_address_state          TEXT,
  vendor_address_postal         TEXT,
  vendor_address_geolocation    TEXT
);

COPY eva_procurement_2024
FROM 'path/to/eva_procurement_data_2024.csv'
DELIMITER ','
CSV HEADER
QUOTE '"';
```

### Step 3 — Build the dashboard
Open Power BI Desktop → Get Data → Text/CSV → import the 4 query result CSVs → build the 4-page dashboard.

### Step 4 — Publish
Export dashboard screenshots to `/screenshots/` and push everything to GitHub.

---

## Skills Demonstrated

- **SQL:** `GROUP BY`, `ORDER BY`, `COUNT DISTINCT`, `SUM`, `AVG`, window functions (`OVER()`), `DATE_TRUNC`, `CASE WHEN`, type casting
- **PostgreSQL:** bulk CSV loading, schema design, query optimization across 1.9M rows
- **Power BI:** data modeling, KPI cards, bar charts, line charts, slicers, Top N filters, data labels, page-level formatting
- **Analytics:** outlier identification, procurement trend analysis, vendor concentration, sector benchmarking
- **Real-world data:** sourced directly from Virginia's Open Data Portal — updated daily

---

## Author

**Sebastian Uribe Diaz** — MIS Student, George Mason University  
B.S. Business Administration, Concentration in MIS (Expected Dec 2026)  
[LinkedIn](#) · [Portfolio](#)

---

*Source: Virginia eVA Procurement Data 2024 | Virginia Open Data Portal | virginia.gov*

