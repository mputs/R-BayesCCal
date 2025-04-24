.onLoad <- function(...) {
	reticulate::use_virtualenv("env", required = TRUE)

	# Optional: check Python version
	py_version <- reticulate::py_config()$version
	if (py_version < '3.0') stop("This package requires Python >= 3.0. Found: ", py_version)

	# Optional: check for required Python module
	if (!reticulate::py_module_available(c("BayesCCal", "pandas"))) {
		message("Python module 'BayesCCal' is not available.", "Please use install_BayesCCal() to install it.")
	}
	assign("env_name", "", envir = .BCC)
}

#' @export
#' @rdname tmap_internal
.BCC = new.env(FALSE, parent = globalenv())
