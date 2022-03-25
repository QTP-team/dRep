configfile: "config.yaml"
shell.executable("bash")

rule all:
  input:
    config["assay"]["strain"],
    config["assay"]["species"]

rule dRep_strain:
    input:
        MAG_dir = "0.MAGs",
        g_info = "MAGs_checkm.csv"
    output:
        directory(config["assay"]["strain"])
    params:
        min_len = config["params"]["dRep"]["min_len"],
        completeness = config["params"]["dRep"]["completeness"],
        contamination = config["params"]["dRep"]["contamination"],
        comW = config["params"]["dRep"]["choose_comW"],
        conW = config["params"]["dRep"]["choose_conW"],
        strW = config["params"]["dRep"]["choose_strW"],
        N50W = config["params"]["dRep"]["choose_n50"]
    threads:
        config["params"]["dRep"]["threads"]
    benchmark:
        "benchmarks/dRep_strain.log"
    log:
        os.path.join(config["logs"], "dRep_strain.log")
    shell:
        '''
        dRep dereplicate \
        {output} \
        -g {input.MAG_dir}/*.fa \
        -p {threads} \
        --length {params.min_len} \
        --completeness {params.completeness} \
        --contamination {params.contamination} \
        --genomeInfo {input.g_info} \
        --MASH_sketch 10000 \
        --S_algorithm ANImf \
        --P_ani 0.95 \
        --S_ani 0.99 \
        --cov_thresh 0.3 \
        --completeness_weight {params.comW} \
        --contamination_weight {params.conW} \
        --strain_heterogeneity_weight {params.strW} \
        --N50_weight {params.N50W} \
        2>> {log}
        '''

rule dRep_species:
    input:
        config["assay"]["strain"]
    output:
        directory(config["assay"]["species"])
    params:
        min_len = config["params"]["dRep"]["min_len"],
        completeness = config["params"]["dRep"]["completeness"],
        contamination = config["params"]["dRep"]["contamination"],
        comW = config["params"]["dRep"]["choose_comW"],
        conW = config["params"]["dRep"]["choose_conW"],
        strW = config["params"]["dRep"]["choose_strW"],
        N50W = config["params"]["dRep"]["choose_n50"]
    threads:
        config["params"]["dRep"]["threads"]
    log:
        os.path.join(config["logs"], "dRep_species.log")
    benchmark:
        "benchmarks/dRep_species.log"
    shell:
        '''
        dRep dereplicate \
        {output} \
        -g {input}/dereplicated_genomes/*.fa \
        -p {threads} \
        --MASH_sketch 10000 \
        --S_algorithm ANImf \
        --P_ani 0.90 \
        --S_ani 0.95 \
        --cov_thresh 0.3 \
        --genomeInfo {input}/data_tables/genomeInformation.csv \
        --completeness_weight {params.comW} \
        --contamination_weight {params.conW} \
        --strain_heterogeneity_weight {params.strW} \
        --N50_weight {params.N50W} \
        2>> {log}
        '''
