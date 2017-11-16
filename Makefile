.PHONY: deps install clean image build push
export GOPATH=/go
SHELL=/bin/bash
MAKEFILE_DIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
CURRENT_DIR := $(notdir $(patsubst %/,%,$(dir $(MAKEFILE_DIR))))
DIR=$(MAKEFILE_DIR)

all: image push

image: 
	docker build --tag=davidwalter/$(notdir $(PWD)):latest .

push: image
	docker push davidwalter/$(notdir $(PWD)):latest
