-- TO VIEW ENTIRE TABLE --
SELECT * FROM nexloom_analytics.fact_invoices_payments;

                                  #################################################### FACT TABLE ####################################################

-- CLEANING THE "USERS" TABLE TO ENSURE PROPER DATA QUALITY --
CREATE VIEW fact_invoices_payments_cleaned AS
-- INVOICE ID --
SELECT 
	TRIM(UPPER(ï»¿invoice_id)) AS invoice_id, 
    
-- SUBSCRIPTION ID --    
	TRIM(UPPER(
	CASE
	WHEN TRIM(subscription_id) LIKE 'SUB-%'
	THEN CONCAT('S1', SUBSTRING(TRIM(subscription_id), 6))
	ELSE TRIM(subscription_id) END))  
	AS subscription_id, 
    
-- ISSUE DATE --   
	created_at AS issue_date, 

-- DUE DATE --  
	CASE
    WHEN due_date IS NULL
      OR TRIM(due_date) = ''
      OR due_date = '0000-00-00'
        THEN NULL

    -- MM/DD/YYYY
    WHEN due_date LIKE '__/__/____'
        THEN DATE_FORMAT(STR_TO_DATE(due_date, '%m/%d/%Y'), '%Y-%m-%d 00:00:00')

    -- YYYY-MM-DD H:MM (single-digit hour)
    WHEN due_date LIKE '____-__-__ _:%'
        THEN DATE_FORMAT(STR_TO_DATE(due_date, '%Y-%m-%d %H:%i'), '%Y-%m-%d %H:%i:00')

    -- YYYY-MM-DD HH:MM
    WHEN due_date LIKE '____-__-__ __:%'
        THEN DATE_FORMAT(STR_TO_DATE(due_date, '%Y-%m-%d %H:%i'), '%Y-%m-%d %H:%i:00')

    -- YYYY-MM-DD (no time)
    WHEN due_date LIKE '____-__-__'
        THEN DATE_FORMAT(STR_TO_DATE(due_date, '%Y-%m-%d'), '%Y-%m-%d 00:00:00')

    ELSE NULL
END AS due_date,

-- PAID DATE--
	CASE
    WHEN paid_date IS NULL
      OR TRIM(paid_date) = ''
      OR paid_date = '0000-00-00'
        THEN NULL

    -- MM/DD/YYYY
    WHEN paid_date LIKE '__/__/____'
        THEN DATE_FORMAT(STR_TO_DATE(paid_date, '%m/%d/%Y'), '%Y-%m-%d 00:00:00')

    -- YYYY-MM-DD H:MM (single-digit hour)
    WHEN paid_date LIKE '____-__-__ _:%'
        THEN DATE_FORMAT(STR_TO_DATE(paid_date, '%Y-%m-%d %H:%i'), '%Y-%m-%d %H:%i:00')

    -- YYYY-MM-DD HH:MM
    WHEN paid_date LIKE '____-__-__ __:%'
        THEN DATE_FORMAT(STR_TO_DATE(paid_date, '%Y-%m-%d %H:%i'), '%Y-%m-%d %H:%i:00')

    -- YYYY-MM-DD (no time)
    WHEN paid_date LIKE '____-__-__'
        THEN DATE_FORMAT(STR_TO_DATE(paid_date, '%Y-%m-%d'), '%Y-%m-%d 00:00:00')

    ELSE NULL
END AS paid_date,

-- INVOICE AMOUNT --
	CASE WHEN invoice_amount = 'N/A' THEN NULL ELSE ROUND(invoice_amount, 2) END AS invoice_amount, 
	
-- CURRENCY --    
    CASE WHEN TRIM(currency) = '' THEN 'Unknown' ELSE UPPER(currency) END AS currency, 
    
-- PAYMENT STATUS --
	CASE
    WHEN payment_status IS NULL OR TRIM(payment_status) = '' 
        THEN 'Not Tracked'

    ELSE CONCAT(
            UPPER(LEFT(TRIM(payment_status), 1)),
            LOWER(SUBSTRING(TRIM(payment_status), 2))
         )
	END AS payment_status
,  

-- PAYMENT METHOD --
	CASE
    WHEN payment_method IS NULL OR TRIM(payment_method) = '' 
        THEN 'Not Tracked'

    ELSE CONCAT(
            UPPER(LEFT(TRIM(payment_method), 1)),
            LOWER(SUBSTRING(TRIM(payment_method), 2))
         )
	END AS payment_method, 
    
-- TAX APPLIED --
	CASE WHEN tax_applied = '' THEN 2
		 WHEN tax_applied = 'TRUE' THEN 1
         WHEN tax_applied = 'FALSE' THEN 0
	ELSE tax_applied
    END AS tax_applied

FROM nexloom_analytics.fact_invoices_payments;
