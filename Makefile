IMAGE_NAME := elevator/dqn
WORKINGDIR := /var/www
PWD := $(shell pwd)

.PHONY: build
build:
	@docker build . -t $(IMAGE_NAME)

.PHONY: run
run:
	@docker run -it -u root -v $(PWD):$(WORKINGDIR) $(IMAGE_NAME) bash
