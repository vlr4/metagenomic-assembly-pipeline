rule nano_dehost:
    input:
        fastq = lambda wildcards: f"{config['input']['long_reads']}/{wildcards.sample}.fastq",
        ref = config["reference"]["human"]
    output:
        sam = str(base / f"{config['output']['dehost']['sam']}/{{sample}}.sam"),
        unmapped = str(base / f"{config['output']['dehost']['sam']}/{{sample}}.unmapped.names"),
        copied = str(base / f"{config['output']['dehost']['result']}/{{sample}}.unmapped.names"),
        dehosted = str(base / f"{config['output']['dehost']['sam']}/nano.{{sample}}.dehost.fq.gz")
    params:
        sam_dir = str(base / config["output"]["dehost"]["sam"]),
        result_dir = str(base / config["output"]["dehost"]["result"]),
        minimap2_options = config["minimap2"]["options"]
    threads: config["threads"]["dehost"]
    shell:
        """
        source activate nanosoft
        mkdir -p {params.sam_dir} {params.result_dir}
        minimap2 {params.minimap2_options} -t {threads} {input.ref} {input.fastq} > {output.sam}
        awk "($2==4) {{print $1}}" {output.sam} > {output.unmapped}
        cp {output.unmapped} {output.copied}
        seqkit grep -f {output.unmapped} {input.fastq} > tmp.{wildcards.sample}.fq
        gzip -c tmp.{wildcards.sample}.fq > {output.dehosted}
        rm tmp.{wildcards.sample}.fq
        """