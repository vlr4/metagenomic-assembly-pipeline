# Reassembly: MetaWrap2 reassemble_bins (strict/permissive; ONT reads for the hybrid type),
# then selection of the best version of each bin with CheckM2.

rule reassemble_bins:
    input:
        bins=rules.bin_refinement.output.bins,
        r1=rules.read_qc.output.r1,
        r2=rules.read_qc.output.r2,
        ont=ont_reads,
        toml=rules.metawrap2_config.output.toml,
    output:
        outdir=directory(TMP / "reassembly" / "{sample}"),
    params:
        mem_gb=mem_gb,
        nanopore=nanopore_flag,
    container:
        sif("metawrap2")
    threads: res("reassemble_bins", "threads")
    resources:
        mem_mb=res("reassemble_bins", "mem_mb"),
        runtime=res("reassemble_bins", "runtime"),
    log:
        "logs/{assembly_type}/reassemble_bins/{sample}.log",
    benchmark:
        "benchmarks/{assembly_type}/reassemble_bins/{sample}.tsv"
    shell:
        """
        if ls {input.bins}/*.fasta > /dev/null 2>&1; then
            metawrap2 --force reassemble_bins --config {input.toml} \
                -o {output.outdir} -b {input.bins} -1 {input.r1} -2 {input.r2} \
                {params.nanopore} -t {threads} -m {params.mem_gb} -c {COMP} -x {CONT} \
                --skip-checkm > {log} 2>&1
            rm -rf {output.outdir}/reads_for_reassembly {output.outdir}/reassemblies \
                {output.outdir}/binned_assembly
        else
            mkdir -p {output.outdir}/original_bins {output.outdir}/reassembled_bins
            echo "no refined bins; reassembly skipped" > {log}
        fi
        """


rule reassembly_select:
    input:
        reassembly=rules.reassemble_bins.output.outdir,
        dmnd=rules.checkm2_db.output.dmnd,
    output:
        bins=directory(TMP / "reassembly_select" / "{sample}" / "bins"),
        stats=TMP / "reassembly_select" / "{sample}" / "bins.stats.tsv",
    params:
        workdir=str(TMP / "reassembly_select" / "{sample}"),
        script=SCRIPTS / "select_reassembled_bins.py",
    container:
        sif("metawrap2")
    threads: res("reassembly_select", "threads")
    resources:
        mem_mb=res("reassembly_select", "mem_mb"),
        runtime=res("reassembly_select", "runtime"),
    log:
        "logs/{assembly_type}/reassembly_select/{sample}.log",
    benchmark:
        "benchmarks/{assembly_type}/reassembly_select/{sample}.tsv"
    shell:
        """
        cand={params.workdir}/candidates
        report={params.workdir}/checkm2/quality_report.tsv
        rm -rf $cand {params.workdir}/checkm2
        python {params.script} stage --reassembly {input.reassembly} --candidates $cand > {log} 2>&1
        if ls $cand/*.fasta > /dev/null 2>&1; then
            mamba run -n metawrap2-checkm2 checkm2 predict --input $cand \
                --output-directory {params.workdir}/checkm2 -x fasta --threads {threads} \
                --database_path {input.dmnd} --force >> {log} 2>&1
        fi
        python {params.script} select --candidates $cand --report $report \
            --completeness {COMP} --contamination {CONT} \
            --out-bins {output.bins} --out-stats {output.stats} >> {log} 2>&1
        rm -rf $cand
        """
