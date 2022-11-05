$SPARK_HOME/bin/spark-submit \
--class com.github.supermariolabs.spooq.Application \
--master local[*] \
--packages mysql:mysql-connector-java:8.0.30 \
--conf spark.executor.extraJavaOptions=-Dlog4j.configurationFile=log4j2.properties \
--conf spark.driver.extraJavaOptions=-Dlog4j.configurationFile=log4j2.properties \
../Spooq-0.9.9beta-spark3.3.0_2.12.16-standalone.jar \
-c conf/hide.conf -v
