#!/bin/bash

HOME_DIR=/Users/sanand/Downloads/ATTSummit/SmartBus
VIN=123456789

REQUEST_ID_FILENAME=$HOME_DIR/REQ_ID
DIAGNOSTIC_HISTORY_FILENAME=$HOME_DIR/DIAGNOSTIC_HISTORY


capture_and_store()
{
#POST
curl -X POST http://yankee.hack.att.io:3000/remoteservices/v1/vehicle/diagnostics/view/${VIN} -H "Content-Type: application/json" -H "Authorization: 'Basic cHJvdmlkZXI6MTIzNA== Base64(provider:1234)" -H "api-key: 1234" 2> /dev/null | \
$HOME_DIR/JSON.sh -b | awk '{if($1 ~ /requestId/)print $2}' > ${REQUEST_ID_FILENAME}


#GET
REQ_ID=`cat ${REQUEST_ID_FILENAME}`

curl -X GET http://yankee.hack.att.io:3000/remoteservices/v1/vehicle/status/${VIN}/${REQ_ID} -H "Content-Type: application/json" -H "Authorization: 'Basic cHJvdmlkZXI6MTIzNA== Base64(provider:1234)" -H "api-key: 1234" 2> /dev/null | \
$HOME_DIR/JSON.sh -b |
awk '{
     if($1 ~ /requestTime/)requestTime=$2
else if($1 ~ /odometer/)odometer=$2
else if($1 ~ /frontRightTirePressure/)frontRightTirePressure=$2
else if($1 ~ /frontLeftTirePressure/)frontLeftTirePressure=$2
else if($1 ~ /rearRightTirePressure/)rearRightTirePressure=$2
else if($1 ~ /rearLeftTirePressure/)rearLeftTirePressure=$2
}
END{printf "%s %s %s %s %s %s\n", requestTime, odometer, frontRightTirePressure, frontLeftTirePressure, rearRightTirePressure, rearLeftTirePressure}' | post_to_M2X
}

post_to_M2X ()
{
read requestTime odometer frontRightTirePressure frontLeftTirePressure rearRightTirePressure rearLeftTirePressure

curl -X PUT http://api-m2x.att.com/v2/devices/d0e6b9bb82a59fd8fe4eebd38ca5fc3d/streams/odometer/value -H "X-M2X-KEY: 5f1a0a56aeb4e81d45ced331efee39cb" -H "Content-Type: application/json" -d "{ \"value\": \"$odometer\" }"

curl -X PUT http://api-m2x.att.com/v2/devices/d0e6b9bb82a59fd8fe4eebd38ca5fc3d/streams/frontRightTirePressure/value -H "X-M2X-KEY: 5f1a0a56aeb4e81d45ced331efee39cb" -H "Content-Type: application/json" -d "{ \"value\": \"$frontRightTirePressure\" }"

curl -X PUT http://api-m2x.att.com/v2/devices/d0e6b9bb82a59fd8fe4eebd38ca5fc3d/streams/frontLeftTirePressure/value -H "X-M2X-KEY: 5f1a0a56aeb4e81d45ced331efee39cb" -H "Content-Type: application/json" -d "{ \"value\": \"$frontLeftTirePressure\" }"

curl -X PUT http://api-m2x.att.com/v2/devices/d0e6b9bb82a59fd8fe4eebd38ca5fc3d/streams/rearRightTirePressure/value -H "X-M2X-KEY: 5f1a0a56aeb4e81d45ced331efee39cb" -H "Content-Type: application/json" -d "{ \"value\": \"$rearRightTirePressure\" }"

curl -X PUT http://api-m2x.att.com/v2/devices/d0e6b9bb82a59fd8fe4eebd38ca5fc3d/streams/rearLeftTirePressure/value -H "X-M2X-KEY: 5f1a0a56aeb4e81d45ced331efee39cb" -H "Content-Type: application/json" -d "{ \"value\": \"$rearLeftTirePressure\" }"

}

while [ true ]
do
capture_and_store
sleep 5
done

