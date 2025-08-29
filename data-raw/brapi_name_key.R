## code to prepare `brapi_name_key` dataset goes here

# the BrAPI response dataframe has colnames drawn from the BrAPI spec
# all of these need to be changed to match DeltaBreed names/conventions
# earlier I had hard-coded this into various functions
# but it's much easier to just edit a single CSV instead
# brapi_name_key

brapi_name_key <- read.csv('data-raw/brapi_name_key.csv')

usethis::use_data(brapi_name_key, overwrite = TRUE, internal = TRUE)
