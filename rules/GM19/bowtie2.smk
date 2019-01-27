rule GM_hg19_bowtie2:
    input:
        sample=["data/2018-06-23/GM/{unit}.fastq"]
    output:
        "results/2018-11-27/GM/{unit}.bam"
    log:
        "logs/hg19/GM/bowtie2/{unit}.log"
    params:
        index="data/2018-11-27/genome",
        extra=""
    threads: 4
    wrapper:
        "0.27.1/bio/bowtie2/align"
