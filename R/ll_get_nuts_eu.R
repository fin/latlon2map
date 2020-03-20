#' Gets NUTS as sf object from Eurostat's website 
#'
#' Source: https://ec.europa.eu/eurostat/web/gisco/geodata/reference-data/administrative-units-statistical-units/nuts#nuts16
#'
#' @param level Defaults to 3, corresponding to nuts3. Available values are: 0, 1, 2, and 3.
#' @param resolution Defaults to "60", for 1:60 Million. Available values: are 20, 10, 3, 1 (1 is highest quality available)-
#' @param year Defaults to 2016. Available values: 2016, 2013, 2010, 2006, 2001
#' @return NUTS in sf format
#' @export
#'
#' @examples
#' ll_get_lau_eu()
ll_get_nuts_eu <- function(level = 3,
                           resolution = 60,
                           year = 2016) {
  resolution <- stringr::str_pad(string = resolution, width = 2, side = "left", pad = 0)
  usethis::ui_info("Source: https://ec.europa.eu/eurostat/web/gisco/geodata/reference-data/administrative-units-statistical-units/countries")
  usethis::ui_info("© EuroGeographics for the administrative boundaries")
  
  ll_create_folders(geo = "eu",
                    level = level,
                    resolution = resolution,
                    year = year)
  
  ll_create_folders(geo = "eu",
                    level = "all_levels",
                    resolution = resolution,
                    year = year)
  
  rds_file <- ll_find_file(geo = "eu",
                           level = level,
                           resolution = resolution,
                           year = year,
                           name = "abl",
                           file_type = "rds")
  
  if (fs::file_exists(rds_file)) {
    return(readr::read_rds(path = rds_file))
  }

  shp_folder <- ll_find_file(geo = "eu",
                             level = "all_levels",
                             resolution = resolution,
                             year = year,
                             name = "abl",
                             file_type = "shp")
  
  shp_folder_level <- fs::path(shp_folder, paste0("NUTS_RG_", resolution, "M_", year, "_3857_LEVL_", level, ".shp"))
  
  if (fs::file_exists(shp_folder_level)==FALSE) {
    
    zip_file <- ll_find_file(geo = "eu",
                             level = "all_levels",
                             resolution = resolution,
                             year = year,
                             name = "abl",
                             file_type = "zip")
    source_url <- paste0("https://ec.europa.eu/eurostat/cache/GISCO/distribution/v2/nuts/download/ref-nuts-", year, "-", resolution, "m.shp.zip")
    
    if (fs::file_exists(zip_file)==FALSE) {
      download.file(url = source_url,
                    destfile = zip_file)
    }
    unzip(zipfile = zip_file,
          exdir = shp_folder)
    unzip(zipfile = paste0(shp_folder_level, ".zip"),
          exdir = shp_folder)
    
  }
  sf <- sf::read_sf(shp_folder_level) %>% 
    sf::st_transform(crs = 4326)
  readr::write_rds(x = sf,
                   path = rds_file)
  return(sf)
}