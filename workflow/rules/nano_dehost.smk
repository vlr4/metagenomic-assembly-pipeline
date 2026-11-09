# ONT host removal: keep reads minimap2 leaves unmapped (SAM flag 4). No SAM on disk.

rule nano_dehost:
    input:
        fq=DATA / config["reads"]["ont"],
        mmi=rules.minimap2_index.output.mmi,
    output:
        fq=temp(SHARED / "dehost" / "{sample}.ont.fastq.gz"),
    container:
        sif("dehost")
    threads: res("nano_dehost", "threads")
    resources:
        mem_mb=res("nano_dehost", "mem_mb"),
        runtime=res("nano_dehost", "runtime"),
    log:
        "logs/nano_dehost/{sample}.log",
    benchmark:
        "benchmarks/nano_dehost/{sample}.tsv"
    shell:
        """
        (minimap2 -ax map-ont -t {threads} {input.mmi} {input.fq} \
            | samtools fastq -f 4 - \
            | pigz -p {threads} > {output.fq}) 2> {log}
        # Read counts; -f passes uncompressed input through.
        n_in=$(( $(pigz -dcf {input.fq} | wc -l) / 4 ))
        n_kept=$(( $(pigz -dc {output.fq} | wc -l) / 4 ))
        echo "ont_reads_in: $n_in" >> {log}
        echo "ont_reads_kept: $n_kept" >> {log}
        echo "ont_host_reads: $(( n_in - n_kept ))" >> {log}
        """
