drop table if exists all_citizens;

# Create citizens table to populate using the data from the csvs
create table if not exists all_citizens (
first_name  varchar(30),
last_name   varchar(30),
company_name  varchar(50),
address varchar(50),
city varchar(30),
county varchar(30),all_citizens
province varchar(50),
postal varchar(50),
state char(2),
zip varchar(5),
phone1 varchar(255) NOT NULL,
phone2 varchar(255),
email varchar(50),
web varchar(50),
country varchar(50),
PRIMARY KEY (phone1));

 # Load data from csvs and add to table
LOAD DATA INFILE 'ca-500.csv'
INTO TABLE all_citizens
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r'
ignore 1 rows
(first_name,last_name,company_name, address, city, province, postal, phone1, phone2, email, web);

LOAD DATA INFILE 'us-500.csv'
INTO TABLE all_citizens
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r'
ignore 1 rows
(first_name,last_name,company_name, address, city, county, state, zip, phone1, phone2, email, web);

# Create separate table for country ids and link to main citizens table
create table if not exists countries (
id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
country varchar(50));

INSERT INTO countries (country)
VALUES ('USA');

INSERT INTO countries (country)
VALUES ('CANADA');

SELECT @us_id := id
FROM countries
WHERE country LIKE 'USA';

SELECT @canada_id := id
FROM countries
WHERE country LIKE 'CANADA';

update all_citizens
     set country = (CASE
					   WHEN zip is not null
						 THEN @us_id
					   ELSE @canada_id
					   END);


# Create triggers to keep track of new insertions to citizens table per country
SET @canadian_citizens_counter = 0;
SET @us_citizens_counter = 0;

DELIMITER $$
CREATE TRIGGER ins_count BEFORE INSERT ON all_citizens
   FOR EACH ROW
	BEGIN
		IF NEW.country = @us_id THEN
			SET @us_citizens_counter = @us_citizens_counter + 1;
		ELSE
			SET @canadian_citizens_counter = @canadian_citizens_counter + 1;
		END IF;
	END$$
DELIMITER ;

/*
# Test trigger is working correctly, us_citizen counter should be set to 2, 
# and canadian citizen counter should be set to 1
INSERT INTO all_citizens (phone1, country)
VALUES ('0000', 1);
INSERT INTO all_citizens (phone1, country)
VALUES ('0001', 1);
INSERT INTO all_citizens (phone1, country)
VALUES ('00002', 2);

SELECT @us_citizens_counter AS 'US Citizens inserted';
SELECT @canadian_citizens_counter AS 'Canadian Citizens inserted';
*/

# Create procedure for getting all citizens for a given country, and reset counter to 0
DELIMITER $$
CREATE PROCEDURE get_citizens_from_country(IN country varchar(50))
	BEGIN
		# get country id
        SELECT @country_id := id FROM countries WHERE countries.country LIKE country;
        # get all rows from table that match country id
		SELECT * FROM all_citizens WHERE all_citizens.country = @country_id;
        # reset counters
        IF @country_id = @us_id THEN
			SET @us_citizens_counter = 0;
		ELSE
			SET @canadian_citizens_counter = 0;
		END IF;
	END$$
DELIMITER ;

/*
# Test for get_citizens_from_country procedure
CALL get_citizens_from_country('CANADA');
CALL get_citizens_from_country('USA');

SELECT @us_citizens_counter AS 'US Citizens inserted';
SELECT @canadian_citizens_counter AS 'Canadian Citizens inserted';
*/
