# PARC TOX Template User Guide

This repository contains the Quarto code for rendering the PARC TOX Template User guide, which you can consult by clicking the link at the top-left of this GitHub page or going to <https://eu-parc.github.io/tox-template-guide> directly. 

For instructions on how to edit the guide, see below.

## Editing

To edit this book, you can directly edit the files on GitHub and commit your changes, a GitHub action will then render the updated guide (Recommended). 

Alternatively (not recommended if you've never worked with R/RStudio), you can clone this repository and make changes locally, which will give you an (almost instant) preview of your changes.
To do so, follow the instructions in the [Quarto documentation](https://quarto.org/docs/get-started/) to set up the required Quarto tools.

### Quarto Markdown

This project is a [Quarto book](https://quarto.org/docs/books/). Add chapters by creating a new `.qmd` file and listing it in the `chapters` section of `_quarto.yml` in the desired order. In the `_quarto.yml` you can also edit the authors and formatting of the book.

To write/edit Quarto Markdown (`.qmd`), please see the [Quarto Authoring](https://quarto.org/docs/authoring/) documentation.

#### Workbook tables

The workbook tables in the guide are generated from the CSV files in the `data` directory. The description column can be formatted using Markdown, see the documentation linked above for the options (**NB:** you can add paragraph breaks by using `<br><br>`).

More complex (e.g., conditional) formatting of the tables can be achieved using the `gt` package (<https://gt.rstudio.com/>). For example, we make the text red if the value is "Mandatory" using the following code in the `data_as_gt_tables()` function in `R/utils.R`:

```r
tab_style(
    locations = cells_body(
        columns = value,
        rows = value == "Mandatory"
    ),
    style = list(cell_text(color = 'red'))
) 
```