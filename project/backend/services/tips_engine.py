import json
import os
from typing import List, Dict
import random

class TipsEngine:
    def __init__(self):
        # Load master tips list
        self.tips_path = os.path.join(os.path.dirname(__file__), '../models/tips_master.json')
        self.tips_master = self._load_tips()
        
    def _load_tips(self):
        try:
            with open(self.tips_path, 'r') as f:
                return json.load(f)
        except Exception as e:
            print(f"Error loading tips: {e}")
            return []
    
    def generate_tips(self, scores: Dict, shape: str, asymmetry_zones: List[str], 
                     is_premium: bool = False, shown_tip_ids: List[str] = None) -> List[Dict]:
        """
        Generate personalized tips based on facial analysis.
        
        Args:
            scores: Component scores from ScoringEngine
            shape: Primary face shape
            asymmetry_zones: List of asymmetric zones
            is_premium: Whether user has premium access
            shown_tip_ids: List of tip IDs already shown to this user
            
        Returns:
            List of tip dictionaries with id and text
        """
        if shown_tip_ids is None:
            shown_tip_ids = []
        
        components = scores['components']
        relevant_tips = []
        
        # 1. Jawline Tips
        if components['jawline'] < 75:
            relevant_tips.extend(self._get_tips_by_category('jawline', is_premium, shown_tip_ids))
        elif components['jawline'] > 90:
            relevant_tips.extend(self._get_tips_by_category('jawline', is_premium, shown_tip_ids, high_score=True))
        
        # 2. Shape-Specific Tips
        shape_category = f"shape_{shape.lower()}"
        relevant_tips.extend(self._get_tips_by_category(shape_category, is_premium, shown_tip_ids))
        
        # 3. Eyes Tips
        if components['eyes'] < 70:
            relevant_tips.extend(self._get_tips_by_category('eyes', is_premium, shown_tip_ids))
        
        # 4. Nose Tips
        if components['nose'] < 70:
            relevant_tips.extend(self._get_tips_by_category('nose', is_premium, shown_tip_ids))
        
        # 5. Lips Tips
        if components['lips'] < 70:
            relevant_tips.extend(self._get_tips_by_category('lips', is_premium, shown_tip_ids))
        
        # 6. Symmetry Tips
        if asymmetry_zones:
            relevant_tips.extend(self._get_tips_by_category('symmetry', is_premium, shown_tip_ids))
        
        # 7. General Tips (fallback)
        if len(relevant_tips) < 3:
            relevant_tips.extend(self._get_tips_by_category('general', is_premium, shown_tip_ids))
        
        # Remove duplicates while preserving order
        seen = set()
        unique_tips = []
        for tip in relevant_tips:
            if tip['id'] not in seen:
                seen.add(tip['id'])
                unique_tips.append(tip)
        
        # Return appropriate number based on tier
        max_tips = 8 if is_premium else 5
        return unique_tips[:max_tips]
    
    def _get_tips_by_category(self, category: str, is_premium: bool, 
                              shown_tip_ids: List[str], high_score: bool = False) -> List[Dict]:
        """Get tips for a specific category, respecting tier and shown tips."""
        matching_tips = []
        
        for tip in self.tips_master:
            # Skip if already shown
            if tip['id'] in shown_tip_ids:
                continue
            
            # Check category match
            if not tip['category'].startswith(category):
                continue
            
            # Check tier access
            if tip['tier'] == 'premium' and not is_premium:
                continue
            
            # For high scores, only include positive tips
            if high_score and 'strong' not in tip['text'].lower() and 'asset' not in tip['text'].lower():
                continue
            
            matching_tips.append({
                'id': tip['id'],
                'text': tip['text']
            })
        
        # Shuffle for variety
        random.shuffle(matching_tips)
        return matching_tips[:2]  # Max 2 tips per category
