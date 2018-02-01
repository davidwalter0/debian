# Copyright 2018 David Walter.

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#     http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

.PHONY: install clean build yaml appl get push tag tag-push info
# To enable kubernetes commands a valid configuration is required
deploy_list:=$(patsubst %.tmpl,%,$(wildcard *.tmpl))
# export GOPATH=/go
export kubectl=${GOPATH}/bin/kubectl  --kubeconfig=${PWD}/cluster/auth/kubeconfig
SHELL=/bin/bash
MAKEFILE_DIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
CURRENT_DIR := $(notdir $(patsubst %/,%,$(dir $(MAKEFILE_DIR))))
export DIR=$(MAKEFILE_DIR)
export APPL=$(notdir $(PWD))
export IMAGE=$(notdir $(PWD))

export DEBIAN_VERSION=debian:testing-slim
export BUILD_USER=build
export LoadBalancerIP=192.168.0.222
export LoadBalancerIPList=(192.168.0.200 192.168.0.201)
# extract tag from latest commit, use tag for version
export gittag=$$(git tag -l --contains $(git log --pretty="format:%h"  -n1))
export TAG=$(shell if git diff --quiet --ignore-submodules HEAD && [[ -n $(gittag) ]]; then echo $(gittag); else echo "canary"; fi)
include Makefile.defs

all:
	cd systemd; i=0; \
	eval declare -a LoadBalancerIPs=$${LoadBalancerIPList}; \
	for DEBIAN_RELEASE in testing stretch; do set -x ; \
	    export DEBIAN_VERSION=$${DEBIAN_RELEASE}; \
	    export DEBIAN_IMAGE=debian:$${DEBIAN_RELEASE}-slim; \
	    export IMAGE=systemd:$${DEBIAN_RELEASE}; \
	    echo export LoadBalancerIP=$${LoadBalancerIPs[$${i}]}; \
	    export LoadBalancerIP=$${LoadBalancerIPs[$${i}]}; \
	    make -C 
	    for file in *.tmpl; do	\
		echo "$${GOPATH}/bin/applytmpl < $${file} > $${file%.tmpl}"; \
		$(GOPATH)/bin/applytmpl < $${file} > $${file%.tmpl}; done; \
		docker build --tag=$(DOCKER_USER)/systemd:$${DEBIAN_RELEASE} .; \
	   i=$$((i+1)); \
	done;

	for ip in $(LoadBalancerIPList)

info: 
	@echo $(info)

etags:
	etags $(depends) $(build_deps)

.dep:
	mkdir -p .dep
	touch .dep --reference=Makefile

build: yaml .dep/image-$(DOCKER_USER)-$(IMAGE)-latest 

.dep/image-$(DOCKER_USER)-$(IMAGE)-latest: .dep $(wildcard Dockerfile *.tmpl systemd-user-sessions.service) Makefile
	cd systemd; i=0; \
	eval declare -a LoadBalancerIPs=$${LoadBalancerIPList}; \
	for DEBIAN_RELEASE in testing stretch; do set -x ; \
	    export DEBIAN_VERSION=$${DEBIAN_RELEASE}; \
	    export DEBIAN_IMAGE=debian:$${DEBIAN_RELEASE}-slim; \
	    export IMAGE=systemd:$${DEBIAN_RELEASE}; \
	    echo export LoadBalancerIP=$${LoadBalancerIPs[$${i}]}; \
	    export LoadBalancerIP=$${LoadBalancerIPs[$${i}]}; \
	    for file in *.tmpl; do	\
		echo "$${GOPATH}/bin/applytmpl < $${file} > $${file%.tmpl}"; \
		$(GOPATH)/bin/applytmpl < $${file} > $${file%.tmpl}; done; \
		docker build --tag=$(DOCKER_USER)/systemd:$${DEBIAN_RELEASE} .; \
	   i=$$((i+1)); \
	done;
	touch $@ 

tag: info .dep .dep/tag-$(DOCKER_USER)-$(IMAGE)-$(TAG)
	@echo $(info)

.dep/tag-$(DOCKER_USER)-$(IMAGE)-$(TAG): .dep/image-$(DOCKER_USER)-$(IMAGE)-latest
	docker tag $(DOCKER_USER)/$(IMAGE):latest \
	$(DOCKER_USER)/$(IMAGE):$${TAG}
	touch $@ 

push: info .dep .dep/push-$(DOCKER_USER)-$(IMAGE)-latest

.dep/push-$(DOCKER_USER)-$(IMAGE)-latest: .dep/image-$(DOCKER_USER)-$(IMAGE)-latest
	docker push $(DOCKER_USER)/$(IMAGE):latest
	touch $@

tag-push: info .dep/tag-$(DOCKER_USER)-$(IMAGE)-$(TAG) .dep/tag-push-$(DOCKER_USER)-$(IMAGE)-$(TAG)

.dep/tag-push-$(DOCKER_USER)-$(IMAGE)-$(TAG): .dep/image-$(DOCKER_USER)-$(IMAGE)-latest
	docker push $(DOCKER_USER)/$(IMAGE):$(TAG)
	touch $@

yaml: info .dep .dep/yaml-$(DOCKER_USER)-$(IMAGE)-$(TAG) $(patsubst %.tmpl,%,$(wildcard *.tmpl))

.dep/yaml-$(DOCKER_USER)-$(IMAGE)-$(TAG): .dep Makefile $(wildcard *.tmpl)
	cd systemd; i=0; \
	eval declare -a LoadBalancerIPs=$${LoadBalancerIPList}; \
	for DEBIAN_RELEASE in testing stretch; do set -x ; \
	    export DEBIAN_VERSION=$${DEBIAN_RELEASE}; \
	    export DEBIAN_RELEASE=$${DEBIAN_RELEASE}; \
	    export DEBIAN_IMAGE=debian:$${DEBIAN_RELEASE}-slim; \
	    export IMAGE=systemd:$${DEBIAN_RELEASE}; \
	    echo export LoadBalancerIP=$${LoadBalancerIPs[$${i}]}; \
	    export LoadBalancerIP=$${LoadBalancerIPs[$${i}]}; \
	    for file in *.tmpl; do	\
		echo "$(GOPATH)/bin/applytmpl < $${file} > $${file%.tmpl}"; \
		$(GOPATH)/bin/applytmpl < $${file} > $${file%.tmpl}.$${DEBIAN_RELEASE}; done; \
	    i=$$((i+1)); \
	done;
	touch $@

delete: .dep/delete

.dep/delete: yaml
	$(kubectl) delete ds/$(APPL) || true

deploy: info .dep/deploy

.dep/deploy: .dep yaml
	$(kubectl) apply -f deployment.yaml

get: info .dep 

.dep/get: .dep yaml
	$(kubectl) get -f deployment.yaml

clean: .dep bin 
	@if [[ -d "bin" ]]; then rmdir bin; fi
	rm -f .dep/*

bin:
	mkdir -p bin
