predict_calibrated <- function(model, new_data, train_data, train_labels) {
	# Determine outcome variable name
	outcome_var <- NULL

	if (inherits(model, "train")) {
		outcome_var <- tryCatch({
			if (!is.null(model$terms)) {
				as.character(model$terms[[2]])
			} else if (!is.null(model$finalModel$terms)) {
				as.character(model$finalModel$terms[[2]])
			} else if (!is.null(model$trainingData)) {
				".outcome"
			} else {
				NULL
			}
		}, error = function(e) NULL)

	} else if (inherits(model, "workflow")) {
		outcome_var <- tryCatch({
			blueprint <- model$pre$mold$blueprint
			names(blueprint$ptypes$outcomes)[1]
		}, error = function(e) NULL)
	}

	# Remove outcome column from new_data if present
	if (!is.null(outcome_var) && outcome_var %in% names(new_data)) {
		new_data <- new_data[, setdiff(names(new_data), outcome_var), drop = FALSE]
	}

	# Predict probabilities on training data
	if (inherits(model, "workflow")) {
		probabilities <- predict(model, new_data = train_data, type = "prob")
	} else {
		probabilities <- predict(model, newdata = train_data, type = "prob")
	}

	# Convert labels to binary 0/1 (1 = positive class)
	train_labels <- factor(train_labels)
	positive_class <- levels(train_labels)[1]
	negative_class <- setdiff(levels(train_labels), positive_class)
	y <- as.integer(!(train_labels == positive_class))  # 1 = positive class

	# Calibrate
	cal <- Rcalibrator_binary()
	if (inherits(model, "workflow")) {
		cal$calcDensities(as.numeric(probabilities[[paste0(".pred_", positive_class)]]), y)
	} else {
		cal$calcDensities(as.numeric(probabilities[[positive_class]]), y)
	}

	# Predict on new data
	if (inherits(model, "workflow")) {
		predict_probas <- predict(model, new_data = new_data, type = "prob")
		pred_probs <- as.numeric(predict_probas[[paste0(".pred_", positive_class)]])
	} else {
		predict_probas <- predict(model, newdata = new_data, type = "prob")
		pred_probs <- as.numeric(predict_probas[[positive_class]])
	}

	calibrated_probs <- cal$predict_proba(pred_probs)

	# Return original + calibrated output (with clean names)
	calibrated_df <- tibble(
		!!positive_class := calibrated_probs,
		!!negative_class := 1 - calibrated_probs
	)

	list(
		probs_orig = predict_probas,
		probs_cali = calibrated_df,
		proportion = cal$getProportion(pred_probs)
	)
}
