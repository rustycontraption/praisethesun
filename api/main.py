from fastapi import FastAPI
from typing import Literal
from calculate_sun_location import calc_coords, find_sun

app = FastAPI(title="Praise the Sun API", version="1.0.0")

@app.get("/coords/")
async def read_item(lat:float, long:float, radius:float, coord_quantity:int, unit_type:Literal["metric","imperial"] = "metric"):
    return calc_coords(center_lat=lat, center_lng=long, radius=radius, coord_quantity=coord_quantity, unit_type=unit_type)

@app.get("/sun/")
async def read_latlong(start_point_lat: float, start_point_lng: float, radiusKilometers: int):
    data = find_sun(input_lat=start_point_lat, input_lng=start_point_lng, radiusKilometers=radiusKilometers)
    return {"data": data}

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {"status": "healthy"}
