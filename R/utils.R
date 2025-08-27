# Utility functions for deltabreedr package


add_columns_to_match <- function(df, target_cols){
  missing_cols <- setdiff(target_cols, colnames(df))
  for (col in missing_cols) {
    df[[col]] <- NA
  }
  df <- df[, target_cols]
  df
}
