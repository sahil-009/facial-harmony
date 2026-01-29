from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    # App
    PROJECT_NAME: str = "Facial Harmony API"
    
    # Supabase - using placeholders for now as we run locally
    # User will need to provide these via .env
    SUPABASE_URL: str = 'https://cmghxgeyoxafyjkaggye.supabase.co'
    SUPABASE_KEY: str = 'sb_publishable_WQPoTalQh8AXmfPj4HoxIQ_h0Zbmif5'
    
    class Config:
        env_file = ".env"

settings = Settings()
