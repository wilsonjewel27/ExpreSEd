# R/data.R

#' Preform Differential Gene Analysis
#'
#' @param se_ln A SummarizedExperiment object
#' @param ref_level Reference cell type (default: "Tconv")
#' @param group_var determines the column to categorization
#'
#' @return Differential gene expression results between cell types
#'
#' @importFrom SummarizedExperiment assay colData
#' @importFrom DESeq2 DESeqDataSet DESeq results
#' @importFrom stats as.formula relevel
#' @importFrom utils write.table
#' @export
#'
#' @examples
#' data(example_se)
#'
#' # Step 1: Filter low expression genes
#' se_filtered <- filter_low_exp_genes(example_se,
#'                                     min_count_per_group = 10)
#'
#' # Step 2: Run the DESeq2 pipeline
#' se_dge <- run_DESeq2(se_ln = se_filtered,
#'                      group_var = "cell_type",
#'                      ref_level = "Tconv")
#'
run_DESeq2 <- function(se_ln, group_var = "cell_type", ref_level = "Tconv" ){
  #if `group_var` isn't in se, throw error
  if (!group_var %in% colnames(colData(se_ln))){
    stop(sprintf("invalid group_var: %s. Available group_var are: %s",
      group_var,
      paste(colnames(colData(se_ln)), collapse = ", ")
    ))
  }
  #else, run analysis
  else{
    if (!ref_level %in% unique(se_ln[[group_var]])){
      stop(sprintf("invalid ref_level: %s. Available ref_level are: %s",
                   ref_level,
                   paste(unique(se_ln[[group_var]]), collapse = ", ")))
    }
    else{
      #convert the se elements of group_var into a factor
      se_ln[[group_var]] <- as.factor(se_ln[[group_var]])
      #set a one of the group_var categories to a reference level
      se_ln[[group_var]] <- relevel(se_ln[[group_var]], ref = ref_level)
      design_formula <- as.formula(paste('~', group_var))
      #use DESeq2 on se
      dds <- DESeqDataSet(se_ln, design = design_formula)
      dds <- DESeq(dds)
      return(dds)
      }
    }
}
