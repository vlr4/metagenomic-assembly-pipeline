rule bmtagger_index:
    input:
        fasta = REFERENCE_HUMAN
    output:
        bitmask = REFERENCE_HUMAN.with_suffix(".bitmask"),
        srprism = REFERENCE_HUMAN.with_suffix(".srprism")
    threads: 16
    resources:
        mem_mb = 32000
    shell:
        """
        source activate sra_tools

        bmtool -d {input.fasta} -o {output.bitmask}

        srprism mkindex \
            -i {input.fasta} \
            -o {output.srprism} \
            -M 16000 \
            -t {threads}
        """
