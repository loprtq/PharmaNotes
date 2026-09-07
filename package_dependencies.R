# Get files
files <- list.files(pattern = "\\.qmd$", recursive = TRUE)

if (length(files) == 0) {
  warning("No .qmd files found")
  writeLines(character(), "quarto-packages.txt")
  q(status = 0)
}

## Read files and extract lines
all_lines <- character()
for (f in files) {
  tryCatch(
    all_lines <- c(all_lines, readLines(f)),
    error = function(e) warning(sprintf("Error reading %s: %s", f, e$message))
  )
}

## Extract package names - simple pattern matching
# Look for library(package) or require(package) with optional quotes
pkgs <- character()

# Extract from library() calls
lib_pattern <- '\\blibrary\\s*\\(\\s*["\']?([A-Za-z0-9._]+)["\']?\\s*\\)'
lib_matches <- gregexpr(lib_pattern, all_lines)
lib_pkgs <- unique(gsub(lib_pattern, '\\1', all_lines[which(lengths(lib_matches) > 0)]))
lib_pkgs <- lib_pkgs[lib_pkgs != ""]

# Extract from require() calls
req_pattern <- '\\brequire\\s*\\(\\s*["\']?([A-Za-z0-9._]+)["\']?\\s*\\)'
req_matches <- gregexpr(req_pattern, all_lines)
req_pkgs <- unique(gsub(req_pattern, '\\1', all_lines[which(lengths(req_matches) > 0)]))
req_pkgs <- req_pkgs[req_pkgs != ""]

pkgs <- unique(c(lib_pkgs, req_pkgs))

# Filter out invalid or commonly excluded packages
exclude_pkgs <- c("base", "stats", "graphics", "grDevices", "utils", "datasets", 
                  "methods", "grDevices", "grid", "Matrix")
pkgs <- pkgs[!pkgs %in% exclude_pkgs]

# Additional validation - packages should not contain problematic characters
pkgs <- pkgs[grepl("^[A-Za-z0-9._]+$", pkgs)]

if (length(pkgs) > 0) {
  pkgs <- sort(unique(pkgs))
  message(sprintf("Found %d packages to install:", length(pkgs)))
  cat(paste(" -", pkgs), sep = "\n")
  writeLines(pkgs, "quarto-packages.txt")
} else {
  message("No R packages found in .qmd files")
  writeLines(character(), "quarto-packages.txt")
}
