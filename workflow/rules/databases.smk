# One-time database setup: host index (BMTagger + minimap2), CheckM2, GUNC.
# HOST_DIR is MetaWrap2's BMTAGGER_DB (holds <host>.bitmask and <host>.srprism.*).

HOST_DIR = DB / "host"
SRPRISM_EXT = [".amp", ".idx", ".imp", ".map", ".pmp", ".rmp", ".ss", ".ssa", ".ssd"]
CHECKM2_DMND = DB / "checkm2" / "CheckM2_database" / "uniref100.KO.1.dmnd"
GUNC_DMND = DB / "gunc" / f"gunc_db_{config['gunc']['db'].replace('_', '')}.dmnd"


rule host_fasta:
    output:
        fa=HOST_DIR / f"{HOST}.fa",
    params:
        url=config["host"]["url"],
        md5=config["host"]["md5"],
    container:
        sif("metawrap2")
    threads: res("host_fasta", "threads")
    resources:
        mem_mb=res("host_fasta", "mem_mb"),
        runtime=res("host_fasta", "runtime"),
    log:
        DB / "logs" / "host_fasta.log",
    benchmark:
        DB / "benchmarks" / "host_fasta.tsv"
    shell:
        """
        wget -q -O {output.fa}.gz {params.url} 2> {log}
        echo "{params.md5}  {output.fa}.gz" | md5sum -c - >> {log} 2>&1
        gzip -dc {output.fa}.gz > {output.fa}
        rm {output.fa}.gz
        """


rule bmtool:
    input:
        fa=rules.host_fasta.output.fa,
    output:
        bitmask=HOST_DIR / f"{HOST}.bitmask",
    container:
        sif("metawrap2")
    threads: res("bmtool", "threads")
    resources:
        mem_mb=res("bmtool", "mem_mb"),
        runtime=res("bmtool", "runtime"),
    log:
        DB / "logs" / "bmtool.log",
    benchmark:
        DB / "benchmarks" / "bmtool.tsv"
    shell:
        """
        mamba run -n metawrap2-reads \
            bmtool -d {input.fa} -o {output.bitmask} -A 0 -w 18 > {log} 2>&1
        """


rule srprism:
    input:
        fa=rules.host_fasta.output.fa,
    output:
        multiext(str(HOST_DIR / f"{HOST}.srprism"), *SRPRISM_EXT),
    params:
        prefix=HOST_DIR / f"{HOST}.srprism",
        # srprism -M is its memory budget in MB; leave headroom under the job limit.
        mem=lambda wildcards, resources: int(resources.mem_mb * 0.9),
    container:
        sif("metawrap2")
    threads: res("srprism", "threads")
    resources:
        mem_mb=res("srprism", "mem_mb"),
        runtime=res("srprism", "runtime"),
    log:
        DB / "logs" / "srprism.log",
    benchmark:
        DB / "benchmarks" / "srprism.tsv"
    shell:
        """
        mamba run -n metawrap2-reads \
            srprism mkindex -i {input.fa} -o {params.prefix} -M {params.mem} > {log} 2>&1
        """


rule minimap2_index:
    input:
        fa=rules.host_fasta.output.fa,
    output:
        mmi=HOST_DIR / f"{HOST}.map-ont.mmi",
    container:
        sif("dehost")
    threads: res("minimap2_index", "threads")
    resources:
        mem_mb=res("minimap2_index", "mem_mb"),
        runtime=res("minimap2_index", "runtime"),
    log:
        DB / "logs" / "minimap2_index.log",
    benchmark:
        DB / "benchmarks" / "minimap2_index.tsv"
    shell:
        """
        minimap2 -x map-ont -t {threads} -d {output.mmi} {input.fa} 2> {log}
        """


rule checkm2_db:
    output:
        dmnd=CHECKM2_DMND,
    params:
        path=DB / "checkm2",
        sha256=config["checkm2"]["sha256"],
    container:
        sif("metawrap2")
    threads: res("checkm2_db", "threads")
    resources:
        mem_mb=res("checkm2_db", "mem_mb"),
        runtime=res("checkm2_db", "runtime"),
    log:
        DB / "logs" / "checkm2_db.log",
    benchmark:
        DB / "benchmarks" / "checkm2_db.tsv"
    shell:
        """
        mamba run -n metawrap2-checkm2 \
            checkm2 database --download --path {params.path} --no_write_json_db > {log} 2>&1
        echo "{params.sha256}  {output.dmnd}" | sha256sum -c - >> {log} 2>&1
        """


rule gunc_db:
    output:
        dmnd=GUNC_DMND,
    params:
        path=DB / "gunc",
        db=config["gunc"]["db"],
    container:
        sif("metawrap2")
    threads: res("gunc_db", "threads")
    resources:
        mem_mb=res("gunc_db", "mem_mb"),
        runtime=res("gunc_db", "runtime"),
    log:
        DB / "logs" / "gunc_db.log",
    benchmark:
        DB / "benchmarks" / "gunc_db.tsv"
    shell:
        """
        mamba run -n metawrap2-binqc \
            gunc download_db {params.path} -db {params.db} > {log} 2>&1
        """


rule databases:
    input:
        rules.bmtool.output,
        rules.srprism.output,
        rules.minimap2_index.output,
        rules.checkm2_db.output,
        rules.gunc_db.output if config["gunc"]["enabled"] else [],


rule metawrap2_config:
    input:
        bitmask=rules.bmtool.output.bitmask,
        checkm2=rules.checkm2_db.output.dmnd,
        gunc=rules.gunc_db.output.dmnd if config["gunc"]["enabled"] else [],
    output:
        toml=SHARED / "metawrap2.toml",
    params:
        bmtagger_db=HOST_DIR,
        gunc_line=f'GUNC_DB = "{GUNC_DMND}"' if config["gunc"]["enabled"] else "",
        disk=config["metawrap2"]["max_disk_fraction"],
    container:
        sif("metawrap2")
    threads: res("metawrap2_config", "threads")
    resources:
        mem_mb=res("metawrap2_config", "mem_mb"),
        runtime=res("metawrap2_config", "runtime"),
    log:
        "logs/metawrap2_config.log",
    benchmark:
        "benchmarks/metawrap2_config.tsv"
    shell:
        """
        cat > {output.toml} <<TOML
[settings]
use_conda_envs = true

[limits]
max_thread_fraction = 1.0
max_memory_fraction = 1.0
max_disk_fraction = {params.disk}

[databases]
BMTAGGER_DB = "{params.bmtagger_db}"
CHECKM2DB = "{input.checkm2}"
{params.gunc_line}
TOML
        metawrap2 config show --config {output.toml} > {log} 2>&1
        """
