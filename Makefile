.PHONY: all build build-no-cache fmt

# Params for env-aws-params dev environment
APPLICATION_NAME=env-aws-params

all: build

build:
	@docker-compose build --pull
	@docker-compose run --rm ${APPLICATION_NAME} go build

build-no-cache:
	@docker-compose build --no-cache --pull
	@docker-compose run --rm ${APPLICATION_NAME} go build

fmt:
	@docker-compose run --rm ${APPLICATION_NAME} go fmt
