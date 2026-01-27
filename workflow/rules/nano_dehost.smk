rule nano_dehost:
    input:
        fastq = INPUT["long_reads"] / "{sample}.fastq",
        ref = REFERENCE_HUMAN
    output:
        sam = BASE / config["output"]["dehost"]["sam"] / "{sample}.sam",
        unmapped = BASE / config["output"]["dehost"]["sam"] / "{sample}.unmapped.names",
        copied = BASE / config["output"]["dehost"]["result"] / "{sample}.unmapped.names",
        dehosted = BASE / config["output"]["dehost"]["sam"] / "nano.{sample}.dehost.fq.gz"
    params:
        minimap2_options = config["minimap2"]["options"]
    threads:
        config["threads"]["dehost"]
    shell:
        """
        source activate nanosoft
        minimap2 {params.minimap2_options} -t {threads} {input.ref} {input.fastq} > {output.sam}
        awk '($$2==4){{print $$1}}' {output.sam} > {output.unmapped}
        cp {output.unmapped} {output.copied}
        tmp=$(mktemp tmp.{wildcards.sample}.XXXX.fq)
        seqkit grep -f {output.unmapped} {input.fastq} > "$tmp"
        gzip -c "$tmp" > {output.dehosted}
        rm -f "$tmp"
        """
