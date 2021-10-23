#!/bin/bash

function monitor(){
job_num=$(bjobs | grep AMber |wc -l)
while [ $job_num -gt 0 ];do
	pend_num=$(bjobs | grep AMber | grep PEND |wc -l)
	job_num=$(bjobs | grep AMber |wc -l)
	if [ $pend_num -gt 0 ];then
		for ((i=600; i>0; i--));do
			sleep 1 
			wait
		done
	else
		sleep 1m
	fi
done
}

cd ./for_feature
mkdir xscore
mkdir ligand
cd ../data
cp *_protein.pdb ../for_feature/GBSA/setup
cp *_ligand.mol2 ../for_feature/GBSA/setup
cp *_protein.pdb ../for_feature/xscore
cp *_ligand.mol2 ../for_feature/xscore
cp *_ligand.mol2 ../for_feature/ligand

cd ../for_feature/GBSA/setup
sh main-setup.sh
sh run_tleap_min1.sh
monitor
sh run_min2.sh
monitor
sh run_gbsa.sh

cd ..
sh gbsa_results.sh
cp final_gbsa.csv ..
cd ..
sh xscore.sh
sh ligand.sh
python combine_feature.py
cp test.csv ../for_model
cd ../for_model
python GXLE.py
cp results.csv ..
