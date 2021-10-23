import csv

gbsa=open('./final_gbsa.csv')
gbsaReader=csv.reader(gbsa)
gbsaData=list(gbsaReader)
xscore=open('./xscore.csv')
xscoreReader=csv.reader(xscore)
xscoreData=list(xscoreReader)
ligand=open('./ligand.csv')
ligandReader=csv.reader(ligand)
ligandData=list(ligandReader)


add=open('./test.csv','w')
addWriter=csv.writer(add)

d=['Name','GBSA-Evdw','GBSA-Eele','GBSA-GGB','GBSA-GSA','VDW','HB','HP','HM','HS','RT','x-score','charge','C','N','O','H','F','P','S','Cl','Br','I','heavy atoms']
addWriter.writerow(d)

for i in gbsaData:
    a=i[0]
    for j in xscoreData:
        b=j[0]
        if a==b:
            c=i
            c=c+j[1:]
            for k in ligandData:
                x=k[0]
                if x==b:
                    c=c+k[1:]
                    addWriter.writerow(c)


gbsa.close()
xscore.close()
ligand.close()
add.close()