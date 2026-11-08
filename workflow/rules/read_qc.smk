# Illumina QC + host removal: MetaWrap2 read_qc (fastp + BMTagger).

rule read_qc:
    input:
        r1=DATA / config["reads"]["illumina_r1"],
        r2=DATA / config["reads"]["illumina_r2"],
        bitmask=rules.bmtool.output.bitmask,
        srprism=rules.srprism.output,
        toml=rules.metawrap2_config.output.toml,
    output:
        r1=temp(TMP / "read_qc" / "{sample}" / "final_pure_reads_1.fastq"),
        r2=temp(TMP / "read_qc" / "{sample}" / "final_pure_reads_2.fastq"),
        report=TMP / "read_qc" / "{sample}" / "fastp.json",
    params:
        outdir=lambda wildcards, output: Path(output.report).parent,
        host=HOST,
        extra=config["read_qc"]["extra"],
    container:
        sif("metawrap2")
    threads: res("read_qc", "threads")
    resources:
        mem_mb=res("read_qc", "mem_mb"),
        runtime=res("read_qc", "runtime"),
    log:
        "logs/read_qc/{sample}.log",
    benchmark:
        "benchmarks/read_qc/{sample}.tsv"
    shell:
        """
        metawrap2 --force read_qc --config {input.toml} \
            -1 {input.r1} -2 {input.r2} -o {params.outdir} -t {threads} -x {params.host} \
            --trimmer fastp --fastp-quality-trim {params.extra} > {log} 2>&1
        # Host reads are not kept; record the count.
        for i in 1 2; do
            f={params.outdir}/host_reads_$i.fastq
            if [ -f $f ]; then echo "host_reads_$i: $(( $(wc -l < $f) / 4 ))" >> {log}; rm $f; fi
        done
        """
