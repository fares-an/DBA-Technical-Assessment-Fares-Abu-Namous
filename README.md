# DBA Technical Assessment: Fares Abu-Namous

## Steps:
1) Imported csv data into mysql workbench and created a table containg all the imported data.
2) Created a seperate table in mysql that contained unique ids for the countries.
3) Assigned countries to each citizen basen on the data given.
4) Created a trigger that would keep track of new entries in the table and which country the new data is assigned to
5) Created a procedure that would list the data of all citizens of a country when passed that country and also restart the counter for that country
6) Exported the mysql database as an sql file uing mysql workbench
7) Developed a python script to transfer the sql database into a mongo database
   - Connected mysql database establishing a connection to mysql and imoporting all the data from the all_citizens table in JSON string format using mysql.connector
   - Setup an export of the JSON string from the mysql database to mongodb by establishing a connection to mongo using pymongo.mongoclient.
8) Exported the mongodb as a json file using MongoDB Compass

## Files:
1) mysql_script.sql: copy of the script used in mysql to create the database (steps 1-5)
2) mysql_export.sql: export of the mysql_data, procedure, and trigger
3) mongo_export.json: json string of the exported mongo database
4) example_config.json: json string template of config file used to establish connection with mysql and mongo
5) mysql_to_mongo.py: python script used to transfer the mysql database to a mongo database