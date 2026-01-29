import json
import os
import numpy as np
from typing import List, Dict, Any
from sklearn.metrics.pairwise import cosine_similarity

class MatchEngine:
    def __init__(self):
        # Load celebrity database
        self.db_path = os.path.join(os.path.dirname(__file__), '../models/celebrities.json')
        self.celebrities = self._load_db()

    def _load_db(self):
        try:
            with open(self.db_path, 'r') as f:
                return json.load(f)
        except Exception as e:
            print(f"Error loading celebrity DB: {e}")
            return []

    def find_matches(self, user_embedding: List[float], user_shapes: List[str], user_jaw: float, user_symmetry: float) -> List[Dict]:
        """
        Find celebrity resemblance matches based on:
        1. Face Shape Filter (Must match at least one of user's top 3 shapes)
        2. Embedding Cosine Similarity (Primary - 70%)
        3. Jaw + Symmetry Score Alignment (Secondary - 30%)
        
        Returns top 3 matches with "resemblance" terminology
        """
        if not user_embedding or not user_shapes:
            return []

        potential_matches = []
        
        for celeb in self.celebrities:
            # 1. Shape Filter: Celebrity must match at least one of user's shapes
            if not any(shape in celeb['face_shapes'] for shape in user_shapes):
                continue

            # 2. Calculate Resemblance Score
            if celeb.get('embedding') and len(celeb['embedding']) > 0:
                # Real embedding comparison (for production)
                user_emb = np.array(user_embedding).reshape(1, -1)
                celeb_emb = np.array(celeb['embedding']).reshape(1, -1)
                embedding_sim = cosine_similarity(user_emb, celeb_emb)[0][0]
                # Convert from [-1, 1] to [0, 1]
                embedding_sim = (embedding_sim + 1) / 2
            else:
                # Mock similarity for MVP (based on facial scores)
                jaw_sim = 1.0 - (abs(user_jaw - celeb['jaw_score']) / 100.0)
                sym_sim = 1.0 - (abs(user_symmetry - celeb['symmetry_score']) / 100.0)
                embedding_sim = (jaw_sim + sym_sim) / 2
            
            # 3. Combine with facial feature alignment
            jaw_alignment = 1.0 - (abs(user_jaw - celeb['jaw_score']) / 100.0)
            sym_alignment = 1.0 - (abs(user_symmetry - celeb['symmetry_score']) / 100.0)
            feature_alignment = (jaw_alignment + sym_alignment) / 2
            
            # Final resemblance score: 70% embedding, 30% features
            resemblance = (embedding_sim * 0.7) + (feature_alignment * 0.3)
            resemblance_percentage = int(resemblance * 100)
            
            # Determine similar features
            similar_features = []
            if any(shape in celeb['face_shapes'] for shape in user_shapes):
                similar_features.append("Face Shape")
            if abs(user_jaw - celeb['jaw_score']) < 10:
                similar_features.append("Jawline Structure")
            if abs(user_symmetry - celeb['symmetry_score']) < 10:
                similar_features.append("Facial Symmetry")
            
            potential_matches.append({
                "name": celeb['name'],
                "resemblance_score": resemblance_percentage,
                "similar_features": similar_features if similar_features else ["Overall Facial Proportions"]
            })

        # Sort by resemblance score and return top 3
        potential_matches.sort(key=lambda x: x['resemblance_score'], reverse=True)
        return potential_matches[:3]
