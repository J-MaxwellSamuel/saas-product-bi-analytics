-- TO VIEW ENTIRE TABLE --
SELECT * FROM nexloom_analytics.fact_support_tickets;

                                  #################################################### FACT TABLE ####################################################

-- CLEANING THE "USAGE EVENTS" TABLE TO ENSURE PROPER DATA QUALITY --
CREATE VIEW fact_support_tickets_cleaned AS 
SELECT 
-- TICKET ID --
	TRIM(UPPER(ï»¿ticket_id)) as ticket_id,
    
-- USER ID --
    CONCAT('U', ROW_NUMBER() OVER (ORDER BY user_id)) AS user_id,
    user_id AS old_user_id,
    
-- CATEGORY --
	category, 
    
 -- PRIORITY --   
	CASE 
		WHEN priority = '' THEN 'Not Selected' 
		ELSE 
			CONCAT(
            UPPER(LEFT(priority, 1)),
            LOWER(SUBSTRING(priority, 2))
            )
	END AS priority,
    
-- STATUS --   
	CASE 
		WHEN status IS NOT NULL 
        THEN 
			CONCAT(
            UPPER(LEFT(status, 1)),
            LOWER(SUBSTRING(status, 2))
            )
	END AS status, 

-- SUPPORT CHANNEL --       
	CASE 
		WHEN support_channel = '' THEN 'Unknown (Tracking Issue)'
        ELSE 
			CONCAT(
            UPPER(LEFT(support_channel, 1)),
            LOWER(SUBSTRING(support_channel, 2))
            )
	END AS support_channel, 
    
-- SENTIMENT --
	CASE 
		WHEN sentiment = '' THEN 'Unknown'
        ELSE 
			CONCAT(
            UPPER(LEFT(sentiment, 1)),
            LOWER(SUBSTRING(sentiment, 2))
            )
	END AS sentiment,
    
-- ASSIGNED AGENT --
	CASE 
		WHEN TRIM(assigned_agent) = '' THEN 'Unassigned (Tracking Issue)'
        ELSE assigned_agent
	END AS assigned_agent, 
    
-- RESOLVED DATE --
	CASE
    -- 1. Zero dates → NULL
    WHEN resolved_date = '0000-00-00'
         OR resolved_date = '0000-00-00 00:00:00'
         OR TRIM(resolved_date) = ''
         OR resolved_date IS NULL
    THEN NULL

    -- 2. U.S. format MM/DD/YYYY
    WHEN resolved_date LIKE '%/%/%'
         AND resolved_date NOT LIKE '%:%'
    THEN DATE_FORMAT(
            STR_TO_DATE(resolved_date, '%m/%d/%Y'),
            '%Y-%m-%d 00:00:00'
         )

    -- 3. U.S. format with time (MM/DD/YYYY HH:MM)
    WHEN resolved_date LIKE '%/%/%'
         AND resolved_date LIKE '%:%'
    THEN DATE_FORMAT(
            STR_TO_DATE(resolved_date, '%m/%d/%Y %H:%i'),
            '%Y-%m-%d %H:%i:%s'
         )

    -- 4. ISO format with time (YYYY-MM-DD HH:MM)
    WHEN resolved_date LIKE '%-%-%'
         AND resolved_date LIKE '%:%'
    THEN DATE_FORMAT(
            STR_TO_DATE(resolved_date, '%Y-%m-%d %H:%i'),
            '%Y-%m-%d %H:%i:%s'
         )

    -- 5. ISO format without time (YYYY-MM-DD)
    WHEN resolved_date LIKE '%-%-%'
         AND resolved_date NOT LIKE '%:%'
    THEN DATE_FORMAT(
            STR_TO_DATE(resolved_date, '%Y-%m-%d'),
            '%Y-%m-%d 00:00:00'
         )

    -- 6. Fallback → NULL
    ELSE NULL
END AS resolved_date, 
    
-- RESOLUTION HRS --
	CASE
    WHEN resolution_time_hours IS NULL
         OR TRIM(resolution_time_hours) = ''
         OR LOWER(resolution_time_hours) = 'unknown'
    THEN NULL

    WHEN resolution_time_hours REGEXP '^[0-9]+$'
    THEN CAST(resolution_time_hours AS UNSIGNED)

    ELSE NULL
END AS resolution_time_hours, 
    
-- CREATED AT --
	created_at 
		
FROM nexloom_analytics.fact_support_tickets; 

                                  #################################################### DIMENSION TABLES ####################################################

-- CREATING A DIMENSION TABLE FOR TICKET TYPES --

CREATE VIEW dim_ticket_category AS 
SELECT DISTINCT category
FROM fact_support_tickets 
WHERE category <> '';

-- CREATING A DIMENSION TABLE FOR TICKET PRIOTITY --

CREATE VIEW dim_ticket_priority AS 
SELECT DISTINCT priority
FROM fact_support_tickets 
WHERE priority <> '';

-- CREATING A DIMENSION TABLE FOR TICKET STATUS --

CREATE VIEW dim_status_tickets AS 
SELECT DISTINCT LOWER(status) AS status
FROM fact_support_tickets 
WHERE status <> '';

-- CREATING A DIMENSION TABLE FOR SUPPORT CHANNEL --

CREATE VIEW dim_channels AS 
SELECT DISTINCT TRIM(support_channel) AS support_channel
FROM fact_support_tickets
WHERE TRIM(support_channel) <> ''
  AND support_channel IS NOT NULL;

-- CREATING A DIMENSION TABLE FOR SENTIMENT --

CREATE VIEW dim_sentiments AS 
SELECT DISTINCT TRIM(sentiment) AS sentiment
FROM fact_support_tickets
WHERE TRIM(sentiment) <> ''
  AND sentiment IS NOT NULL;
