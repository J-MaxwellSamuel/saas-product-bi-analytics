-- TO VIEW ENTIRE TABLE --
SELECT * FROM nexloom_users;

-- CLEANING THE "USERS" TABLE TO ENSURE PROPER DATA QUALITY --
SELECT 
	   -- USER ID --
	   UPPER(TRIM(REPLACE(user_id, 'USR-', 'U1'))) AS user_id,
       
	   -- FIRST NAME --
       CONCAT(
			UPPER(LEFT(first_name, 1)),
			LOWER(SUBSTRING(first_name, 2))
		) AS first_name,
        
       -- LAST NAME --
       CONCAT(
			UPPER(LEFT(last_name, 1)),
			LOWER(SUBSTRING(last_name, 2))
		) AS last_name,
        
        -- FULL NAME --
        CONCAT(
			UPPER(LEFT(first_name, 1)),
			LOWER(SUBSTRING(first_name, 2)),
            ' ', 
            UPPER(LEFT(last_name, 1)),
			LOWER(SUBSTRING(last_name, 2))
            ) AS full_name,
        
       -- EMAIL ADDRESS --
       LOWER(email) as email,
       
       -- COUNTRY CODE --
	   CASE
        -- Missing, blank, or junk
        WHEN country_code IS NULL 
             OR TRIM(country_code) IN ('', '-', '_') 
        THEN 'UNKNOWN'

        -- USA variants
        WHEN UPPER(TRIM(country_code)) IN ('USA', 'UNITED STATES', 'US', 'U.S.') 
        THEN 'USA'

        -- UK variants
        WHEN UPPER(TRIM(country_code)) IN ('UK', 'U.K.', 'UNITED KINGDOM', 'GB') 
        THEN 'UK'
        ELSE UPPER(country_code)
END AS country_code,
       
	   -- REGION STATE --
       CASE 
			WHEN region_state IS NULL 
				 OR TRIM(region_state) = '' 
				 OR TRIM(region_state) = '-' 
			THEN 'unknown'
			ELSE region_state
	   END AS region_state,
       
       -- TIME ZONE --
       CASE 
			WHEN timezone IS NULL 
				 OR TRIM(timezone) = '' 
			THEN 'UTC'
			ELSE timezone
	   END AS timezone,
       
       -- ACQUISITION CHANNEL --
       CONCAT(
			UPPER(LEFT(acquisition_channel, 1)),
			LOWER(SUBSTRING(acquisition_channel, 2))
		) AS acquisition_channel,
        
       -- MARKETING CAMPAIGN --
       CASE 
			WHEN marketing_campaign IS NULL
			OR TRIM(marketing_campaign) = ''
            OR marketing_campaign = 'N/A'
            OR marketing_campaign = 'NA'
			THEN 'n/a'
       ELSE marketing_campaign
       END AS marketing_campaign,
       
	   -- DEVICE OPERATING SYSTEM --
       device_os,
       
       -- APP VERSION AT SIGNUP --
       REPLACE(app_version_at_signup, 'v', '') as app_version_at_signup,
       CASE WHEN company_size = '10-Jan' THEN '1-10' ELSE company_size END AS company_size,
       
       -- JOB ROLE --
       job_role,
       
       -- STUDENT CONFIRMATION --
       CASE
			WHEN is_student IS NULL OR TRIM(is_student) = '' THEN '2'
			WHEN LOWER(is_student) = 'yes' THEN '1'
			WHEN LOWER(is_student) = 'no' THEN '0'
			ELSE '2'
	   END AS is_student,
       
       -- AGE --
       CASE 
			WHEN age IS NULL OR TRIM(age) = '' THEN 0 
            WHEN LOWER(age) = 'unknown' THEN 0
            WHEN UPPER(age) = 'N/A' THEN 0
	   ELSE age
	   END AS age,
       
       -- REFERENCE ID --
       CASE WHEN referred_by_user_id IS NULL OR TRIM(referred_by_user_id) = '' THEN 'U0'
       ELSE referred_by_user_id END AS referred_by_user_id,
       
       -- CONSENT MARKETING CONFIRMATION --
       CASE 
		   WHEN consent_marketing IS NULL OR TRIM(consent_marketing) = '' THEN 0
		   WHEN consent_marketing = 'Y' THEN 1
		   WHEN consent_marketing = 'TRUE' THEN 1
		   WHEN consent_marketing = 'no' THEN 0
		   WHEN consent_marketing = 'FALSE' THEN 0
       ELSE 0 END AS consent_marketing,
       
       -- SIGN UP DATE --
       CASE
			WHEN signup_date LIKE '%/%/%' THEN
				DATE_FORMAT(STR_TO_DATE(signup_date, '%m/%d/%Y'), '%Y-%m-%d 00:00:00')

			WHEN signup_date LIKE '%:%' THEN
				DATE_FORMAT(STR_TO_DATE(signup_date, '%Y-%m-%d %H:%i'), '%Y-%m-%d 00:00:00')

			ELSE
				DATE_FORMAT(STR_TO_DATE(signup_date, '%Y-%m-%d'), '%Y-%m-%d 00:00:00')
END AS signup_date,

       -- CREATED AT --
       CASE
			WHEN created_at LIKE '%/%/%' THEN
				DATE_FORMAT(STR_TO_DATE(created_at, '%m/%d/%Y %H:%i'), '%Y-%m-%d %H:%i:%s')

			WHEN created_at LIKE '%-%-%' THEN
				DATE_FORMAT(STR_TO_DATE(created_at, '%Y-%m-%d %H:%i'), '%Y-%m-%d %H:%i:%s')

			ELSE NULL
END AS created_at,

	   -- UPDATED AT --
       CASE
       WHEN updated_at LIKE '% %' THEN
			-- Has a space → contains a time
		DATE_FORMAT(STR_TO_DATE(updated_at, '%Y-%m-%d %H:%i'), '%Y-%m-%d %H:%i:%s')

	   ELSE
			-- No time → add 00:00:00
	   DATE_FORMAT(STR_TO_DATE(updated_at, '%Y-%m-%d'), '%Y-%m-%d 00:00:00')
END AS updated_at
	
FROM nexloom_users;


-- CREATING A DIMENSION TABLE FOR COUNTRY CODES --

CREATE TABLE dim_countrycode_users AS 
SELECT DISTINCT 
	CASE 
		WHEN country_code IS NULL
        OR TRIM(country_code) = ''
        OR TRIM(country_code) = '-'
        OR TRIM(country_code) = '_'
	THEN ''
		WHEN UPPER(TRIM(country_code)) IN ('USA', 'UNITED STATES', 'US', 'U.S.') 
	THEN 'USA' 
	    WHEN UPPER(TRIM(country_code)) IN ('UK', 'U.K.', 'UNITED KINGDOM', 'GB') 
	THEN 'UK'
	ELSE UPPER(TRIM(country_code))
END AS country_code
FROM nexloom_users
WHERE country_code <> 'unknown';

-- CREATING A DIMENSION TABLE FOR REGION STATES --

CREATE TABLE dim_regionstate_users AS 
SELECT DISTINCT region_state
FROM nexloom_users
WHERE region_state IS NOT NULL
	  AND region_state <> 'unknown'
	  AND region_state <> '-'
      AND region_state <> '';

-- CREATING A DIMENSION TABLE FOR ACQUISITION CHANNELS --

CREATE TABLE dim_acqchannels_users AS 
SELECT DISTINCT acquisition_channel
FROM nexloom_users ;

-- CREATING A DIMENSION TABLE FOR MARKET CAMPAIGNS --

CREATE TABLE dim_marketcampaign_users AS
SELECT DISTINCT marketing_campaign
FROM nexloom_users
WHERE TRIM(marketing_campaign) <> ''
	  AND marketing_campaign IS NOT NULL 
      AND marketing_campaign <> 'n/a'
      AND marketing_campaign <> 'NA';

-- CREATING A DIMENSION TABLE FOR DEVICE OPERATING SYSTEMS --

CREATE TABLE dim_deviceos_users AS
SELECT DISTINCT device_os
FROM nexloom_users
WHERE device_os <> 'Unknown';

-- CREATING A DIMENSION TABLE FOR APP VERSIONS --
      
CREATE TABLE dim_appversion_users AS
SELECT DISTINCT 
    REPLACE(app_version_at_signup, 'v', '') AS app_version_at_signup 
FROM nexloom_users
ORDER BY app_version_at_signup DESC;

-- CREATING A DIMENSION TABLE FOR JOB ROLES --

CREATE TABLE dim_roles_users AS
SELECT DISTINCT job_role
FROM nexloom_users;
