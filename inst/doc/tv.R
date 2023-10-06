## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## -----------------------------------------------------------------------------
library(tv)
library(tibble)
library(dplyr)
library(lubridate)
data <- tribble(
  ~ pat_id, ~ feature, ~ datetime, ~ value,
  1, "lactate", "2021-12-31 23:00:00", 9,
  1, "lactate", "2022-01-01 03:41:00", 10,
  1, "lactate", "2022-01-01 07:00:00", 11,
  1, "blood pressure", "2022-01-01 02:00:00", 120,
  1, "blood pressure", "2022-01-01 04:00:00", 115,
  1, "blood pressure", "2022-01-01 06:00:00", 118,
  1, "6-hour", "2022-01-01 00:00:00", NA_real_,
  1, "6-hour", "2022-01-01 06:00:00", NA_real_,
  1, "6-hour", "2022-01-01 12:00:00", NA_real_,
  1, "6-hour", "2022-01-01 18:00:00", NA_real_,
  1, "event", "2022-01-01 08:00:00", NA_real_,
  1, "event", "2022-01-01 13:00:00", NA_real_
) %>%
  mutate(datetime = as_datetime(datetime))

specs <- tribble(
  ~ feature, ~ use_for_grid, ~ lookback_start, ~ lookback_end, ~ aggregation,
  "lactate", TRUE, 0, Inf, "ts",
  "lactate", TRUE, 0, Inf, "lvcf",
  "blood pressure", FALSE, 0, 7200, "ts", # two hours
  "blood pressure", FALSE, 0, 7200, "lvcf", # two hours
  "6-hour", TRUE, 0, Inf, "n",
  "event", TRUE, 0, 0, "event"
)

exposure <- tibble(
  pat_id = 1,
  encounter = 1:2, # optional id
  exposure_start = as_datetime(c("2022-01-01 00:00:00", "2022-01-01 08:00:00")),
  exposure_stop = as_datetime(c("2022-01-01 08:00:00", "2022-01-01 13:00:00")),
)

time_varying(data, specs, exposure = exposure, time_units = "seconds", n_cores = 1) %>%
  arrange(pat_id, row_start)


## ----eval=FALSE---------------------------------------------------------------
#  data %>%
#    tidyr::pivot_longer(c(start_time, end_time), names_to = "which_time", values_to = "datetime") %>%
#    dplyr::mutate(
#      value = +(which_time == "start_time")
#    )

## ----eval=FALSE---------------------------------------------------------------
#  data %>%
#    tidyr::pivot_longer(c(start_time, end_time), names_to = "which_time", values_to = "datetime") %>%
#    dplyr::arrange(pat_id, datetime) %>%
#    dplyr::group_by(pat_id) %>%
#    dplyr::mutate(
#      value = cumsum(ifelse(which_time == "start_time", 1, -1))
#    ) %>%
#    dplyr::ungroup()

