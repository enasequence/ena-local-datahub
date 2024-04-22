#!/usr/bin/env nextflow

nextflow.enable.dsl=2 

process ENA_RAWREADS_FETCH {
	tag "Downloading: $run_id"                  
	label 'default'                
	//publishDir "$readFiles_output", mode: 'move' 

    input:
        val url
        val run_id
        val sample_id
        val fileType
        path readFiles_output
        path metadata_output
        path ignore_list

    output:
        //path "$readFiles_output/*.${fileType}*", arity: "0..*", emit: files  //"arity" is not compatible with older versions of nextflow < 23.10.1.5891
        path "$metadata_output/temp/fetchedFiles_temp.txt", emit: metadata_logs, optional: true


    script:
        """
        fetchReads.py -url '$url' -r $run_id -s $sample_id -ft $fileType -o $readFiles_output -log $metadata_output -i $ignore_list 
        """
}
