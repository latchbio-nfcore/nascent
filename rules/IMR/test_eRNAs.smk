rule test_IMR_vs_Peng:
    input:
        IMR="results/2018-12-02/IMR_eRNA.bed",
        peng="data/2018-01-25/eRNA_GM_hg19.sorted.bed",
    output:
        "results/2018-11-10/test/IMR_eRNA_vs_Peng.bed"
    log:
        "logs/IMR/test_IMR_vs_Peng.log"
    conda:
        "../../envs/bedtools.yaml"
    shell:
        "bedtools intersect -a {input.IMR} -b {input.peng} \
        -sorted -u > {output} 2> {log}"

rule test_IMR_vs_GM19:
    input:
        IMR="results/2018-12-02/IMR_eRNA.bed",
        GM19="results/2018-12-02/GM19_eRNA.bed",
    output:
        "results/2018-11-10/test/IMR_eRNA_vs_GM19.bed"
    log:
        "logs/IMR/test_IMR_vs_GM19.log"
    conda:
        "../../envs/bedtools.yaml"
    shell:
        "bedtools intersect -a {input.IMR} -b {input.GM19} \
        -sorted -u > {output} 2> {log}"

rule test_IMR_vs_liftOver:
    input:
        GM_liftOver="results/2018-11-10/eRNA_GM_liftover_hg19.sorted.bed",
        IMR="results/2018-12-02/IMR_eRNA.bed",
    output:
        "results/2018-11-10/test/IMR_eRNA_vs_liftOver.bed"
    log:
        "logs/IMR/test_IMR_vs_liftOver.log"
    conda:
        "../../envs/bedtools.yaml"
    shell:
        "bedtools intersect -a {input.IMR} -b {input.GM_liftOver} \
        -sorted -u > {output} 2> {log}"