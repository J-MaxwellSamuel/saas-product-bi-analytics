-- TO VIEW ENTIRE TABLE --
SELECT * FROM nexloom_analytics.fact_marketing_spend;

                                  #################################################### FACT TABLE ####################################################

-- CLEANING THE "USERS" TABLE TO ENSURE PROPER DATA QUALITY --
CREATE VIEW fact_marketing_spend_cleaned AS 
-- SPEND ID -- 
SELECT 
	UPPER(TRIM(ï»¿spend_id)) AS spend_id, 
    
-- DATE --

-- ACQUISITION CHANNEL -- 
	CASE WHEN acquisition_channel = '' THEN 'Unknown'
    ELSE
			CONCAT(
			UPPER(LEFT(acquisition_channel, 1)),
			LOWER(SUBSTRING(acquisition_channel, 2))
		) 
	END AS acquisition_channel,
	
-- CAMPAIGN NAME -- 
    CASE WHEN TRIM(campaign_name) = '' THEN 'N/A' ELSE UPPER(campaign_name)
    END AS campaign_name,

-- REGION --
   CASE WHEN region = '' THEN 'Unknown' 
        WHEN region = 'US-East' THEN 'USA'
        WHEN region = 'US-West' THEN 'USA'
        WHEN region = 'US' THEN 'USA'
   ELSE UPPER(region)
   END AS country_code, 
    
-- CURRENCY --
	CASE
    WHEN UPPER(region) IN ('UK', 'GB') THEN 'GBP'
    WHEN UPPER(region) IN ('EU', 'FR', 'DE') THEN 'EUR'
    WHEN UPPER(region) IN ('CA') THEN 'CAD'
    WHEN UPPER(region) IN ('IN') THEN 'INR'
    WHEN UPPER(region) IN ('BR') THEN 'BRL'
	WHEN UPPER(region) IN ('AU') THEN 'AUD'
    ELSE NULL
	END AS currency, 
    
-- SPEND AMOUNT --
	ROUND(spend_amount, 1) as spend_amount,

-- IMPRESSIONS --
	CASE WHEN impressions = '' THEN NULL 
		ELSE impressions	
	END AS impressions,
 
 -- CLICKS --
	CASE WHEN clicks = '' THEN NULL 
		ELSE clicks	
	END AS clicks,
	
-- CONVERSIONS --
	CASE WHEN conversions = '' THEN NULL 
		ELSE conversions	
	END AS conversions, 
    
 -- CREATED AT --   
	created_at
    
FROM nexloom_analytics.fact_marketing_spend;



