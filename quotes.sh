#! /bin/bash
# sirMackk, 06/28/2014

fonts=(smbraille wideterm future)

lc=$((($RANDOM % $(wc -l $HOME/quotes | cut -f1 -d" ")) + 1))
words=$(sed -n "${lc}p" $HOME/quotes)
if type toilet > /dev/null 2>&1; then
  echo -e $words | toilet -t -f ${fonts[$(($RANDOM % ${#fonts[@]}))]}
else
  echo -e $words
fi
