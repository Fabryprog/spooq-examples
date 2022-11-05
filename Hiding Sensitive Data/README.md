## Hiding sensitive data

Sensitive information will be hidden using 3 simple regexes to 3 columns of a MySQL table. 

At the end a CSV file will be created containing the "secret data"

### Init example db

1. git clone https://github.com/datacharmer/test_db
2. docker run --name my-mysql -e MYSQL_ROOT_PASSWORD=password -d -p 3306:3306 mysql
3. docker cp test_db my-mysql:/tmp 
4. docker exec -it my-mysql bash
5. cd /tmp/test_db/ 
6. mysql -ppassword < employees.sql 
7. mysql -ppassword -t < test_employees_md5.sql
8. exit

### Spooq 

Configuration file: conf/hide.conf
Output files: data/*.csv

### Run Example

Execute the script

```
export SPARK_HOME=<your local spark home>
sh run.sh
``` 

### How to works?

```(json)
id = "hide sensitive data job"
desc = """

A simple rule to hide sensitive data 

Note: in your system mysql ip should be different!!! 
"""
steps = [
    {
        id = employees
        shortDesc = "read employees table from jdbc database"
        kind = input
        format = jdbc
        options = {
            url = "jdbc:mysql://192.168.1.15:3306/employees"
            driver = "com.mysql.cj.jdbc.Driver"
            dbtable = "employees.employees"
            user = "root"
            password = "password"
        }
        cache = false
        show = false
    },
    {
        id = employees_limit
        shortDesc = "limit employees to 10"
        kind = sql
        sql = "select * from employees limit 10"
        show = true
    },
    {
        id = employees_script
        kind = script
        jsr223Engine = scala
        code = """
	import org.apache.spark.sql.DataFrame
	import org.apache.spark.sql.functions._

    employees_limit
        .withColumn("first_name", regexp_replace(col("first_name"), "^.{0,3}", "xxx"))
        .withColumn("last_name", regexp_replace(col("last_name"), "^.{2,5}", "yyy"))
        .withColumn("birth_date", regexp_replace(col("birth_date"), "^\\d{4}", "zzzz"))
"""
    },

    {
        id = out
        shortDesc = "write to fs"
        dependsOn = ["employees_script"]
        desc = "write 'employees_script' table to fs using csv format"
        kind = output
        source = employees_script
        format = csv
        options = {
            header = "true"
        }
        mode = overwrite
        path = "data/employees_script.csv"
    }
]

```


The Scoop configuration file consists of 4 steps:
 - input jdbc: to load employees table inside spark context
 - sql: to limit data (only for example purpose)
 - script scala: to apply the regex
 - output csv: to write data into the csv file

