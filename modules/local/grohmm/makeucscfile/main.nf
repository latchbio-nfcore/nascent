// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
def options    = initOptions(params.options)

def VERSION = '1.24'

process GROHMM_MAKEUCSCFILE {
    tag "$meta.id"
    label 'process_medium'
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), publish_id:'') }

    conda     (params.enable_conda ? "conda-forge::r-base=4.0 conda-forge::r-optparse=1.6.6 conda-forge::r-ggplot2=3.3.2 bioconda::bioconductor-txdb.hsapiens.ucsc.hg19.knowngene bioconda::bioconductor-edger bioconda::bioconductor-grohmm=1.24.0 bioconda::bioconductor-org.hs.eg.db"  : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "https://depot.galaxyproject.org/singularity/mulled-v2-23844d1c70fe2a9a1394628f89f59b8eb6ce99ef:e59b53a885d99af36e5b0f1cf8e5bdeac2f30c22-0"
    } else {
        container "quay.io/biocontainers/mulled-v2-23844d1c70fe2a9a1394628f89f59b8eb6ce99ef:e59b53a885d99af36e5b0f1cf8e5bdeac2f30c22-0"
    }

    input:
    tuple val(meta), path(bam)

    output:
    path "*.collapsed.wig"        , optional:true    , emit: wig
    path "*.plus.wig"             , optional:true    , emit: pluswig
    path "*.minus.wig"            , optional:true    , emit: minuswig
    path "*.RData"                , optional:true    , emit: rdata
    path "*.version.txt"          , emit: version

    script:
    def software = getSoftwareName(task.process)
    """
    makeucscfile.R --bam_file ${bam} --outdir ./ --cores $task.cpus $options.args

    # if [ -f "R_sessionInfo.log" ]; then
    # commands based on r file
    # fi

    Rscript -e "library(groHMM); write(x=as.character(packageVersion('groHMM')), file='${software}.version.txt')"
    """
}
