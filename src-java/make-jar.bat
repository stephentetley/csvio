
set %JAVA_HOME%="C:\Program Files\Zulu\zulu-11"

javac -cp "../lib/commons-csv-1.9.0.jar;../lib/commons-io-2.11.0.jar" -Xlint:deprecation -d ./build  flixspt/csvio/*.java

cd build 

jar cf csviojava-1.3.jar ./flixspt/csvio/*.class

