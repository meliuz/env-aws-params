# Params for dev environment
APPLICATION_NAME = env-aws-params
PARAMS ?= --help

.PHONY: all
all: build

.PHONY: build
build:
	@docker build \
		--tag ${APPLICATION_NAME}:development \
		--build-arg APPLICATION_NAME=${APPLICATION_NAME} .
	@docker build \
		--tag ${APPLICATION_NAME}-example:development \
		--build-arg APPLICATION_NAME=${APPLICATION_NAME} \
		--file Dockerfile.example .

.PHONY: run
run:
	@docker run --rm ${APPLICATION_NAME}-example:development /app/${APPLICATION_NAME} ${PARAMS}

.PHONY: lint
lint:
	@docker pull meliuz/docker-linter:latest
	@docker run --rm -v $$PWD:/app meliuz/docker-linter:latest " \
		lint-commit origin/master \
		&& lint-dockerfile \
		&& lint-markdown \
		&& lint-yaml"
