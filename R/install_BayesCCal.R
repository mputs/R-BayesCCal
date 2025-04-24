#' Install BayesCCal Python Dependencies
#'
#' Creates a virtualenv and installs the BayesCCal Python package.
#' @param envname Name of the virtualenv to create/use.
#' @param python Optional path to a Python 3 executable. If NULL, one is auto-detected.
#' @export
install_BayesCCal <- function(envname = "BCCenv", python = NULL) {

	# Try to find a suitable Python 3 binary
	if (is.null(python)) {
		py_config <- tryCatch(reticulate::py_discover_config(), error = function(e) NULL)

		if (!is.null(py_config) && py_config$version >= "3.0") {
			python <- py_config$python
			message("Using detected Python: ", python)
		} else {
			# Try some known options
			candidates <- c("python3", "/usr/bin/python3", "/opt/homebrew/bin/python3", "python")
			for (cmd in candidates) {
				if (reticulate::py_available(initialize = FALSE, python = cmd)) {
					version <- tryCatch(reticulate::py_config(python = cmd)$version, error = function(e) NULL)
					if (!is.null(version) && as.numeric(substr(version, 1, 1)) >= 3) {
						python <- cmd
						message("Using fallback Python: ", python)
						break
					}
				}
			}

			if (is.null(python)) {
				stop("Could not find a suitable Python 3 executable. Please install Python 3.")
			}
		}
	}

	# Create virtualenv if needed
	if (!reticulate::virtualenv_exists(envname)) {
		message("Creating virtualenv: ", envname)
		reticulate::virtualenv_create(envname, python = python)
	}

	# Install Python package
	message("Installing Python packages into: ", envname)
	reticulate::virtualenv_install(envname, packages = c("BayesCCal", "pandas"))

	reticulate::use_virtualenv(envname)

	.BCC$env_name = envname
	message("Done!")
}
