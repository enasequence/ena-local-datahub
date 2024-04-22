#!/usr/bin/env nextflow

nextflow.enable.dsl=2 

process ENA_ANALYSIS_SUBMIT {
	tag "Submitting $analysis_file"                  
	label 'default'                
	//publishDir "$output", mode: 'move' 

    input:
        val project_id
        val sample_list
        val run_list
        path analysis_file
        val analysis_type
        val analysis_username
        val analysis_password
        val asynchronous
        val test
        path output
        path analysisConfig_location
        path ignore_list

    output:
        path "$output/*.txt", emit: logs, optional: true


    script:
        def asynchronous = params.asynchronous?.toString()?.toLowerCase()
        def test = params.test?.toString()?.toLowerCase()
        

        if (asynchronous == 'true') {
        """
        analysis_submission.py -t $test -p $project_id -s $sample_list -r $run_list -f $analysis_file -a $analysis_type -au $analysis_username -ap $analysis_password -as $asynchronous -o $output -c $analysisConfig_location -i $ignore_list
        """
            
        }
        else {

        """
        analysis_submission.py -t $test -p $project_id -s $sample_list -r $run_list -f $analysis_file -a $analysis_type -au $analysis_username -ap $analysis_password  -o $output -c $analysisConfig_location -i $ignore_list
        """
        }
    
}
