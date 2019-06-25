rule AWS_iGenomes:
    output:
        "scripts/aws-igenomes.sh"
    shell:
       "curl -fsSL https://ewels.github.io/AWS-iGenomes/aws-igenomes.sh > {output} && chmod +x {output}"

# Datasets TODO

rule GM_download:
    output:
        expand("data/2018-06-23/GM/{unit}.fastq",unit=GM_SAMPLES),

rule IMR_download:
    output:
        expand("data/2018-06-23/IMR/{unit}.fastq",unit=IMR_SAMPLES),

rule GM_Original_eRNAs:
    output:
        "data/2018-01-25/eRNA_GM_hg19.sorted.bed"

# Reference Genomes

rule hg18_reference_Genome:
    output:
        directory("data/2018-06-24/hg18/"),
    params:
        script="scripts/aws-igenomes.sh",
        genome="Homo_sapiens",
        source="UCSC",
        build="hg18",
        typeOf="bowtie2",
        outDir="data/2018-06-24/hg18/",
    conda:
        "../envs/awscli.yaml"
    priority: 50
    shell:
        "{params.script} -g {params.genome} -s {params.source} "
        "-b {params.build} -t {params.typeOf} -o {output}"

rule hg19_reference_Genome:
    output:
        directory("data/2018-06-24/hg19/"),
    params:
        script="scripts/aws-igenomes.sh",
        genome="Homo_sapiens",
        source="UCSC",
        build="hg19",
        typeOf="bowtie2",
    conda:
        "../envs/awscli.yaml"
    priority: 50
    shell:
        "{params.script} -g {params.genome} -s {params.source} "
        "-b {params.build} -t {params.typeOf} -o {output}"

# RefSeq

rule hg18_download_refSeq:
    output:
        hg18_genes="data/2018-11-09/hg18/genes.bed",
    params:
        script="scripts/aws-igenomes.sh",
        genome="Homo_sapiens",
        source="UCSC",
        build="hg18",
        typeOf="bed12",
        outDir="data/2018-11-09/hg18/",
    conda:
        "../envs/awscli.yaml"
    shell:
        "{params.script} -g {params.genome} -s {params.source} "
        "-b {params.build} -t {params.typeOf} -o {params.outDir}"

rule hg19_download_refSeq:
    output:
        hg19_genes="data/2018-11-09/hg19/genes.bed",
    params:
        script="scripts/aws-igenomes.sh",
        genome="Homo_sapiens",
        source="UCSC",
        build="hg19",
        typeOf="bed12",
        outDir="data/2018-11-09/hg19/",
    conda:
        "../envs/awscli.yaml"
    shell:
        "{params.script} -g {params.genome} -s {params.source} "
        "-b {params.build} -t {params.typeOf} -o {output.outDir}"

# RefSeq

rule download_refSeq_hg19:
    output:
        hg19="data/2018-11-28/",
    params:
        script="scripts/aws-igenomes.sh",
        genome="Homo_sapiens",
        source="UCSC",
        build="hg19",
        typeOf="bed12",
        outDir="data/2018-11-28/",
    conda:
        "../envs/awscli.yaml"
    shell:
        "{params.script} -g {params.genome} -s {params.source} "
        "-b {params.build} -t {params.typeOf} -o {params.outDir}"

# Histones

# https://www.encodeproject.org/experiments/ENCSR000AKF/
GM_h3k4me1_gz="https://www.encodeproject.org/files/ENCFF000ASM/@@download/ENCFF000ASM.fastq.gz"
# https://www.encodeproject.org/experiments/ENCSR000AKC/
GM_h3k27ac_gz="https://www.encodeproject.org/files/ENCFF000ASU/@@download/ENCFF000ASU.fastq.gz"

rule GM_H3K4me1_fastq:
    output:
        "data/2018-11-13/GM_H3K4me1.fastq",
    shell:
        "curl -Ls {GM_h3k4me1_gz} | gunzip > {output}"

rule GM_H3K27ac_fastq:
    output:
        "data/2018-11-13/GM_H3K27ac.fastq",
    shell:
        "curl -Ls {GM_h3k27ac_gz} | gunzip > {output}"

# TODO Figure out the agregation
# https://www.encodeproject.org/experiments/ENCSR831JSP/
IMR_h3k4me1_gz="https://www.encodeproject.org/files/ENCFF123RFO/@@download/ENCFF123RFO.fastq.gz"
# https://www.encodeproject.org/experiments/ENCSR002YRE/
IMR_h3k27ac_gz="https://www.encodeproject.org/files/ENCFF200XEH/@@download/ENCFF200XEH.fastq.gz"

rule IMR_H3K4me1_fastq:
    output:
        "data/2018-11-13/IMR_H3K4me1.fastq",
    shell:
        "curl -Ls {IMR_h3k4me1_gz} | gunzip > {output}"

rule IMR_H3K27ac_fastq:
    output:
        "data/2018-11-13/IMR_H3K27ac.fastq",
    shell:
        "curl -Ls {IMR_h3k27ac_gz} | gunzip > {output}"

# liftOver
hg18mapChain="http://hgdownload.soe.ucsc.edu/goldenPath/hg18/liftOver/hg18ToHg19.over.chain.gz"

rule download_mapChain:
    output:
        "data/2018-11-10/hg18ToHg19.over.chain"
    shell:
        "curl -Ls {hg18mapChain} | gunzip > {output}"
