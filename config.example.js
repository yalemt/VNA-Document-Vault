// Copy to config.js and fill in (Supabase dashboard > Project Settings > API).
// The anon key is designed to be public; your data is protected by the Row Level Security rules in supabase/schema.sql.
// NEVER put the service_role key here.
window.VNA_CONFIG = {
  SUPABASE_URL: "https://YOUR-PROJECT.supabase.co",
  SUPABASE_ANON_KEY: "YOUR-ANON-PUBLIC-KEY",
  BUCKET: "vault"
};
