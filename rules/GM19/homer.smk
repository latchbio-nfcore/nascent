rule GM19_meta_makeTagDirectory:
    input:
        expand("results/2018-10-04/GM19/{unit}.bam",unit=GM_SAMPLES)
    output:
        directory("results/2018-11-07/GM19_meta_tagDir")
    singularity:
        "docker://emiller88/homer:latest"
    threads: 4
    shell:
        "makeTagDirectory {output} -genome hg19 -checkGC {input}"

rule GM19_meta_findPeaks:
    input:
        tagdir="results/2018-11-07/GM19_meta_tagDir",
        uniqmap="data/2019-07-26/hg19-50nt-uniqmap",
    output:
        "results/2018-11-07/GM19_meta_groseq_peak.gtf"
    singularity:
        "docker://emiller88/homer:latest"
    threads: 4
    shell:
        "findPeaks {input.tagdir} -o {output} -style groseq -uniqmap {input.uniqmap}"

rule GM19_meta_pos2bed:
    input:
        "results/2018-11-07/GM19_meta_groseq_peak.gtf"
    output:
        "results/2018-11-07/GM19_meta_groseq_peak.bed"
    conda:
        "../../envs/homer.yaml"
    threads: 4
    shell:
        "pos2bed.pl {input} > {output}"

rule GM19_sample_makeTagDirectory:
    input:
        sample=["results/2018-10-04/GM19/{unit}.bam"],
    output:
        directory("results/2019-01-28/GM/{unit}_tagDir"),
    threads: 2
    shell:
        "makeTagDirectory {output} -genome hg19 -checkGC {input}"

rule GM19_sample_findPeaks:
    input:
        tagdir="results/2019-01-28/GM/{unit}_tagDir",
        uniqmap="data/2019-07-26/hg19-50nt-uniqmap",
    output:
        "results/2019-01-28/GM/{unit}_groseq_peak.gtf"
    singularity:
        "docker://emiller88/homer:latest"
    threads: 2
    shell:
        "findPeaks {input.tagdir} -o {output} -style groseq -uniqmap {input.uniqmap}"

rule GM19_sample_pos2bed:
    input:
        "results/2019-01-28/GM/{unit}_groseq_peak.gtf"
    output:
        "results/2019-01-28/GM/{unit}_groseq_peak.bed"
    conda:
        "../../envs/homer.yaml"
    shell:
        "pos2bed.pl {input} > {output}"
