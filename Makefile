DOCKER_TAG				?= go-hello-world
FULL_TAG				?= ${DOCKER_TAG}:${HASH}
DYNAMODB_TABLE			?= ${DOCKER_TAG}
PORT					?= "8080"
GO_TEST_DOCKER_COMPOSE  ?=  go test ./... -v -cover
# AWS_CLI_DOCKER_COMPOSE  ?= docker-compose run --rm awscli
HASH := $(shell git rev-parse HEAD)
VERACODE_ID?= "someveracodeid"

export CODECOV_TOKEN

.PHONY : build
build:
	docker build -t ${FULL_TAG} .

.PHONY: run
run:
	docker run -d -p ${PORT}:${PORT} --name ${DOCKER_TAG} ${FULL_TAG}

.PHONY: test
test: 
	go test ./... -v -coverprofile=c.out
	go tool cover -html=c.out -o coverage.html
	cat coverage.html
	mv coverage.html /tmp/artifacts

.PHONY: codecov_report
codecov_report:
	echo ${CODECOV_TOKEN}
	curl -X GET https://codecov.io/api/pub/gh/james5101/gsd-hello-world/settings \
		-H 'Authorization: ${CODECOV_TOKEN}'

# .PHONY: create_table
# create_table: 
# 	echo "from create_table"
# 	echo "FOO=${FOO}"
# 	echo "BAR=${BAR}"
# 	${AWS_CLI_DOCKER_COMPOSE} dynamodb create-table \
# 		--table-name ${DYNAMODB_TABLE} \
# 		 --attribute-definitions \
# 			AttributeName=GIT_COMMIT,AttributeType=S \
# 			AttributeName=VERACODE_ID,AttributeType=S \
#     	--key-schema \
# 			AttributeName=GIT_COMMIT,KeyType=HASH \
# 			AttributeName=VERACODE_ID,KeyType=RANGE \
# 		--provisioned-throughput \
#         	ReadCapacityUnits=10,WriteCapacityUnits=5

# create_tags: 
# 	${AWS_CLI_DOCKER_COMPOSE} dynamodb put-item \
# 		--table-name ${DYNAMODB_TABLE}  \
# 		--item \
# 			'{"GIT_COMMIT": {"S": "${HASH}"}, "VERACODE_ID":{"S": ${VERACODE_ID}}}'

.PHONY: clean
clean:
	docker kill ${DOCKER_TAG}
	docker rm ${DOCKER_TAG}




	
