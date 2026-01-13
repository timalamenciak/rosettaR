#' Change a data frame into a series of statements based on templates.
#'
#' @param df A data frame with headers that match the slots in a template. The
#' dataframe must have one column called "TemplateID" that contains the ID
#' of the template used to interpret the row.
#' @param templates A Rosetta Statement template library created by the
#' initLibrary function.
#'
#' @returns A data frame statement library containing the statements and
#' associated templates.
#' @export
#'
#' @examples
#' templates <- init_library()
#' templates <- add_template(templates, apple_template)
#' df <- data.frame(object = "Apple X",
#'                               quality = "weight", value="100.2",
#'                              unit="grams", TemplateID = "1")
#' statements <- df_to_statements(df,templates)
df_to_statements <- function(df, templates) {
  results <- data.frame(TemplateID = as.character(),
                        statement = as.character())
  #Verify that the templates DF is in fact a proper templates DF.
  if (!identical(colnames(templates),
                 c("TemplateID", "templateText"))){
  stop(paste0("Template library format is incorrect. Did you create it with
                rosettaR::initLibrary()?"))
  }
  df_names <- colnames(df)
  TemplateID <- NULL #this fixes a silly warning potentially
  for (i in seq_len(nrow(df))) {
    row <- df[i,]
    template <- dplyr::filter(templates, TemplateID == row$TemplateID)
    statement <- jinjar::render(template$templateText, !!!as.list(row))
    out_df <- data.frame(TemplateID = row$TemplateID, statement = statement)
    results <- rbind(results, out_df)
  }

  return(results)
}
