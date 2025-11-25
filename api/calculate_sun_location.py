import math
import requests
import logging
import time
from typing import TypedDict
from fastapi import HTTPException

class Coord(TypedDict):
    lat: float
    lng: float

def calc_coords(center_lat: float, center_lng: float, radius: float, **kwargs) -> dict:
    """
    Calculate points along a circle on the Earth's surface.
    
    Args:
        lat (float): Center latitude in degrees
        long (float): Center longitude in degrees
        radius (float): Radius of the circle
    
    Returns:
        list: List of dictionaries with 'lat' and 'lng' keys
    """
    # default values in km
    coord_separation = min(radius, 250)
    earth_radius = 6371.0
    
    center_lat_rad = math.radians(center_lat)
    center_lng_rad = math.radians(center_lng)
    radius_rad = radius / earth_radius
    coord_quantity = math.floor(math.pi / math.asin(coord_separation / (2 * radius)))

    coords = []
    #testing 
    for i in range(coord_quantity):
        # Bearing angle for this point (0 to 2π)
        bearing = (2 * math.pi * i) / coord_quantity
        
        # Calculate latitude using spherical trigonometry
        coord_lat_rad = math.asin(
            math.sin(center_lat_rad) * math.cos(radius_rad) +
            math.cos(center_lat_rad) * math.sin(radius_rad) * math.cos(bearing)
        )
        
        # Calculate longitude using spherical trigonometry
        coord_lng_rad = center_lng_rad + math.atan2(
            math.sin(bearing) * math.sin(radius_rad) * math.cos(center_lat_rad),
            math.cos(radius_rad) - math.sin(center_lat_rad) * math.sin(center_lat_rad)
        )
        
        # Convert back to degrees
        coord_lat_deg = math.degrees(coord_lat_rad)
        coord_lng_deg = math.degrees(coord_lng_rad)

        # Normalize longitude to 180/-180
        coord_lng_deg = ((coord_lng_deg + 540) % 360) - 180

        coords.append({
            'lat': round(coord_lat_deg, 6),
            'lng': round(coord_lng_deg, 6),
        })

    return coords
    
def find_sun(input_lat: float, input_lng: float, radiusKilometers: int) -> dict:
    logger = logging.getLogger("check_sun") 
    sun_location = []

    if radiusKilometers == 0:
        coords = [{'lat': input_lat, 'lng': input_lng}]
    else:
        coords = calc_coords(center_lat=input_lat, center_lng=input_lng, radius=radiusKilometers)

    for coord in coords:
        try:
            response = requests.get(f"https://api.open-meteo.com/v1/forecast?latitude={coord['lat']}&longitude={coord['lng']}&current=weather_code&timezone=auto&models=ecmwf_ifs")
            if response.status_code == 200:
                if response.json()["current"]["weather_code"] == 0:
                    sun_location.append({"lat": coord['lat'], "lng": coord['lng']})
                    print(coord)
            else:
                response.raise_for_status()
        except requests.RequestException:
            logger.critical("Internal error when trying to contact weather API.")

    return {"start_point": {'lat': input_lat, 'lng': input_lng}, "sun_location": sun_location}
    