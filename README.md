#### One repo for uniting multiple target dependent container types

based on debian release containers

- systemd base container and children of that container type
  - ssh 
  - golang  - golang compiler/tools + govendor, godep, 
  - builder - 

* davidwalter/debian:{RELEASE}

Base image for testing docker containers and network tooling like
kubernetes hosted applications. Added dnsutils to assist in debugging

---
### systemd based utility containers

- decouple/isolate secrets from template generated yaml files for
  kubernetes deployments, secrets can be stored as normal on developer
  workstations and included during template processing
- deployments `deployment.yaml` assume kubernetes
  `github.com/davidwalter0/loadbalancer` and a suitably operating
  kubernetes cluster
- entrypoint.sh.tmpl - templated start script for the container
- Dockerfile.tmpl    - templated doesn't store credential or id information
- deployment.yaml.tmpl - templated kubernetes secrets, service, deployment
