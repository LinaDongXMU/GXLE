#run_min2
source ~/.bashrc
cd ../minimization
cat > wat_min2.in << EOF
initial minimisation whole system
 &cntrl
        imin   = 1,
        maxcyc = 30000,
        ncyc   = 5000,
        ntb    = 1,
        ntr    = 0,
        cut    = 15
 /
EOF

function tretleap()
{
pdbid=$1

sed -i "1c\$AMBERHOME/bin/pmemd.cuda -O -i wat_min2.in -o ${pdbid}_wat_min2.log -c ${pdbid}_wat_min1.rst -p ${pdbid}_solv.prmtop -r ${pdbid}_wat_min2.rst -ref ${pdbid}_wat_min1.rst" amber18-min2.sh
}

function bjobmin()
{
	while true;do
	  sh amber18-min2.sh
	done
}

for i in $(ls *_wat_min1.rst);do
	name=$(echo ${i%.*} | awk -F '_wat_min1' '{print $1}')
	if [ -e ${name}_wat_min2.rst ];then
		continue
	else
		echo "$i is running~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
		tretleap $name
		while true;do
			if [ -e amber18-min2.sh ] && [ -e ${name}_solv.prmtop ]  && [ -e wat_min2.in ];then
				echo "$i will be submited~~~~~~~~~~~~~~~~~~~~"
				bjobmin
				break
			else
				echo "The lack of -in or -prmtop ~~~~~~~~~~~~~~~~~~~~~~~~~"
				sleep 1
				continue
			fi
		done
	fi
done
