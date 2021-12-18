#!/bin/bash

from=/media/sf_COMMON_coding/__synopsis/   # copy from path
to=./                                      # copy to path
mask=*                                     # filename mask

lastcommit=`git log --date=format:"%Y%m%d%H" --pretty=format:"%ad" | sed -n 1p`
except='~'  # prevent copying of opened files

# copy files were changed till last commit
for name in $from$mask
do
  lastchange=`date -r "$name" +%Y%m%d%H`
  newname="`basename "$name"`"
  if [ ${newname:0:1} != $except ] && [ $lastchange -gt $lastcommit ] 
  then
    cp "$name" "$to$newname"
    git add "$to$newname"
  fi
done

ch=`git status | grep modified`
if [ "$ch" ]
then
  git add $0
  git commit -m "x"
  git push
fi