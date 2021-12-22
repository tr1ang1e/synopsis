#!/bin/bash

# synchronize >> git add + commit + push
# only modified files or modified script 
# new and deleted files are just added to an index

from=/media/sf_COMMON_coding/__synopsis/   # copy from path
to=./                                      # copy to path
oldpdf="pdf"                               # to remove before copiyng
newpdf="pdf"                              # new remote path and new dir name here
mask=*                                     # filename mask
except='~'                                 # prevent copying of opened files

# 'sed' so we have only the last commit
lastcommit=`git log --date=format:"%Y%m%d%H%M" --pretty=format:"%ad" | sed -n 1p`

repeat()
{
  # add files names from 'to' to the array
  index=0
  while read line; do
      array[$index]="$line"
      index=$(($index+1))
  done < <(ls -I "$oldpdf" | grep -v -E '.*\.sh$')

  # if any file doesn't exist anymore
  for ((a=0; a < ${#array[*]}; a++))
  do
    if [ ! -f "$from${array[$a]}"  ]
    then
      rm "$to${array[$a]}"
      if git add "${array[$a]}"   # if git add succeed (just 'if' example)
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
      cp "$name" "$to$newname" 2> /dev/null   # copy (2> /dev/null is to omit massages about dir copying ommiting)
      git add "$to$newname"                   # immediately add to git
      echo + "`basename "$name"`"  
    fi
  done
}

# processing .docx files
repeat

# processing .pdf files
rm -r "./$oldpdf"
cp -r "$from$newpdf" .
git add "$oldpdf"
git add "$newpdf"

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