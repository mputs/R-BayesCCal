.onLoad <- function(...) {
	conda_env <- "BCCenv"
	virtualenv <- "BCCenv"
	env_set <- FALSE

	# Try conda environment
	try({
		suppressWarnings(reticulate::use_condaenv(conda_env, required = TRUE))
		env_set <- TRUE
	}, silent = TRUE)

	# Fallback to virtualenv only if conda fails
	if (!env_set && reticulate::virtualenv_exists(virtualenv)) {
		try({
			suppressWarnings(reticulate::use_virtualenv(virtualenv, required = TRUE))
			env_set <- TRUE
			cli::cli_alert_info("Fell back to using virtualenv {.val {virtualenv}}.")
		}, silent = TRUE)
	}

	# Warn if Python module is not available
	if (!reticulate::py_module_available("BayesCCal")) {
		cli::cli_alert_warning(c(
			"!" = "Python module {.pkg BayesCCal} not found in the active environment.",
			">" = "Run {.code install_BayesCCal()} to create the environment and install the package."
		))
	}

	if (env_set) {
		source_BCC_py()
	}

	# Track environment info
	assign("env_name", if (env_set) conda_env else NA_character_, envir = .BCC)
	assign("env_set", env_set, envir = .BCC)
}

source_BCC_py = function() {
	# Source the Python helper script
	py_script <- system.file("python", "RBayesCCal.py", package = "BayesCCal")
	if (file.exists(py_script)) {
		reticulate::source_python(py_script)
	} else {
		cli::cli_alert_warning("Python helper script not found at {.file {py_script}}.")
	}
}



#' @export
.BCC = new.env(FALSE, parent = globalenv())
