#!/usr/bin/env bash


#we deploy this using the target user (and target GOPATH define in ~/.bashrc"
function installLinter {
#source : https://github.com/Microsoft/vscode-go
    su $MYUSERNAME bash -c 'set -x; source ~/.bashrc;
    echo "we are deploying in $GOPATH";
    chown -R $MYUID:$MYGID $GOPATH;
    echo "Install more powerful linter to check code";
    go get -u github.com/alecthomas/gometalinter;
    gometalinter --install;
    echo "For debugging we need to install delve";
    go get -u -v github.com/derekparker/delve/cmd/dlv;
    echo "Install go Helpers for VsCode";
    go get -u -v github.com/nsf/gocode;
    go get -u -v github.com/rogpeppe/godef;
    go get -u -v github.com/golang/lint/golint;
    go get -u -v github.com/lukehoban/go-outline;
    go get -u -v sourcegraph.com/sqs/goreturns;
    go get -u -v golang.org/x/tools/cmd/gorename;
    go get -u -v github.com/tpng/gopkgs;
    go get -u -v github.com/newhook/go-symbols;
    go get -u -v golang.org/x/tools/cmd/guru;
    echo "go packages installed" ; set +X
    '
}


echo "You are connecting with User ${MYUSERNAME}"

ID=$(id -u)
#If we are root and we have give a MYUID different from default
if [ "$ID" -eq "0" ] && [ $MYUID != "" ]; then
    echo "Creating user $MYUSERNAME"
    groupadd -g $MYGID myusers || true
    useradd --uid $MYUID --gid $MYGID -s /bin/bash --home /home/$MYUSERNAME $MYUSERNAME
    echo "${MYUSERNAME} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${MYUSERNAME} 
    sudo chmod 0440 /etc/sudoers.d/${MYUSERNAME}

    echo "reset default env"
    export HOME=/home/${MYUSERNAME}
    export GOPATH=/home/${MYUSERNAME}/go
    export PATH=$PATH:/home/${MYUSERNAME}/go/bin:/usr/local/go/bin
fi

if [ "$1" == "vscode" ]; then
    
    if [ ! -d /home/${MYUSERNAME}/go/src/github.com/alecthomas/gometalinter ]; then
	# We are running a fresh install we install some packages
	installLinter
    else
	echo "Go Linters already installed in your GOPATH.. Skipping"
    fi
    
    echo "Starting vscode $1, code"
    if [ $ID = 0 ];then
	if [ -f /home/$MYUSERNAME/.bashrc ]; then
	    echo "there is a .bashrc we source it and launch code"
	    su $MYUSERNAME -c "source /home/$MYUSERNAME/.bashrc && code --verbose -w"
	else
	    echo "there is NO .bashrc we just launch code -verbose -w"
	    su $MYUSERNAME -c "code"
	fi
	echo "Code a rendu la main..., we Exit"
	#exec su $MYUSERNAME -c bash # give a bash
#	exec bash
    fi
else
    echo "Starting your overrided command: exec $@"
    exec $@
fi

echo "end of script"

exit 0
