import math
import requests
import logging
import os
from pydantic import BaseModel

class Coord(BaseModel):
    lat: float
    lng: float

def calc_coords(center_lat: float, center_lng: float, radius: int, **kwargs) -> list[Coord]:
    """
    Calculate points along a circle on the Earth's surface.
    
    Args:
        center_lat (float): Center latitude in degrees
        center_lng (float): Center longitude in degrees
        radius (int): Radius of the circle
    
    Returns:
        list: List of Coords with 'lat' and 'lng' keys
    """
    coord_separation = min(radius, 250)
    earth_radius = 6371.0
    coords: list[Coord] = []
    center_coord: Coord = Coord(lat=center_lat, lng=center_lng)
    radian_center: Coord = Coord(lat=math.radians(center_coord.lat), lng=math.radians(center_coord.lng))
    radian_radius = radius / earth_radius
    coord_quantity = math.floor(math.pi / math.asin(coord_separation / (2 * radius)))

    for i in range(coord_quantity):
        # Bearing angle for this point (0 to 2π)
        bearing = (2 * math.pi * i) / coord_quantity
        
        # Calculate latitude using spherical trigonometry
        radian_latitude = math.asin(
            math.sin(radian_center.lat) * math.cos(radian_radius) +
            math.cos(radian_center.lat) * math.sin(radian_radius) * math.cos(bearing)
        )
        
        # Calculate longitude using spherical trigonometry
        radian_longitude = radian_center.lng + math.atan2(
            math.sin(bearing) * math.sin(radian_radius) * math.cos(radian_center.lat),
            math.cos(radian_radius) - math.sin(radian_center.lat) * math.sin(radian_center.lat)
        )
        
        # Convert back to degrees
        latitude = math.degrees(radian_latitude)
        longitude = math.degrees(radian_longitude)

        # Normalize longitude to 180/-180
        longitude = ((longitude + 540) % 360) - 180

        coord = Coord(
            lat=round(latitude, 6),
            lng=round(longitude, 6)
        )
        
        coords.append(coord)

    return coords
    
def find_sun(start_lat: float, start_lng: float, radiusKilometers: int) -> list[Coord]:
    """
    Search lat/lng coordinates on a given radius for clear weather.

    Args:
        start_lat (float): Starting latitude
        start_lng (float): Starting longitude
        radiusKilometers (int): Search radius from start in kilometers
    
    Returns:
        list of Coords with clear weather
    """

    logger = logging.getLogger("check_sun") 
    search_coords: list[Coord] = []
    sun_locations: list[Coord] = []
    weather_api_base_url = os.getenv("WEATHER_API_BASE_URL")

    if radiusKilometers == 0:
        search_coords.append(Coord(lat=start_lat, lng=start_lng))
    else:
        search_coords = calc_coords(center_lat=start_lat, center_lng=start_lng, radius=radiusKilometers)

    for coord in search_coords:
        try:
            weather_api_parameters = f"latitude={coord.lat}&longitude={coord.lng}&current=weather_code&timezone=auto&models=ecmwf_ifs"
            response = requests.get(f"{weather_api_base_url}?{weather_api_parameters}")
            if response.status_code == 200:
                weather_code = response.json().get("current", {}).get("weather_code")
                if weather_code == 0:
                    sun_locations.append(Coord(lat=coord.lat, lng=coord.lng))
                elif weather_code is None:
                    logger.critical(f"Invalid response structure for coord {coord.lat}, {coord.lng}")
            else:
                response.raise_for_status()
        except requests.RequestException:
            logger.error("Internal error when trying to contact weather API.")
        except Exception as e:
            logger.error(f"Unexpected error: {e}")

    return sun_locations
    