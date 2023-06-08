## ---- include=FALSE------------------------------------------------------------------------------------------
knitr::opts_chunk$set(warning = FALSE, message = FALSE)


## ------------------------------------------------------------------------------------------------------------
library(tidyverse)
library(car)
library(readxl)
library(janitor)

x <- readxl::read_xlsx("HighSchool.xlsx", sheet = 1) %>% clean_names()


## ------------------------------------------------------------------------------------------------------------
x <- x %>%
  # sudaromas jungtinis faktorius
  mutate(combined = factor(paste(parental_education, test_prep_course))) %>%
  drop_na()


write_csv(x, "high_school_modified.csv")


# Tiriamieji grafikai

# Faktorių efektai neatsižvelgiant į kovariantes
ggplot(x, aes(parental_education, result, color = test_prep_course, group = test_prep_course)) +
  stat_summary(fun = "mean", geom = "line", size = 1) +
  theme_minimal(base_size = 16) +
  guides(x = guide_axis(n.dodge = 2))


# Hipotezės apie koeficientų lygybę visiems faktorių lygmenims
ggplot(x, aes(attendance, result, color = parental_education)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  facet_wrap(vars(test_prep_course)) +
  theme_minimal()


ggplot(x, aes(daily_study_hours, result, color = parental_education)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  facet_wrap(vars(test_prep_course)) +
  theme_minimal()


# Kovariančių pasiskirstymas pagal faktorių lygmenis
ggplot(x, aes(x = parental_education, y = daily_study_hours, color = test_prep_course)) +
  geom_boxplot() +
  theme_minimal() +
  scale_color_brewer(palette = "Set2")


ggplot(x, aes(x = parental_education, y = attendance, color = test_prep_course)) +
  geom_boxplot() +
  theme_minimal() +
  scale_color_brewer(palette = "Set2")


## ------------------------------------------------------------------------------------------------------------
library(rstatix)

# Hipotezė apie koeficientų lygybę neatmetama
anova_test(result ~ attendance * combined + daily_study_hours * combined, data = x, type = 3, detailed = TRUE)


# Hipotezė apie faktorių sąveikos nebuvimą neatmetama
anova_test(result ~ attendance + daily_study_hours + parental_education * test_prep_course, data = x, type = 3, detailed = TRUE)


model <- anova_test(result ~  parental_education + test_prep_course + attendance + daily_study_hours, data = x, type = 3, detailed = TRUE)
model


## ------------------------------------------------------------------------------------------------------------
# Modelio prielaidų patikrinimas
model_aov <- aov(result ~ parental_education + test_prep_course + attendance + daily_study_hours, data = x)

plot(model_aov)

leveneTest(result ~ combined, data = x, center = "mean")
shapiro.test(resid(model_aov))


# Tiesinis ryšys tarp kovariančių ir priklausomo kintamojo
ggplot(x, aes(attendance, result, color = combined)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  theme_minimal() +
  facet_wrap(vars(combined))

ggplot(x, aes(daily_study_hours, result, color = combined)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  theme_minimal() +
  facet_wrap(vars(combined))


## ------------------------------------------------------------------------------------------------------------
library(emmeans)

res <- x %>% emmeans_test(result ~ parental_education, model = model_aov)
res
get_emmeans(res)

