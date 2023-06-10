# In minimization,tleap.in wat_min1.in wat_min2.in and amber18-gpu.sh should be prepared
# "*_complex.pdb", "*_ligand.mol2_1", "*_ligand.frcmod" prepared from setup can generate *_solv.inpcrd, *_solv.prmtop
source ~/.bashrc > /dev/null 2>/dev/null
cd ../minimization
cat > tleap.in << EOF
source oldff/leaprc.ff14SB
source leaprc.gaff2
LIA = loadmol2 2fvd_ligand.mol2_1
loadamberparams 2fvd_ligand.frcmod
loadamberparams frcmod.ions1lm_126_tip3p
loadamberparams frcmod.ions234lm_126_tip3p
mol = loadpdb 2fvd_complex.pdb
savepdb mol  2fvd_dry.pdb
saveamberparm mol 2fvd_dry.prmtop 2fvd_dry.inpcrd 
solvatebox mol TIP3PBOX 12.0
addions mol Na+ 0
addions mol Cl- 0
savepdb mol 2fvd_solv.pdb
saveamberparm mol 2fvd_solv.prmtop 2fvd_solv.inpcrd

quit
EOF

cat > wat_min1.in << EOF
initial minimisation solvent
 &cntrl
        imin   = 1,
        maxcyc = 30000,
        ncyc   = 5000,
        ntb    = 1,
        ntr    = 1,
        restraint_wt = 500,
        restraintmask = ':1-287',
        cut    = 15
 /
EOF

function tretleap()
{
pdbid=$1
unk=$(grep ATOM ${pdbid}_complex.pdb | grep -v WAT |head -n 1 | awk '{print $4}')
sed -i "3c $unk = loadmol2 ${pdbid}_ligand.mol2_1" tleap.in
sed -i "4c\loadamberparams ${pdbid}_ligand.frcmod" tleap.in
sed -i "7c\mol = loadpdb ${pdbid}_complex.pdb" tleap.in
sed -i "8c\savepdb mol  ${pdbid}_dry.pdb" tleap.in
sed -i "9c\saveamberparm mol ${pdbid}_dry.prmtop ${pdbid}_dry.inpcrd" tleap.in
sed -i "13c\savepdb mol ${pdbid}_solv.pdb" tleap.in
sed -i "14c\saveamberparm mol ${pdbid}_solv.prmtop ${pdbid}_solv.inpcrd" tleap.in
}

function trewatmin()
{
pdbid=$1
safe=5
while [ $safe -gt 0 ];do
	if [ -e ${pdbid}_dry.pdb ];then
		fin_num=$(grep ATOM ${pdbid}_dry.pdb | grep -v WAT |tail -n 1 | awk '{print $5}')
		break
	else
		echo -e "${pdbid} tleap is not completed~~~~~~\nThe number of times remaining in the check: $safe"
		safe=$(($safe-1))
		sleep 2
		continue
	fi
done
if [ $safe -eq 0 ];then mv $i backup;fi
sed -i "9c\        restraintmask = ':1-${fin_num}'," wat_min1.in
sed -i "1c\$AMBERHOME/bin/pmemd.cuda -O -i wat_min1.in -o ${pdbid}_wat_min1.log -c ${pdbid}_solv.inpcrd -p ${pdbid}_solv.prmtop -r ${pdbid}_wat_min1.rst -ref ${pdbid}_solv.inpcrd" amber18-gpu.sh
}

function bjobmin()
{
	while true;do
	  sh amber18-gpu.sh
	done
}

#main


cp ../setup/*_complex.pdb ../minimization
cp ../setup/*_ligand.mol2_1 ../minimization
cp ../setup/*_ligand.frcmod ../minimization

grep Cl *complex.pdb | grep CL | sed -i 's/CL/Cl/' *complex.pdb
grep Br *complex.pdb | grep BR | sed -i 's/BR/Br/' *complex.pdb
list=(CAS CSO LLP PCA PTR SEP TPO UNK);for err in ${list[*]};do sed -i '/'$err'/d' *complex.pdb;done

mkdir -p backup

for i in $(ls *_ligand.frcmod);do
	name=$(echo ${i%.*} | awk -F '_ligand' '{print $1}')
	if [ -e ${name}_wat_min1.rst ] || [ -e backup/$i ];then
		continue
	else
		echo "$i is running~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
		tretleap $name 
		tleap -s -f tleap.in > /dev/null
		trewatmin $name
		safe=5
		while [ $safe -gt 0 ];do
			if [ -e ${name}_solv.inpcrd ] && [ -e ${name}_solv.prmtop ] && [ -e tleap.in ] && [ -e wat_min1.in ];then
				echo "$i will be submited~~~~~~~~~~~~~~~~~~~~"
				bjobmin
				break
			else
				echo -e "The lack of -inpcrd, -prmtop or -in ~~~~~~~~~~\nThe number of times remaining in the check: $safe"
				safe=$(($safe-1))
				sleep 10
				continue
			fi
		done
		if [ $safe -eq 0 ];then mv $i backup;fi
	fi
done
