# PETscans
The is the source code for the quality control check for PiB PET scans at the Waisman center. 
The quality control check consisted of three main parts: 1. successful conversion of dicom to nifti while saving dicom metadata information that was lost into a nicely printed html file.`wc_dicom2nii.m` 2. Mainting spatial orientation of dicom image when viewed an image viewer such as Amide, `wc_dicom2origin.m`. 3. check for motion in dynamic PET series from a single study, `wc_motion_corr_4D.m`. 4. Defining normal movement from many PET studies, `wc_def_norm_movement.m`. 5. 1. Sorting metadata produced by unique dicom series,`wc_dicom_petct_sorter4_0.m` (note this function is error prone.)

These quality checks are meant to flag possible errors that come from the massive throughput of PET data, not correct any errors in the files.

To run all of these quality metrics run `wc_master_qc.m` and specify flages in the `opts` structure. 
A detailed description of functions is found in `manual1_1.pdf` and source code comments. 

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
