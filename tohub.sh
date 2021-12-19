#!/bin/bash

# add >> commit >>  push
# only copied files or modified script 

from=/media/sf_COMMON_coding/__synopsis/   # copy from path
to=./                                      # copy to path
mask=*                                     # filename mask
except='~'                                 # prevent copying of opened files

# 'sed' so we have only the last commit
lastcommit=`git log --date=format:"%Y%m%d%H%M" --pretty=format:"%ad" | sed -n 1p`

# dealing with deleted from source directory files
index=0
while read line; do
    array[$index]="$line"
    index=$(($index+1))
done < <(ls | grep -v -E '.*\.sh$')

for ((a=0; a < ${#array[*]}; a++))
do
  if [ ! -f "$from${array[$a]}"  ]
  then
    rm "$to${array[$a]}"
    if git add "${array[$a]}"
    then
      echo - "${array[$a]}"
    fi
  fi
done

# copy files were modified till last commit
for name in $from$mask
do
  lastchange=`date -r "$name" +%Y%m%d%H%M`
  newname="`basename "$name"`"
  if [ ${newname:0:1} != $except ] && [ $lastchange -gt $lastcommit ] 
  then
    cp "$name" "$to$newname"    # copy
    git add "$to$newname"       # immediately add to git
    echo + "`basename "$name"`"  
  fi
done

# add to git this script if modified till last commit
if [ `date -r $0 +%Y%m%d%H%M` -gt $lastcommit ]
then
  git add $0
  echo + $0
fi

# check if any files modified >> commit, push
changes=`git status | grep modified`
if [ "$changes" ]
then
  git commit -m "x"    # no sence
  git push
fi