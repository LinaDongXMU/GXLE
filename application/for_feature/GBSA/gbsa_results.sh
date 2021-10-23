cd ./gbsa
> final_gbsa.dat
for i in $(ls *_FINAL_RESULTS_MMPBSA.dat);do
	awk 'NR==90, NR==93 {printf "%15s\n", $1}' $i | paste -s | sed 's/^/0000/' > final1.tmp
	awk 'NR==90, NR==93 {printf "%15.4f\n",$2}' $i | paste -s | sed 's/^/'${i:0:4}'/'> final2.tmp
	cat final1.tmp final2.tmp >> final_gbsa.dat
done
cat final_gbsa.dat | sort -u > final_gbsa.csv

sed -i '1 s/^0000/name/' final_gbsa.csv
sed -i 's/\s\+/,/g' final_gbsa.csv
cp final_gbsa.csv ..
