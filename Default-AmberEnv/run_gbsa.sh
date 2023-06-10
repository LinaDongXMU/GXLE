#run_gbsa
# mmpbsa.in 
source ~/.bashrc
cd ../gbsa
cat > mmpbsa.in <<EOF
Input file for running PB and GB
&general
  startframe=1, endframe=1, interval=1, verbose=1,
  debug_printlevel=1
  receptor_mask=':1-435', ligand_mask=':PGI'
##
  strip_mask=":Na+:Cl-:WAT"
#strip_mask=":Na+:Cl-:TIP:TIP3:WAT:CL:CIO:CS:IB:K:LI:MG:NA:RB"
##
#  entropy=1,
/
&gb
  igb=2, saltcon=0.00
/
#&pb
#  istrng=0.
#  radiopt=0,inp=1
#/
EOF
function tretleap()
{
pdbid=$1
fin_num=$(grep ATOM ${pdbid}_dry.pdb | grep -v WAT |tail -n 1 | awk '{print $5}')
unk=$(grep ATOM ${pdbid}_dry.pdb | grep -v WAT |head -n 1 | awk '{print $4}')
if [ ! -e ${pdbid}_dry.prmtop ] && [ ! -e ${pdbid}_ligand.prmtop ];then
ante-MMPBSA.py -p ${pdbid}_solv.prmtop -c ${pdbid}_dry.prmtop -r ${pdbid}_protein.prmtop -l ${pdbid}_ligand.prmtop -s ":WAT,Cl-,Na+" -n ":$unk" --radii=mbondi2> prmtop_progress.tmp #/dev/null
fi
sed -i "5c\  receptor_mask=':2-${fin_num}', ligand_mask=':$unk'" mmpbsa.in
sed -i "1c\$AMBERHOME/bin/MMPBSA.py -O -i mmpbsa.in -o ${pdbid}_FINAL_RESULTS_MMPBSA.dat -sp ${pdbid}_solv.prmtop -cp ${pdbid}_dry.prmtop -rp ${pdbid}_protein.prmtop -lp ${pdbid}_ligand.prmtop -y ${pdbid}_wat_min2.rst > ${pdbid}_progress.log" amber18-mmpbsa.sh
}

function bjobgbsa()
{
	while true;do
	  sh amber18-mmpbsa.sh
	done
}

#main
cp ../minimization/*_dry.pdb ../gbsa
cp ../minimization/*_wat_min2.rst ../gbsa
cp ../minimization/*_solv.prmtop ../gbsa

mkdir -p unfinished
for i in $(ls *_solv.prmtop);do
	name=$(echo ${i%.*} | awk -F '_solv' '{print $1}')
	if [ -e ${name}_FINAL_RESULTS_MMPBSA.dat ];then continue;fi
	echo "$i is running~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	tretleap $name
	safe=5
	while [ $safe -gt 0 ];do
		if [ -e amber18-mmpbsa.sh ] && [ -e ${name}_solv.prmtop ] && [ -e ${name}_dry.prmtop ] && [ -e ${name}_ligand.prmtop ] && [ -e mmpbsa.in ];then
			echo "$i will be submited~~~~~~~~~~~~~~~~~~~~"
			bjobgbsa
			break
		else
			echo "The lack of -in or -prmtop ~~~~~~~~~~~~~~~~~~~~~~~~~"
			sleep 20
			safe=$(($safe-1))
			continue
		fi
	done
#	if [ $safe -eq 0 ];then mv $i unfinished;fi
	safe=20
	while [ $safe -gt 0 ];do
		if [ -e ${name}_FINAL_RESULTS_MMPBSA.dat ];then
			break
		else
			echo -e "${name}_FINAL_RESULTS_MMPBSA.dat is not completed,waiting for a moment~~~~~~~~~~~\nThe number of times remaining in the check: $safe"
			sleep 1m
			safe=$(($safe-1))
			continue
		fi
	done
#	if [ $safe -eq 0 ];then mv $i unfinished;fi
done
