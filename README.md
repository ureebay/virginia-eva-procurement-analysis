Virginia eVA Procurement Analytics — NoVA Spending Dashboard
Tools: SQL · Power BI · PostgreSQL
Data Source: Virginia eVA Procurement Data 2024 — Virginia Open Data Portal
Domain: Public Sector · Government Procurement · Business Intelligence

Project Overview
This project analyzes real Virginia state procurement data from the eVA system to answer:

Which Northern Virginia agencies spent the most in 2024?
Which contractors and vendors captured the most contract value?
What sectors (IT, consulting, construction, etc.) dominated NoVA procurement spending?
How did spending trend month-over-month throughout the year?

The final deliverable is a 3-page interactive Power BI dashboard built on 500K+ purchase order records, surfacing insights relevant to the DC Metro government contracting market.

Repository Structure
eva-procurement-analysis/
│
├── data/
│   └── README.md               
│
├── sql/
│   ├── 01_top_agencies.sql     # Top 15 NoVA agencies by total spend
│   ├── 02_top_vendors.sql      # Top 20 contractors by revenue
│   ├── 03_sector_breakdown.sql # Spend % by commodity/sector with window function
│   └── 04_monthly_trend.sql    # Monthly spend trend for Power BI time intelligence
│
├── powerbi/
│   └── eva_dashboard.pbix      # Power BI Desktop file (3-page dashboard)
│
├── screenshots/
│   ├── page1_executive_overview.png
│   ├── page2_vendor_breakdown.png
│   └── page3_sector_dominance.png
│
└── README.md

Dataset
FieldValueSourceVirginia Open Data Portal — Department of General ServicesDataseteVA Procurement Data 2024URLhttps://data.virginia.gov/dataset/eva-procurement-data-2024FormatCSV (direct download)Update FrequencyDailyEach row representsOne purchase order line item
Key columns used
ColumnDescriptionPO_NUMBERUnique purchase order identifierAGENCY_NAMEVirginia state agency that placed the orderVENDOR_NAMEContractor or supplier receiving paymentTOTAL_AMOUNTDollar value of the purchase orderCOMMODITY_DESCSector / category of goods or servicesPO_DATEDate the purchase order was issuedVENDOR_CITYCity where the vendor is locatedVENDOR_STATEVendor state — filtered to VA for NoVA focusPO_STATUSOrder status (Complete, Pending, etc.)

Note: Download the CSV and verify exact column names before running queries — eVA occasionally uses slightly different casing or naming across annual releases.


SQL Queries
1. Top agencies by total spend (NoVA filter)
sqlSELECT AGENCY_NAME,
       COUNT(DISTINCT PO_NUMBER)       AS total_orders,
       SUM(TOTAL_AMOUNT)               AS total_spend,
       ROUND(AVG(TOTAL_AMOUNT), 2)     AS avg_order_value
FROM eva_procurement_2024
WHERE VENDOR_CITY IN ('Arlington','Alexandria','Fairfax',
                      'McLean','Reston','Herndon',
                      'Tysons','Manassas','Woodbridge')
  AND VENDOR_STATE = 'VA'
GROUP BY AGENCY_NAME
ORDER BY total_spend DESC
LIMIT 15;
2. Top vendors / contractors by revenue
sqlSELECT VENDOR_NAME,
       VENDOR_CITY,
       COUNT(PO_NUMBER)            AS contracts_won,
       SUM(TOTAL_AMOUNT)           AS total_revenue,
       COUNT(DISTINCT AGENCY_NAME) AS agencies_served
FROM eva_procurement_2024
WHERE VENDOR_STATE = 'VA'
  AND PO_STATUS = 'Complete'
GROUP BY VENDOR_NAME, VENDOR_CITY
ORDER BY total_revenue DESC
LIMIT 20;
3. Spending by sector (with window function)
sqlSELECT COMMODITY_DESC                      AS sector,
       COUNT(*)                            AS order_count,
       SUM(TOTAL_AMOUNT)                   AS total_spend,
       ROUND(SUM(TOTAL_AMOUNT) * 100.0 /
         SUM(SUM(TOTAL_AMOUNT)) OVER (), 2) AS pct_of_total
FROM eva_procurement_2024
WHERE VENDOR_STATE = 'VA'
GROUP BY COMMODITY_DESC
ORDER BY total_spend DESC
LIMIT 10;
4. Monthly spend trend
sqlSELECT DATE_TRUNC('month', PO_DATE)    AS order_month,
       AGENCY_NAME,
       SUM(TOTAL_AMOUNT)               AS monthly_spend,
       COUNT(DISTINCT VENDOR_NAME)     AS unique_vendors
FROM eva_procurement_2024
WHERE VENDOR_STATE = 'VA'
  AND PO_DATE >= '2024-01-01'
GROUP BY order_month, AGENCY_NAME
ORDER BY order_month, monthly_spend DESC;

Power BI Dashboard
The .pbix file contains 3 report pages:
PageVisualsExecutive OverviewKPI cards (total spend, orders, vendors, avg order size) · Bar chart top 10 agencies · Monthly trend line · Agency slicerVendor & Contractor BreakdownTop 20 vendors horizontal bar · Treemap by vendor city · Drill-through vendor detail tableSector DominanceDonut chart spend % by sector · Stacked bar sector × agency · Matrix of agency-sector reliance

Key Findings

(Update these with your actual numbers after running the analysis)


Top agency: [Agency Name] accounted for $X in procurement spend
Top contractor: [Vendor Name] won $X across X contracts from X agencies
Dominant sectors: IT Services and Professional Consulting represented ~40% of total NoVA contract value
Spend trend: Procurement spending peaked in Q[X] 2024, with a [X]% increase vs. Q[X]


How to Reproduce
Step 1 — Download the data
Go to data.virginia.gov/dataset/eva-procurement-data-2024 and click Download next to eVA_Procurement_Data_2024 (CSV).
Step 2 — Run the SQL
See How to run SQL with DB Fiddle below, or load the CSV into a local PostgreSQL instance.
Step 3 — Build the dashboard
Open Power BI Desktop → Get Data → Text/CSV → import your query result exports. Connect the 4 query outputs as separate tables and build relationships on AGENCY_NAME and VENDOR_NAME.
Step 4 — Publish
Export dashboard screenshots to /screenshots/ and push everything to GitHub.

How to Run SQL with DB Fiddle
DB Fiddle is a free, browser-based SQL tool — no installation needed.

Go to https://www.db-fiddle.com
In the top-left dropdown, select PostgreSQL 15 (or 14)
In the Schema SQL panel (left side), create your table and paste in sample data:

sqlCREATE TABLE eva_procurement_2024 (
  PO_NUMBER       TEXT,
  AGENCY_NAME     TEXT,
  VENDOR_NAME     TEXT,
  TOTAL_AMOUNT    NUMERIC,
  COMMODITY_DESC  TEXT,
  PO_DATE         DATE,
  VENDOR_CITY     TEXT,
  VENDOR_STATE    TEXT,
  PO_STATUS       TEXT
);

INSERT INTO eva_procurement_2024 VALUES
('PO-001','Dept of Transportation','Acme IT Solutions',125000,'Information Technology','2024-03-15','Arlington','VA','Complete'),
('PO-002','Dept of Health','TechCorp Inc',89000,'Professional Services','2024-05-22','McLean','VA','Complete'),
('PO-003','Dept of Education','BuildRight LLC',240000,'Construction','2024-07-10','Fairfax','VA','Complete');

In the Query SQL panel (right side), paste any of the queries from this repo
Click Run (or press Ctrl+Enter) — results appear below


For the full dataset, load the CSV into a local PostgreSQL instance using \copy eva_procurement_2024 FROM 'eva_procurement_2024.csv' CSV HEADER;


Skills Demonstrated

SQL: GROUP BY, ORDER BY, COUNT DISTINCT, AVG, SUM, window functions (OVER()), DATE_TRUNC, CTEs
Power BI: data modeling, DAX measures, drill-through, slicers, KPI cards, treemaps
Data analysis: procurement trend analysis, vendor concentration, sector benchmarking
Real-world public data: sourced directly from Virginia's Open Data Portal


Author
Sebastian — MIS Student, George Mason University
B.S. Business Administration, Concentration in MIS (Expected Dec 2026)
LinkedIn · Portfolio
