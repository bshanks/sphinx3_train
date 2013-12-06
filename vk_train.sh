#!/bin/sh

# usage: vk_train.sh ../wsj_all_cont_3no_4000_32/

acoustic_model=$1
bw_args="-feat s3_1x39  -cmn current -agc none -timing no"

a=`
  a=;
  cat training_set_list | 
    while read set_name; do 
      echo -n \ training_sets/$set_name.listoffiles; 
    done; 
    echo $a`
cat $a > mytrain.listoffiles

a=`
  a=;
  cat training_set_list | 
    while read set_name; do 
      echo -n \ training_sets/$set_name.transcription;
    done; 
    echo $a`
cat $a > mytrain.transcription

a=`
  a=;
  cat dictionary_list | 
    while read set_name; do 
      echo -n \ $set_name;
    done; 
    echo $a`
cat $a > mytrain.dic_tmp


sort -u -k 1,1 mytrain.dic_tmp > mytrain.dic
stripDict.pl mytrain.dic

bw -hmmdir $acoustic_model -ts2cbfn .cont. $bw_args  -dictfn mytrain.dic -fdictfn filler_dict.filler -ctlfn mytrain.listoffiles -lsnfn mytrain.transcription -accumdir .

mllr_solve -meanfn $acoustic_model/means -varfn $acoustic_model/variances -outmllrfn mllr_matrix -accumdir .
