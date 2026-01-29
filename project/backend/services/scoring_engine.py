from typing import Dict, Any, List
import math
import numpy as np

class ScoringEngine:
    def __init__(self):
        # Weighted Scoring Logic for Men
        self.WEIGHTS = {
            "symmetry": 0.30,
            "jawline": 0.25,
            "face_shape": 0.15,
            "eyes": 0.15,
            "nose": 0.10,
            "lips": 0.05
        }

    def calculate_score(self, symmetry_data: Dict, shape_data: Dict, landmarks: List[Dict]) -> Dict[str, Any]:
        """
        Calculate final beauty score (0-100) based on weighted features.
        All calculations use RATIOS, not raw pixel values.
        """
        
        # 1. Symmetry Score (30%)
        symmetry_score = symmetry_data['score']

        # 2. Jawline Score (25%)
        # Proxy: Jaw width relative to face width (Output from ShapeEngine)
        # Male Ideal: Strong, wide jaw. Near 90-100% of cheek width is often considered "strong"
        # Ratios from ShapeEngine: 'j_c' = jaw_width / face_width
        jaw_ratio = shape_data['ratios']['j_c']
        # Evaluation: 0.9 is strong, 0.7 is narrow. 
        # Score peaks at 0.95, drops off as it gets too wide or too narrow
        jaw_score = self._calculate_ratio_score(jaw_ratio, ideal=0.9, tolerance=0.15)

        # 3. Face Shape Score (15%)
        # Preference: Square, Rectangle, Diamond > Round, Oblong
        primary_shape = shape_data['primary']
        shape_scores = {
            "Square": 98, "Rectangle": 95, "Diamond": 92,
            "Oval": 88, "Round": 75, "Oblong": 78
        }
        shape_score = shape_scores.get(primary_shape, 75)

        # 4. Eye Proportion Score (15%)
        # Ideal: Inter-ocular distance ≈ Eye Width (Ratio ≈ 1.0)
        eye_score = self._calculate_eye_score(landmarks)

        # 5. Nose Proportion Score (10%)
        # Ideal: Nose width ≈ Inter-ocular distance (Ratio ≈ 1.0)
        nose_score = self._calculate_nose_score(landmarks)

        # 6. Lips Score (5%)
        # Ideal for men: Balanced, not too full. Ratio of Mouth Width / Face Width ≈ 0.35 - 0.45
        lips_score = self._calculate_lips_score(landmarks)

        # Calculate Final Weighted Score
        final_score = (
            (symmetry_score * self.WEIGHTS['symmetry']) +
            (jaw_score * self.WEIGHTS['jawline']) +
            (shape_score * self.WEIGHTS['face_shape']) +
            (eye_score * self.WEIGHTS['eyes']) +
            (nose_score * self.WEIGHTS['nose']) +
            (lips_score * self.WEIGHTS['lips'])
        )
        
        # Clamp Score
        final_score = max(0, min(100, final_score))

        return {
            "total_score": round(final_score, 1),
            "category": self._get_category(final_score),
            "components": {
                "symmetry": round(symmetry_score, 1),
                "jawline": round(jaw_score, 1),
                "structure": round(shape_score, 1),
                "eyes": round(eye_score, 1),
                "nose": round(nose_score, 1),
                "lips": round(lips_score, 1)
            }
        }

    def _calculate_eye_score(self, landmarks):
        # Indices: Left Eye Outer(33) Inner(133), Right Eye Inner(362) Outer(263)
        l_outer = self._pt(landmarks[33])
        l_inner = self._pt(landmarks[133])
        r_inner = self._pt(landmarks[362])
        r_outer = self._pt(landmarks[263])

        left_eye_width = self._dist(l_outer, l_inner)
        right_eye_width = self._dist(r_inner, r_outer)
        avg_eye_width = (left_eye_width + right_eye_width) / 2
        
        inter_ocular_dist = self._dist(l_inner, r_inner)

        if avg_eye_width == 0: return 50
        
        # Ideal ratio: Distance / Width ≈ 1.0
        ratio = inter_ocular_dist / avg_eye_width
        return self._calculate_ratio_score(ratio, ideal=1.0, tolerance=0.2)

    def _calculate_nose_score(self, landmarks):
        # Nose Width: 49 (Left Alae) -> 279 (Right Alae)
        # Inner Eye Distance: 133 -> 362
        nose_left = self._pt(landmarks[49])
        nose_right = self._pt(landmarks[279])
        l_inner = self._pt(landmarks[133])
        r_inner = self._pt(landmarks[362])

        nose_width = self._dist(nose_left, nose_right)
        eye_dist = self._dist(l_inner, r_inner)

        if eye_dist == 0: return 50

        # Ideal: Nose Width ≈ Eye Distance (Ratio 1.0)
        ratio = nose_width / eye_dist
        # Men often have slightly wider noses, so ideal maybe 1.1 is fine too
        return self._calculate_ratio_score(ratio, ideal=1.0, tolerance=0.25)

    def _calculate_lips_score(self, landmarks):
        # Mouth Corners: 61 (Left) - 291 (Right)
        # Face Width: 234 (Left Cheek) - 454 (Right Cheek)
        mouth_l = self._pt(landmarks[61])
        mouth_r = self._pt(landmarks[291])
        face_l = self._pt(landmarks[234])
        face_r = self._pt(landmarks[454])

        mouth_width = self._dist(mouth_l, mouth_r)
        face_width = self._dist(face_l, face_r)

        if face_width == 0: return 50
        
        # Ideal Ratio: Mouth is about 35-45% of face width
        ratio = mouth_width / face_width
        return self._calculate_ratio_score(ratio, ideal=0.40, tolerance=0.1)

    def _calculate_ratio_score(self, val, ideal, tolerance):
        """
        Generic score calculator based on deviation from ideal ratio.
        Score drops as value moves away from ideal ± tolerance.
        """
        diff = abs(val - ideal)
        # If within 1/2 tolerance, score is very high (90-100)
        # If at tolerance limit, score is ~60
        # If double tolerance, score is ~20
        
        # Linear drop-off
        # score = 100 - (diff / tolerance) * 40
        
        if diff <= tolerance / 2:
            score = 100 - (diff / (tolerance/2)) * 10 # 100 -> 90
        elif diff <= tolerance:
            score = 90 - ((diff - tolerance/2) / (tolerance/2)) * 30 # 90 -> 60
        else:
            score = max(40, 60 - ((diff - tolerance) / tolerance) * 40) # 60 -> 20 -> 40 floor
            
        return round(score, 1)

    def _get_category(self, score):
        if score >= 90: return "Model / Elite Harmony"
        if score >= 75: return "Very Attractive"
        if score >= 60: return "Above Average"
        if score >= 40: return "Average"
        return "Needs Improvement"

    def _pt(self, lm):
        return np.array([lm['x'], lm['y']])

    def _dist(self, p1, p2):
        return np.linalg.norm(p1 - p2)
