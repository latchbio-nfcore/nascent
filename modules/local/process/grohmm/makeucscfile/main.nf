// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
def options    = initOptions(params.options)

def VERSION = '1.24'

process GROHMM_MAKEUCSCFILE {
    tag "$meta.id"
    label 'process_low'
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), publish_id:meta.id) }

    conda     (params.enable_conda ? "bioconda::grohmm =1.24.0" : null)
    container "quay.io/biocontainers/bedtools:2.29.2--hc088bd4_0"

    input:
    tuple val(meta), path(bam)

    output:
    path "*fwd.wig"                  , optional:true    , emit: fwdwig
    path "*rev.wig"                  , optional:true    , emit: revwig
    path "*fwd.normalized.wig"       , optional:true    , emit: fwdwig_normalized
    path "*rev.normalized.wig"       , optional:true    , emit: revwig_normalized
    path "*.RData"                   , optional:true    , emit: rdata
    path "*.version.txt"             , emit: version

    script:
    def software = getSoftwareName(task.process)
    def prefix   = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"
    """
    makeucscfile.R \\

        --bam_files $bam \\
        --outdir ./ \\
        --cores $task.cpus \\
        $options.args

    if [ -f "R_sessionInfo.log" ]; then
    # commands based on r file
    fi

    Rscript -e "library(groHMM); write(x=as.character(packageVersion('groHMM')), file='${software}.version.txt')"
    """
}
