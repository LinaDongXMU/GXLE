path=./xscore
cd $path
> xscore.csv
for f in $(ls *_protein.pdb)
do
{
	i=$(basename $f)
	echo ${i:0:4}
        xscore -score ${i:0:4}_protein.pdb ${i:0:4}_ligand.mol2 > ${i:0:4}.tmp
        echo -n "${i:0:4} " >> xscore.csv
        grep Total xscore.log | awk '{$1="";print $0}' >> xscore.csv
        sed -i 's/\s\+/,/g' xscore.csv
        cp xscore.csv ../

}
done

