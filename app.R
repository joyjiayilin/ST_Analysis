

# ===============================================
# Title: ST Analysis
# Description: Association of Standardized Test Score Requirements with Graduate Student Academic Outcomes and Diversity
# Author: Joy Lin


# ===============================================
# Packages & Functions
# ===============================================

library(shiny)
library(openxlsx)
library(reactable)
library(tidyverse)
library(readxl)
library(RColorBrewer)
library(echarts4r)
library(purrr)

create_col_defs <- function(data) {
  numeric_cols <- sapply(data, is.numeric)
  
  format_sig_figs <- function(value) {
    if (is.na(value) || value == 0) {
      return(as.character(value))
    }
    
    # Format with significant figures
    formatted_value <- formatC(value, digits = 4, format = "fg")
    
    # Remove trailing zeros after decimal point
    formatted_value <- sub("\\.0+$", "", formatted_value)
    formatted_value
  }
  
  col_defs <- lapply(names(data)[numeric_cols], function(col) {
    colDef(cell = function(value) format_sig_figs(value))
  })
  names(col_defs) <- names(data)[numeric_cols]
  
  col_defs
}


make_donut <- function(df) {
  
  # Prepare data for pie chart
  pie_data <- df %>%
    slice(-1) %>%  # Exclude the first row
    mutate(
      Value = as.numeric(sub(" \\(.*", "", Value)),  # Remove text after " (" and convert to numeric
      Category = as.factor(Category)  # Convert Category to a factor
    )
  
  if (any(pie_data$Value != 0)) {
    
    # Define a color palette
    full_palette <- c("#4682B4", "#32CD32", "#FFD700", "#FF69B4", "#8A2BE2", "#7FFF00", "#D2691E", "#DC143C", "#00BFFF")
    
    # Determine the number of colors needed
    num_colors <- nrow(pie_data)
    colors <- full_palette[1:num_colors]
    
    pie_data %>%
      e_charts(Category) %>%  # Use the 'Category' column for the chart
      e_pie(
        Value,  # Use the 'Percentage' column for pie chart values
        radius = c("50%", "80%")  # Adjust the size of the pie chart
      ) %>%
      e_labels(
        show = TRUE,
        formatter = "{c} \n {d}%",
        position = "outside"  # Position the labels outside the pie chart
      ) %>%
      e_legend(show = TRUE, orient = "vertical", left = "right") %>%
      e_tooltip()  # Enable tooltips
    
    
  }
  
}



# ===============================================
# Import data
# ===============================================

## Doc

doc_summary <- read_excel("Doc_Complete Summaries.xlsx", sheet = 'stats')
doc_stem_summary <- read_excel("Doc_Complete Summaries.xlsx", sheet = 'stats_s')
doc_non_stem_summary <- read_excel("Doc_Complete Summaries.xlsx", sheet = 'stats_n')
doc_summary_1 <- read_excel("Doc_Complete Summaries.xlsx", sheet = 'stats_1')
doc_stem_summary_1 <- read_excel("Doc_Complete Summaries.xlsx", sheet = 'stats_s_1')
doc_non_stem_summary_1 <- read_excel("Doc_Complete Summaries.xlsx", sheet = 'stats_n_1')
doc_summary_0 <- read_excel("Doc_Complete Summaries.xlsx", sheet = 'stats_0')
doc_stem_summary_0 <- read_excel("Doc_Complete Summaries.xlsx", sheet = 'stats_s_0')
doc_non_stem_summary_0 <- read_excel("Doc_Complete Summaries.xlsx", sheet = 'stats_n_0')

doc_anal_sum <- read_excel("Doc_Complete Summaries.xlsx", sheet = 'summary')

doc_miss1 <- read_excel("Doc_Reasons for Missing Data.xlsx", sheet = 'miss1')
doc_miss2 <- read_excel("Doc_Reasons for Missing Data.xlsx", sheet = 'miss2')
doc_stem_miss1 <- read_excel("Doc_Reasons for Missing Data.xlsx", sheet = 'miss1_s')
doc_stem_miss2 <- read_excel("Doc_Reasons for Missing Data.xlsx", sheet = 'miss2_s')
doc_non_stem_miss1 <- read_excel("Doc_Reasons for Missing Data.xlsx", sheet = 'miss1_n')
doc_non_stem_miss2 <- read_excel("Doc_Reasons for Missing Data.xlsx", sheet = 'miss2_n')

doc_gpa1 <- read_excel("Doc_Complete Summaries.xlsx", sheet = 'gpa1')
doc_stem_gpa1 <- read_excel("Doc_Complete Summaries.xlsx", sheet = 'gpa1_s')
doc_non_stem_gpa1 <- read_excel("Doc_Complete Summaries.xlsx", sheet = 'gpa1_n')
doc_gpa2 <- read_excel("Doc_Complete Summaries.xlsx", sheet = 'gpa2')
doc_stem_gpa2 <- read_excel("Doc_Complete Summaries.xlsx", sheet = 'gpa2_s')
doc_non_stem_gpa2 <- read_excel("Doc_Complete Summaries.xlsx", sheet = 'gpa2_n')

doc_ttd_stats <- read_excel("Doc_Missing_TTD_Stats.xlsx", sheet = 'ttd_stats')
doc_stem_ttd_stats <- read_excel("Doc_Missing_TTD_Stats.xlsx", sheet = 'ttd_stats_s')
doc_non_stem_ttd_stats <- read_excel("Doc_Missing_TTD_Stats.xlsx", sheet = 'ttd_stats_n')

doc_ttd <- read_excel("Doc_Complete Summaries.xlsx", sheet = 'ttd')
doc_stem_ttd <- read_excel("Doc_Complete Summaries.xlsx", sheet = 'ttd_s')
doc_non_stem_ttd <- read_excel("Doc_Complete Summaries.xlsx", sheet = 'ttd_n')

doc_urm <- read_excel("Doc_Complete Summaries.xlsx", sheet = 'urm')
doc_stem_urm <- read_excel("Doc_Complete Summaries.xlsx", sheet = 'urm_s')
doc_non_stem_urm <- read_excel("Doc_Complete Summaries.xlsx", sheet = 'urm_n')

doc_gender <- read_excel("Doc_Complete Summaries.xlsx", sheet = 'gender')
doc_stem_gender <- read_excel("Doc_Complete Summaries.xlsx", sheet = 'gender_s')
doc_non_stem_gender <- read_excel("Doc_Complete Summaries.xlsx", sheet = 'gender_n')

doc_8 <- read_excel("Doc_Completion_Stats.xlsx", sheet = '8')
doc_stem_8 <- read_excel("Doc_Completion_Stats.xlsx", sheet = '8_s')
doc_non_stem_8 <- read_excel("Doc_Completion_Stats.xlsx", sheet = '8_n')
doc_10 <- read_excel("Doc_Completion_Stats.xlsx", sheet = '10')
doc_stem_10 <- read_excel("Doc_Completion_Stats.xlsx", sheet = '10_s')
doc_non_stem_10 <- read_excel("Doc_Completion_Stats.xlsx", sheet = '10_n')

doc_completed_8 <- read_excel("Doc_Complete Summaries.xlsx", sheet = 'completed_8')
doc_stem_completed_8 <- read_excel("Doc_Complete Summaries.xlsx", sheet = 'completed_8_s')
doc_non_stem_completed_8 <- read_excel("Doc_Complete Summaries.xlsx", sheet = 'completed_8_n')

doc_completed_10 <- read_excel("Doc_Complete Summaries.xlsx", sheet = 'completed_10')
doc_stem_completed_10 <- read_excel("Doc_Complete Summaries.xlsx", sheet = 'completed_10_s')
doc_non_stem_completed_10 <- read_excel("Doc_Complete Summaries.xlsx", sheet = 'completed_10_n')

doc_sep_list <- list()
doc_stem_sep_list <- list()
doc_non_stem_sep_list <- list()
mas_sep_list <- list()
mas_stem_sep_list <- list()
mas_non_stem_sep_list <- list()
for (i in 1:10) {
  doc_sep_list[[i]] <- read_excel("Doc_Complete Summaries.xlsx", sheet = paste0("sep", i))
  doc_stem_sep_list[[i]] <- read_excel("Doc_Complete Summaries.xlsx", sheet = paste0("sep", i, "_s"))
  doc_non_stem_sep_list[[i]] <- read_excel("Doc_Complete Summaries.xlsx", sheet = paste0("sep", i, "_n"))
}


### ST Change

doc_st_change_summary <- read_excel("Doc_ST_Change_Complete Summaries.xlsx", sheet = 'stats')
doc_st_change_stem_summary <- read_excel("Doc_ST_Change_Complete Summaries.xlsx", sheet = 'stats_s')
doc_st_change_non_stem_summary <- read_excel("Doc_ST_Change_Complete Summaries.xlsx", sheet = 'stats_n')
doc_st_change_summary_1 <- read_excel("Doc_ST_Change_Complete Summaries.xlsx", sheet = 'stats_1')
doc_st_change_stem_summary_1 <- read_excel("Doc_ST_Change_Complete Summaries.xlsx", sheet = 'stats_s_1')
doc_st_change_non_stem_summary_1 <- read_excel("Doc_ST_Change_Complete Summaries.xlsx", sheet = 'stats_n_1')
doc_st_change_summary_0 <- read_excel("Doc_ST_Change_Complete Summaries.xlsx", sheet = 'stats_0')
doc_st_change_stem_summary_0 <- read_excel("Doc_ST_Change_Complete Summaries.xlsx", sheet = 'stats_s_0')
doc_st_change_non_stem_summary_0 <- read_excel("Doc_ST_Change_Complete Summaries.xlsx", sheet = 'stats_n_0')

doc_st_change_anal_sum <- read_excel("Doc_ST_Change_Complete Summaries.xlsx", sheet = 'summary')

doc_st_change_miss1 <- read_excel("Doc_ST_Change_Reasons for Missing Data.xlsx", sheet = 'miss1')
doc_st_change_miss2 <- read_excel("Doc_ST_Change_Reasons for Missing Data.xlsx", sheet = 'miss2')
doc_st_change_stem_miss1 <- read_excel("Doc_ST_Change_Reasons for Missing Data.xlsx", sheet = 'miss1_s')
doc_st_change_stem_miss2 <- read_excel("Doc_ST_Change_Reasons for Missing Data.xlsx", sheet = 'miss2_s')
doc_st_change_non_stem_miss1 <- read_excel("Doc_ST_Change_Reasons for Missing Data.xlsx", sheet = 'miss1_n')
doc_st_change_non_stem_miss2 <- read_excel("Doc_ST_Change_Reasons for Missing Data.xlsx", sheet = 'miss2_n')

doc_st_change_gpa1 <- read_excel("Doc_ST_Change_Complete Summaries.xlsx", sheet = 'gpa1')
doc_st_change_stem_gpa1 <- read_excel("Doc_ST_Change_Complete Summaries.xlsx", sheet = 'gpa1_s')
doc_st_change_non_stem_gpa1 <- read_excel("Doc_ST_Change_Complete Summaries.xlsx", sheet = 'gpa1_n')
doc_st_change_gpa2 <- read_excel("Doc_ST_Change_Complete Summaries.xlsx", sheet = 'gpa2')
doc_st_change_stem_gpa2 <- read_excel("Doc_ST_Change_Complete Summaries.xlsx", sheet = 'gpa2_s')
doc_st_change_non_stem_gpa2 <- read_excel("Doc_ST_Change_Complete Summaries.xlsx", sheet = 'gpa2_n')

doc_st_change_ttd_stats <- read_excel("Doc_Missing_TTD_Stats.xlsx", sheet = 'ttd_st_change_stats')
doc_st_change_stem_ttd_stats <- read_excel("Doc_Missing_TTD_Stats.xlsx", sheet = 'ttd_st_change_stats_s')
doc_st_change_non_stem_ttd_stats <- read_excel("Doc_Missing_TTD_Stats.xlsx", sheet = 'ttd_st_change_stats_n')

doc_st_change_ttd <- read_excel("Doc_ST_Change_Complete Summaries.xlsx", sheet = 'ttd')
doc_st_change_stem_ttd <- read_excel("Doc_ST_Change_Complete Summaries.xlsx", sheet = 'ttd_s')
doc_st_change_non_stem_ttd <- read_excel("Doc_ST_Change_Complete Summaries.xlsx", sheet = 'ttd_n')

doc_st_change_urm <- read_excel("Doc_ST_Change_Complete Summaries.xlsx", sheet = 'urm')
doc_st_change_stem_urm <- read_excel("Doc_ST_Change_Complete Summaries.xlsx", sheet = 'urm_s')
doc_st_change_non_stem_urm <- read_excel("Doc_ST_Change_Complete Summaries.xlsx", sheet = 'urm_n')

doc_st_change_gender <- read_excel("Doc_ST_Change_Complete Summaries.xlsx", sheet = 'gender')
doc_st_change_stem_gender <- read_excel("Doc_ST_Change_Complete Summaries.xlsx", sheet = 'gender_s')
doc_st_change_non_stem_gender <- read_excel("Doc_ST_Change_Complete Summaries.xlsx", sheet = 'gender_n')

doc_st_change_8 <- read_excel("Doc_Completion_Stats.xlsx", sheet = 'st_change_8')
doc_st_change_stem_8 <- read_excel("Doc_Completion_Stats.xlsx", sheet = 'st_change_8_s')
doc_st_change_non_stem_8 <- read_excel("Doc_Completion_Stats.xlsx", sheet = 'st_change_8_n')
doc_st_change_10 <- read_excel("Doc_Completion_Stats.xlsx", sheet = 'st_change_10')
doc_st_change_stem_10 <- read_excel("Doc_Completion_Stats.xlsx", sheet = 'st_change_10_s')
doc_st_change_non_stem_10 <- read_excel("Doc_Completion_Stats.xlsx", sheet = 'st_change_10_n')

doc_st_change_completed_8 <- read_excel("Doc_ST_Change_Complete Summaries.xlsx", sheet = 'completed_8')
doc_st_change_stem_completed_8 <- read_excel("Doc_ST_Change_Complete Summaries.xlsx", sheet = 'completed_8_s')
doc_st_change_non_stem_completed_8 <- read_excel("Doc_ST_Change_Complete Summaries.xlsx", sheet = 'completed_8_n')

doc_st_change_completed_10 <- read_excel("Doc_ST_Change_Complete Summaries.xlsx", sheet = 'completed_10')
doc_st_change_stem_completed_10 <- read_excel("Doc_ST_Change_Complete Summaries.xlsx", sheet = 'completed_10_s')
doc_st_change_non_stem_completed_10 <- read_excel("Doc_ST_Change_Complete Summaries.xlsx", sheet = 'completed_10_n')

doc_st_change_sep_list <- list()
doc_st_change_stem_sep_list <- list()
doc_st_change_non_stem_sep_list <- list()
doc_st_change_sep_list <- list()
doc_st_change_stem_sep_list <- list()
doc_st_change_non_stem_sep_list <- list()
for (i in 1:10) {
  doc_st_change_sep_list[[i]] <- read_excel("Doc_ST_Change_Complete Summaries.xlsx", sheet = paste0("sep", i))
  doc_st_change_stem_sep_list[[i]] <- read_excel("Doc_ST_Change_Complete Summaries.xlsx", sheet = paste0("sep", i, "_s"))
  doc_st_change_non_stem_sep_list[[i]] <- read_excel("Doc_ST_Change_Complete Summaries.xlsx", sheet = paste0("sep", i, "_n"))
}


## Mas

mas_summary <- read_excel("Mas_Complete Summaries.xlsx", sheet = 'stats')
mas_stem_summary <- read_excel("Mas_Complete Summaries.xlsx", sheet = 'stats_s')
mas_non_stem_summary <- read_excel("Mas_Complete Summaries.xlsx", sheet = 'stats_n')
mas_summary_1 <- read_excel("Mas_Complete Summaries.xlsx", sheet = 'stats_1')
mas_stem_summary_1 <- read_excel("Mas_Complete Summaries.xlsx", sheet = 'stats_s_1')
mas_non_stem_summary_1 <- read_excel("Mas_Complete Summaries.xlsx", sheet = 'stats_n_1')
mas_summary_0 <- read_excel("Mas_Complete Summaries.xlsx", sheet = 'stats_0')
mas_stem_summary_0 <- read_excel("Mas_Complete Summaries.xlsx", sheet = 'stats_s_0')
mas_non_stem_summary_0 <- read_excel("Mas_Complete Summaries.xlsx", sheet = 'stats_n_0')

mas_anal_sum <- read_excel("Mas_Complete Summaries.xlsx", sheet = 'summary')

mas_miss1 <- read_excel("Mas_Reasons for Missing Data.xlsx", sheet = 'miss1')
mas_miss2 <- read_excel("Mas_Reasons for Missing Data.xlsx", sheet = 'miss2')
mas_stem_miss1 <- read_excel("Mas_Reasons for Missing Data.xlsx", sheet = 'miss1_s')
mas_stem_miss2 <- read_excel("Mas_Reasons for Missing Data.xlsx", sheet = 'miss2_s')
mas_non_stem_miss1 <- read_excel("Mas_Reasons for Missing Data.xlsx", sheet = 'miss1_n')
mas_non_stem_miss2 <- read_excel("Mas_Reasons for Missing Data.xlsx", sheet = 'miss2_n')

mas_gpa1 <- read_excel("Mas_Complete Summaries.xlsx", sheet = 'gpa1')
mas_stem_gpa1 <- read_excel("Mas_Complete Summaries.xlsx", sheet = 'gpa1_s')
mas_non_stem_gpa1 <- read_excel("Mas_Complete Summaries.xlsx", sheet = 'gpa1_n')
mas_gpa2 <- read_excel("Mas_Complete Summaries.xlsx", sheet = 'gpa2')
mas_stem_gpa2 <- read_excel("Mas_Complete Summaries.xlsx", sheet = 'gpa2_s')
mas_non_stem_gpa2 <- read_excel("Mas_Complete Summaries.xlsx", sheet = 'gpa2_n')

mas_ttd_stats <- read_excel("Mas_Missing_TTD_Stats.xlsx", sheet = 'ttd_stats')
mas_stem_ttd_stats <- read_excel("Mas_Missing_TTD_Stats.xlsx", sheet = 'ttd_stats_s')
mas_non_stem_ttd_stats <- read_excel("Mas_Missing_TTD_Stats.xlsx", sheet = 'ttd_stats_n')

mas_ttd <- read_excel("Mas_Complete Summaries.xlsx", sheet = 'ttd')
mas_stem_ttd <- read_excel("Mas_Complete Summaries.xlsx", sheet = 'ttd_s')
mas_non_stem_ttd <- read_excel("Mas_Complete Summaries.xlsx", sheet = 'ttd_n')

mas_urm <- read_excel("Mas_Complete Summaries.xlsx", sheet = 'urm')
mas_stem_urm <- read_excel("Mas_Complete Summaries.xlsx", sheet = 'urm_s')
mas_non_stem_urm <- read_excel("Mas_Complete Summaries.xlsx", sheet = 'urm_n')

mas_gender <- read_excel("Mas_Complete Summaries.xlsx", sheet = 'gender')
mas_stem_gender <- read_excel("Mas_Complete Summaries.xlsx", sheet = 'gender_s')
mas_non_stem_gender <- read_excel("Mas_Complete Summaries.xlsx", sheet = 'gender_n')

mas_8 <- read_excel("Mas_Completion_Stats.xlsx", sheet = '8')
mas_stem_8 <- read_excel("Mas_Completion_Stats.xlsx", sheet = '8_s')
mas_non_stem_8 <- read_excel("Mas_Completion_Stats.xlsx", sheet = '8_n')
mas_10 <- read_excel("Mas_Completion_Stats.xlsx", sheet = '10')
mas_stem_10 <- read_excel("Mas_Completion_Stats.xlsx", sheet = '10_s')
mas_non_stem_10 <- read_excel("Mas_Completion_Stats.xlsx", sheet = '10_n')

mas_completed_8 <- read_excel("Mas_Complete Summaries.xlsx", sheet = 'completed_8')
mas_stem_completed_8 <- read_excel("Mas_Complete Summaries.xlsx", sheet = 'completed_8_s')
mas_non_stem_completed_8 <- read_excel("Mas_Complete Summaries.xlsx", sheet = 'completed_8_n')

mas_completed_10 <- read_excel("Mas_Complete Summaries.xlsx", sheet = 'completed_10')
mas_stem_completed_10 <- read_excel("Mas_Complete Summaries.xlsx", sheet = 'completed_10_s')
mas_non_stem_completed_10 <- read_excel("Mas_Complete Summaries.xlsx", sheet = 'completed_10_n')

mas_sep_list <- list()
mas_stem_sep_list <- list()
mas_non_stem_sep_list <- list()
mas_sep_list <- list()
mas_stem_sep_list <- list()
mas_non_stem_sep_list <- list()
for (i in 1:10) {
  mas_sep_list[[i]] <- read_excel("Mas_Complete Summaries.xlsx", sheet = paste0("sep", i))
  mas_stem_sep_list[[i]] <- read_excel("Mas_Complete Summaries.xlsx", sheet = paste0("sep", i, "_s"))
  mas_non_stem_sep_list[[i]] <- read_excel("Mas_Complete Summaries.xlsx", sheet = paste0("sep", i, "_n"))
}


### ST Change

mas_st_change_summary <- read_excel("Mas_ST_Change_Complete Summaries.xlsx", sheet = 'stats')
mas_st_change_stem_summary <- read_excel("Mas_ST_Change_Complete Summaries.xlsx", sheet = 'stats_s')
mas_st_change_non_stem_summary <- read_excel("Mas_ST_Change_Complete Summaries.xlsx", sheet = 'stats_n')
mas_st_change_summary_1 <- read_excel("Mas_ST_Change_Complete Summaries.xlsx", sheet = 'stats_1')
mas_st_change_stem_summary_1 <- read_excel("Mas_ST_Change_Complete Summaries.xlsx", sheet = 'stats_s_1')
mas_st_change_non_stem_summary_1 <- read_excel("Mas_ST_Change_Complete Summaries.xlsx", sheet = 'stats_n_1')
mas_st_change_summary_0 <- read_excel("Mas_ST_Change_Complete Summaries.xlsx", sheet = 'stats_0')
mas_st_change_stem_summary_0 <- read_excel("Mas_ST_Change_Complete Summaries.xlsx", sheet = 'stats_s_0')
mas_st_change_non_stem_summary_0 <- read_excel("Mas_ST_Change_Complete Summaries.xlsx", sheet = 'stats_n_0')

mas_st_change_anal_sum <- read_excel("Mas_ST_Change_Complete Summaries.xlsx", sheet = 'summary')

mas_st_change_miss1 <- read_excel("Mas_ST_Change_Reasons for Missing Data.xlsx", sheet = 'miss1')
mas_st_change_miss2 <- read_excel("Mas_ST_Change_Reasons for Missing Data.xlsx", sheet = 'miss2')
mas_st_change_stem_miss1 <- read_excel("Mas_ST_Change_Reasons for Missing Data.xlsx", sheet = 'miss1_s')
mas_st_change_stem_miss2 <- read_excel("Mas_ST_Change_Reasons for Missing Data.xlsx", sheet = 'miss2_s')
mas_st_change_non_stem_miss1 <- read_excel("Mas_ST_Change_Reasons for Missing Data.xlsx", sheet = 'miss1_n')
mas_st_change_non_stem_miss2 <- read_excel("Mas_ST_Change_Reasons for Missing Data.xlsx", sheet = 'miss2_n')

mas_st_change_gpa1 <- read_excel("Mas_ST_Change_Complete Summaries.xlsx", sheet = 'gpa1')
mas_st_change_stem_gpa1 <- read_excel("Mas_ST_Change_Complete Summaries.xlsx", sheet = 'gpa1_s')
mas_st_change_non_stem_gpa1 <- read_excel("Mas_ST_Change_Complete Summaries.xlsx", sheet = 'gpa1_n')
mas_st_change_gpa2 <- read_excel("Mas_ST_Change_Complete Summaries.xlsx", sheet = 'gpa2')
mas_st_change_stem_gpa2 <- read_excel("Mas_ST_Change_Complete Summaries.xlsx", sheet = 'gpa2_s')
mas_st_change_non_stem_gpa2 <- read_excel("Mas_ST_Change_Complete Summaries.xlsx", sheet = 'gpa2_n')

mas_st_change_ttd_stats <- read_excel("Mas_Missing_TTD_Stats.xlsx", sheet = 'ttd_st_change_stats')
mas_st_change_stem_ttd_stats <- read_excel("Mas_Missing_TTD_Stats.xlsx", sheet = 'ttd_st_change_stats_s')
mas_st_change_non_stem_ttd_stats <- read_excel("Mas_Missing_TTD_Stats.xlsx", sheet = 'ttd_st_change_stats_n')

mas_st_change_ttd <- read_excel("Mas_ST_Change_Complete Summaries.xlsx", sheet = 'ttd')
mas_st_change_stem_ttd <- read_excel("Mas_ST_Change_Complete Summaries.xlsx", sheet = 'ttd_s')
mas_st_change_non_stem_ttd <- read_excel("Mas_ST_Change_Complete Summaries.xlsx", sheet = 'ttd_n')

mas_st_change_urm <- read_excel("Mas_ST_Change_Complete Summaries.xlsx", sheet = 'urm')
mas_st_change_stem_urm <- read_excel("Mas_ST_Change_Complete Summaries.xlsx", sheet = 'urm_s')
mas_st_change_non_stem_urm <- read_excel("Mas_ST_Change_Complete Summaries.xlsx", sheet = 'urm_n')

mas_st_change_gender <- read_excel("Mas_ST_Change_Complete Summaries.xlsx", sheet = 'gender')
mas_st_change_stem_gender <- read_excel("Mas_ST_Change_Complete Summaries.xlsx", sheet = 'gender_s')
mas_st_change_non_stem_gender <- read_excel("Mas_ST_Change_Complete Summaries.xlsx", sheet = 'gender_n')

mas_st_change_8 <- read_excel("Mas_Completion_Stats.xlsx", sheet = 'st_change_8')
mas_st_change_stem_8 <- read_excel("Mas_Completion_Stats.xlsx", sheet = 'st_change_8_s')
mas_st_change_non_stem_8 <- read_excel("Mas_Completion_Stats.xlsx", sheet = 'st_change_8_n')
mas_st_change_10 <- read_excel("Mas_Completion_Stats.xlsx", sheet = 'st_change_10')
mas_st_change_stem_10 <- read_excel("Mas_Completion_Stats.xlsx", sheet = 'st_change_10_s')
mas_st_change_non_stem_10 <- read_excel("Mas_Completion_Stats.xlsx", sheet = 'st_change_10_n')

mas_st_change_completed_8 <- read_excel("Mas_ST_Change_Complete Summaries.xlsx", sheet = 'completed_8')
mas_st_change_stem_completed_8 <- read_excel("Mas_ST_Change_Complete Summaries.xlsx", sheet = 'completed_8_s')
mas_st_change_non_stem_completed_8 <- read_excel("Mas_ST_Change_Complete Summaries.xlsx", sheet = 'completed_8_n')

mas_st_change_completed_10 <- read_excel("Mas_ST_Change_Complete Summaries.xlsx", sheet = 'completed_10')
mas_st_change_stem_completed_10 <- read_excel("Mas_ST_Change_Complete Summaries.xlsx", sheet = 'completed_10_s')
mas_st_change_non_stem_completed_10 <- read_excel("Mas_ST_Change_Complete Summaries.xlsx", sheet = 'completed_10_n')

mas_st_change_sep_list <- list()
mas_st_change_stem_sep_list <- list()
mas_st_change_non_stem_sep_list <- list()
mas_st_change_sep_list <- list()
mas_st_change_stem_sep_list <- list()
mas_st_change_non_stem_sep_list <- list()
for (i in 1:10) {
  mas_st_change_sep_list[[i]] <- read_excel("Mas_ST_Change_Complete Summaries.xlsx", sheet = paste0("sep", i))
  mas_st_change_stem_sep_list[[i]] <- read_excel("Mas_ST_Change_Complete Summaries.xlsx", sheet = paste0("sep", i, "_s"))
  mas_st_change_non_stem_sep_list[[i]] <- read_excel("Mas_ST_Change_Complete Summaries.xlsx", sheet = paste0("sep", i, "_n"))
}



# ===============================================
# Define UserInterface "ui" for application
# ===============================================


ui <- fluidPage(
  
  titlePanel("Association of Standardized Test Score Requirements with Graduate Student Academic Outcomes and Diversity"),
  
  fluidRow(
    column(3,
           radioButtons(inputId = "degree", 
                        label = "Select Degree Type", 
                        choices = list("Master" = "Master",
                                       "Doctorate" = "Doctorate"), 
                        selected = "Doctorate")
    ),
    column(3,
           radioButtons(inputId = "stem", 
                        label = "Select major types", 
                        choices = list("All" = "All",
                                       "STEM" = "STEM",
                                       "Non-STEM" = "Non-STEM"), 
                        selected = "All")
    ),
    column(3,
           checkboxInput(inputId = "change_only", 
                         label = "Only include departments with test requirement changes for sensitivity analyses", 
                         value = FALSE, 
                         width = NULL)
    )
  ),
  
  hr(),
  h3("Link to ST Requirements"),
  uiOutput("st_req"),
  hr(),    
  
  tabsetPanel(type = "tabs",
              tabPanel("Sample Size Flow",
                       img(src = 'Sample Size Flow Chart.svg', height = "1800px", width = "1600px")
              ),
              tabPanel("Descriptive statistics", 
                       h3("Summary of Statistics"),
                       tabsetPanel(
                         tabPanel('All',
                                  reactableOutput("stats_tbl"),
                                  hr(),
                                  radioButtons(inputId = "year1", 
                                               label = "Select year for GPA analysis", 
                                               choices = list("Year 1 GPA" = "Year 1 GPA",
                                                              "Year 2 GPA" = "Year 2 GPA"), 
                                               selected = "Year 1 GPA"),
                                  fluidRow(
                                    column(6,
                                           h4("Distribution of GPA"),
                                           uiOutput("gpa_hist")
                                    ),
                                    column(6,
                                           h4("Distribution of Time-to-Degree"),
                                           uiOutput("time_hist")
                                    )
                                  )
                                  ),
                         tabPanel('ST Required',
                                  reactableOutput("stats_tbl_1"),
                                  hr(),
                                  radioButtons(inputId = "year2", 
                                               label = "Select year for GPA analysis", 
                                               choices = list("Year 1 GPA" = "Year 1 GPA",
                                                              "Year 2 GPA" = "Year 2 GPA"), 
                                               selected = "Year 1 GPA"),
                                  fluidRow(
                                    column(6,
                                           h4("Distribution of GPA"),
                                           uiOutput("gpa_hist_1")
                                    ),
                                    column(6,
                                           h4("Distribution of Time-to-Degree"),
                                           uiOutput("time_hist_1")
                                    )
                                  )
                         ),
                         tabPanel('ST Not Required',
                                  reactableOutput("stats_tbl_0"),
                                  hr(),
                                  radioButtons(inputId = "year3", 
                                               label = "Select year for GPA analysis", 
                                               choices = list("Year 1 GPA" = "Year 1 GPA",
                                                              "Year 2 GPA" = "Year 2 GPA"), 
                                               selected = "Year 1 GPA"),
                                  fluidRow(
                                    column(6,
                                           h4("Distribution of GPA"),
                                           uiOutput("gpa_hist_0")
                                    ),
                                    column(6,
                                           h4("Distribution of Time-to-Degree"),
                                           uiOutput("time_hist_0")
                                    )
                                  )
                         )
                       )
              ),
              tabPanel("Summary of Analysis",
                       h3("Against st_required,
                          coefficient for linear regression,
                          marginal effect for logistic regression
                          (p-value in parentheses)"),
                       reactableOutput("anal_sum")
              ),
              tabPanel("GPA: Linear Regression",
                       h3("GPA (measured at the end of the 1st and 2nd year for programs that last 2 years or more)"),
                       radioButtons(inputId = "year4", 
                                    label = "Select year", 
                                    choices = list("Year 1" = "Year 1",
                                                   "Year 2" = "Year 2"), 
                                    selected = "Year 1"),
                       h4("Reasons for missing data records"),
                       echarts4rOutput("miss_plot"),
                       hr(),
                       h4("Statistics"),
                       reactableOutput('gpa_tbl')
              ),
              tabPanel("Separation: Logistic Regression",
                       h3("Whether the student has separated from the program"),
                       sliderInput("sep_year", 
                                   "Select year of separation:",
                                   min = 1, max = 10,
                                   value = 1),
                       reactableOutput('sep_tbl')
              ),
              tabPanel("Time-to-Degree: Linear Regression",
                       h3("Time-to-degree (measured in quarters)"),
                       hr(),
                       h4("Breakdown of missing TIME_DEG data"),
                       echarts4rOutput("ttd_breakdown"),
                       hr(),
                       h4("Linear Regression"),
                       reactableOutput("ttd_tbl"),
                       # hr(),
                       # h4("Survival Analysis"),
                       #reactableOutput("ttd_surv_tbl")
              ),
              tabPanel("URM: Logistic Regression",
                       h3("Whether the student is from a domestic underrepresented group"),
                       reactableOutput("urm_tbl")),
              tabPanel("Gender: Logistic Regression",
                       h3("Whether the student is non-male"),
                       reactableOutput("gender_tbl")),
              tabPanel("Completion: Logistic Regression",
                       tabsetPanel(
                         tabPanel('Completed within 8 Years',
                                   h3("Whether the student has completed the program within 8 years"),
                                   hr(),
                                   h4("Breakdown of completion data"),
                                   echarts4rOutput("completed_8_breakdown"),
                                   hr(),
                                   h4("Statistics"),
                                   reactableOutput("completed_8_tbl")
                         ),
                         tabPanel('Completed within 10 Years',
                                  h3("Whether the student has completed the program within 10 years"),
                                  hr(),
                                  h4("Breakdown of completion data"),
                                  echarts4rOutput("completed_10_breakdown"),
                                  hr(),
                                  h4("Statistics"),
                                  reactableOutput("completed_10_tbl")
                         )
                         
                       )
                       
              ),
              
  )
)







# ===============================================
# Define Server "server" logic
# ===============================================



server <- function(input, output) {
  
  output$st_req <- renderUI({
    
    if (input$degree == "Master") {
      
      a("Master's Programs", 
        href = "https://docs.google.com/spreadsheets/d/1MIO1QZXL8sMhCfDzIPPSMsiyBCAce-CQ/edit?usp=drive_link&ouid=110609596162251316147&rtpof=true&sd=true", 
        target = "_blank")
      
    } else {
      
      a("Doctorate's Programs", 
        href = "https://docs.google.com/spreadsheets/d/1HbtziVALMDCCsofnjnLiFyy3Rl24MWHm/edit?usp=drive_link&ouid=110609596162251316147&rtpof=true&sd=true", 
        target = "_blank")
      
    }
    
  })
  
  output$gpa_hist <- renderUI({
    img_src <- paste0(ifelse(input$degree == "Master", "mas_", "doc_"), 
                      ifelse(input$change_only, "st_change_", ""),
                      ifelse(input$stem == "All", "", ifelse(input$stem == "STEM", "stem_", "non_stem_")),
                      ifelse(input$year1 == "Year 1 GPA", "gpa1_", "gpa2_"),
                      "hist.png")
    tags$img(src = img_src, height = "400px", width = "400px")
  })
  
  output$gpa_hist_1 <- renderUI({
    img_src <- paste0(ifelse(input$degree == "Master", "mas_", "doc_"), 
                      ifelse(input$change_only, "st_change_", ""),
                      ifelse(input$stem == "All", "", ifelse(input$stem == "STEM", "stem_", "non_stem_")),
                      ifelse(input$year2 == "Year 1 GPA", "gpa1_", "gpa2_"),
                      "hist_1.png")
    tags$img(src = img_src, height = "400px", width = "400px")
  })
  
  output$gpa_hist_0 <- renderUI({
    img_src <- paste0(ifelse(input$degree == "Master", "mas_", "doc_"), 
                      ifelse(input$change_only, "st_change_", ""),
                      ifelse(input$stem == "All", "", ifelse(input$stem == "STEM", "stem_", "non_stem_")),
                      ifelse(input$year3 == "Year 1 GPA", "gpa1_", "gpa2_"),
                      "hist_0.png")
    tags$img(src = img_src, height = "400px", width = "400px")
  })
  
  output$time_hist <- renderUI({
    img_src <- paste0(ifelse(input$degree == "Master", "mas_", "doc_"), 
                      ifelse(input$change_only, "st_change_", ""),
                      ifelse(input$stem == "All", "", ifelse(input$stem == "STEM", "stem_", "non_stem_")),
                      "time_hist.png")
    tags$img(src = img_src, height = "400px", width = "400px")
  })
  
  output$time_hist_1 <- renderUI({
    img_src <- paste0(ifelse(input$degree == "Master", "mas_", "doc_"), 
                      ifelse(input$change_only, "st_change_", ""),
                      ifelse(input$stem == "All", "", ifelse(input$stem == "STEM", "stem_", "non_stem_")),
                      "time_hist_1.png")
    tags$img(src = img_src, height = "400px", width = "400px")
  })
  
  output$time_hist_0 <- renderUI({
    img_src <- paste0(ifelse(input$degree == "Master", "mas_", "doc_"), 
                      ifelse(input$change_only, "st_change_", ""),
                      ifelse(input$stem == "All", "", ifelse(input$stem == "STEM", "stem_", "non_stem_")),
                      "time_hist_0.png")
    tags$img(src = img_src, height = "400px", width = "400px")
  })
  
  output$stats_tbl <- renderReactable({
    df_name <- paste0(ifelse(input$degree == "Master", "mas_", "doc_"), 
                      ifelse(input$change_only, "st_change_", ""),
                      ifelse(input$stem == "All", "", ifelse(input$stem == "STEM", "stem_", "non_stem_")),
                      "summary")
    reactable(get(df_name), columns = create_col_defs(get(df_name)))
  })
  
  output$stats_tbl_1 <- renderReactable({
    df_name <- paste0(ifelse(input$degree == "Master", "mas_", "doc_"), 
                      ifelse(input$change_only, "st_change_", ""),
                      ifelse(input$stem == "All", "", ifelse(input$stem == "STEM", "stem_", "non_stem_")),
                      "summary_1")
    reactable(get(df_name), columns = create_col_defs(get(df_name)))
  })
  
  output$stats_tbl_0 <- renderReactable({
    df_name <- paste0(ifelse(input$degree == "Master", "mas_", "doc_"), 
                      ifelse(input$change_only, "st_change_", ""),
                      ifelse(input$stem == "All", "", ifelse(input$stem == "STEM", "stem_", "non_stem_")),
                      "summary_0")
    reactable(get(df_name), columns = create_col_defs(get(df_name)))
  })
  
  output$anal_sum <- renderReactable({
    df_name <- paste0(ifelse(input$degree == "Master", "mas_", "doc_"),
                      ifelse(input$change_only, "st_change_", ""),
                      "anal_sum")
    reactable(get(df_name), columns = create_col_defs(get(df_name)))
  })
  
  output$miss_plot <- renderEcharts4r({
    df_name <- paste0(ifelse(input$degree == "Master", "mas_", "doc_"),
                      ifelse(input$change_only, "st_change_", ""),
                      ifelse(input$stem == "All", "", ifelse(input$stem == "STEM", "stem_", "non_stem_")),
                      ifelse(input$year4 == "Year 1", "miss1", "miss2"))
    make_donut(get(df_name))
  })
  
  
  # Render GPA table
  output$gpa_tbl <- renderReactable({
    df_name <- paste0(ifelse(input$degree == "Master", "mas_", "doc_"),
                      ifelse(input$change_only, "st_change_", ""),
                      ifelse(input$stem == "All", "", ifelse(input$stem == "STEM", "stem_", "non_stem_")),
                      ifelse(input$year4 == "Year 1", "gpa1", "gpa2"))
    reactable(get(df_name), columns = create_col_defs(get(df_name)))
  })
  
  # Render Separation table
  output$sep_tbl <- renderReactable({
    if (input$degree == "Master") {
      if (input$change_only) {
        df_list <- mas_st_change_sep_list
      } else if (input$stem == "STEM") {
        df_list <- mas_stem_sep_list
      } else if (input$stem == "Non-STEM") {
        df_list <- mas_non_stem_sep_list
      } else {
        df_list <- mas_sep_list
      }
    } else {
      if (input$change_only) {
        df_list <- doc_st_change_sep_list
      } else if (input$stem == "STEM") {
        df_list <- doc_stem_sep_list
      } else if (input$stem == "Non-STEM") {
        df_list <- doc_non_stem_sep_list
      } else {
        df_list <- doc_sep_list
      }
    }
    
    df <- df_list[[input$sep_year]]
    reactable(df, columns = create_col_defs(df))
  })
  
  
  # Render Time-to-Degree breakdown table
  output$ttd_breakdown <- renderEcharts4r({
    df_name <- paste0(ifelse(input$degree == "Master", "mas_", "doc_"),
                      ifelse(input$change_only, "st_change_", ""),
                      ifelse(input$stem == "All", "", ifelse(input$stem == "STEM", "stem_", "non_stem_")),
                      "ttd_stats")
    make_donut(get(df_name))
  })
  
  # Render Time-to-Degree table
  output$ttd_tbl <- renderReactable({
    df_name <- paste0(ifelse(input$degree == "Master", "mas_", "doc_"),
                      ifelse(input$change_only, "st_change_", ""),
                      ifelse(input$stem == "All", "", ifelse(input$stem == "STEM", "stem_", "non_stem_")),
                      "ttd")
    reactable(get(df_name), columns = create_col_defs(get(df_name)))
  })
  
  # Render URM table
  output$urm_tbl <- renderReactable({
    df_name <- paste0(ifelse(input$degree == "Master", "mas_", "doc_"),
                      ifelse(input$change_only, "st_change_", ""),
                      ifelse(input$stem == "All", "", ifelse(input$stem == "STEM", "stem_", "non_stem_")),
                      "urm")
    reactable(get(df_name), columns = create_col_defs(get(df_name)))
  })
  
  # Render Gender table
  output$gender_tbl <- renderReactable({
    df_name <- paste0(ifelse(input$degree == "Master", "mas_", "doc_"),
                      ifelse(input$change_only, "st_change_", ""),
                      ifelse(input$stem == "All", "", ifelse(input$stem == "STEM", "stem_", "non_stem_")),
                      "gender")
    reactable(get(df_name), columns = create_col_defs(get(df_name)))
  })
  
  output$completed_8_breakdown <- renderEcharts4r({
    df_name <- paste0(ifelse(input$degree == "Master", "mas_", "doc_"),
                      ifelse(input$change_only, "st_change_", ""),
                      ifelse(input$stem == "All", "", ifelse(input$stem == "STEM", "stem_", "non_stem_")),
                      "8")
    make_donut(get(df_name))
  })
  
  output$completed_8_tbl <- renderReactable({
    df_name <- paste0(ifelse(input$degree == "Master", "mas_", "doc_"),
                      ifelse(input$change_only, "st_change_", ""),
                      ifelse(input$stem == "All", "", ifelse(input$stem == "STEM", "stem_", "non_stem_")),
                      "completed_8")
    reactable(get(df_name), columns = create_col_defs(get(df_name)))
  })
  
  output$completed_10_breakdown <- renderEcharts4r({
    df_name <- paste0(ifelse(input$degree == "Master", "mas_", "doc_"),
                      ifelse(input$change_only, "st_change_", ""),
                      ifelse(input$stem == "All", "", ifelse(input$stem == "STEM", "stem_", "non_stem_")),
                      "10")
    make_donut(get(df_name))
  })
  
  output$completed_10_tbl <- renderReactable({
    df_name <- paste0(ifelse(input$degree == "Master", "mas_", "doc_"),
                      ifelse(input$change_only, "st_change_", ""),
                      ifelse(input$stem == "All", "", ifelse(input$stem == "STEM", "stem_", "non_stem_")),
                      "completed_10")
    reactable(get(df_name), columns = create_col_defs(get(df_name)))
  })
  
  
}



# Run the application 
shinyApp(ui = ui, server = server)




