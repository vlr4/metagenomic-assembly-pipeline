# Per-MAG coverage (CoverM genome, cleaned Illumina reads of every sample) joined onto dRep's Widb.csv.
# One CoverM call per sample: all cleaned read files share a name, which CoverM uses as column label.

rule mag_coverage:
    input:
        genomes=rules.drep.output.final,
        work=rules.drep.output.work,
        r1=expand(rules.read_qc.output.r1, sample=SAMPLES),
        r2=expand(rules.read_qc.output.r2, sample=SAMPLES),
    output:
        table=RES / "drep_bins" / "{assembly_type}" / "{assembly_type}_drep_coverage.tsv",
    params:
        workdir=str(TMP / "mag_coverage"),
        samples=" ".join(SAMPLES),
        methods=config["mag_coverage"]["methods"],
        mapper=config["mag_coverage"]["mapper"],
        script=SCRIPTS / "join_coverage.py",
    container:
        sif("metawrap2")
    threads: res("mag_coverage", "threads")
    resources:
        mem_mb=res("mag_coverage", "mem_mb"),
        runtime=res("mag_coverage", "runtime"),
    log:
        "logs/{assembly_type}/mag_coverage.log",
    benchmark:
        "benchmarks/{assembly_type}/mag_coverage.tsv"
    shell:
        """
        rm -rf {params.workdir} && mkdir -p {params.workdir} && : > {log}
        samples=({params.samples}); r1=({input.r1}); r2=({input.r2})
        if ls {input.genomes}/*.fa > /dev/null 2>&1; then
            for i in "${{!samples[@]}}"; do
                mamba run -n metawrap2-bins coverm genome -d {input.genomes} -x fa \
                    -1 ${{r1[$i]}} -2 ${{r2[$i]}} -p {params.mapper} -m {params.methods} --min-covered-fraction 0 \
                    -t {threads} -o {params.workdir}/${{samples[$i]}}.tsv >> {log} 2>&1
            done
        fi
        python {params.script} --widb {input.work}/data_tables/Widb.csv --samples {params.samples} \
            --coverm-dir {params.workdir} --out {output.table} >> {log} 2>&1
        """
