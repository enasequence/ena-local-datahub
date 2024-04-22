# ENA/localdatahub: Usage

## Table of contents

* [Table of contents](#table-of-contents)
* [Introduction](#introduction)
* [Running the pipeline](#running-the-pipeline)
* [Main arguments](#main-arguments)
  * [`-profile`](#-profile)
  * [`--metadata_project_id & --tax_id`](#--metadata_project_id&--tax_id)
  * [`--fileType`](#--fileType)
  * [`--readFiles_output`](#--readFiles_output)
  * [`--metadata_output`](#--metadata_output)
  * [`--submit_project_id`](#--submit_project_id)
  * [`--analysis_type`](#--analysis_type)
  * [`--webin_username  & --webin_password`](#--webin_username&--webin_password)
  * [`--analysis_logs_output`](#--analysis_logs_output)
  * [`--analysisConfig_location`](#--analysisConfig_location)
  * [`--ignore_list`](#--ignore_list)
  * [`--asynchronous`](#--asynchronous)
  * [`--test`](#--test)
* [Job resources](#job-resources)
  * [Automatic resubmission](#automatic-resubmission)
  * [Custom resource requests](#custom-resource-requests)
* [AWS Batch specific parameters](#aws-batch-specific-parameters)
  * [`--awsqueue`](#--awsqueue)
  * [`--awsregion`](#--awsregion)
  * [`--awscli`](#--awscli)
* [Other command line parameters](#other-command-line-parameters)
  * [`--outdir`](#--outdir)
  * [`-resume`](#-resume)
  * [`-c`](#-c)
  * [`--max_memory`](#--max_memory)
  * [`--max_time`](#--max_time)
  * [`--max_cpus`](#--max_cpus)

## Introduction

Nextflow handles job submissions on SLURM or other environments, and supervises running the jobs. Thus the Nextflow process must run until the pipeline is finished. We recommend that you put the process running in the background through `screen` / `tmux` or similar tool. Alternatively you can run nextflow within a cluster job submitted your job scheduler.

It is recommended to limit the Nextflow Java virtual machines memory. We recommend adding the following line to your environment (typically in `~/.bashrc` or `~./bash_profile`):

```bash
NXF_OPTS='-Xms1g -Xmx4g'
```

<!-- TODO nf-core: Document required command line parameters to run the pipeline-->

## Running the pipeline
Before Running the pipeline make sure to complete the following analysis metadata parameters for submission in the `./conf/config.yml` file:
```
CENTER_NAME: <The name of the Institution that analysed and submitted the data>
ALIAS: <Analysis Alias>
TITLE: <Analysis Title> 
DESCRIPTION: <Analysis Description>
PIPELINE_NAME: <Pipeline title>
PIPELINE_VERSION: <Pipeline Version>
SUBMISSION_TOOL: Local DataHub
SUBMISSION_TOOL_VERSION: Local DataHub Version
ACTION: add
```
The typical command for running the pipeline is as follows:

```bash
nextflow run main.nf --metadata_project_id <PRJ#####> --submit_project_id <PRJ#####> --tax_id <####> --fileType <fastq/bam>  --analysis_type <analysis type> --webin_username <Webin-####> --webin_password <webin password> --asynchronous <true/false> --test <true/false>  -with-docker [docker image] or -with-singularity [docker image]
```

This will launch the pipeline with the `docker` or `singularity` by using the following arguments:
- for Docker: `-with-docker [docker image]`
- for Singularity: `-with-singularity [docker image]` or `-with-singularity [singularity image]`

Conda can be used by adding the `--profile conda` arguments
*Note:* To avoid using all the above arguments, they can be included as a *params* in the `nextflow.config` file as following:
```
params {
  readFiles_output = 
  ignore_list = 
  asynchronous = 
  test = 
  metadata_project_id = 
  tax_id = 
  submit_project_id = 
  fileType = 
  analysis_type = 
  webin_username = 
  webin_password = 
```
*Note:*  to avoid using the container arguments you can add the image into the `nextflow.config` file as follows:
`process.container = '/path/to/containerImage'`

Note that the pipeline will create the following files in your working directory:

```bash
work            # Directory containing the nextflow working files
results         # pipeline running results (configurable, by modifying nextflow.config)
.nextflow_log   # Log file from Nextflow
rawReadsFiles   # Directory contains the downloaded raw reads (configurable, by modifying nextflow.config)
logs            # Directory contains the pipeline log files (configurable, by modifying nextflow.config)
ignore_list.txt # accession list for runs to be excluded from the pipeline (configurable, by modifying nextflow.config)
# Other nextflow hidden files, eg. history of pipeline runs and old logs.
```

## Main arguments

### `-profile`

Use this parameter to choose a configuration profile. Profiles can give configuration presets for different compute environments.

Several generic profiles are bundled with the pipeline which instruct the pipeline to use software packaged using different methods (Docker, Singularity, Conda) - see below.

> We highly recommend the use of Docker or Singularity containers for full pipeline reproducibility, however when this is not possible, Conda is also supported.

Note that multiple profiles can be loaded, for example: `-profile test,docker` - the order of arguments is important!
They are loaded in sequence, so later profiles can overwrite earlier profiles.

If `-profile` is not specified, the pipeline will run locally and expect all software to be installed and available on the `PATH`. This is _not_ recommended.

* `docker`
  * A generic configuration profile to be used with [Docker](http://docker.com/)
* `singularity`
  * A generic configuration profile to be used with [Singularity](http://singularity.lbl.gov/)
* `conda`
  * Please only use Conda as a last resort i.e. when it's not possible to run the pipeline with Docker or Singularity.
  * A generic configuration profile to be used with [Conda](https://conda.io/docs/)
  * Pulls most software from [Bioconda](https://bioconda.github.io/)


### `--metadata_project_id&--tax_id`

Use one or both of these parameters to specify the project and the tax_id of the raw data needs to be downloaded from ENA. For example:

```
--metadata_project_id PRJ#### --tax_id #####
```

Please note the following requirements:

1. The project id must be in the format of PRJ#####
2. The Tax Id must be compatible with [NCBI taxonomy](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi)

One of the above parameters *at least*  needs to be specified

### `--fileType`

Use this to specify the type of the raw files that will be downloaded, this is a mandatory parameter that only accept two options `bam` and `fastq` as a value. For example:

```bash
--fileType <fastq/bam>
```

### `--readFiles_output`

Use this parameter to indicate the output directory of the downloaded raw files, this is by default directed toward the `./rawReadsFiles` directory, however this configrable by changing its value in the `nextflow.config` file or by adding the relative path directly on the command line. 

```
#nextflow.config
params {
  readFiles_output = './rawReadsFiles'
  }
```
```
#command line
--readFiles_output ./rawReadsFiles
```
### `--metadata_output`

Use this parameter to indicate the log directory of the downloaded raw files metadata, this is by default directed toward the `./logs` directory, however this configrable by changing its value in the `nextflow.config` file or by adding the relative path directly on the command line. 

```
#nextflow.config
params {
  metadata_output = './logs'
  }
```
```
#command line
--metadata_output ./logs
```

### `--submit_project_id`

Use this parameter to indicate the project Id that you wish to submit the analysed files to, this is a mandatory parameter can be included in the command line directly or add it to the `nextflow.config` file
```
#nextflow.config
params {
  submit_project_id = <'PRJ####'>
  }
```
```
#command line
--submit_project_id <PRJ####>
```

### `--analysis_type`
This parameter is to declare the submitted analyses type, this is a mandatory parameter, only these options are supported: 
`'PATHOGEN_ANALYSIS', 'COVID19_CONSENSUS', 'COVID19_FILTERED_VCF', 'PHYLOGENY_ANALYSIS', 'FILTERED_VARIATION', 'SEQUENCE_CONSENSUS'`. This can be added as a `params` into the `nextflow.config` file or directly into the command line for example:

```
#nextflow.config
params {
  analysis_type = <'PATHOGEN_ANALYSIS'>
  }
```
```
#command line
--analysis_type <'PATHOGEN_ANALYSIS'>
```

### `--webin_username&--webin_password`
These are mandatory parameters for the submission webin account credentials. if you dont have a webin account please register through [webin submission portal](https://www.ebi.ac.uk/ena/submit/webin/login). This can be added as a `params` into the `nextflow.config` file or directly into the command line for example:

```
#nextflow.config
params {
  webin_username = <'webin-####'>
  webin_password = <'password'>
  }
```
```
#command line
--webin_username <webin-####> --webin_password <'password'>
```  

### `--analysis_logs_output`
Use this parameter to indicate the output directory of the analysis submission logs, this is by default directed toward the `./logs` directory, however this configrable by changing its value in the `nextflow.config` file or by adding the relative path directly on the command line. 

```
#nextflow.config
params {
  analysis_logs_output = './logs'
  }
```
```
#command line
--analysis_logs_output ./logs
```
### `--analysisConfig_location`
This parameter to indicate the directory where the analysis submission configration file `config.yml` reside this is by default directed toward the `./conf` directory, however, this configrable by changing its value in the `nextflow.config` file or by adding the relative path directly on the command line. 
```
#nextflow.config
params {
  analysisConfig_location = './conf'
  }
```
```
#command line
--analysisConfig_location ./conf
```
### `--ignore_list`
Ignore list is a list of run accessions that will be excluded from being downloaded and analysed. This parameter is used to locate the path of this list. The list will be extended while the pipeline is running to include all the run ids related to the analysis that have sucessfully been submitted. Additionally, the list can be modified manually or using a script provided by the user. By default the value of this parameter is `./ignore_list.txt`.  however, this configrable by changing its value in the `nextflow.config` file or by adding the relative path directly on the command line. 
```
#nextflow.config
params {
  ignore_list = './ignore_list.txt'
  }
```
```
#command line
--ignore_list ./ignore_list.txt
```

### `--asynchronous`
This parameter to specify usage of the asynchronous Webin API for analysis submissions. When a submission is made using the asynchronous endpoint, it enters a pending state in a queue of submissions. This submission is processed once it reaches the front of this queue. The asynchronous submission endpoint supports larger and a higher volume of submissions than the synchronous endpoint. The default value of this parameter is `false`. 

```
--asynchronous true
```

### `--test`
This parameter to specify usage of the test server for analysis submissions. The default value of this parameter is `true`. to submit on the production server you need to change the value to `false` 

```
--test false
```

## Job resources

### Automatic resubmission

Each step in the pipeline has a default set of requirements for number of CPUs, memory and time. For most of the steps in the pipeline, if the job exits with an error code of `143` (exceeded requested resources) it will automatically resubmit with higher requests (2 x original, then 3 x original). If it still fails after three times then the pipeline is stopped.

### Custom resource requests

Wherever process-specific requirements are set in the pipeline, the default value can be changed by creating a custom config file. See the files hosted at [`nf-core/configs`](https://github.com/nf-core/configs/tree/master/conf) for examples.

## AWS Batch specific parameters

Running the pipeline on AWS Batch requires a couple of specific parameters to be set according to your AWS Batch configuration. Please use [`-profile awsbatch`](https://github.com/nf-core/configs/blob/master/conf/awsbatch.config) and then specify all of the following parameters.

### `--awsqueue`

The JobQueue that you intend to use on AWS Batch.

### `--awsregion`

The AWS region in which to run your job. Default is set to `eu-west-1` but can be adjusted to your needs.

### `--awscli`

The [AWS CLI](https://www.nextflow.io/docs/latest/awscloud.html#aws-cli-installation) path in your custom AMI. Default: `/home/ec2-user/miniconda/bin/aws`.

Please make sure to also set the `-w/--work-dir` and `--outdir` parameters to a S3 storage bucket of your choice - you'll get an error message notifying you if you didn't.

## Other command line parameters

<!-- TODO: Describe any other command line flags here -->

### `--outdir`

The output directory where the results will be saved.


### `-resume`

Specify this when restarting a pipeline. Nextflow will used cached results from any pipeline steps where the inputs are the same, continuing from where it got to previously.

You can also supply a run name to resume a specific run: `-resume [run-name]`. Use the `nextflow log` command to show previous run names.

**NB:** Single hyphen (core Nextflow option)

### `-c`

Specify the path to a specific config file (this is a core NextFlow command).

**NB:** Single hyphen (core Nextflow option)

Note - you can use this to override pipeline defaults.

### `--max_memory`

Use to set a top-limit for the default memory requirement for each process.
Should be a string in the format integer-unit. eg. `--max_memory '8.GB'`

### `--max_time`

Use to set a top-limit for the default time requirement for each process.
Should be a string in the format integer-unit. eg. `--max_time '2.h'`

### `--max_cpus`

Use to set a top-limit for the default CPU requirement for each process.
Should be a string in the format integer-unit. eg. `--max_cpus 1`

