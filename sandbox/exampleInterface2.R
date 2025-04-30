library(caret)

# Load data
url <- "https://archive.ics.uci.edu/ml/machine-learning-databases/00267/data_banknote_authentication.txt"
data <- read.csv(url, header = FALSE)
colnames(data) <- c("variance", "skewness", "kurtosis", "entropy", "class")

# Convert class to factor and relabel levels
data$class <- as.factor(data$class)
levels(data$class) <- c("genuine", "forged") # <--- fix levels here!

# Split data
set.seed(123)
trainIndex <- createDataPartition(data$class, p = 0.8, list = FALSE)

train_data = data[trainIndex,1:4]
train_labels = data$class[trainIndex]
new_data = data[-trainIndex,1:4]

model <- caret::train(
	x = train_data,
	y = train_labels,
	method = "rf",
	trControl = trainControl(classProbs = TRUE)
)

res <- predict_calibrated(model, newdata, train_data = train_data, train_labels = train_labels)


library(tidymodels)
split <- initial_split(data, prop = 0.8, strata = "class")
train <- training(split)
test  <- testing(split)

wf <- workflow() %>%
	add_model(logistic_reg() %>% set_engine("glm") %>% set_mode("classification")) %>%
	add_formula(class ~ .)

fit <- fit(wf, data = train)

res <- predict_calibrated(fit, new_data = test, train_data = train, train_labels = train$class)


library(tidyverse)

# In a test set where y is present:
test_with_y <- test  # y (Class) still included
predict_calibrated(fit, new_data = test_with_y, train_data = train, train_labels = train$class)

# In production deployment where y is absent:
test_without_y <- dplyr::select(test, -class)
predict_calibrated(fit, new_data = test_without_y, train_data = train, train_labels = train$class)
