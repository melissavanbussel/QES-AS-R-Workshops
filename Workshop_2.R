# R Workshop 2: July 29th, 2021

#################### RECAP FROM WORKSHOP 1 #####################

# Comments are made with hashtags. Comments do not get evaluated as code.

# Running code in an R Script vs. in the Console
2 + 3

# To assign an object to a variable, use the assignment operator
years <- c(2010, 2020, 2021) 

# Any line of code with the assignment operator will not have output
# To view the output, type the name of the variable
years 

# Functions take input(s) and return an output 
mean(years)

# To view the documentation for a function
?mean

# Missing values are represented as NAs in R 
# Even one missing value => result returned is an NA
mean(c(1, 2, 3)) # No problem
mean(c(1, NA, 3)) # Result is NA 
# Same problem for the min(), max(), median() functions

# One option is to use the na.rm = TRUE option
mean(c(1, NA, 3), na.rm = TRUE)

# Use install.packages("packageName") to install packages
# Use library(packageName) to load installed packages
# Only needs to be done once
install.packages("tidyverse")
# Needs to be done every time you open RStudio and want to use the package
library(tidyverse) 

# Using a function from a package without loading the package: packageName::functionName
scales::dollar(123456)
# This is also useful if there are multiple packages with the same function name

# The View() function is useful for viewing dataframes
library(palmerpenguins)
View(penguins)

# Another useful function for getting quick information about dataframes:
# Shows us the number of columns/rows, variable types, and a preview 
str(penguins) # Note: tibbles are a type of data frame (much simpler/faster)

#################### INTRO TO DPLYR #####################

# The select function selects a subset of columns from a data frame
select(.data = penguins, bill_length_mm, bill_depth_mm)

# To select all columns EXCEPT for one, use the minus sign 
select(.data = penguins, -species)

# The filter function selects a subset of rows from a data frame
filter(.data = penguins, bill_length_mm >= 55)

# Multiple conditions can be combined, using logical operators 
filter(.data = penguins, bill_length_mm <= 180 | bill_length_mm >= 200)

# The pipe operator takes the object on the left 
# and passes it as the first argument to the function on the right.
# Tip: Read the %>% symbol as the word "then"
penguins %>% 
  select(bill_length_mm, bill_depth_mm) %>%
  filter(bill_length_mm >= 55)

# The above code is equivalent to (but much more compact than):
step1 <- select(penguins, bill_length_mm, bill_depth_mm)
filter(step1, bill_length_mm >= 55)

# The mutate function creates a new variable from existing variables
penguins %>% 
  mutate(bill_length_m = bill_length_mm / 1000) %>% 
  select(bill_length_m, bill_length_mm)

# The group_by and summarise functions are often used together
# group_by: splits data into groups based on categorical variable(s)
# summarise: returns a summary value for each of the groups
penguins %>% 
  group_by(species) %>%
  summarise(num_penguins = n())

# The arrange function sorts the data frame by a specified variable
# Default is in ascending order
penguins %>% 
  group_by(species) %>%
  summarise(num_penguins = n()) %>%
  arrange(num_penguins)

# To sort in descending order, use the desc() function
penguins %>% 
  group_by(species) %>%
  summarise(num_penguins = n()) %>%
  arrange(desc(num_penguins))

# The count() function is a shortcut for summarise(n = n())
penguins %>% 
  group_by(species) %>%
  count() %>%
  arrange(desc(n))

# Missing values are represented as NAs in R 
# View(penguins)
# One NA in the calculation => result returned will be an NA
penguins %>% 
  group_by(species) %>% 
  summarise(mean_body_mass = mean(body_mass_g))

# To exclude NAs in the body_mass_g variable from the calculation:
penguins %>% 
  group_by(species) %>% 
  summarise(mean_body_mass = mean(body_mass_g, na.rm = TRUE))

# To create a new data frame that removes observations with ANY missing values:
penguins2 <- penguins %>% 
  drop_na()

# Now we can compute the means without getting NAs!
penguins2 %>% 
  group_by(species) %>% 
  summarise(mean_body_mass = mean(body_mass_g))

#################### INTRO TO GGPLOT2 #####################

### LAYER 1: DATA

# Equivalent to ggplot(data = penguins2)
penguins2 %>% 
  ggplot()

### LAYER 2: AESTHETICS
penguins2 %>%
  ggplot(aes(x = flipper_length_mm,
             y = body_mass_g,
             colour = species,
             shape = species))

### LAYER 3: GEOMETRIES
penguins2 %>%
  ggplot(aes(x = flipper_length_mm,
             y = body_mass_g,
             colour = species,
             shape = species)) +
  geom_point(size = 3, alpha = 0.5)

### LAYER 4: FACETS
# Vertical facets
penguins2 %>%
  ggplot(aes(x = flipper_length_mm,
             y = body_mass_g,
             colour = species,
             shape = species)) +
  geom_point(size = 3, alpha = 0.5) +
  facet_grid(sex ~ .) # Vertical

# Horizontal facets
penguins2 %>%
  ggplot(aes(x = flipper_length_mm,
             y = body_mass_g,
             colour = species,
             shape = species)) +
  geom_point(size = 3, alpha = 0.5) +
  facet_grid(. ~ sex) # Horizontal 

# More than one facetting variable
penguins2 %>%
  ggplot(aes(x = flipper_length_mm,
             y = body_mass_g,
             colour = species,
             shape = species)) +
  geom_point(size = 3, alpha = 0.5) +
  facet_wrap(. ~ sex + year) 

### LAYER 5: STATISTICS
penguins2 %>%
  ggplot(aes(x = flipper_length_mm,
             y = body_mass_g,
             colour = species,
             shape = species)) +
  geom_point(size = 3, alpha = 0.5) +
  facet_grid(. ~ sex) +
  stat_smooth(method = "lm", se = FALSE)

### LAYER 6: COORDINATES
# Add commas to the y-axis labels
penguins2 %>%
  ggplot(aes(x = flipper_length_mm,
             y = body_mass_g,
             colour = species,
             shape = species)) +
  geom_point(size = 3, alpha = 0.5) +
  facet_grid(. ~ sex) +
  stat_smooth(method = "lm", se = FALSE) + 
  scale_y_continuous(labels = scales::comma)

# Manually change the colours for the species
penguins2 %>%
  ggplot(aes(x = flipper_length_mm,
             y = body_mass_g,
             colour = species,
             shape = species)) +
  geom_point(size = 3, alpha = 0.5) +
  facet_grid(. ~ sex) +
  stat_smooth(method = "lm", se = FALSE) + 
  scale_y_continuous(labels = scales::comma) + 
  scale_colour_manual(values = c("darkorange", "purple", "cyan4"))

### LAYER 7: THEME 
# Add labels to the plot 
penguins2 %>%
  ggplot(aes(x = flipper_length_mm,
             y = body_mass_g,
             colour = species,
             shape = species)) +
  geom_point(size = 3, alpha = 0.5) +
  facet_grid(. ~ sex) +
  stat_smooth(method = "lm", se = FALSE) + 
  scale_y_continuous(labels = scales::comma) + 
  scale_colour_manual(values = c("darkorange", "purple", "cyan4")) +
  labs(x = "Flipper length (mm)",
       y = "Bill length (mm)",
       colour = "Penguin species",
       shape = "Penguin species")

# Change the position of the legend
penguins2 %>%
  ggplot(aes(x = flipper_length_mm,
             y = body_mass_g,
             colour = species,
             shape = species)) +
  geom_point(size = 3, alpha = 0.5) +
  facet_grid(. ~ sex) +
  stat_smooth(method = "lm", se = FALSE) + 
  scale_y_continuous(labels = scales::comma) + 
  scale_colour_manual(values = c("darkorange", "purple", "cyan4")) + 
  labs(x = "Flipper length (mm)",
       y = "Bill length (mm)",
       colour = "Penguin species",
       shape = "Penguin species") +
  theme(legend.position = "bottom")

# Using a pre-defined theme
penguins2 %>%
  ggplot(aes(x = flipper_length_mm,
             y = body_mass_g,
             colour = species,
             shape = species)) +
  geom_point(size = 3, alpha = 0.5) +
  facet_grid(. ~ sex) +
  stat_smooth(method = "lm", se = FALSE) + 
  scale_y_continuous(labels = scales::comma) + 
  scale_colour_manual(values = c("darkorange", "purple", "cyan4")) + 
  labs(x = "Flipper length (mm)",
       y = "Body mass (g)",
       colour = "Penguin species",
       shape = "Penguin species") +
  theme(legend.position = "bottom") +
  theme_minimal()

# Saving a ggplot
# (Replace with your own filepath)
# (Filepath below is for Windows, Mac filepaths look slightly different)
ggsave(plot = p, 
       filename = "C:/Users/Melissa/Documents/ggplot.png",
       width = 8, height = 4,
       units = "in")

# You can also change your working directory
# (Useful if loading/saving many different files)
getwd() # Shows your working directory
setwd("C:/Users/Melissa/Documents") # Changes your working directory
# Now we can use the ggsave function with a shorter filepath
ggsave(plot = p, 
       filename = "ggplot.png",
       width = 8, height = 4,
       units = "in")
