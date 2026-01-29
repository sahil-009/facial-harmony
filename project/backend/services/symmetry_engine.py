import numpy as np
from typing import List, Dict, Any

class SymmetryEngine:
    def __init__(self):
        # MediaPipe landmark indices
        self.LEFT_EYE = [33, 160, 158, 133, 153, 144]
        self.RIGHT_EYE = [362, 385, 387, 263, 373, 380]
        self.LEFT_EYEBROW = [70, 63, 105, 66, 107]
        self.RIGHT_EYEBROW = [336, 296, 334, 293, 300]
        self.NOSE_MIDLINE = [1, 2, 98, 327]  # Points defining the vertical axis
        self.JAW_LEFT = [58, 172, 136, 150, 149, 176, 148, 152]
        self.JAW_RIGHT = [288, 397, 365, 379, 378, 400, 377, 152]
        self.LIPS = {
            'left': [61, 185, 146, 91, 181, 84], # Corners + Upper/Lower curves
            'right': [291, 409, 375, 321, 405, 314]
        }

    def analyze(self, landmarks: List[Dict]) -> Dict[str, Any]:
        """
        Calculate facial symmetry score (0-100)
        Logic: Compare distances of left/right features from the central midline
        """
        # 1. Define Midline (Nose bridge to chin)
        top_point = np.array([landmarks[10]['x'], landmarks[10]['y']])  # Forehead top
        bottom_point = np.array([landmarks[152]['x'], landmarks[152]['y']])  # Chin bottom
        
        # 2. Calculate symmetry for key regions
        eye_sym = self._check_region_symmetry(landmarks, self.LEFT_EYE, self.RIGHT_EYE, top_point, bottom_point)
        brow_sym = self._check_region_symmetry(landmarks, self.LEFT_EYEBROW, self.RIGHT_EYEBROW, top_point, bottom_point)
        jaw_sym = self._check_region_symmetry(landmarks, self.JAW_LEFT, self.JAW_RIGHT, top_point, bottom_point)
        lip_sym = self._check_region_symmetry(landmarks, self.LIPS['left'], self.LIPS['right'], top_point, bottom_point)
        
        # 3. Weighted Score
        # Symmetry weights: Eyes (30%), Jaw (30%), Brows (20%), Lips (20%)
        total_score = (eye_sym * 0.30) + (jaw_sym * 0.30) + (brow_sym * 0.20) + (lip_sym * 0.20)
        
        # Identify asymmetry zones
        zones = []
        if eye_sym < 85: zones.append("Eyes")
        if jaw_sym < 85: zones.append("Jawline")
        if brow_sym < 85: zones.append("Eyebrows")
        if lip_sym < 85: zones.append("Lips")

        return {
            "score": round(self._clamp(total_score), 1),
            "asymmetry_zones": zones,
            "details": {
                "eyes": round(eye_sym, 1),
                "jaw": round(jaw_sym, 1),
                "brows": round(brow_sym, 1),
                "lips": round(lip_sym, 1)
            }
        }

    def _clamp(self, value):
        return max(0, min(100, value))

    def _check_region_symmetry(self, landmarks, left_indices, right_indices, p1, p2):
        """Calculate symmetry between left and right feature sets relative to midline p1-p2"""
        if len(left_indices) != len(right_indices):
            return 0.0

        diffs = []
        for l_idx, r_idx in zip(left_indices, right_indices):
            l_pt = np.array([landmarks[l_idx]['x'], landmarks[l_idx]['y']])
            r_pt = np.array([landmarks[r_idx]['x'], landmarks[r_idx]['y']])
            
            # Distance to midline
            d_left = self._point_line_distance(l_pt, p1, p2)
            d_right = self._point_line_distance(r_pt, p1, p2)
            
            # Normalized difference
            avg_dist = (d_left + d_right) / 2
            if avg_dist > 0:
                diff = abs(d_left - d_right) / avg_dist
                diffs.append(diff)
            else:
                diffs.append(0)

        avg_diff = np.mean(diffs)
        # Convert difference to score (0 diff -> 100 score, 0.2 diff -> 0 score)
        score = max(0, 100 - (avg_diff * 400))
        return score

    def _point_line_distance(self, point, line_start, line_end):
        """Calculate perpendicular distance from point to line segment"""
        return np.linalg.norm(np.cross(line_end-line_start, line_start-point))/np.linalg.norm(line_end-line_start)
