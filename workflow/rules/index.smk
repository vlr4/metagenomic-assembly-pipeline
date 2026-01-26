rule bmtagger_index:
    input:
        fasta = REFERENCE_HUMAN
    output:
        bitmask = INDEX_DIR / REFERENCE_HUMAN.name + ".bitmask",
        srprism = INDEX_DIR / REFERENCE_HUMAN.name + ".srprism"
    threads: 1
    resources:
        mem_mb = 32000
    shell:
        """
        source activate sra_tools
        mkdir -p {INDEX_DIR}

        bmtool -d {input.fasta} -o {output.bitmask}

        srprism mkindex \
            -i {input.fasta} \
            -o {output.srprism} \
            -M 16000
        """
