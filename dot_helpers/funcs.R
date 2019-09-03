#Ryan's Commonly Used Data Exploration Functions

#' Table Function with useNA = "ifany"
#'
#' Straight-forward wrapper of \code{table} using useNA = "ifany" by
#' default
#'
#'
#' @inherit base::table
#'
#' @seealso \code{\link{table}}
rb_table <- function(...,
                    exclude = if (useNA == "no") c(NA, NaN),
                    useNA = "ifany",
                    dnn = names(...),
                    deparse.level = 1){
  return(table(...,
               exclude       = exclude,
               useNA         = useNA,
               dnn           = dnn,
               deparse.level = deparse.level))
}

#' Test if Two Vectors Are The Same When Sorted
#'
#' Check if two vectors have the same contents, allowing for reordering
#'
#' @param v1 A vector to compare
#' @param v2 A vector to compare
#'
rb_vec_sorted_equal <- function(v1, v2){
  if(length(v1) != length(v2)){
    return(FALSE)
  } else if (all(rbtable(v1) == rbtable(v2))){
    return(TRUE)
  } else {
    return(FALSE)
  }
}

#' Test if Two Dataframes Are Equal
#'
#' Check if two dataframes are equal, looking only at the values in the columns
#' and rows. (factors, column names, row names, attributes are ignored).
#'
#' @param df1 A dataframe to compare
#' @param df2 A dataframe to compare
#'
#' @details Validates: \itemize{
#'   \item DFs are the same dimensions
#'   \item NA's are in the same locations
#'   \item All non NAs are the same value
#'   \item NaNs are in the same location
#' }
#'
rb_df_equal <- function(df1, df2){
  print("This is really slow and needs to be rewritten using lapply-like constructions")
  if(any(dim(df1) != dim(df2))){
    return(FALSE)
  } else if ( all(df1 == df2, na.rm = TRUE) &
              all(is.na(df1) == is.na(df2)) &
              all(apply(df1, 2, is.nan) == apply(df2, 2, is.nan))){
    return(TRUE)
  } else {
    return(FALSE)
  }
}

#' Print a Vector Wit or without Quoting and Return Delimited
#'
#' Given a vector, print all values return delimited in order
#'
#' @param v Vector to print
#' @param sep Additional seperator to preceed the newline when printing
#' @param quote String to preceed and follow each element. For example "'".
#'
rb_vec_print_ret_delimited <- function(v, sep = '', quote = ''){
  if (quote != ''){
    v <- paste0(quote, v, quote)
  }
  collapse <- paste0(sep, "\n")
  return(cat(paste0(v, collapse = collapse)))
}


#' Print a Sorted Vector with or without Quoting and Return Delimited
#'
#' Given a vector, print all values return delimited in sorted order
#'
#' @param v Vector to print
#' @param sep Additional seperator to preceed the newline when printing
#' @param quote String to preceed and follow each element. For example "'".
#'
rb_vec_print_sort_ret_delimited <- function(v, sep = '', quote = ''){
  if (quote != ''){
    v <- paste0(quote, v, quote)
  }
  collapse <- paste0(sep, "\n")
  return(cat(paste0(sort(v), collapse = collapse)))
}


#' Get a datetime in a nice format to put in filenames
#'
#' Get a datetime in a nice format to put in filenames'
#'
rb_dt_for_file <- function(time = Sys.time(), use_ms=FALSE){
  if(use_ms){
    format_str <- '%Y%m%d_%H%M%OS6'
  } else {
    format_str <- '%Y%m%d_%H%M%S'
  }
  time <- strftime(time, format = format_str)
  time <- gsub(pattern = "\\.", replacement = "_", x = time)
  return(time)
}
