-- TO VIEW ENTIRE TABLE --
SELECT * FROM fact_users;

                                  #################################################### CLEAN FACT TABLE ####################################################
					
-- CLEANING THE "USERS" TABLE TO ENSURE PROPER DATA QUALITY --
CREATE VIEW fact_users_cleaned AS
SELECT 

    /* USER ID */
	ROW_NUMBER() OVER (ORDER BY user_id) AS user_id,
    user_id AS old_user_id,

    /* FIRST NAME */
    CONCAT(
        UPPER(LEFT(first_name, 1)),
        LOWER(SUBSTRING(first_name, 2))
    ) AS first_name,

    /* LAST NAME */
    CONCAT(
        UPPER(LEFT(last_name, 1)),
        LOWER(SUBSTRING(last_name, 2))
    ) AS last_name,

    /* FULL NAME */
    CONCAT(
        UPPER(LEFT(first_name, 1)),
        LOWER(SUBSTRING(first_name, 2)),
        ' ',
        UPPER(LEFT(last_name, 1)),
        LOWER(SUBSTRING(last_name, 2))
    ) AS full_name,

    /* EMAIL */
    LOWER(email) AS email,

    /* COUNTRY CODE NORMALIZATION */
    CASE
        WHEN UPPER(TRIM(country_code)) IN ('US','USA','UNITED STATES') THEN 'US'
        WHEN UPPER(TRIM(country_code)) IN ('UK','U.K.','GB') THEN 'UK'
        WHEN UPPER(TRIM(country_code)) IN ('AU','BR','IN','MX','SG','FR','ZA','SE','DE','JP','CA','NL')
            THEN UPPER(TRIM(country_code))
        ELSE NULL
    END AS country_code,

    /* CLEAN REGION */
    CASE
        WHEN region_state IS NULL OR TRIM(region_state) IN ('','-','_')
            THEN 'UNKNOWN'
        ELSE UPPER(TRIM(region_state))
    END AS clean_region,

    /* VALIDATED REGION */
    CASE
        WHEN UPPER(TRIM(country_code)) = 'AU' AND UPPER(TRIM(region_state)) IN ('WA','NSW') THEN UPPER(TRIM(region_state))
        WHEN UPPER(TRIM(country_code)) = 'BR' AND UPPER(TRIM(region_state)) IN ('SP','RJ') THEN UPPER(TRIM(region_state))
        WHEN UPPER(TRIM(country_code)) = 'MX' AND UPPER(TRIM(region_state)) = 'BC' THEN 'BC'
        WHEN UPPER(TRIM(country_code)) IN ('US','USA','UNITED STATES','U.S.') 
             AND UPPER(TRIM(region_state)) IN ('CA','TX','NY','WA') THEN UPPER(TRIM(region_state))
        WHEN UPPER(TRIM(country_code)) IN ('UK','U.K.','GB','UNITED KINGDOM') 
             AND UPPER(TRIM(region_state)) = 'LND' THEN 'LND'
        WHEN UPPER(TRIM(country_code)) = 'CA' AND UPPER(TRIM(region_state)) IN ('BC','ON') THEN UPPER(TRIM(region_state))
        WHEN UPPER(TRIM(country_code)) = 'IN' AND UPPER(TRIM(region_state)) = 'MH' THEN 'MH'
        ELSE 'UNKNOWN'
    END AS validated_region,

    /* TIME ZONE */
    CASE
        WHEN timezone IS NULL OR TRIM(timezone) = '' THEN 'UTC'
        ELSE timezone
    END AS timezone,

    /* ACQUISITION CHANNEL */
    CONCAT(
        UPPER(LEFT(acquisition_channel, 1)),
        LOWER(SUBSTRING(acquisition_channel, 2))
    ) AS acquisition_channel,

    /* MARKETING CAMPAIGN */
    CASE
        WHEN marketing_campaign IS NULL
          OR TRIM(marketing_campaign) = ''
          OR marketing_campaign IN ('N/A','NA')
            THEN 'N/A'
        ELSE marketing_campaign
    END AS marketing_campaign,

    /* DEVICE OS */
    device_os,

    /* APP VERSION */
    REPLACE(app_version_at_signup, 'v', '') AS app_version_at_signup,

    /* COMPANY SIZE FIX */
    CASE 
        WHEN company_size = '10-Jan' THEN '1-10'
        ELSE company_size
    END AS company_size,

    /* JOB ROLE */
    job_role,

    /* STUDENT FLAG */
    CASE
        WHEN is_student IS NULL OR TRIM(is_student) = '' THEN '2'
        WHEN LOWER(is_student) = 'yes' THEN '1'
        WHEN LOWER(is_student) = 'no' THEN '0'
        ELSE '2'
    END AS is_student,

    /* AGE */
    CASE
        WHEN age IS NULL OR TRIM(age) = '' THEN 0
        WHEN LOWER(age) = 'unknown' THEN 0
        WHEN UPPER(age) = 'N/A' THEN 0
        ELSE age
    END AS age,

    /* REFERRAL */
    CASE 
        WHEN referred_by_user_id IS NULL OR TRIM(referred_by_user_id) = '' THEN 'U0'
        ELSE referred_by_user_id
    END AS referred_by_user_id,

    /* CONSENT MARKETING */
    CASE
        WHEN consent_marketing IS NULL OR TRIM(consent_marketing) = '' THEN 0
        WHEN consent_marketing IN ('Y','TRUE') THEN 1
        WHEN consent_marketing IN ('no','FALSE') THEN 0
        ELSE 0
    END AS consent_marketing,

    /* CREATED AT */
    created_at AS signup_date,

-- NEW AGE GROUP COLUMN --- 
	CASE 
		WHEN fact_users.age IS NULL OR TRIM(fact_users.age) = '' OR fact_users.age IN ('unknown','Unknown','N/A') THEN 'Unknown'
        WHEN fact_users.age BETWEEN 5 AND 18 THEN 'Under 18'
        WHEN fact_users.age BETWEEN 13 AND 19 THEN '13-19'
        WHEN fact_users.age BETWEEN 20 AND 39 THEN '20-39' 
        WHEN fact_users.age BETWEEN 40 AND 64 THEN '40-64'
        WHEN fact_users.age >= 65 THEN '65+' ELSE 'Unknown' 
        END AS age_group

FROM fact_users;

                                  #################################################### DIMENSION TABLES ####################################################

-- CREATING A DIMENSION TABLE FOR ACQUISITION CHANNELS --

CREATE VIEW dim_acqchannels AS 
SELECT DISTINCT acquisition_channel
FROM fact_users ;

-- CREATING A DIMENSION TABLE FOR MARKET CAMPAIGNS --

CREATE VIEW dim_marketing_campaign AS
SELECT DISTINCT 
    UPPER(TRIM(marketing_campaign)) AS marketing_campaign
FROM fact_users
WHERE marketing_campaign IS NOT NULL
  AND TRIM(marketing_campaign) <> ''
  AND TRIM(marketing_campaign) <> 'NA'
  AND TRIM(marketing_campaign) <> 'N/A';

-- CREATING A DIMENSION TABLE FOR DEVICE OPERATING SYSTEMS --

CREATE VIEW dim_deviceos AS
SELECT DISTINCT device_os
FROM fact_users
WHERE device_os <> 'Unknown';

-- CREATING A DIMENSION TABLE FOR APP VERSIONS --
      
CREATE VIEW dim_appversion AS
SELECT DISTINCT 
    REPLACE(app_version_at_signup, 'v', '') AS app_version_at_signup 
FROM fact_users
ORDER BY app_version_at_signup DESC;

-- CREATING A DIMENSION TABLE FOR JOB ROLES --

CREATE VIEW dim_roles AS
SELECT DISTINCT job_role
FROM fact_users;



