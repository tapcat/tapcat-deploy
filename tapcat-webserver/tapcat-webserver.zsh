
#fail on errors
set -e 

#build container
cp ../../war/tapcat-webserver.jar .
CONTAINER_ID=$(docker build -t tapcat/tapcat-webserver . | grep "Success" | awk '{ print $3 }')
rm tapcat-webserver.jar

# There are two nodes behind the nginx
# 8080 and 8081
# 8080 -> main ; 8081 -> backup
# redeploy proc:
# 1. stop 8081 old container
# 2. start 8081 new container with sessions from 8080
# 4. perform tests on 8081
# 5. stop 8080. Now, nginx will activate backup node
# 6. start 8080 new container with sessions from 8081
# 7. Done. Session migration complete. 2 new nodes deployed
# 8. 8081 can be disabled on demand

PROD_NODE=$(docker ps | grep -w "8080->8080" | awk '{ print $1 }')
TEST_NODE=$(docker ps | grep -w "8081->8080" | awk '{ print $1 }')
if [ -n "$TEST_NODE" ]; then docker stop $TEST_NODE; fi;
#Test node
echo 'Prod node ID: '$PROD_NODE
if [ -z "$PROD_NODE" ]; then
	VOLUME='-v=/logs,/sessions'
else 
	VOLUME='-volumes-from='$PROD_NODE
fi
echo 'Mounting volumes: '$VOLUME
TEST_NODE=$(docker run -d -p 8081:8080 $VOLUME $CONTAINER_ID)

#perform tests on 8081

#update current main node
#during update, server will be redirected to backup node
echo 'Prod container is about to be replaced'
if [ -n "$PROD_NODE" ]; then docker stop $PROD_NODE; fi;
PROD_NODE=$(docker run -d -p 8080:8080 -volumes-from=$TEST_NODE $CONTAINER_ID)
echo 'Prod container replaced: '$PROD_NODE
docker ps
echo 'Docker nodes: TEST: '$TEST_NODE' PROD: '$PROD_NODE' Container ID: '$CONTAINER_ID
