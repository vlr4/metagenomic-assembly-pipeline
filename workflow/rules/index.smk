
rule bmtagger_index:
    input:
        fasta = REFERENCE_HUMAN
    output:
        bitmask = HUMAN_DIR /  "{HG}.bitmask"
    shell:
        """
        source activate sra_tools

        bmtool -d {input.fasta} -o {output.bitmask}

        srprism mkindex \
            -i {input.fasta} \
            -o {HUMAN_DIR}/{HG}.srprism \
            -M 16000
        """
