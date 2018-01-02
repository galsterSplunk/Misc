#!/bin/bash
export AVANTI_SERVER=http://localhost:8080
export AVANTI_PROVIDER=$1
export AVANTI_REGION=us-west-2
avanticli provider add --kind aws -arn arn:aws:iam::801351377084:role/DefaultAvantiProvider --regions us-west-2
export AVANTI_CLUSTER=$2
avanticli cluster create

cond=$(avanticli cluster describe --cluster $AVANTI_CLUSTER | grep stackStatus | cut -f 2 -d ":" | cut -f 2 -d "\"")

while [ "$cond" != "CREATE_COMPLETE" ]
do
    echo "server is not created yet going to sleep"
    sleep 10
    cond=$(avanticli cluster describe --cluster $AVANTI_CLUSTER | grep stackStatus | cut -f 2 -d ":" | cut -f 2 -d "\"")
    echo $cond
done

echo "server is up"

export AVANTI_NAMESPACE=$3
avanticli namespace create

echo "conatiner: $5"

avanticli service run --count 1 --service $4 --cd '{"logPath": "/opt/splunk/var/log/splunk", "image": "801351377084.dkr.ecr.us-west-2.amazonaws.com/majorkeyskynet","name":'"\"${5}\","'"portMappings": [{"containerPort": 8000,"protocol": "tcp"},{"containerPort": 9997,"protocol": "tcp"}]}'

serviceStatus=$(avanticli service describe --service $4 | grep status | cut -f 2 -d ":" | cut -f 1 -d "," | cut -f 2 -d "\"")
		
while [ "$serviceStatus" == "activating" ]
do
    echo "service $4 is begin activated"
    sleep 10
    serviceStatus=$(avanticli service describe --service $4 | grep status | cut -f 2 -d ":" | cut -f 1 -d "," | cut -f 2 -d "\"")
done

avanticli service describe --service $4

