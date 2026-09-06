from supabase import create_client, Client

# Hardcoded for hackathon speed and reliability
SUPABASE_URL = "https://ogvxhpbbygnexqafcalz.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9ndnhocGJieWduZXhxYWZjYWx6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODcxNTg4NzgsImV4cCI6MjEwMjczNDg3OH0.D8U2ZbT4JQyXQ3TJkcEQdHlx2dA9S2NrVyX58fbXgvI"

supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

print("✅ Supabase connected successfully!")