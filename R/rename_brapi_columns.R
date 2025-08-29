# Utility functions for deltabreedr package

rename_brapi_columns <- function(resp_df, endpoint){
  # brapi_name_key is an internally available data frame
  brapi_name_key |>
    filter(endpoint_name == endpoint) -> filtered_key
  # add missing columns (if any)
  missing_cols <- setdiff(filtered_key$name_brapi, colnames(resp_df))
  for (col in missing_cols) {
    resp_df[[col]] <- NA
  }
  # create a named vector lookup for use with rename()
  endpoint_lookup <- filtered_key$name_brapi
  names(endpoint_lookup) <- filtered_key$name_output
  resp_df |>
    rename(all_of(endpoint_lookup))
}


