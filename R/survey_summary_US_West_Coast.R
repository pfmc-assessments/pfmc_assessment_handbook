# Explorations of US West Coast trawl surveys

# surveys to consider
survey_names <- c("Triennial", "AFSC.Slope", "NWFSC.Slope", "NWFSC.Combo")
# extract data and bind into single dataframe
catch <- NULL
for (survey in survey_names) {
  catch <- rbind(catch, 
    nwfscSurvey::pull_catch(
      common_name = "Pacific spiny dogfish", # random species
      survey = survey
    )
  )
}

# use shorter names for surveys
catch <- catch |> dplyr::mutate(
    survey_name = dplyr::case_when(
      Project == "Groundfish Triennial Shelf Survey" ~ "Triennial",
      Project == "AFSC/RACE Slope Survey" ~ "AFSC Slope",
      Project == "Groundfish Slope Survey" ~ "NWFSC Slope",
      Project == "Groundfish Slope and Shelf Combination Survey" ~ "WCGBTS"
    ) |> as.factor()
  )

# transform some dates
catch$date <- lubridate::as_date(catch$Datetime_utc_iso)
# day within each year (numeric, don't know how to make axis look right)
catch$yday <- lubridate::yday(catch$date)
# 2nd try for day within each year by making the year be the same for all entries
catch$yday2 <- catch$date
lubridate::year(catch$yday2) <- 1900

# make plots 
library(ggplot2)
g1 <- ggplot(catch, aes(date, yday2)) +
  geom_point(aes(color = survey_name), alpha = 0.3) +
  labs(x = "Date", y = "Day within year", color = "") + 
  scale_y_date(date_breaks = "1 month", date_labels = "%b") + 
  guides(colour = guide_legend(override.aes = list(alpha = 1)))

g2 <- ggplot(catch, aes(date, Latitude_dd)) +
  geom_point(aes(color = survey_name), alpha = 0.3) +
  labs(x = "Date", y = "Latitude (°N)", color = "") + 
  guides(colour = guide_legend(override.aes = list(alpha = 1)))

g3 <- ggplot(catch, aes(date, Depth_m)) +
  geom_point(aes(color = survey_name), alpha = 0.3) + 
  scale_y_continuous(transform = "log2") +
  labs(x = "Date", y = "Depth (m)", color = "") + 
  guides(colour = guide_legend(override.aes = list(alpha = 1)))

# combine plots and save results
ggpubr::ggarrange(g1, g2, g3, ncol = 1, common.legend = TRUE, legend = "top") +  ggpubr::bgcolor("white")
ggsave("img/survey_summary_US_West_Coast.png", width = 8, height = 12)
