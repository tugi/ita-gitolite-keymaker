#!/bin/bash
divide="========================================================================"

mkdir -p temp_sshkey
cd temp_sshkey
rm -rf mykey*

thisdir=$(pwd)
thisuser=$USER

echo $divide
echo "Hello $USER!"

echo $divide
echo "This script will:"
echo "-create an rsa key for you, and"
echo "-upload it to Tim's gitolite keys inbox."

echo $divide
echo "!!!ATTENTION!!!"
echo "This will *delete* your ~/.ssh/id_rsa."
echo "If you already have one in use, please do not continue!"

echo -n "Continue? (y/n) "
read continue

if [ $continue != y ]; then
    echo -n "Do you want to add your .pub key to the ITA gitolite repo? (y/n) "
    read continue2
    if [ $continue2 != y ]; then
	echo "quitting!"
	rm -rf $thisdir
	exit 1
    fi
    echo "We need a keyname for you that is recoginisable to other ITA members."
    echo "If you're using one of the institute's computers, it would be wise to use your username."
    echo "If you're using a private machine, please name the key something like 'matthias-laptop'"
    echo -n "Enter a keyname:"
    read keyname
    
    mkdir -p $HOME/.ssh
    cd $HOME/.ssh/
    cp id_rsa.pub ${keyname}.pub
    echo $divide
    echo "Uploading key..."
    mailx -s "ITA keymaker: New userkey ${keyname}.pub" -a ${keyname}.pub < /dev/null "tugendhat@uni-heidelberg.de" >> /dev/null
    echo "done"
    echo $divide
    rm -rf ${keyname}.pub
    rm -rf $thisdir
    exit 1
fi

echo "Generating..."
echo "SSH:" > keygen.log
ssh-keygen -t rsa -b 2048 -f ${thisdir}/mykey -P "" >> keygen.log
echo "done"
echo $divide

echo "Moving keys..."
mv mykey $HOME/.ssh/id_rsa
mv mykey.pub $HOME/.ssh/id_rsa.pub
mv keygen.log $HOME/.ssh/
echo "done"
echo $divide

echo "Cool!"
echo "Now we need a keyname for you that is recoginisable to other ITA members."
echo "If you're using one of the institute's computers, it would be wise to use your username."
echo "If you're using a private machine, please name the key something like 'matthias-laptop'"
echo -n "Enter a keyname:"
read keyname

cd $HOME/.ssh/
cp id_rsa.pub ${keyname}.pub

echo "Uploading key..."
#ftp -inv $FTPHOST <<EOF
#user $FTPUSER $FTPPASS
#put ${keyname}.pub
#bye
#EOF
echo "MAIL:" >> keygen.log
mailx -s "ITA keymaker: New userkey ${keyname}.pub" -a ${keyname}.pub < /dev/null "tugendhat@uni-heidelberg.de" >> keygen.log
echo "KEY:" >> keygen.log
cat ${keyname}.pub >> keygen.log
echo "done"
echo $divide

echo "Cleaning up..."
rm -rf ${keyname}.pub
rm -rf $thisdir
echo "done"
echo $divide
