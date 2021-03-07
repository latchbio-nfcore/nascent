////////////////////////////////////////////////////
/* --         LOCAL PARAMETER VALUES           -- */
////////////////////////////////////////////////////

params.summary_params = [:]

////////////////////////////////////////////////////
/* --          VALIDATE INPUTS                 -- */
////////////////////////////////////////////////////

// TODO nf-core: Add all file path parameters for the pipeline to the list below
// Check input path parameters to see if they exist
checkPathParamList = [ params.input, params.multiqc_config, params.fasta ]
for (param in checkPathParamList) { if (param) { file(param, checkIfExists: true) } }

// Check mandatory parameters
if (params.input) { ch_input = file(params.input) } else { exit 1, 'Input samplesheet not specified!' }
if (params.fasta) { ch_fasta = file(params.fasta) } else { exit 1, 'Genome fasta file not specified!' }

// Check alignment parameters
def prepareToolIndices  = []

////////////////////////////////////////////////////
/* --          CONFIG FILES                    -- */
////////////////////////////////////////////////////

ch_multiqc_config        = file("$projectDir/assets/multiqc_config.yaml", checkIfExists: true)
ch_multiqc_custom_config = params.multiqc_config ? Channel.fromPath(params.multiqc_config) : Channel.empty()

////////////////////////////////////////////////////
/* --       IMPORT MODULES / SUBWORKFLOWS      -- */
////////////////////////////////////////////////////

// Don't overwrite global params.modules, create a copy instead and use that within the main script.
def modules = params.modules.clone()

def publish_genome_options = params.save_reference ? [publish_dir: 'genome']       : [publish_files: false]
def publish_index_options  = params.save_reference ? [publish_dir: 'genome/index'] : [publish_files: false]

def multiqc_options   = modules['multiqc']
multiqc_options.args += params.multiqc_title ? " --title \"$params.multiqc_title\"" : ''

// Local: Modules
include { GET_SOFTWARE_VERSIONS } from './modules/local/process/get_software_versions' addParams( options: [publish_files : ['csv':'']] )

/*
 * SUBWORKFLOW: Consisting of a mix of local and nf-core/modules
 */
def gffread_options         = modules['gffread']
if (!params.save_reference) { gffread_options['publish_files'] = false }

def bwa_align_options            = modules['bwa_align']
// TODO
// bwa_align_options.args          += params.save_unaligned ? " --outReadsUnmapped Fastx" : ''
// if (params.save_align_intermeds)  { bwa_align_options.publish_files.put('bam','') }
// if (params.save_unaligned)        { bwa_align_options.publish_files.put('fastq.gz','unmapped') }

def samtools_sort_options = modules['samtools_sort']
// TODO
// if (['bwa'].contains(params.aligner)) {
//     if (params.save_align_intermeds || (!params.with_umi && params.skip_markduplicates)) {
//         samtools_sort_options.publish_files.put('bam','')
//         samtools_sort_options.publish_files.put('bai','')
//     }
// } else {
//     if (params.save_align_intermeds || params.skip_markduplicates) {
//         samtools_sort_options.publish_files.put('bam','')
//         samtools_sort_options.publish_files.put('bai','')
//     }
// }

// Local: Sub-workflows
include { INPUT_CHECK           } from './modules/local/subworkflow/input_check'       addParams( options: [:]                          )
include { PREPARE_GENOME        } from './modules/local/subworkflow/prepare_genome'    addParams( genome_options: publish_genome_options, index_options: publish_index_options, gffread_options: gffread_options )
include { ALIGN_BWA             } from './modules/local/subworkflow/align_bwa'         addParams( align_options: bwa_align_options, samtools_options: samtools_sort_options )
include { GROHMM                } from './modules/local/subworkflow/grohmm'            addParams( options: [:]                          )
// nf-core/modules: Modules
include { FASTQC                } from './modules/nf-core/software/fastqc/main'        addParams( options: modules['fastqc']            )
include { MULTIQC               } from './modules/nf-core/software/multiqc/main'       addParams( options: multiqc_options              )

////////////////////////////////////////////////////
/* --           RUN MAIN WORKFLOW              -- */
////////////////////////////////////////////////////

// Info required for completion email and summary
def multiqc_report = []

workflow GROSEQ {
    /*
     * SUBWORKFLOW: Uncompress and prepare reference genome files
     */
    PREPARE_GENOME (
        prepareToolIndices
    )
    ch_software_versions = Channel.empty()
    ch_software_versions = ch_software_versions.mix(PREPARE_GENOME.out.gffread_version.ifEmpty(null))

    /*
     * SUBWORKFLOW: Read in samplesheet, validate and stage input files
     */
    INPUT_CHECK ( 
        ch_input
    )
    /*
     * MODULE: Run FastQC
     */
    FASTQC (
        INPUT_CHECK.out.reads
    )
    ch_software_versions = ch_software_versions.mix(FASTQC.out.version.first().ifEmpty(null))
    

    /*
     * SUBWORKFLOW: Alignment with BWA
     */
    ch_genome_bam                 = Channel.empty()
    ch_genome_bai                 = Channel.empty()
    ch_samtools_stats             = Channel.empty()
    ch_samtools_flagstat          = Channel.empty()
    ch_samtools_idxstats          = Channel.empty()
    ch_star_multiqc               = Channel.empty()
    ch_aligner_pca_multiqc        = Channel.empty()
    ch_aligner_clustering_multiqc = Channel.empty()
    ALIGN_BWA(
        INPUT_CHECK.out.reads,
        PREPARE_GENOME.out.bwa_index,
        PREPARE_GENOME.out.gtf
    )
    ch_genome_bam        = ALIGN_BWA.out.bam
    ch_genome_bai        = ALIGN_BWA.out.bai
    ch_samtools_stats    = ALIGN_BWA.out.stats
    ch_samtools_flagstat = ALIGN_BWA.out.flagstat
    ch_samtools_idxstats = ALIGN_BWA.out.idxstats
    ch_software_versions = ch_software_versions.mix(ALIGN_BWA.out.bwa_version.first().ifEmpty(null))
    ch_software_versions = ch_software_versions.mix(ALIGN_BWA.out.samtools_version.first().ifEmpty(null))


    /*
     * SUBWORKFLOW: Transcript indetification with GROHMM
     */
    // GROHMM ()

    /*
     * MODULE: Pipeline reporting
     */
    GET_SOFTWARE_VERSIONS ( 
        ch_software_versions.map { it }.collect()
    )

    /*
     * MultiQC
     */  
    if (!params.skip_multiqc) {
        workflow_summary    = Schema.params_summary_multiqc(workflow, params.summary_params)
        ch_workflow_summary = Channel.value(workflow_summary)

        ch_multiqc_files = Channel.empty()
        ch_multiqc_files = ch_multiqc_files.mix(Channel.from(ch_multiqc_config))
        ch_multiqc_files = ch_multiqc_files.mix(ch_multiqc_custom_config.collect().ifEmpty([]))
        ch_multiqc_files = ch_multiqc_files.mix(ch_workflow_summary.collectFile(name: 'workflow_summary_mqc.yaml'))
        ch_multiqc_files = ch_multiqc_files.mix(GET_SOFTWARE_VERSIONS.out.yaml.collect())
        ch_multiqc_files = ch_multiqc_files.mix(FASTQC.out.zip.collect{it[1]}.ifEmpty([]))
        
        MULTIQC (
            ch_multiqc_files.collect()
        )
        multiqc_report       = MULTIQC.out.report.toList()
        ch_software_versions = ch_software_versions.mix(MULTIQC.out.version.ifEmpty(null))
    }
}

////////////////////////////////////////////////////
/* --              COMPLETION EMAIL            -- */
////////////////////////////////////////////////////

workflow.onComplete {
    Completion.email(workflow, params, params.summary_params, projectDir, log, multiqc_report)
    Completion.summary(workflow, params, log)
}

////////////////////////////////////////////////////
/* --                  THE END                 -- */
////////////////////////////////////////////////////
