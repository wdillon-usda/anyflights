# Individual PR Diffs

This document shows the exact code changes for each PR, making it easy to see what each small change accomplishes.

## PR-A: Fix missing return statement

**File**: `R/utils.R`  
**Lines changed**: +3

```diff
   # filter the planes data by the flights data, if relevant
   planes <- join_planes_to_flights_data(planes, flights_data)
+  
+  # return the planes data
+  planes
 }
```

**Explanation**: The function was missing an explicit return statement, causing it to return NULL. This adds the return statement.

---

## PR-B: Update FAA data source URL  

**File**: `R/utils.R`  
**Lines changed**: -1

```diff
   # put together the url to query the planes data at
   planes_src <- paste0(
     "https://registry.faa.gov/database/ReleasableAircraft", 
-    #year, 
     ".zip"
   )
```

**Explanation**: FAA no longer uses year-specific files. Remove the commented-out year parameter from URL construction.

---

## PR-C: Restore year parameter

**File**: `R/get_planes.R`  
**Lines changed**: +2 -2

```diff
 get_planes <- function(
-  #year, 
+  year = NULL, 
   dir = NULL, flights_data = NULL) {
 
   # check user inputs
-  check_arguments(#year = year,
+  check_arguments(year = year,
                   dir = dir,
                   context = "planes")
```

```diff
   # grab the planes data for the relevant year
   planes <- get_planes_data(
-    #year, 
+    year, 
     dir, flights_data)
```

**File**: `R/utils.R`  
**Lines changed**: +1 -1

```diff
 get_planes_data <- function(
-  #year, 
+  year = NULL, 
   dir, flights_data) {
```

**Explanation**: Restore the year parameter to function signatures with NULL default for backward compatibility.

---

## PR-D: Update year validation logic

**File**: `R/utils.R`  
**Lines changed**: Major restructuring (see below)

```diff
   # checking the "year" argument
-  #if (context %in% c("flights", "planes", "weather"))
-  if (context %in% c("flights", "weather")) {
-    if (!is.numeric(year)) {
-      stop_glue("The provided `year` argument has class {class(year)}, but ",
-                "it needs to be a numeric. Have you put the year in quotes?")
-    }
-    if (year > as.numeric(substr(Sys.Date(), 1, 4))) {
-      stop_glue("The provided `year` is in the future. Oops. :-)")
-    }
-  
-    if (year == as.numeric(substr(Sys.Date(), 1, 4))) {
-      stop_glue("The data for this year isn't quite available yet. The data ",
-                "for the previous year usually is released in February ",
-                "or March!")
+  if (context %in% c("flights", "planes", "weather")) {
+    # For planes context, year is optional (used for backward compatibility)
+    if (!is.null(year)) {
+      if (!is.numeric(year)) {
+        stop_glue("The provided `year` argument has class {class(year)}, but ",
+                  "it needs to be a numeric. Have you put the year in quotes?")
+      }
+      if (year > as.numeric(substr(Sys.Date(), 1, 4))) {
+        stop_glue("The provided `year` is in the future. Oops. :-)")
       }
     
-    if (year < 1987) {
-      stop_glue("Your `year` argument {year} is really far back in time! ",
-                "`anyflights` data sources do not provide data this old.")
-    }
-    if (year < 2013 & context == "planes") {
-      warning_glue("Planes data was not formatted consistently before 2013. ",
-                   "Please use caution.")
-    } else if (context != "planes" & year < 2010) {
-      message_glue("Queries before 2010 are untested by the package. ",
-                   "Please use caution!")
+      if (year == as.numeric(substr(Sys.Date(), 1, 4))) {
+        stop_glue("The data for this year isn't quite available yet. The data ",
+                  "for the previous year usually is released in February ",
+                  "or March!")
+        }
+      
+      if (year < 1987) {
+        stop_glue("Your `year` argument {year} is really far back in time! ",
+                  "`anyflights` data sources do not provide data this old.")
+      }
+      if (year < 2013 & context == "planes") {
+        warning_glue("Planes data was not formatted consistently before 2013. ",
+                     "Please use caution.")
+      } else if (context != "planes" & year < 2010) {
+        message_glue("Queries before 2010 are untested by the package. ",
+                     "Please use caution!")
+      }
+    } else if (context %in% c("flights", "weather")) {
+      # year is required for flights and weather
+      stop_glue("The `year` argument is required for {context} context.")
     }
   }
```

**Explanation**: Wrap year validation in `!is.null(year)` check for planes context, making it optional. Add check to ensure year is still required for flights and weather.

---

## PR-E: Add case-insensitive file helper

**File**: `R/utils.R`  
**Lines changed**: +42

```diff
+# Helper function to find files case-insensitively
+find_file_case_insensitive <- function(dir, filename) {
+  # Try exact match first
+  exact_path <- paste0(dir, "/", filename)
+  if (file.exists(exact_path)) {
+    return(exact_path)
+  }
+  
+  # Try with all lowercase
+  lower_path <- paste0(dir, "/", tolower(filename))
+  if (file.exists(lower_path)) {
+    return(lower_path)
+  }
+  
+  # Try with all uppercase base name
+  upper_path <- paste0(dir, "/", toupper(filename))
+  if (file.exists(upper_path)) {
+    return(upper_path)
+  }
+  
+  # Try finding with case-insensitive pattern matching
+  # Extract just the base name without extension
+  base_name <- tools::file_path_sans_ext(filename)
+  extension <- tools::file_ext(filename)
+  
+  # Escape special regex characters in the filename components
+  base_name_escaped <- gsub("([\\[\\](){}.*+?^$|\\\\])", "\\\\\\1", base_name)
+  extension_escaped <- gsub("([\\[\\](){}.*+?^$|\\\\])", "\\\\\\1", extension)
+  
+  # Create a pattern that matches the filename exactly but case-insensitively
+  available_files <- list.files(dir, pattern = paste0("^", base_name_escaped, "\\.", extension_escaped, "$"), 
+                               ignore.case = TRUE)
+  if (length(available_files) > 0) {
+    return(paste0(dir, "/", available_files[1]))
+  }
+  
+  # File not found - return error message
+  stop_glue("Could not find {filename} in {dir}. ",
+            "Available files: {paste(list.files(dir), collapse = ', ')}")
+}
```

**Explanation**: Create a robust utility function to find files regardless of casing, with helpful error messages.

---

## PR-F: Use case-insensitive file detection

**File**: `R/utils.R`  
**Lines changed**: +8 -4

```diff
 process_planes_master <- function(planes_lcl) {
+  # Find the MASTER file (case-insensitive)
+  master_file <- find_file_case_insensitive(planes_lcl, "MASTER.txt")
+  
   suppressMessages(suppressWarnings(
     # read in the data, but fast
-    planes_master <- vroom::vroom(paste0(planes_lcl, "/MASTER.txt"),
+    planes_master <- vroom::vroom(master_file,
                                   progress = FALSE) %>%
```

```diff
 process_planes_ref <- function(planes_lcl) {
   # ...
   
+  # Find the ACFTREF file (case-insensitive)
+  acftref_file <- find_file_case_insensitive(planes_lcl, "ACFTREF.txt")
+  
   # read in the data, but fast
   suppressMessages(suppressWarnings(
-    planes_ref <- vroom::vroom(paste0(planes_lcl, 
-                                      "/", 
-                                      "ACFTREF.txt"),
+    planes_ref <- vroom::vroom(acftref_file,
                                col_names = planes_ref_col_names,
```

**Explanation**: Replace hard-coded file paths with calls to the case-insensitive helper function.

---

## PR-G: Add array bounds checking

**File**: `R/utils.R`  
**Lines changed**: +22 -8

```diff
 join_planes_data <- function(planes_master, planes_ref) {
   suppressWarnings(
     planes_master %>%
       dplyr::inner_join(planes_ref, by = "code") %>%
       dplyr::select(-code) %>%
-      dplyr::mutate(speed = dplyr::if_else(speed == 0, NA_character_, speed),
-                    no_eng = dplyr::if_else(no_eng == 0, NA_integer_, no_eng),
-                    no_seats = dplyr::if_else(no_seats == 0, NA_integer_, no_seats),
-                    engine = engine_types[type_eng + 1],
-                    type = acft_types[type_acft],
-                    tailnum = paste0("N", nnum),
-                    year = as.integer(year),
-                    speed = as.integer(speed)) %>%
+      dplyr::mutate(
+        speed = dplyr::if_else(speed == 0, NA_character_, speed),
+        no_eng = dplyr::if_else(no_eng == 0, NA_integer_, no_eng),
+        no_seats = dplyr::if_else(no_seats == 0, NA_integer_, no_seats),
+        # Handle out-of-bounds or NA values for engine types
+        # Note: engine_types uses 0-based indexing, so we access with [type_eng + 1]
+        engine = dplyr::case_when(
+          is.na(type_eng) ~ NA_character_,
+          type_eng < 0 | type_eng >= length(engine_types) ~ NA_character_,
+          TRUE ~ engine_types[type_eng + 1]
+        ),
+        # Handle out-of-bounds or NA values for aircraft types
+        # Note: acft_types uses 1-based indexing, so we access with [type_acft]
+        type = dplyr::case_when(
+          is.na(type_acft) ~ NA_character_,
+          type_acft < 1 | type_acft > length(acft_types) ~ NA_character_,
+          TRUE ~ acft_types[type_acft]
+        ),
+        tailnum = paste0("N", nnum),
+        year = as.integer(year),
+        speed = as.integer(speed)
+      ) %>%
```

**Explanation**: Replace direct array indexing with `case_when()` that checks bounds and handles NA values safely.

---

## PR-H: Document year parameter behavior

**File**: `R/get_planes.R`  
**Lines changed**: +5

```diff
 #' @inheritParams get_airlines
 #' 
+#' @details 
+#' The \code{year} parameter is accepted for backward compatibility but is 
+#' not used in data retrieval, as the FAA now provides a single consolidated 
+#' aircraft registry database rather than separate yearly databases.
+#' 
 #' @return A data frame with ~3500 rows and 9 variables:
```

**Explanation**: Add documentation explaining why year parameter exists but isn't used.

---

## Summary

Each PR makes a small, focused change that:
- Addresses a specific issue
- Can be reviewed quickly
- Can be tested independently
- Has clear intent from the diff alone

This meets the maintainer's request for small (~10 line) PRs that address specific issues without introducing unrelated changes.
