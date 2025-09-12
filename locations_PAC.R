# Read in locations

# Pacific by main_report for each project
recordings_PAC_1 <- read.csv("C:/Users/Kevin/Documents/Repos/Nature_Bioacoustics/Data_WildTrax/CWS-PAC/CWS-PAC_Boreal_Monitoring_-_2022_CORE__main_report.csv")
recordings_PAC_2 <- read.csv("C:/Users/Kevin/Documents/Repos/Nature_Bioacoustics/Data_WildTrax/CWS-PAC/CWS-PAC_Boreal_Monitoring_-_2023_CORE_main_report.csv")
recordings_PAC_3 <- read.csv("C:/Users/Kevin/Documents/Repos/Nature_Bioacoustics/Data_WildTrax/CWS-PAC/CWS-PAC_Boreal_Monitoring_-_2024_CORE_main_report.csv")
recordings_PAC_4 <- read.csv("C:/Users/Kevin/Documents/Repos/Nature_Bioacoustics/Data_WildTrax/CWS-PAC/CWS-PAC_Boreal_Monitoring_-_2022_FNFN_main_report.csv")
recordings_PAC_5 <- read.csv("C:/Users/Kevin/Documents/Repos/Nature_Bioacoustics/Data_WildTrax/CWS-PAC/CWS-PAC_Boreal_Monitoring_-_2023_FNFN_main_report.csv")
recordings_PAC_6 <- read.csv("C:/Users/Kevin/Documents/Repos/Nature_Bioacoustics/Data_WildTrax/CWS-PAC/CWS-PAC_Boreal_Monitoring_-_2024_FNFN_main_report.csv")
recordings_PAC_7 <- read.csv("C:/Users/Kevin/Documents/Repos/Nature_Bioacoustics/Data_WildTrax/CWS-PAC/CWS-PAC_Boreal_Monitoring_-_2023_BMS_NE_main_report.csv")
recordings_PAC_8 <- read.csv("C:/Users/Kevin/Documents/Repos/Nature_Bioacoustics/Data_WildTrax/CWS-PAC/CWS-PAC_High_Elevation_Monitoring_-_2024_Paddy_Peak_main_report.csv")
# combine PAC recordings
recordings_PAC <- rbind(recordings_PAC_1, recordings_PAC_2, recordings_PAC_3, recordings_PAC_4, recordings_PAC_5, recordings_PAC_6, recordings_PAC_7, recordings_PAC_8)

rm(recordings_PAC_1, recordings_PAC_2, recordings_PAC_3, recordings_PAC_4, recordings_PAC_5, recordings_PAC_6, recordings_PAC_7, recordings_PAC_8)

# group and count by recording
recordings_PAC <- recordings_PAC %>%
  group_by(location, latitude, longitude, recording_id) %>%
  summarise(count = n(), .groups = "drop") %>%
  group_by(location, latitude, longitude) %>%
  summarise(count = n(), .groups = "drop") %>%
  mutate(count_adjusted = pmin(count, 10)) %>%
  filter(!is.na(latitude))

# Convert to sf points
recordings_PAC <- st_as_sf(recordings_PAC, 
                            coords = c("longitude", "latitude"), 
                            crs = 4326)  

locations_PAC_boreal <- st_join(recordings_PAC, boreal) %>%
  filter(!is.na(TYPE))

# Combine locations
locations_boreal <- rbind(locations_ABMI_boreal, locations_PAC_boreal)
