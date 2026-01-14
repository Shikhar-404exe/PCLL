# Quick Start: Environment Variables

## 1. Copy the Template

```powershell
Copy-Item .env.example .env
```

## 2. Add Your Azure Keys (Optional)

Edit `.env`:

```env
AZURE_OPENAI_ENDPOINT=https://your-resource.openai.azure.com
AZURE_OPENAI_DEPLOYMENT=gpt-4
AZURE_OPENAI_API_KEY=your_api_key_here
AZURE_INSIGHTS_ENABLED=true
```

## 3. That's It!

Run the app:

```powershell
flutter run -d windows
```

---

**No Azure?** No problem! Leave `.env` empty - app works perfectly without it.

**Full Documentation**: See `ENV_SETUP.md` for detailed instructions.
