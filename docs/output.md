# ENA/localdatahub: Output

This document describes the process and the output produced by the pipeline.

<!-- TODO : Write this documentation describing your workflow's output -->

## Pipeline overview

The pipeline is built using [Nextflow](https://www.nextflow.io/) and download, analyse and submit data to ENA using the following steps:

* [Raw Reads Metadata Fetching](#RawReads_Metadata_Fetching) - retrieve the metadata for the raw read from ENA
* [Raw Reads Data Fetching](#RawReadsDataFetching) - download the raw read files from ENA based on the metadata
* [Data Analysis](#Data_Analysis)- analysis module/subworkflow, implemented by the user
* [Analysis Submission](#Analysis_Submission) - submitting the analyse data into ENA
## RawReads_Metadata_Fetching
The module fetch the metadata from the specified project or the tax id and deposit the data into a comma seperated text file. The file will contain three columns, run_accession, sample_accession and ftp link for each file. the file will be located by default in the `logs` directory. 

**Output directory: `logs/reads_metadata.txt`

## RawReads_Data_Fetching
The module input and parse the output of the metadata fetching step and download the raw read files using the ftp links specified in the metadata file. Before downloading the data, the script check the runs in the `ignore_list.txt` file and exclude these runs -if exist- from the downloading process. the script will output a summary comma seperated text file contains the downloaded metadata in three columns, run_accession, sample_accession and file name. the summary file will be located by default in the `logs` directory. Additionally, the script will create a similar temprorary file for each run in `logs/temp` directory.  

**Output directory:** 
- Summary file with all the downloaded data: `logs/fetchedFiles_log.txt`
- Temprorary file for each run : `logs/temp/fetchedFiles_temp.txt`

## Data_Analysis
This is a data analysis module/subworkflow implemented by the user. it should be able to accept the comma seperated format output from the previous step and output a comma seperated format with at least three columns, run_accession, sample_accession and analysed_file name including the *relative path where the file is deposited*. 

*Note: to be able to plug this module/workflow into the template, you should be able to parse the output of the previous step, analyse the data and output the results into the next step per run.* 


**The output directory of this step is determined by the user**

## Analysis_Submission
This module uses the output of the analysis step in a comma seperated format, the output will be parsed and run_accession, sample_accession and the analysis file name ( the relative path should be included, for example `analysis/file.fasta`) will be retrieved.
The module will output a submission log and metadata xmls in the `logs` directory and add the sucessfully submitted runs into the `ignore_list.txt` file. 
 

**Output directory:** 
- log files: `logs/successful_submissions.txt`
- metadata xml file: `logs/*.xml`

