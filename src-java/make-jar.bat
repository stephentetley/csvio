
set %JAVA_HOME%="C:\Program Files\Zulu\zulu-11"

javac -cp "../lib/commons-csv-1.8.jar;../lib/commons-io-2.6.jar" -d ./build  flixspt/csvio/*.java

cd build 

jar cf csviojava-1.0.jar ./flixspt/csvio/*.class

