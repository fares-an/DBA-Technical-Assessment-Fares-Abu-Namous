"""
Script to convert a mysql database table to mongo db

Dependencies:
 - mysql-connector-python
 - pymongo

Setup steps:
 - install mongodb and setup a local server using the mongod command
 - used port 27810 for the local mongo server

Code adapted from: https://dzone.com/articles/migrate-mysql-table-data-to-mongodb-collections-us
"""
import json
import mysql.connector
import pymongo

def get_mysql_data(config):
    """
    Connect to mysql database and retrieve all data

    Returns:
        JSON String: all data from all_citizens table in JSON format
    """
    sqldb = mysql.connector.connect(
        host=config["mysql_host_name"],
        database=config["mysql_db_name"],
        user=config["mysql_user_name"],
        password=config["mysql_password"],
        auth_plugin='mysql_native_password')

    cursor = sqldb.cursor(dictionary=True)
    cursor.execute("SELECT * from all_citizens;")
    result = cursor.fetchall()

    return result

def write_to_mongo_db(data, config):
    """
    Write data to mongo db

    Args:
        data (JSON string): data to write to database

    Returns:
        int: number of entries inserted into mongo db
    """
    mongo_client = pymongo.MongoClient(config["mongo_host"], config["mongo_port"])
    db = mongo_client[config["mongo_db_name"]]
    col = db["all_citizens"]

    result = col.insert_many(data)
    return len(result.inserted_ids)

def main():
    with open("config.json") as config_file:
        config = json.load(config_file)

        data = get_mysql_data(config)
        result = write_to_mongo_db(data, config)

        print(result)

if __name__ == "__main__":
    main()
