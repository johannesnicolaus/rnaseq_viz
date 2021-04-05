
# functions ---------------------------------------------------------------


# combine metadata and gex table

sort_df_filter <- function(df, metadata, iden = 3){
  # pivot longer based on identifier
  df_combined <- df %>% 
    pivot_longer(cols = (iden+1):length(.), names_to = "id") %>%
    left_join(metadata %>% rename(id = "id"))
  
  return(df_combined)

}
