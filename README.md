# Dev-tools

This project provides a Docker-based development environment equipped with various tools and utilities commonly used for development and DevOps tasks. The Docker image includes essential tools such as Kubernetes CLI, Helm, ArgoCD, Flux CLI, Azure CLI, and more, allowing developers to have a consistent and portable development setup.

## Features

- **Kubernetes CLI**: Manage Kubernetes clusters with `kubectl`.
- **Helm**: Package manager for Kubernetes.
- **ArgoCD**: Declarative GitOps continuous delivery tool for Kubernetes.
- **Flux CLI**: Continuous delivery solution for Kubernetes.
- **Azure CLI**: Command-line tools for managing Azure resources.
- **Additional Tools**: Includes tools like Git, Docker, Node.js, Go, PowerShell, and more.
- **kube-no-trouble**: Easily check your clusters for the use of deprecated APIs
- **Krew: plugin manager for `kubectl` command-line tool

## Usage

### Build the Docker Image

``` bash
docker build -t dev-tools:latest .

```

## Docker run

``` bash
docker run -it  -v ${PWD}:/work -v $home/.root:/root -v $home/.azure:/root/.azure -v $home/.kube:/root/.kube -v /var/run/docker.sock:/var/run docker.sock --net host --rm --workdir /work dev-tools:latest
```

## Powershell alias

Put this in your powershell $profile

``` powershell

function start-dev-tools-container {  
    docker run -it  -v ${PWD}:/work -v $home/.root:/root -v $home/.azure:/root/.azure -v $home/.kube:/root/.kube -v /var/run/docker.sock:/var/run/docker.sock --net host --rm --workdir /work dev-tools:latest
}
Set-Alias devtools start-dev-tools-container

```

## Windows Terminal

Put this in you Windows Terminal "Commandline" when creating a new profile for the Dev-tools. Remember to type exit in the terminal to kill the docker container when done using the terminal 😁

``` bash
docker run -it --rm -v C:/Users/#USERNAME#:/work -v C:/Users/#USERNAME#/.azure:/root/.azure -v /var/run/docker.sock:/var/run/docker.sock -v C:/Users/#USERNAME#/.kube:/root/.kube -v C:/Users/#USERNAME#/.minikube:/root/.minikube --rm --workdir /work dev-tools:latest
```
