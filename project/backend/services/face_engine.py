import cv2
import mediapipe as mp
import numpy as np
import base64
import insightface
from insightface.app import FaceAnalysis
from typing import Dict, Any, List, Tuple

class FaceEngine:
    def __init__(self):
        # 1. MediaPipe for Landmarks (Beauty Analysis)
        self.mp_face_mesh = mp.solutions.face_mesh
        self.face_mesh = self.mp_face_mesh.FaceMesh(
            static_image_mode=True,
            max_num_faces=1,
            refine_landmarks=True,
            min_detection_confidence=0.5
        )
        
        # 2. InsightFace for Embeddings (Celebrity Match)
        # using 'buffalo_l' model pack giving 512-d embeddings
        self.face_app = FaceAnalysis(name='buffalo_l', providers=['CPUExecutionProvider'])
        self.face_app.prepare(ctx_id=0, det_size=(640, 640))

    def process_image(self, base64_image: str) -> Dict[str, Any]:
        # Decode image
        try:
            if ',' in base64_image:
                base64_image = base64_image.split(',')[1]
            image_bytes = base64.b64decode(base64_image)
            np_arr = np.frombuffer(image_bytes, np.uint8)
            image = cv2.imdecode(np_arr, cv2.IMREAD_COLOR)
            
            if image is None:
                raise ValueError("Could not decode image")
                
        except Exception as e:
            raise ValueError(f"Invalid image format: {str(e)}")

        # 1. Quality Validation
        quality_score = self._validate_image_quality(image)

        # Convert to RGB for MediaPipe
        image_rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
        height, width, _ = image.shape

        # A. MediaPipe: Get 468 landmarks
        mp_results = self.face_mesh.process(image_rgb)
        if not mp_results.multi_face_landmarks:
            raise ValueError("No face detected by MediaPipe. Ensure good lighting and face camera directly.")
            
        if len(mp_results.multi_face_landmarks) > 1:
            raise ValueError("Multiple faces detected. Please ensure only one face is visible.")

        landmarks = mp_results.multi_face_landmarks[0]
        
        # Calculate alignment angle
        angle = self._calculate_face_angle(landmarks, width, height)
        
        # Check Head Pose (approximate using landmarks)
        if not self._is_frontal_face(landmarks, width, height):
            raise ValueError("Face is not frontal. Please look directly at the camera.")
        
        # If angle is significant (> 2 degrees), align the face
        if abs(angle) > 2.0:
            image = self._align_face(image, angle)
            # Re-process aligned image
            image_rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
            height, width, _ = image.shape
            mp_results = self.face_mesh.process(image_rgb)
            if mp_results.multi_face_landmarks:
                landmarks = mp_results.multi_face_landmarks[0]
        
        pixel_landmarks = []
        for lm in landmarks.landmark:
            pixel_landmarks.append({
                'x': lm.x * width,
                'y': lm.y * height,
                'z': lm.z
            })

        # B. InsightFace: Get Embedding
        try:
            # InsightFace expects BGR
            insight_faces = self.face_app.get(image)
            if not insight_faces:
                 # Fallback: log warning
                 embedding = None
                 face_bbox = None
            else:
                 # Take the largest face if multiple
                 face = sorted(insight_faces, key=lambda x: (x.bbox[2]-x.bbox[0]) * (x.bbox[3]-x.bbox[1]))[-1]
                 embedding = face.embedding.tolist()
                 face_bbox = face.bbox.tolist()
        except Exception as e:
            print(f"InsightFace error: {e}")
            embedding = None
            face_bbox = None

        return {
            'landmarks': pixel_landmarks,
            'raw_landmarks': list(landmarks.landmark),
            'embedding': embedding,
            'face_bbox': face_bbox,
            'image_dims': (width, height),
            'aligned': abs(angle) > 2.0,
            'quality_score': quality_score
        }

    def _validate_image_quality(self, image) -> float:
        # 1. Blur Check (Laplacian Variance)
        gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
        laplacian_var = cv2.Laplacian(gray, cv2.CV_64F).var()
        if laplacian_var < 100: # Threshold for blur
            raise ValueError("Image is too blurry. Please stabilize camera.")

        # 2. Brightness Check
        mean_brightness = np.mean(gray)
        if mean_brightness < 40:
            raise ValueError("Image is too dark. Please use better lighting.")
        if mean_brightness > 250:
            raise ValueError("Image is overexposed. Please reduce lighting.")
            
        return min(100.0, max(0.0, laplacian_var / 5.0)) # Normalize to roughly 0-100 logic (heuristic)

    def _is_frontal_face(self, landmarks, width, height):
        # Nose tip: 1
        # Left cheek: 234
        # Right cheek: 454
        nose = landmarks.landmark[1]
        left_cheek = landmarks.landmark[234]
        right_cheek = landmarks.landmark[454]
        
        # Check x-symmetry
        nose_x = nose.x * width
        left_x = left_cheek.x * width
        right_x = right_cheek.x * width
        
        left_dist = abs(nose_x - left_x)
        right_dist = abs(right_x - nose_x)
        
        # If one side is significantly larger (>1.5x) than other, likely turning head
        ratio = left_dist / (right_dist + 1e-6)
        if ratio < 0.5 or ratio > 2.0:
            return False
            
        return True

    def _calculate_face_angle(self, landmarks, width, height):
        # Left Eye (Left pupil approx): Index 468
        # Right Eye (Right pupil approx): Index 473
        # MediaPipe iris landmarks are refined, but general eye corners are stable
        # Left Eye Outer Corner: 33
        # Right Eye Outer Corner: 263
        
        left_eye = landmarks.landmark[33]
        right_eye = landmarks.landmark[263]
        
        lx, ly = left_eye.x * width, left_eye.y * height
        rx, ry = right_eye.x * width, right_eye.y * height
        
        delta_y = ry - ly
        delta_x = rx - lx
        angle = np.degrees(np.arctan2(delta_y, delta_x))
        return angle

    def _align_face(self, image, angle):
        (h, w) = image.shape[:2]
        center = (w // 2, h // 2)
        M = cv2.getRotationMatrix2D(center, angle, 1.0)
        aligned_image = cv2.warpAffine(image, M, (w, h), flags=cv2.INTER_CUBIC)
        return aligned_image
