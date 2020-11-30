# PETscans

The quality control check consisted of three main parts: 1. sorting metadata produced by unique dicom series, 2. successful conversion of dicom to nifti while saving dicom metadata information that was lost into a nicely printed html file. 3. check for motion in dynamic PET series from a single study. These quality checks are meant to flag possible errors that come from the massive throughput of PET data, not correct any errors in the files.

## Manual 
Read manual1_1.pdf for detailed descriptions of program function and hierarchy 

## Environment

Requirements: 
- Download SPM12
- Unix Operating System
- MATLAB Software

## Functions 
`wc_*` : functions that have been made at the waisman center 

`wc_master_qc.m` : master script to run if you want to perform quality checks across dicom studies

`*.mat` files: contain reference information for data that is used across function runs. Make sure to define error_path.mat before running. 

Functions downloaded from internet: `cell2csv.m`, `print2html.m`, `NestedStruct2table.m`
