# In setup, *_ligand.mol2 and *_protein.pdb prepared from casf2016 can generate "*_complex.pdb", "*_ligand.mol2_1", "*_ligand.frcmod"
# For gbsa calculation, following files should be prepared

mkdir -p ../minimization
mkdir -p ../gbsa
cp run_tleap_min1.sh ../minimization
cp run_min2.sh ../minimization
cp run_gbsa.sh ../gbsa
cp amber18-gpu.bsub ../minimization
cp amber18-min2.bsub ../minimization
cp amber18-mmpbsa.bsub ../gbsa
#cp tleap.in ../minimization
#cp wat_min1.in ../minimization
#cp wat_min2.in ../minimization

source ~/.cshrc 2>/dev/null

function pdbsetup()
{
	pdbid=$(echo $1 | awk -F '_ligand' '{print $1}')

#protein
	if [ -f ${pdbid}_protein.pdb ]&&[ ! -e ${pdbid}_protein.pdb_1 ];then
		pdb4amber -i ${pdbid}_protein.pdb -s @H*,1H*,2H* -o ${pdbid}_protein-h.pdb > /dev/null
		sed '/HEADER/d;/COMPND/d;/SEQRES/d;/REMARK/d;/TER/d;/END/d;/H$/d' ${pdbid}_protein-h.pdb > ${pdbid}_protein.pdb_1
	fi
#ligand
	chg=$(awk '/<TRIPOS>ATOM/{f=1;next} /<TRIPOS>BOND/{f=0} f' $1 | awk '{sum += $NF};END {print sum}'); intchg=$(printf "%.0f\n" $chg)
	echo "### ${pdbid}_ligand.mol2 Charge is $intchg ###"
	obabel -imol2 ${pdbid}_ligand.mol2 -opdb -O ${pdbid}_ligand.tmp > /dev/null
	grep ATOM ${pdbid}_ligand.tmp > ${pdbid}_ligand.pdb

	antechamber -i ${pdbid}_ligand.pdb -fi pdb -o ${pdbid}_ligand.mol2_1 -fo mol2 -c bcc -nc $intchg -pf Y > /dev/null
	safe=20
	while [ $safe -gt 0 ];do
		if [ -e "${pdbid}_ligand.mol2_1" ];then
			parmchk2 -i ${pdbid}_ligand.mol2_1 -f mol2 -o ${pdbid}_ligand.frcmod -a Y
			break
		else
			echo -e "### ${pdbid}_ligand.mol2_1 is not complete### \nThe number of times remaining in the check: $safe"
			safe=$(($safe-1))
			sleep 1m
			continue
		fi
	done
	if [ $safe -eq 0 ];then mv $i backup;fi
#complex
	cat ${pdbid}_ligand.pdb ${pdbid}_protein.pdb_1 > ${pdbid}_complex.pdb
	sed -i '$a\END' ${pdbid}_complex.pdb
}
#pdbsetup $1 

#main
mkdir -p backup
for i in $(ls *_ligand.mol2);do
	if [ -e ${i%.*}.frcmod ];then
		echo "${i%.*}.frcmod already exists and next will be executed~~~~~~~~~~~~~~~~"
		continue
	else
		echo "${i} is running~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
		pdbsetup $i
	fi
done
