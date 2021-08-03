CMD = $(shell aws ecr get-login --no-include-email --region us-east-1)

.PHONY: build
build:
	docker build -t <image_name> .

.PHONY: publish
publish:
	eval $(CMD)
	docker tag <image_name>:latest 844647875270.dkr.ecr.us-east-1.amazonaws.com/<image_name>:latest
	docker push 844647875270.dkr.ecr.us-east-1.amazonaws.com/<image_name>:latest

.PHONY: default
default: build publish
