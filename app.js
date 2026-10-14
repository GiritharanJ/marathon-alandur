// 1) Paste your Supabase values (Project Settings > API). The anon key is safe to expose; RLS protects data.
const SUPABASE_URL = "https://YOUR-PROJECT.supabase.co";
const SUPABASE_ANON_KEY = "YOUR-ANON-KEY";
const GPAY_NUMBER = "9384280149";          // number shown for payment
const UPI_ID = "";                          // optional e.g. name@okhdfcbank
const sb = supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

async function uploadFile(file, folder) {
  if (!file) return null;
  if (file.size > 5 * 1024 * 1024) throw new Error("File must be under 5 MB / 5 MB-க்குள் இருக்க வேண்டும்");
  const ext = file.name.split(".").pop().toLowerCase();
  const path = `${folder}/${Date.now()}-${Math.random().toString(36).slice(2, 8)}.${ext}`;
  const { error } = await sb.storage.from("uploads").upload(path, file);
  if (error) throw error;
  return sb.storage.from("uploads").getPublicUrl(path).data.publicUrl;
}
