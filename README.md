# OCaml Nix template

This is a OCaml nix template
It provides:
- Development environment
- Building docker image
- Testing

## Starting development environment
The only command you need to get a development environment is running 
```
nix develop
```

and you should be able to just run  `dune build` to build the program

## Building for production - binary
Building a binary can be done using 
```
nix build '#.packages.x86_64-linux.default'
```
and ./result gives you the binary

## Building for production - docker image
Building a docker image can be done using 
```
nix build '#.packages.x86_64-linux.dockerImage'
```
and ./result gives you all the layers you need. If you want to import this layers can you do it by running
```
docker load -i ./result
```

## Running tests
Running tests can be done by running
```
nix build '#.packages.x86_64-linux.test'
```
