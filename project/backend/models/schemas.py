from pydantic import BaseModel
from typing import List, Optional, Dict, Any

class FaceAnalysisRequest(BaseModel):
    user_id: str
    image: str  # Base64 encoded image
    gender: str = "male"

class Point(BaseModel):
    x: float
    y: float

class FaceLandmarks(BaseModel):
    landmarks: List[Point]
    jaw_width: float
    face_height: float
    face_width: float

class SymmetryResult(BaseModel):
    score: float
    asymmetry_zones: List[str]

class ShapeResult(BaseModel):
    face_shapes: List[str]  # Top 3 shapes
    primary_shape: String

class BeautyScoreResult(BaseModel):
    total_score: float
    category: str
    component_scores: Dict[str, float]

class CelebrityMatch(BaseModel):
    name: str
    resemblance_score: int
    similar_features: List[str]

class FaceAnalysisResponse(BaseModel):
    user_id: str
    beauty_score: BeautyScoreResult
    face_shapes: List[str]
    symmetry: SymmetryResult
    tips: List[str]
    celebrity_matches: List[CelebrityMatch] = []
    analysis_version: str = "beauty_v1"

class PurchaseVerifyRequest(BaseModel):
    device_id: str
    purchase_token: str
    product_id: str
    package_name: str
