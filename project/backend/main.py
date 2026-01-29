from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import time

from services.face_engine import FaceEngine
from services.symmetry_engine import SymmetryEngine
from services.shape_engine import ShapeEngine
from services.scoring_engine import ScoringEngine
from services.tips_engine import TipsEngine
from services.match_engine import MatchEngine
from models.schemas import FaceAnalysisRequest, FaceAnalysisResponse, BeautyScoreResult, SymmetryResult, ShapeResult
from db.supabase_client import db

app = FastAPI(title="Facial Harmony API", version="1.0.0")

# CORS Middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize Services
face_engine = FaceEngine()
symmetry_engine = SymmetryEngine()
shape_engine = ShapeEngine()
scoring_engine = ScoringEngine()
tips_engine = TipsEngine()
match_engine = MatchEngine()

@app.get("/health")
async def health_check():
    return {"status": "ok", "version": "1.0.0"}

@app.post("/analyze/face", response_model=FaceAnalysisResponse)
async def analyze_face(request: FaceAnalysisRequest):
    try:
        start_time = time.time()
        
        # 1. Process Image (Face Engine)
        processed_data = face_engine.process_image(request.image)
        landmarks = processed_data['landmarks']
        embedding = processed_data['embedding']
        
        # 2. Run Analysis Engines (Beauty Score Engine + Others)
        symmetry_data = symmetry_engine.analyze(landmarks)
        shape_data = shape_engine.analyze(landmarks)
        score_data = scoring_engine.calculate_score(symmetry_data, shape_data, landmarks)
        
        # 3. Celebrity Match (Match Engine)
        matches = match_engine.find_matches(
            embedding, 
            shape_data['shapes'],  # Pass top 3 shapes for filtering
            score_data['components']['jawline'],
            symmetry_data['score']
        )
        match_names = [m['name'] for m in matches]
        
        
        # 4. Generate Tips (Tips Engine)
        # Get user premium status and previously shown tips
        profile = db.get_profile(request.user_id)
        is_premium = profile.get('is_premium', False) if profile else False
        shown_tip_ids = db.get_shown_tips(request.user_id)
        
        tips = tips_engine.generate_tips(
            score_data, 
            shape_data['primary'], 
            symmetry_data['asymmetry_zones'],
            is_premium=is_premium,
            shown_tip_ids=shown_tip_ids
        )
        
        # 5. Store in Supabase (Data Layer)
        # 5a. Create Scan Record
        # Simple quality metric: 100 if face detected well (implied by reaching here)
        quality = 95.0 
        scan_id = db.save_scan(request.user_id, quality)
        
        # 5b. Save Results
        db.save_results(request.user_id, scan_id, score_data, shape_data)
        
        # 5c. Save Tips (for retention/analytics)
        db.save_tips(request.user_id, scan_id, tips)
        
        # 5d. Save Celebrity Matches
        db.save_celebrity_matches(request.user_id, scan_id, matches)
        
        # 6. Construct Response
        return FaceAnalysisResponse(
            user_id=request.user_id,
            beauty_score=BeautyScoreResult(
                total_score=score_data['total_score'],
                category=score_data['category'],
                component_scores=score_data['components']
            ),
            face_shapes=shape_data['shapes'],
            symmetry=SymmetryResult(
                score=symmetry_data['score'],
                asymmetry_zones=symmetry_data['asymmetry_zones']
            ),
            tips=[tip['text'] for tip in tips],
            celebrity_matches=matches 
        )

    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        import traceback
        traceback.print_exc()
        raise HTTPException(status_code=500, detail="Internal Server Error")

from services.purchase_verifier import PurchaseVerifier
from models.schemas import PurchaseVerifyRequest

purchase_verifier = PurchaseVerifier()

@app.post("/purchase/verify")
async def verify_purchase(request: PurchaseVerifyRequest):
    try:
        # 1. Verify with Google
        verification_result = purchase_verifier.verify_purchase(
            request.device_id,
            request.purchase_token,
            request.product_id
        )
        
        # 2. Update Supabase if valid
        if verification_result['valid']:
            db.update_premium_status(request.device_id, True, verification_result)
            
        return verification_result
        
    except Exception as e:
        import traceback
        traceback.print_exc()
        raise HTTPException(status_code=500, detail="Purchase verification failed")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
