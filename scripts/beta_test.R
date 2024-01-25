mean <-0.94
upper_CI <- 0.95
lower_CI <- 0.93
  
SE <- (upper_CI - lower_CI) / 3.92

var <- SE^2

alpha = mean * ((1 - mean) / var - 1 / mean)
beta = (1 - mean) * ((1 -mean) /var - 1 / (1 - mean))

# Generate 1000 random values
random_values <- rbeta(n = 1000, shape1 = alpha, shape2 = beta)

# Use plot() for a basic density plot
plot(density(random_values), main = "Beta Distribution Density Plot", xlab = "x")
