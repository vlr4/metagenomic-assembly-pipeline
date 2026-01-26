
rule bmtagger_index:
    input:
        fasta = REFERENCE_HUMAN
    output:
        bitmask = DB / "{HG}.bitmask"
    shell:
        """
        source activate sra_tools

        bmtool -d {input.fasta} -o {output.bitmask}

        srprism mkindex \
            -i {input.fasta} \
            -o {DB}/{HG}.srprism \
            -M 16000
        """
