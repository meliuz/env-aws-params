.PHONY: all build build-no-cache fmt lint

# Params for env-aws-params dev environment
APPLICATION_NAME=env-aws-params

all: build

build:
	@docker-compose build --pull
	@docker run -v $$PWD:/src --rm ${APPLICATION_NAME}:latest cp ${APPLICATION_NAME} /src

build-no-cache:
	@docker-compose build --no-cache --pull
	@docker run -v $$PWD:/src --rm ${APPLICATION_NAME}:latest cp ${APPLICATION_NAME} /src

down:
	@docker-compose down

fmt:
	@docker-compose run --rm ${APPLICATION_NAME} go fmt

run:
	@docker-compose run --rm ${APPLICATION_NAME} ./${APPLICATION_NAME} ${PARAMS}

test:
	@docker-compose run --rm ${APPLICATION_NAME} go test

lint:
	@docker pull meliuz/docker-linter:latest
	@docker run --rm -v $$PWD:/app meliuz/docker-linter:latest " \
		lint-commit origin/master \
		&& lint-dockerfile \
		&& lint-markdown \
		&& lint-yaml"
