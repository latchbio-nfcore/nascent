#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { REMOVE_GENES } from '../../../../subworkflows/local/remove_genes'

workflow test_remove_genes {
    def reads = []
    def refseq = []
    def chromsizes  = []

    reads = [ file(params.test_data['nf-core']['bed']['test_bed'], checkIfExists: true) ]
    refseq = [ [ id:'test'],
            file(params.test_data['nf-core']['bed']['test2_bed'] checkIfExists: true) ]
    chromsizes = [ file(params.test_data['nf-core']['genome_sizes'], checkIfExists: true) ]

    REMOVE_GENES ( reads,refseq,chromsizes )
}
