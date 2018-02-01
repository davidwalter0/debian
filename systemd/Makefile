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
SHELL=/bin/bash
MAKEFILE_DIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
CURRENT_DIR := $(notdir $(patsubst %/,%,$(dir $(MAKEFILE_DIR))))

export DIR=$(MAKEFILE_DIR)

include Makefile.defs

all: info build

info: 
	@echo $(info)

etags:
	etags $(depends) $(build_deps)

.dep:
	mkdir -p .dep
	touch .dep --reference=Makefile

image: .dep/image-${RELEASE}

.dep/image-${RELEASE}: .dep
	$(info)
	for file in *.tmpl; do \
	   echo "$${GOPATH}/bin/applytmpl < $${file} > $${file%.tmpl}"; \
	   yaml=$${file%.tmpl}.$${DEBIAN_RELEASE}; \
	   $(GOPATH)/bin/applytmpl < $${file} > $${yaml}; \
	   $(GOPATH)/bin/applytmpl < $${file} > $${file%.tmpl}; \
	done;
	docker build --force-rm --rm --tag=$(DOCKER_USER)/$${IMAGE} .; \
	touch $@ 

clean:
	rm -f .dep/*
