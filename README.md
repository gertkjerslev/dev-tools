# Dev-tools

## Build image

``` bash
docker build -t dev-tools:latest .

```

## Docker run

``` bash
docker run -it  -v ${PWD}:/work -v $home/.azure:/root/.azure -v $home/.kube:/root/.kube --rm --workdir /work dev-tools:latest
```

## Powershell alias

Put this in your powershell $profile

``` powershell

function start-dev-tools-container {  
    docker run -it  -v ${PWD}:/work -v $home/.azure:/root/.azure -v $home/.kube:/root/.kube --rm --workdir /work dev-tools:latest
}
Set-Alias devtools  start-dev-tools-container

```

## Powershell Docker (Image with all modules installed)

alias powershell='docker run -it --rm --net host powershell' - virker ikke med alias

## Windows Terminal

Put this in you Windows Terminal "Commandline" when creating a new profile for the Dev-tools. Remember to type exit in the terminal to kill the docker container when done using the terminal 😁

``` bash
docker run -it --rm -v C:/Users/#USERNAME#:/work -v C:/Users/#USERNAME#/.azure:/root/.azure -v C:/Users/#USERNAME#/.kube:/root/.kube --rm --workdir /work dev-tools:latest
```
