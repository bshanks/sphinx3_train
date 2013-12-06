#/bin/sh

# example usage: record_training_set.sh my_training_set_name /dev/dsp1

name=$1
adcin=$2
#PATH_TO_DIC=.
training_directory_path=training_sets
sphinx_fe_args='-feat s3_1x39'

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

perl -e 'undef $/; $_=<>; print uc;' mytrain.dic > mytrain.dic2
mv -f mytrain.dic2 mytrain.dic

#perl -e 'undef $/; $_=<>; print uc;' $name.txt > $name.txt2
#mv -f $name.txt2 $name.txt

echo $'<s> SIL\n</s> SIL\n<sil> SIL' >  filler_dict.filler


echo $name >> training_set_list

mkdir -p $training_directory_path
#mv $name.txt $training_directory_path
cd $training_directory_path

perl -e '$i++; $i_print = sprintf("%.4d", $i); chop; if (! /[<>]/) {print "<s> $_ <\/s> ('$name'_$i_print)\n"}' -n ../$name.txt|less  > $name.transcription_perset

perl -e "s/[^a-zA-Z'\''_0-9\- \n<>()]//g;" -pi $name.transcription_perset


rm -f $name.transcription
touch $name.transcription
sets=`seq 1 2`; 
for set in $sets; 
  do set_print=`printf $name_%.4d $set`
  perl -e 's/(.*) \((.*)\)/$1 (set_'$set_print'_$2)/;' -p $name.transcription_perset >> $name.transcription
done

# to begin recording in the middle of the training set, change "begin"
begin=1;
sets=`seq 1 2`; 
for set in $sets; 

do set_print=`printf $name_%.4d $set`
mkdir ${name}_set_${set_print}; cd ${name}_set_${set_print};
end=`wc -l ../../$name.txt  | cut -f1 -d ' '`;

for i in `seq $begin $end`; 
do fn=`printf $name_%.4d $i`; echo $i; head -n $i ../../$name.txt | tail -n 1 |  perl -ane 'undef $/; print; open(FH, "../../mytrain.dic"); $f = <FH>; foreach $w (@F)  {$w =~ s/[^a-zA-Z'\''_0-9\-]//g; $uw = uc($w); $f2 = $f; $f2 =~ s/^(?!$uw\b(?=(\s|\())).*\n//mg; print $f2;}'; 
read; 
rec -d $adcin -s w -r 16000 $fn.raw; 
echo; 
done; cd ..; 
done

#play -f s -t raw -r 16000 -s w  $name_set_0002/$name_0001.raw 

begin=1;
end=`wc -l ../$name.txt  | cut -f1 -d ' '`;
sets=`seq 1 2`; for set in $sets; do for i in `seq $begin $end`; do print_set=`printf "%.4d" $set`; print_i=`printf "%.4d" $i`; echo set_${print_set}_${name}_${print_i}; done; done  > $name.listoffiles

cd ..

for set in $sets; 
  do set_print=`printf $name_%.4d $set`
  for f in $training_directory_path/${name}_set_${set_print}/*; do ln -s $f set_${set_print}_${name}_`basename $f`; done
done  


sphinx_fe -samprate 16000 -c training_sets/$name.listoffiles -di . -do . -ei raw -eo mfc -raw yes $sphinx_fe_args

for set in $sets; 
  do set_print=`printf $name_%.4d $set`
  for f in $training_directory_path/${name}_set_${set_print}/*; do rm set_${set_print}_${name}_`basename $f`; done
done  
