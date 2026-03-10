library(tidyverse)
library(readxl)
library(gt)

process_raw_data <- function(file_path) {
  expected_keys <- c("Field name", "Description", "Field Type", "Data Type", "Examples")

  data <- read_excel(file_path, col_names = c("key", "value")) |>
    fill(key) |> # merge down key column
    drop_na()

  #QC
  if(!all(data$key %in% expected_keys)) {
    stop("invalid column names in data: ", paste(setdiff(data$key, expected_keys), collapse = ", "))
  }
  
  # find indices of where key column is "Field name" and split data based on those indices
  indices <- data$key == "Field name"
  data_split <- split(data, cumsum(indices))
  
  data_split_merged <- map(data_split, {
    # group by key and collapse value column into a single string
    ~ .x |>
    group_by(key) |>
    summarise(value = paste(value, collapse = "<br><br>"))
  })
  
  map_df(data_split_merged, ~ .x |> 
    pivot_wider(names_from = key, values_from = value)) |>
    select("Field name", "Description", "Field Type", "Data Type", "Examples") |>
    mutate(Examples = str_replace(Examples, "^[-]*$", NA_character_))
  }
  
data_as_gt_tables <- function(file_path) {
  data <- read_csv(file_path, show_col_types = FALSE)
  data |>
    mutate(`Field name` = factor(`Field name`, levels = unique(`Field name`))) |> # prevent auto-sorting of `Field name` column
    group_split(`Field name`) |>
    map(~ .x |>
      pivot_longer(
        cols = everything(),
        names_to = "key",
        values_to = "value"
      )) -> data_split
      
  map(data_split, {
    ~ .x |> 
    slice(-1) |> # Remove `Field name` row
    # filter rows where key = "Examples" and value is NA, as those are not relevant to show in the table
    filter(!(key == "Examples" & is.na(value))) |>
    mutate(
      value = gt::md(value), # Interpret value column as markdown
    ) |>
    gt() |>
    fmt_markdown(columns = value) |> # Render value column as markdown
    tab_style( # Make "Mandatory" values red
      locations = cells_body(
        columns = value,
        rows = value == "Mandatory"
      ),
      style = list(cell_text(color = 'red'))
    ) |>
    tab_options(
      column_labels.hidden = T, # hide key/value column label
      table.width = pct(100), # give 100% width to table
      quarto.disable_processing = TRUE # prevent quarto from messing with gt table formatting
    ) |>
    opt_stylize(style = 1) |> # Striped look
    cols_width(
      key ~ px(125) # first column fixed width
    ) |>
    cols_align(
      align = "left",
      columns = everything()
    ) |>
    tab_header(title = htmltools::tagList(
      htmltools::tags$strong(
        .x$value[.x$key == "Field name"],
        style = "font-size: 18px;"
      )
    )) |>
    opt_align_table_header(align = "left")
  })
}