# Read statistics (seqkit stats -a) before assembly: raw and cleaned reads, per sample and platform.

READ_STATS_INPUT = {
    "illumina": [
        DATA / config["reads"]["illumina_r1"],
        DATA / config["reads"]["illumina_r2"],
        rules.read_qc.output.r1,
        rules.read_qc.output.r2,
    ],
    "ont": [DATA / config["reads"]["ont"], rules.nano_dehost.output.fq],
}


rule read_stats:
    input:
        lambda wildcards: expand(READ_STATS_INPUT[wildcards.platform], sample=wildcards.sample),
    output:
        RES / "read_stats" / "{sample}.{platform}.tsv",
    container:
        sif("seqkit")
    threads: res("read_stats", "threads")
    resources:
        mem_mb=res("read_stats", "mem_mb"),
        runtime=res("read_stats", "runtime"),
    log:
        "logs/read_stats/{sample}.{platform}.log",
    benchmark:
        "benchmarks/read_stats/{sample}.{platform}.tsv"
    shell:
        """
        seqkit stats -a -T -j {threads} {input} > {output} 2> {log}
        """
