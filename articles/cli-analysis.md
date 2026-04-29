# Differential Expression Analysis via Command Line Interface

Designed for RNA-seq workflows, **ExpreSEd** provides a streamlined
pipeline to differential expression results. Use supply raw count
matrices and sample metadata (TSV/CSV) directly via the command-line
interface.

------------------------------------------------------------------------

## Step 1: Install ExpreSEd from GitHub

``` bash
Rscript -e "Rapp::install_pkg_cli_apps('ExpreSEd')"
```

## Step 2: Load example dataset and set paths

``` r
ex_counts_path <- system.file("testdata", "example_counts.tsv", package = "ExpreSEd")
ex_meta_path   <- system.file("testdata", "example_meta.tsv", package = "ExpreSEd")

Sys.setenv(EX_COUNTS = ex_counts_path)
Sys.setenv(EX_META   = ex_meta_path)
```

## Step 3: Start the Differential Gene Expression Analysis

### Step 3.1: Determine the Low Expression Filter Threshold

Evaluate model performance across different threshold values and select
the best one.

``` r
ExpreSEd determine_filter_threshold --count $EX_COUNTS --meta $EX_META --output ./results/
```

Results output a **filtering_analysis.tsv** table in results folder.
Success confirmation will read: “Saved as RDS. Done.”

### Step 3.2: Filter Low Expression Genes

Using the threshold value determined in Step 1, manually replace the
`min_count_per_gene` variable and filter. Default `min_count_per_gene` =
10.

``` r
ExpreSEd filter_low_exp_genes --count $EX_COUNTS --meta $EX_META --output ./results/
```

Success confirmation will read: “Saved as RDS. Done.” Output
**se_filtered.rds** will be save in “./results/”

### Step 3.3: Differential Gene Expression Analysis via DESeq2

With the remaining filtered genes, preform DESeq2 to analyze the gene
expression. Replace `group_var` with the column to be categorized.
Default `group_var` = “cell-type”. Replace `ref_level` with a specific
cell type to be reference. Default `re_level` = “Tconv”

``` r
ExpreSEd run_DESeq2 --input ./results/se_filtered.rds --output ./results/
```

Success confirmation will read: “Saved as RDS. Done.” Output
**se_dge.rds** will be save in “./results/”

### Step 3.4: Apply log2_shrinkage on DESeq2 results to improve estimates.

Replace `shrinkage` with the appropriate GLM estimator. Default
`shrinkage` = “apeglm”

``` r
ExpreSEd log2_shrinkage  --input ./results/se_dge.rds --output ./results/
```

Success confirmation will read: “Saved as RDS. Done.” Results output
**dge_shrink.rds** and a **dge_shrink.tsv** table saved in “./results/”

### Step 3.5: Intrepret the Gene Regulation

Summarize the non-significant and up and down regulated genes in the
data set. Replace `p_threshold` with the appropriate adjusted p-value
threshold. Default `p_threshold` = 0.05. Replace `fc_threshold` with the
appropriate fold-change threshold. Default `fc_threshold` = 0.5.

``` r
ExpreSEd gene_regulation_summary  --input ./results/dge_shrink.rds --output ./results/
```

Success confirmation will read: “Saved as RDS. Done.” Results output
**gene_reg_summary.rds** and a **gene_reg_summary.tsv** table saved in
“./results/”

### Step 3.6: Visualize Expression

Generate a volcano plot to visualize the `gene_reg_summary` results. Use
the same `p_threshold` and `fc_threshold` values utilized in Step 5.
Replace `set_title` with the correct title. Default `set_title` =
“Volcano Plot - Lymph Node Treg vs Tconv”. Replace `xlab` with the
correct x-axis title. Default `xlab` = “log2 Fold Change (Treg vs
Tconv)”.

``` r
ExpreSEd generate_volcano --input ./results/dge_shrink.rds --output ./results/
```

Success confirmation will read: “Saved as RDS. Done.” Results output
**volcano_plot.rds**, **volcano_plot.pdf**, and **volcano_plot.png**
saved in “./results/”
