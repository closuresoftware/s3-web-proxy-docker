#!/usr/bin/env bash

JAVA="$JAVA_HOME/bin/java"

CP="${CATALINA_HOME}/webapps/ROOT/WEB-INF/classes"
for f in ${CATALINA_HOME}/webapps/ROOT/WEB-INF/lib/*.jar
do
    CP="$CP:$f"
done

$JAVA -cp $CP software.closure.s3proxy.S3ProxyTools
