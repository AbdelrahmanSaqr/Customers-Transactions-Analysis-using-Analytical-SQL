-- Query 1: Monthly Sales Analysis
SELECT 
    DISTINCT TO_DATE(TO_CHAR(TO_DATE(INVOICEDATE, 'MM/DD/YYYY'), 'MM/YYYY'), 'MM/YYYY') AS MONTH,
    SUM(QUANTITY * PRICE) OVER (PARTITION BY TO_CHAR(TO_DATE(INVOICEDATE, 'MM/DD/YYYY'), 'MM/YYYY')) AS TOTALSALES
FROM 
    TABLERETAIL
ORDER BY  
    MONTH;
---------------------------------------------------------------------------------------
-- Query 2: Repeat Purchase Rate Analysis
WITH CUSTOMER_PURCHASE_COUNTS AS (
    SELECT 
        COUNT(CASE WHEN PURCHASE_COUNT > 1 THEN CUSTOMER_ID END) AS REPEAT_CUSTOMERS,
        COUNT(*) AS TOTAL_CUSTOMERS,
        (COUNT(CASE WHEN PURCHASE_COUNT > 1 THEN CUSTOMER_ID END) * 100.0) / COUNT(*) AS REPEAT_PURCHASE_RATE
    FROM (
        SELECT 
            CUSTOMER_ID,
            COUNT(DISTINCT INVOICE) AS PURCHASE_COUNT
        FROM 
            TABLERETAIL
        GROUP BY 
            CUSTOMER_ID
    )
)

SELECT 
    REPEAT_CUSTOMERS,
    ROUND(REPEAT_PURCHASE_RATE) AS REPEAT_PURCHASE_RATE
FROM 
    CUSTOMER_PURCHASE_COUNTS;
--------------------------------------------------------------------------------------
-- Query 3: Customer Spending Group Analysis
SELECT SPENDING_GROUP, COUNT(*) AS NUMBER_OF_CUSTOMER
FROM(
SELECT CUSTOMER_ID, TOTAL_SPENDING,
       CASE SPENDINGRANK
           WHEN 1 THEN 'Loyal Customer'
           WHEN 2 THEN 'Normal Customer'
           WHEN 3 THEN 'Potential Churn'
           ELSE 'Unknown'
       END AS SPENDING_GROUP
FROM (
    SELECT CUSTOMER_ID, 
           SUM(QUANTITY * PRICE) AS TOTAL_SPENDING,
           NTILE(3) OVER (ORDER BY SUM(QUANTITY * PRICE) DESC) AS SPENDINGRANK
    FROM TABLERETAIL
    GROUP BY CUSTOMER_ID
) )
GROUP BY SPENDING_GROUP;
--------------------------------------------------------------------------------------
-- Query 4: Churn Rate Analysis
WITH ACTIVECUSTOMERS AS (
    SELECT DISTINCT CUSTOMER_ID
    FROM TABLERETAIL
    WHERE TO_DATE(INVOICEDATE, 'MM/DD/YYYY') BETWEEN TO_DATE('01/01/2011', 'MM/DD/YYYY') AND TO_DATE('06/30/2011', 'MM/DD/YYYY')
),
CHURNEDCUSTOMERS AS (
    SELECT DISTINCT CUSTOMER_ID
    FROM TABLERETAIL
    WHERE TO_DATE(INVOICEDATE, 'MM/DD/YYYY') BETWEEN TO_DATE('07/01/2011', 'MM/DD/YYYY') AND TO_DATE('12/31/2011', 'MM/DD/YYYY')
)
SELECT 
    COUNT(C.CUSTOMER_ID) AS CHURNED_CUSTOMERS_COUNT,
    COUNT(A.CUSTOMER_ID) AS ACTIVE_CUSTOMERS_COUNT,
    ROUND(100 * COUNT(C.CUSTOMER_ID) / COUNT(A.CUSTOMER_ID)) AS CHURN_RATE
FROM ACTIVECUSTOMERS A
LEFT JOIN CHURNEDCUSTOMERS C ON A.CUSTOMER_ID = C.CUSTOMER_ID;
--------------------------------------------------------------------------------------
-- Query 5: Moving Average Spending Analysis
SELECT TO_DATE(INVOICEDATE, 'MM/DD/YYYY') AS INVOICE_DATE ,
       AVG(SUM(QUANTITY * PRICE)) OVER (ORDER BY TO_DATE(INVOICEDATE, 'MM/DD/YYYY') ROWS BETWEEN 3 PRECEDING AND CURRENT ROW) AS MOVING_AVG_SPENDING
FROM TABLERETAIL
GROUP BY INVOICEDATE
ORDER BY INVOICEDATE;








