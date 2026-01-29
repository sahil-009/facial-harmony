import numpy as np
from typing import List, Dict, Any

class ShapeEngine:
    def __init__(self):
        # Key landmark indices (MediaPipe 468)
        self.CHEEK_LEFT = 234
        self.CHEEK_RIGHT = 454
        self.JAW_LEFT = 58
        self.JAW_RIGHT = 288
        self.CHIN_BOTTOM = 152
        self.FOREHEAD_TOP = 10
        self.FOREHEAD_LEFT = 103
        self.FOREHEAD_RIGHT = 332

    def analyze(self, landmarks: List[Dict]) -> Dict[str, Any]:
        """
        Determine Top 3 Face Shapes based on structural ratios.
        Shapes: Square, Rectangle, Round, Diamond, Oval, Oblong, Heart, Triangle
        """
        # 1. Get Measurements
        face_width = self._dist(landmarks[self.CHEEK_LEFT], landmarks[self.CHEEK_RIGHT])
        jaw_width = self._dist(landmarks[self.JAW_LEFT], landmarks[self.JAW_RIGHT])
        face_height = self._dist(landmarks[self.FOREHEAD_TOP], landmarks[self.CHIN_BOTTOM])
        forehead_width = self._dist(landmarks[self.FOREHEAD_LEFT], landmarks[self.FOREHEAD_RIGHT])

        # Avoid division by zero
        if face_width == 0 or face_height == 0:
            return {
                "primary": "Oval", 
                "shapes": ["Oval", "Round", "Square"], 
                "ratios": {"w_h": 0.85, "j_c": 0.75}
            }

        # 2. Calculate Ratios
        width_height_ratio = face_width / face_height # < 1.0 usually (Height > Width)
        jaw_cheek_ratio = jaw_width / face_width      # < 1.0 (Jaw narrower than cheeks usually)
        forehead_cheek_ratio = forehead_width / face_width

        scores = {
            "Square": 0,
            "Rectangle": 0,
            "Round": 0,
            "Diamond": 0,
            "Oval": 0,
            "Oblong": 0,
            "Heart": 0,
            "Triangle": 0
        }

        # 3. Apply Threshold Logic (Strict & Male Optimized)
        
        # Square: Compact face (W~H), Strong jaw (J~C)
        if 0.88 <= width_height_ratio <= 1.05:
            if jaw_cheek_ratio >= 0.9:
                scores["Square"] += 95
            elif jaw_cheek_ratio >= 0.8:
                scores["Square"] += 70

        # Rectangle: Long face (H>W), Strong jaw (J~C)
        if width_height_ratio < 0.88:
            if jaw_cheek_ratio >= 0.9:
                scores["Rectangle"] += 95
            elif jaw_cheek_ratio >= 0.8:
                scores["Rectangle"] += 75

        # Round: Compact face (W~H), Soft jaw
        if 0.88 <= width_height_ratio <= 1.05 and jaw_cheek_ratio < 0.8:
            scores["Round"] += 90

        # Diamond: Narrow jaw & forehead, Wide cheeks
        if jaw_cheek_ratio < 0.75 and forehead_cheek_ratio < 0.75:
            scores["Diamond"] += 95
        elif jaw_cheek_ratio < 0.8 and forehead_cheek_ratio < 0.8:
             scores["Diamond"] += 70

        # Oval: Balanced ratios, slightly longer than wide, tapered jaw
        if 0.75 < width_height_ratio < 0.9:
            if 0.7 < jaw_cheek_ratio < 0.85:
                scores["Oval"] += 95

        # Oblong: Very long face
        if width_height_ratio <= 0.75:
            scores["Oblong"] += 95
        elif width_height_ratio <= 0.78:
            scores["Oblong"] += 70

        # Heart: Wide forehead, narrow chin
        if forehead_cheek_ratio > 0.9 and jaw_cheek_ratio < 0.75:
            scores["Heart"] += 90

        # Triangle: Jaw wider than forehead (or cheeks), rare
        if jaw_cheek_ratio > 1.0 or (jaw_width > forehead_width * 1.1):
             scores["Triangle"] += 85

        # Fallback weighting for common shapes if scores are low
        if max(scores.values()) < 50:
            scores["Oval"] += 30
            scores["Round"] += 20
            scores["Square"] += 10

        # Sort shapes by score
        sorted_shapes = sorted(scores.items(), key=lambda x: x[1], reverse=True)
        top_3 = [shape[0] for shape in sorted_shapes[:3]]

        return {
            "primary": top_3[0],
            "shapes": top_3,
            "ratios": {
                "w_h": round(width_height_ratio, 2),
                "j_c": round(jaw_cheek_ratio, 2),
                "f_c": round(forehead_cheek_ratio, 2)
            }
        }

    def _dist(self, p1, p2):
        return np.linalg.norm(np.array([p1['x'], p1['y']]) - np.array([p2['x'], p2['y']]))
