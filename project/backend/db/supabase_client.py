from supabase import create_client, Client
from core.config import settings
import logging
from typing import Dict, Any, List

class SupabaseDB:
    def __init__(self):
        self.url = settings.SUPABASE_URL
        self.key = settings.SUPABASE_KEY
        self.client: Client = create_client(self.url, self.key)

    def save_scan(self, user_id: str, quality_score: float) -> str:
        """Create a face_scan record and return its ID"""
        data = {
            "user_id": user_id,
            "scan_quality": quality_score,
            "analysis_version": "v1.0"
        }
        res = self.client.table("face_scans").insert(data).execute()
        return res.data[0]['id']

    def save_results(self, user_id: str, scan_id: str, score_data: Dict, shape_data: Dict):
        """Save beauty analysis results"""
        data = {
            "user_id": user_id,
            "scan_id": scan_id,
            "beauty_score": score_data['total_score'],
            "symmetry_score": score_data['components']['symmetry'],
            "jaw_score": score_data['components']['jawline'],
            "face_shape_primary": shape_data['primary'],
            "face_shape_secondary": shape_data['shapes'][1] if len(shape_data['shapes']) > 1 else None
        }
        self.client.table("beauty_results").insert(data).execute()

    def update_premium_status(self, device_id: str, is_premium: bool, purchase_info: Dict = None):
        """Update user premium status based on device ID"""
        # 1. Check if profile exists
        res = self.client.table("profiles").select("id").eq("id", device_id).execute()
        
        data = {
            "id": device_id,
            "is_premium": is_premium,
            # We could store purchase token metadata here if we expand the schema
        }
        
        if not res.data:
            # Create new profile
            self.client.table("profiles").insert(data).execute()
        else:
            # Update existing
            self.client.table("profiles").update(data).eq("id", device_id).execute()

    def get_purchase_status(self, device_id: str) -> bool:
        """Check if user is premium"""
        res = self.client.table("profiles").select("is_premium").eq("id", device_id).execute()
        if res.data and res.data[0]['is_premium']:
            return True
        return False

    def save_tips(self, user_id: str, scan_id: str, tips: List[str]):
        """Log tips shown to the user"""
        if not tips: return
        
        insert_data = []
        for tip in tips:
            insert_data.append({
                "user_id": user_id,
                "scan_id": scan_id,
                "tip_key": tip[:50] # Store first 50 chars as key -> in real app use Tip ID
            })
        
        self.client.table("beauty_tips_shown").insert(insert_data).execute()

    def get_profile(self, user_id: str) -> Dict:
        """Get user profile (premium status)"""
        res = self.client.table("profiles").select("*").eq("id", user_id).execute()
        if res.data:
            return res.data[0]
        return None

    def get_shown_tips(self, user_id: str) -> List[str]:
        """Get list of tip IDs already shown to this user"""
        res = self.client.table("beauty_tips_shown").select("tip_id").eq("user_id", user_id).execute()
        if res.data:
            return [item['tip_id'] for item in res.data]
        return []

    def save_tips(self, user_id: str, scan_id: str, tips: List[Dict]):
        """Log tips shown to the user with tip IDs"""
        if not tips: return
        
        insert_data = []
        for tip in tips:
            insert_data.append({
                "user_id": user_id,
                "scan_id": scan_id,
                "tip_id": tip['id']  # Now using tip ID instead of text
            })
        
        self.client.table("beauty_tips_shown").insert(insert_data).execute()

    def save_celebrity_matches(self, user_id: str, scan_id: str, matches: List[Dict]):
        """Save celebrity matches to database"""
        if not matches: return
        
        insert_data = []
        for match in matches:
            insert_data.append({
                "user_id": user_id,
                "scan_id": scan_id,
                "celebrity_name": match['name'],
                "resemblance_score": match['resemblance_score']
            })
        
        self.client.table("celebrity_matches").insert(insert_data).execute()

db = SupabaseDB()
