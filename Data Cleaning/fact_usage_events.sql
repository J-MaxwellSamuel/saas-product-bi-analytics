-- TO VIEW ENTIRE TABLE --
SELECT * FROM nexloom_analytics.fact_usage_events;

                                  #################################################### FACT TABLE ####################################################
-- CLEANING THE "USAGE EVENTS" TABLE TO ENSURE PROPER DATA QUALITY --
CREATE VIEW fact_usage_events_cleaned AS
SELECT
-- EVENT ID --	
	UPPER(TRIM(event_id)) AS event_id,
    
-- USER ID --
	ROW_NUMBER() OVER (ORDER BY user_id) AS user_id,
    user_id AS old_user_id,

-- EVENT TYPE --
	LOWER(event_type) as event_type,
    
-- PAGE URLs --
	page_url, 
    
-- EVENT TIMESTAMP --  
	created_at AS event_timestamp, 
    
-- DEVICE TYPE --
	CASE 
		WHEN TRIM(device_type) = '' THEN 'unknown'
		ELSE LOWER(device_type)
    END AS device_type, 
    
--  BROWSER --
	CASE 
		WHEN TRIM(browser) = '' THEN 'unknown'
		ELSE LOWER(browser) 
    END AS browser, 
    
--  OPERATING SYSTEM --   
	CASE 
		WHEN TRIM(os) = '' THEN 'unknown'
		ELSE os
	END AS os,  
	CASE 
		WHEN session_duration_seconds = 'unknown' THEN ''
        ELSE session_duration_seconds
	END AS session_duration_seconds,  
	CASE 
		WHEN error_flag = 'TRUE' THEN 1
        WHEN error_flag = 'FALSE' THEN 0
        WHEN error_flag = '' THEN 2
		ELSE error_flag
	END AS error_flag

FROM nexloom_analytics.fact_usage_events;

                                  #################################################### DIMENSION TABLES ####################################################

-- CREATING A DIMENSION TABLE FOR EVENT TYPES --

CREATE VIEW dim_event_usage AS 
SELECT DISTINCT event_type
FROM fact_usage_events ;

-- CREATING A DIMENSION TABLE FOR DEVICE TYPES --

CREATE VIEW dim_devicetypes AS 
SELECT DISTINCT device_type
FROM fact_usage_events 
WHERE device_type <> '';

-- CREATING A DIMENSION TABLE FOR BROWSER TYPES --

CREATE VIEW dim_browser AS 
SELECT DISTINCT browser
FROM fact_usage_events 
WHERE browser <> '';




