// See the NOTICE file distributed with this work for additional information
// regarding copyright ownership.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
nextflow.enable.dsl=2

//default params
params.help = false

// mandatory params
params.submit_project_id = null
params.fileType = null
params.analysis_type = null
params.webin_username = null
params.webin_password = null


// Print usage
def helpMessage() {
  log.info """
        Usage:
        The typical command for running the pipeline is as follows:
        nextflow run main.nf --metadata_project_id <PRJ#####> --submit_project_id <PRJ#####> --tax_id <####> --fileType <fastq/bam>  --analysis_type <analysis type> --webin_username <Webin-####> --webin_password <webin password> --asynchronous <true/false> --test <true/false>

        Mandatory arguments:
        --submit_project_id             Analysis Project accession number ( where the analysis will be submitted to) 
        --metadata_project_id or tax_id Raw read project accession number or the raw reads Tax Id (one parameter should be used at least)
        --fileType                      The downloaded file type (fastq or bam)
        --analysis_type                 The analysis type ('PATHOGEN_ANALYSIS', 'COVID19_CONSENSUS', 'COVID19_FILTERED_VCF', 'PHYLOGENY_ANALYSIS', 'FILTERED_VARIATION', 'SEQUENCE_CONSENSUS')
        --webin_username                The webin account to submit the analysis  
        --webin_password                The password for the webin account

        Optional arguments:
        --help                         This usage statement.
        --asynchronous                 Using the asynchronous option to submit the analysis (true/false), Default false 
        --test                         Using the test server to submit the analysis (true/false) Default true
        --metadata_output              The directory for the logs, Default ./logs
        --readFiles_output             The directory name for the reads output files, default ./rawReadsFiles
        --analysis_logs_output         The directory name for the analysis output logs, default ./logs
        --analysisConfig_location      The directory for the analysis config file, default ./conf
        --ignore_list                  Name of the ignore list file that contains the list of the runs to be excluded from fetching, default ./ignore_list.txt
        """
}

// Show help message
if (params.help) {
    helpMessage()
    exit 0
}

assert params.submit_project_id, "Parameter 'submit_project_id' is not specified"
assert params.fileType, "Parameter 'fileType' is not specified"
assert params.metadata_output, "Parameter 'metadata_output' is not specified"
assert params.readFiles_output, "Parameter 'readFiles_output' is not specified"
assert params.analysis_logs_output, "Parameter 'analysis_logs_output' is not specified"
assert params.analysis_type.toUpperCase() == 'PATHOGEN_ANALYSIS' || params.analysis_type.toUpperCase() == 'COVID19_CONSENSUS' 
|| params.analysis_type.toUpperCase() == 'COVID19_FILTERED_VCF' || params.analysis_type.toUpperCase() == 'PHYLOGENY_ANALYSIS' 
|| params.analysis_type.toUpperCase() == 'FILTERED_VARIATION' || params.analysis_type.toUpperCase() == 'SEQUENCE_CONSENSUS', 
"Parameter 'analysis_type' is not specified, choose from 'PATHOGEN_ANALYSIS', 'COVID19_CONSENSUS', 'COVID19_FILTERED_VCF', 'PHYLOGENY_ANALYSIS', 'FILTERED_VARIATION', 'SEQUENCE_CONSENSUS'"
assert params.webin_username, "Parameter 'analysis_username' is not specified"
assert params.webin_password, "Parameter 'analysis_password' is not specified"
assert params.analysisConfig_location, "Parameter 'analysisConfig_location' is not specified"
assert params.ignore_list, "Parameter 'ignore_list' is not specified"
assert params.test.toString().toLowerCase() == 'true' || params.toString().asynchronous.toLowerCase() == 'false',  "Parameter 'test' is invalid, please specify one of the options(true or false)"
assert params.asynchronous.toString().toLowerCase() == 'true' || params.toString().asynchronous.toLowerCase() == 'false',  "Parameter 'asynchronous' is invalid, please specify one of the options(true or false)"



// Import modules/subworkflows
include { ENA_METADATA_FETCH } from './modules/enaMetadataFetch.nf'
include { ENA_RAWREADS_FETCH } from './modules/enaFetch.nf'
include { ENA_ANALYSIS_SUBMIT } from './modules/enaSubmit.nf'

workflow localDataHub_workflow {
    take:
        metadata_project_id
        submit_project_id
        tax_id
        fileType
        metadata_output
        readFiles_output
        ignore_list
        analysis_logs_output
        analysis_type
        webin_username
        webin_password
        asynchronous
        test
        analysisConfig_location
        


    main:

        // Execute the metadata fetching process and produce a metadata file with URLs
        metadata_output_ch = ENA_METADATA_FETCH(metadata_project_id, tax_id, fileType, "$PWD/${metadata_output}").each { file -> file.text.readLines()}
        // Parse the metadata file and retrieve the runs along with their corresponding samples and URLs
        metadata_content = metadata_output_ch .splitCsv( header: ['run_accession','sample_accession', 'url'], skip: 1 ).multiMap { it ->
        run_acc: it['run_accession']
        sample_acc: it['sample_accession']
        url: it['url']
        }
        .set{metadata}

        // Execute the file fetching process and produce a metadata file with fetched file names
        rawreads_output_ch = ENA_RAWREADS_FETCH(metadata.url, metadata.run_acc, metadata.sample_acc, fileType, "$PWD/${readFiles_output}","$PWD/${metadata_output}","$PWD/${ignore_list}")

        // Parse the metadata file and retrieve the runs along with their corresponding samples and fetched file names
        fetched_metadata_content = rawreads_output_ch.metadata_logs .splitCsv( header: ['run_accession','sample_accession', 'file_name'], skip: 1 ).multiMap { it ->
        run_acc: it['run_accession']
        sample_acc: it['sample_accession']
        file_name: it['file_name']
        }
        .set{fetched_metadata}  



        /*OPTIONAL: you can retrive the run accession, sample accession and the file name and inject them in the next process by refrencing the following: 
         run accession: fetched_metadata.run_acc
         sample accession: fetched_metadata.sample_acc
         file name: fetched_metadata.file_name
        */
        
        /* EXAMPLE OF THE USER SUB-WORKFLOW : user_output_ch = user_process (fetched_metadata.run_acc, fetched_metadata.sample_acc, fetched_metadata.file_name, otherInputParams)
        // Parse the metadata file and retrieve the runs along with their corresponding samples and analysed file names(should be including the relative path)
        analysed_metadata_content = user_output_ch .splitCsv( header: ['run_accession','sample_accession', 'file_name'], skip: 1 ).multiMap { it ->
        run_acc: it['run_accession']
        sample_acc: it['sample_accession']
        analysis_file: it['analysis_file']
        }
        .set{analysed_metadata}  

        **************************************
        The parameters retrieved from the user channel's output can be used as inputs in the submission channel, as follows:
        run accession: analysed_metadata.run_acc
        sample accession: analysed_metadata.sample_acc
        analysis_file: analysed_metadata.file_name

        */


       // Execute the analysed file submitting process
        /*
        in the process below the parameters values for run_accession (analysed_metadata.run_acc), sample accession (analysed_metadata.sample_acc) and analysed file names (analysed_metadata.file_name)
         needs to be considered and changed according to the user sub-workflow/module(s)
                 */

        ena_analysis_submit_ch = ENA_ANALYSIS_SUBMIT(submit_project_id, analysed_metadata.sample_acc, analysed_metadata.run_acc, "$PWD/${analysed_metadata.file_name}",
         analysis_type, webin_username, webin_password, asynchronous, test, "$PWD/${analysis_logs_output}", "$PWD/${analysisConfig_location}", "$PWD/${ignore_list}")



}


// Run main workflow
workflow {
    main:
    localDataHub_workflow(params.metadata_project_id, params.submit_project_id, params.tax_id, params.fileType, params.metadata_output,
    params.readFiles_output, params.ignore_list, params.analysis_logs_output, params.analysis_type, params.webin_username,
    params.webin_password, params.asynchronous, params.test, params.analysisConfig_location)
    
}