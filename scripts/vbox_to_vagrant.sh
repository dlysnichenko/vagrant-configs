#!/bin/bash


if [ $# -ne 2 ]
then
  echo -e "Syntax:\n$0 <source virtualbox vm name> <target vagrant box name>\nList of accessible VBox vms:"
  vboxmanage list vms
else
  SRC_NAME=$1
  TGT_NAME=$2

  vagrant box remove "$TGT_NAME"

  vagrant package --base "$SRC_NAME"
  vagrant box add "$TGT_NAME" package.box
  rm package.box
fi
