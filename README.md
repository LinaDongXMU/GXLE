# Prediction of Binding Free Energy of Protein–Ligand Complexes with a Hybrid Molecular Mechanics/Generalized Born Surface Area and Machine Learning Method
GXLE is a a hybrid molecular mechanics/generalized born surface area (MM/GBSA) and machine learning methond to predict the binding free energy of protein−ligand complexes。


More information are publish in the paper.(https://pubs.acs.org/doi/10.1021/acsomega.1c04996)

Dong, L.; Qu, X.; Zhao, Y.; Wang, B., Prediction of Binding Free Energy of Protein–Ligand Complexes with a Hybrid Molecular Mechanics/Generalized Born Surface Area and Machine Learning Method. ACS Omega. 2021, 6, 32938–47.

![image](https://github.com/LinaDongXMU/GXLE/blob/main/TOC.png)
---------------------------------------------------------------------------------------------------------------------------------------------

This is an instruction for users.

After the requirements are met, to apply our model and parameters, you need to

---------------------------------------------------------------------------------------------------------------------------------------------

1 copy the file named application to your service

2 open the file named application

3 put your data(*_protein.pdb and *_ligand.mol2) in the file named data

4 sh GXLE.sh

5 then the results.csv will show in the file named application

6 open the results.csv to see the score

---------------------------------------------------------------------------------------------------------------------------------------------

See  the file named examples for the whole files process document

---------------------------------------------------------------------------------------------------------------------------------------------
See training set, validation set and testset in trainingset-gxl.csv, validation-gxl.csv and test-gxl.csv
