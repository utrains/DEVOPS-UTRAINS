#### QA deployment steps

1- download artifact 

curl -uadmin:AP8gcgmmset5jeYChTJYDN6XmDd -O "http://52.91.134.51:8081/artifactory/utc-nodejs/<TARGET_FILE_PATH>"

# Replace this <TARGET_FILE_PATH> with your artifact

2- Bring up the app

java -jar <artifact>   # replace <artifact> with the downloaded file

3- Access app on port 8082 

4- Kill the app

ctrl + C

5- clean up

rm -rf *.jar
