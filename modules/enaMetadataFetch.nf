#!/usr/bin/env nextflow

nextflow.enable.dsl=2 

process ENA_METADATA_FETCH {
	tag "ENA_RawReads_metadata_Fetch"                  
	label 'default'                
	//publishDir "$output", mode: 'move' 

    input:
        val project_id
        val tax_id
        val fileType
        path output

    output:
        path "$output/reads_metadata.txt", emit: metadata_list


    script:
    if (project_id != '' & tax_id != '') {
        """
        metadata_fetch.py -p $project_id -t $tax_id -ft $fileType -o $output
        """
     }
     else if (tax_id == '' ) {
        """
        metadata_fetch.py -p $project_id -ft $fileType -o $output
        """
     }
    else if (project_id == '' ) {
        """
        metadata_fetch.py -t $tax_id -ft $fileType -o $output
        """
     }
}
