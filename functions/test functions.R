library(plotly)
library(tidyverse)


# fig <- plot_ly(data, x = ~x, y = ~trace_0, name = 'trace 0', type = 'violin') %>% 
#   add_boxplot(y = ~trace_0, jitter = 0.3, pointpos = 0, boxpoints = 'all', 
#               fillcolor = 'rgba(255,255,255,0)',
#               )



# make df -----------------------------------------------------------------
metadata <- read_csv("raw_data/metadata_out.csv")

tpm <- read_csv("raw_data/tpm.csv")


# pivot longer based on identifier
df_combined <- tpm %>% 
  pivot_longer(cols = (3+1):length(.), names_to = "id") %>%
  left_join(metadata %>% rename(id = "id"))



# filter for whatever it is
df_combined %>% filter(external_gene_name == "IL6") %>% filter()


metadata
tpm

fig <- eval(parse(text = "ggplot(data, aes(x = x, y = trace_0, trace_1 = trace_1)) + 
  geom_violin() + 
  geom_jitter(width = 0.1, height = 0)"))




ggplotly(fig, tooltip = c("x", "trace_0", "trace_1"))




# aa ----------------------------------------------------------------------


ggplot(df_combined, aes(x = condition_1, 
                        y = value, 
                        color = condition_1, 
                        age = age, 
                        sex = sex,
                        sample_type = sample_type, 
                        sampling_day = sampling_day,
                        comorbidity = comorbidity,
                        outcome = outcome,
                        dataset = dataset
                        
)) + 
  geom_violin() + 
  geom_jitter(width = 0.1, height = 0) +
  cowplot::theme_cowplot(20)





# test --------------------------------------------------------------------

# select input ------------------------------------------------------------
install.packages("remotes")
remotes::install_github("chasemc/electricShine", force = T)


dir.create("demo_app")

buildPath <- "demo_app"

run_app <- runApp('apps')


electricShine::electrify(app_name = "My_App",
                         short_description = "My demo application",
                         semantic_version = "1.0.0",
                         build_path = buildPath,
                         mran_date = "2020-02-01",
                         function_name = "run_app",
                         # git_host = "github",
                         # git_repo = "chasemc/demoApp@8426481",
                         local_package_path = "./",
                         package_install_opts = list(type = "binary"),
                         run_build = TRUE)


# fix metadata --------------------------------------------------------------------
metadata_1 <- metadata 

metadata_1 <- metadata_1 %>% select(-c("subject_status", "experiment", "condition")) %>% rename(condition = "condition_1")


metadata_1 <- metadata_1 %>% mutate(medications = case_when(is.na(medications) == T ~ "no medications",
                                              medications == "control" ~ "no medications",
                                              T ~ medications
                                              ))


metadata_1$medications_1 <- metadata_1 %>% pull(medications) %>% tolower() %>% str_split(", ") %>% lapply(function(x){str_remove(x, "^ ")})

all_meds <- metadata_1$medications_1 %>% unlist() %>% unique()

all_meds <- all_meds %>% str_subset("lopinavir", negate = T) %>% c("lopinavir")

metadata_1$medications_1 <- metadata_1$medications_1 %>% lapply(paste, collapse="") %>% unlist()



for(i in 1:length(all_meds)){
  
  for (k in 1:nrow(metadata_1)) {
    metadata_1[k, all_meds[i]] <- str_detect(metadata_1[k,"medications_1"], all_meds[i])
  }
  
  
}



# fix comorbidity
metadata_1 <- metadata_1 %>% mutate(comorbidity = case_when(is.na(comorbidity) == T ~ "no comorbidity",
                                                            comorbidity == "control" ~ "no_comorbidity",
                                                            T ~ comorbidity
))


metadata_1$comorbidity_1 <- metadata_1 %>% pull(comorbidity) %>% tolower() %>% str_split(",") %>% lapply(function(x){str_remove(x, "^ ")})

metadata_1$comorbidity_1 <- metadata_1$comorbidity_1 %>% lapply(function(x){str_replace_all(x, "copd", "chronic obstructive pulmonary disease")})

metadata_1$comorbidity_1 <- metadata_1$comorbidity_1 %>% lapply(function(x){x %>% str_remove_all("and ")})

all_comorbid <- metadata_1$comorbidity_1 %>% unlist() %>% unique()

metadata_1$comorbidity_1 <- metadata_1$comorbidity_1 %>% lapply(paste, collapse="") %>% unlist()


for(i in 1:length(all_comorbid)){
  
  for (k in 1:nrow(metadata_1)) {
    metadata_1[k, all_comorbid[i]] <- str_detect(metadata_1[k,"comorbidity_1"], all_comorbid[i])
  }
  
  
}



# add age group -----------------------------------------------------------
metadata_1 <- metadata_1 %>% mutate(age_group = (age/10) %>% floor() %>% "*"(10))

metadata_1$age_group <- metadata_1$age_group %>% paste0("~y")

metadata_1 <- metadata_1 %>% select(-c("medications_1", "comorbidity_1", ))

colnames(metadata_1) <- make.names(colnames(metadata_1))

metadata_1 %>% write_csv("raw_data/metadata_updated.csv")




# aa ----------------------------------------------------------------------

