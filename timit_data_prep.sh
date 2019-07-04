#!/bin/bash

# Copyright 2013   (Authors: Bagher BabaAli, Daniel Povey, Arnab Ghoshal)
#           2014   Brno University of Technology (Author: Karel Vesely)
# Apache 2.0.

if [ $# -ne 3 ]; then
   echo "Argument should be the Timit directory, see ../run.sh for example."
   exit 1;
fi
CV=$2$3
mkdir -p $CV
dir=$CV/data/local/data
lmdir=$CV/data/local/nist_lm
mkdir -p $dir $lmdir
local=`pwd`/local
utils=`pwd`/utils
conf=`pwd`/conf

. ./path.sh # Needed for KALDI_ROOT
export PATH=$PATH:$KALDI_ROOT/tools/irstlm/bin
sph2pipe=$KALDI_ROOT/tools/sph2pipe_v2.5/sph2pipe
if [ ! -x $sph2pipe ]; then
   echo "Could not find (or execute) the sph2pipe program at $sph2pipe";
   exit 1;
fi

[ -f $conf/test_spk.list ] || error_exit "$PROG: Eval-set speaker list not found.";
#[ -f $conf/dev_spk.list ] || error_exit "$PROG: dev-set speaker list not found.";

# First check if the train & test directories exist (these can either be upper-
# or lower-cased
: <<'END'
if [ ! -d $*/TRAIN -o ! -d $*/TEST ] && [ ! -d $*/train -o ! -d $*/test ]; then
  echo "timit_data_prep.sh: Spot check of command line argument failed"
  echo "Command line argument must be absolute pathname to TIMIT directory"
  echo "with name like /export/corpora5/LDC/LDC93S1/timit/TIMIT"
  exit 1;
fi 
END

# Now check what case the directory structure is
uppercased=true
train_dir=train
test_dir=test

#if [ -d $*/TRAIN ]; then
#  uppercased=true
#  train_dir=TRAIN
#  test_dir=TEST
#fi

tmpdir=$(mktemp -d);
trap 'rm -rf "$tmpdir"' EXIT

# Get the list of speakers. The list of speakers in the 24-speaker core test 
# set and the 50-speaker development set must be supplied to the script. All
# speakers in the 'train' directory are used for training.
#if $uppercased; then
##  tr '[:lower:]' '[:upper:]' < $conf/dev_spk.list > $tmpdir/dev_spk
#  tr '[:lower:]' '[:upper:]' < $conf/test_${CV}.list > $tmpdir/test_spk
#  tr '[:lower:]' '[:upper:]' < $conf/train_${CV}.list > $tmpdir/train_spk
#  #ls -d "$*"/TRAIN/* | sed -e "s:^.*/::" > $tmpdir/train_spk
#else
##  tr '[:upper:]' '[:lower:]' < $conf/dev_spk.list > $tmpdir/dev_spk
#  tr '[:upper:]' '[:lower:]' < $conf/test_${CV}.list > $tmpdir/test_spk
#  tr '[:upper:]' '[:lower:]' < $conf/train_${CV}.list > $tmpdir/train_spk
#  #ls -d "$*"/train/* | sed -e "s:^.*/::" > $tmpdir/train_spk
#fi

cat $conf/test_${CV}.list > $tmpdir/test_spk
cat $conf/train_${CV}.list > $tmpdir/train_spk

cd $dir

for x in train test; do
  # First, find the list of audio files (use only si & sx utterances).
  # Note: train & test sets are under different directories, but doing find on 
  # both and grepping for the speakers will work correctly.
  	: <<'END'
find $1 -iname '*.WAV' | grep -f $tmpdir/${x}_spk | sort > aaa
  zz=$3;
  y=$((zz-1));
	if [ $x == "train" ]; then
		for xx in `cat aaa`; do 
			y=$((y+1)); 
			z=$((y%5)); 
			if [ $z -ne 0 ]; then 
				echo $xx; 
			fi;
		done > ${x}_sph.flist
	else
		for xx in `cat aaa`; do 
			y=$((y+1)); 
			z=$((y%5)); 
			if [ $z -eq 0 ]; then 
				echo $xx; 
			fi;
		done > ${x}_sph.flist
	fi
    rm -rf aaa 
END
	find $1 -iname '*.WAV' \
    | grep -f $tmpdir/${x}_spk > ${x}_sph.flist

  sed -e 's:.*/\(.*\)/\(.*\).WAV$:\2:i' ${x}_sph.flist \
    > $tmpdir/${x}_sph.uttids
  paste $tmpdir/${x}_sph.uttids ${x}_sph.flist \
    | sort -k1,1 > ${x}_sph.scp

  cat ${x}_sph.scp | awk '{print $1}' > ${x}.uttids

  # Now, Convert the transcripts into our format (no normalization yet)
  # Get the transcripts: each line of the output contains an utterance 
  # ID followed by the transcript.
  find $1 -iname '*.PHO' \
    | grep -f $tmpdir/${x}_spk > $tmpdir/${x}_phn.flist
  #cp $tmpdir/${x}_phn.flist ${x}_phn.flist
	: <<'END'
find $1 -iname '*.PHO' | grep -f $tmpdir/${x}_spk | sort > aaa
  zz=$3;
  y=$((zz-1));
	if [ $x == "train" ]; then
		for xx in `cat aaa`; do 
			y=$((y+1)); 
			z=$((y%5)); 
			if [ $z -ne 0 ]; then 
				echo $xx; 
			fi;
		done > $tmpdir/${x}_phn.flist
	else
		for xx in `cat aaa`; do 
			y=$((y+1)); 
			z=$((y%5)); 
			if [ $z -eq 0 ]; then 
				echo $xx; 
			fi;
		done > $tmpdir/${x}_phn.flist
	fi
	rm -rf aaa 
END
  sed -e 's:.*/\(.*\)/\(.*\).PHO$:\2:i' $tmpdir/${x}_phn.flist \
    > $tmpdir/${x}_phn.uttids
  #while read line; do
  #  [ -f $line ] || error_exit "Cannot find transcription file '$line'";
  #  cut -f3 -d' ' "$line" | tr '\n' ' ' | sed -e 's: *$:\n:'
  #done < $tmpdir/${x}_phn.flist > $tmpdir/${x}_phn.trans
  #paste $tmpdir/${x}_phn.uttids $tmpdir/${x}_phn.trans \
  #  | sort -k1,1 > ${x}.trans
  
  while read line ; do
    [ -f $line ] || error_exit "Cannot find transcription file '$line'";
    cat $line | awk '{print}' 
  done < $tmpdir/${x}_phn.flist > $tmpdir/${x}_phn.trans
  paste $tmpdir/${x}_phn.uttids $tmpdir/${x}_phn.trans \
    | sort -k1,1 > ${x}.trans

  # Do normalization steps. 
  cat ${x}.trans | $local/timit_norm_trans.pl -i - -m $conf/phones.60-48-39.map -to 39 | sort > $x.text || exit 1;

  # Create wav.scp
  #awk '{printf("%s '$sph2pipe' -f wav %s |\n", $1, $2);}' < ${x}_sph.scp > ${x}_wavv.scp
	#sed -i 's/WAV/WAV/g' ${x}_wavv.scp
  cp ${x}_sph.scp ${x}_mv.scp

  # Make the utt2spk and spk2utt files.
#	if [ $x == "train" ]; then
    cut -f1,2 -d'_'  $x.uttids | paste -d' ' $x.uttids - > $x.utt2spk 
#  else
#    cat $x.uttids | paste -d' ' $x.uttids - > $x.utt2spk 
#  fi
  cat $x.utt2spk | $utils/utt2spk_to_spk2utt.pl > $x.spk2utt || exit 1;

  # Prepare gender mapping
  cat $x.spk2utt | awk '{print $1}' | perl -ane 'chop; m:^.:; $g = lc($&); print "$_ m\n";' > $x.spk2gender

  # Prepare STM file for sclite:
  #wav-to-duration scp:${x}_wavv.scp ark,t:${x}_dur.ark || exit 1
  cat ${x}_mv.scp | while read line1 line2; do echo "$line1 $((`cat $line2 | wc -l`/100)).$((`cat $line2 | wc -l`%100))"; done > ${x}_dur.ark
  
  awk -v dur=${x}_dur.ark \
  'BEGIN{ 
     while(getline < dur) { durH[$1]=$2; } 
     print ";; PHOEL \"O\" \"Overall\" \"Overall\"";
     print ";; PHOEL \"F\" \"Female\" \"Female speakers\"";
     print ";; PHOEL \"M\" \"Male\" \"Male speakers\""; 
   } 
   { wav=$1; spk=gensub(/_._.*/,"",1,wav); $1=""; ref=$0;
     gender=(substr(spk,0,1) == "f" ? "F" : "M");
     printf("%s 1 %s 0.0 %f <O,%s> %s\n", wav, spk, durH[wav], gender, ref);
   }
  ' ${x}.text >${x}.stm || exit 1
 
  # Create dummy GLM file for sclite:
  echo ';; empty.glm
  [FAKE]     =>  %HESITATION     / [ ] __ [ ] ;; hesitation token
  ' > ${x}.glm
done

echo "Data preparation succeeded"
