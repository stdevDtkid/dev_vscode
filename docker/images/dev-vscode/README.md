# Supported tags and respective `Dockerfile` links

## Simple Tags

-	[`latest` (*docker/images/skycoindev-cli/Dockerfile*)](https://github.com/skycoin/skycoin/tree/develop/docker/images/skycoindev-cli/Dockerfile)

# Skycoin development image

This image has the necessary tools to build, test, edit, lint and version the Skycoin
source code.  It comes with the Vim editor installed, along with some plugins
to ease go development and version control with git.

# How to use this image

## Initialize your development environment.

```sh
$ mkdir src
$ docker run --rm \
    -v src:/go/src skycoin/skycoindev-cli \
    go get github.com/skycoin/skycoin
$ sudo chown -R `whoami` src
```

This downloads the skycoin source to src/skycoin/skycoin and changes the owner
to your user. This is necessary, because all processes inside the container run
as root and the files created by it are therefore owned by root.

If you already have a Go development environment installed, you just need to
mount the src directory from your $GOPATH in the /go/src volume of the
container. 

## Running commands inside the container

You can run commands by just passing the them to the image.  Everything is run
in a container and deleted when finished.

### Running tests

```sh
$ docker run --rm \
    -v src:/go/src skycoin/skycoindev-cli \
    sh -c "cd skycoin; make test"
```

### Running lint

```sh
$ docker run --rm \
    -v src:/go/src skycoin/skycoindev-cli \
    sh -c "cd skycoin; make lint"
```

### Editing code

```sh
$ docker run --rm \
    -v src:/go/src skycoin/skycoindev-cli \
    vim
```



# Added vscode 

Includes:

- [Visual Studio Code](https://code.visualstudio.com/) [ 140 Mo ]
  - [vscode-go](https://github.com/Microsoft/vscode-go)
- [Go 1.6.3](https://golang.org/) [ 320Mo ]
- [git]() 2.7.4
- [Emacs]() 24.5.1 + ruby 2.3.1 [ 189Mo ]
- Cloud Foundry Client 6.12 [25Mo]

## Managing User

The best way to work with this tool is to bind-mount you $HOME inside the container so that you will be 
able to work on you file.
I prefer not to work as root inside the container, so I will create you user inside the container at startup.
You'll have to pass env variables `MYUSERNAME`, `MYUID` and `MYGID` so that when you edit files inside the container you'll have the sames rights as outside.

## Running

```bash
alias vscode='docker rm vscode || true ; \
  docker run -dti \
    --net="host" \
    --name=vscode \
    -h vscode \
    -e DISPLAY=$DISPLAY \
    -e MYUID=$(id -u) \
    -e MYGID=$(id -g) \
    -e MYUSERNAME=$(id -un) \
    -e SSH_AUTH_SOCK=$SSH_AUTH_SOCK \
    -v $(dirname $SSH_AUTH_SOCK):$(dirname $SSH_AUTH_SOCK) \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v $HOME:$HOME \
    -w $HOME \
    sebmoule/docker-vscode'
```

### Entrypoint

The entrypoint will create your user inside the container if you have passed the according Environment variables.
It will also install some of tools for developping in `Golang`

The command will do the following:

- Create the user according to `MYUID` `MYGID` and `MYUSERNAME`
- save the IDE preferences into `<your-HOME-dir>/.vscode`
- mounts the `GOPATH` from your computer to the one in the container. This
assumes you have a single directory. If you have multiple directories in your
GOPATH, then see below how you can customize this to run correctly.

When bind-mounting you Home into the Container it will execture your `.bashrc` inside the container.

### Configuring .bashrc

This Tool when bind-mounting your $HOME inside the container will  source your `HOME/.bashrc` file.
To work properly this file must at least contains :

```bash
...
#Add my PATH                                                                                                                                                                   
export GOPATH=~/go                                                                                                                                                             
PATH=$PATH:~/bin:~/.local/bin/:$GOPATH/bin/:/usr/local/go/bin/ 
...
```

In order to know when I work inside the container or on my box, I have differentiate my bash Prompt with different colors :

```bash
       # If we have MYUSERNAME we are in Docker                                                                                                                               
        if [ -z "$MYUSERNAME" ]; then                                                                                                                                          
            #I am on my box                                                                                                                                                    
            PS1="[\[\033[31m\]\u\[\033[00m\]@\[\033[35m\]\h\[\033[00m\]: \[\033[34m\]\w\[\033[00m\]]\[\033[00m\]$"                                                             
        else                                                                                                                                                                   
            #I am in the container                                                                                                                                             
            PS1="[\[\033[34m\]\u\[\033[00m\]@\[\033[32m\]\h-in-docker\[\033[00m\]: \[\033[35m\]\w\[\033[00m\]]\[\033[00m\]$"                                                   
        fi  
```
