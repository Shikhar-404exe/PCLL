# Environment Configuration Guide

This project uses environment variables to securely store sensitive configuration like API keys.

## Setup Instructions

### 1. Create Your .env File

Copy the example file:

```bash
cp .env.example .env
```

Or on Windows:

```powershell
Copy-Item .env.example .env
```

### 2. Configure Your Variables

Edit the `.env` file with your actual values:

```env
# Azure OpenAI Configuration (Optional)
AZURE_OPENAI_ENDPOINT=https://your-resource.openai.azure.com
AZURE_OPENAI_DEPLOYMENT=gpt-4
AZURE_OPENAI_API_KEY=your_actual_api_key_here
AZURE_INSIGHTS_ENABLED=true
```

### 3. Security Notes

⚠️ **IMPORTANT:**

- The `.env` file is **gitignored** and will NOT be committed to version control
- Never commit API keys or secrets to Git
- Keep your `.env` file secure and don't share it
- Use different API keys for development and production

### 4. How It Works

The app uses `flutter_dotenv` package to load environment variables:

1. **On app startup** (`main.dart`), it loads the `.env` file
2. **EnvConfig service** (`lib/core/config/env_config.dart`) provides access to variables
3. **Azure service** tries `.env` first, then falls back to SharedPreferences

### 5. Configuration Priority

The app checks configuration in this order:

1. **User settings** (in-app configuration via Settings screen)
2. **Environment variables** (.env file)
3. **Defaults** (disabled by default)

This means users can still configure Azure manually in the app, even without a .env file.

## Azure OpenAI Setup (Optional)

### Getting Azure Credentials

1. Go to [Azure Portal](https://portal.azure.com)
2. Create an Azure OpenAI resource
3. Deploy a model (e.g., GPT-4 or GPT-3.5-Turbo)
4. Get your:
   - **Endpoint**: Found in resource overview
   - **Deployment Name**: Your model deployment name
   - **API Key**: Found under "Keys and Endpoint"

### Example Configuration

```env
AZURE_OPENAI_ENDPOINT=https://mycompany-openai.openai.azure.com
AZURE_OPENAI_DEPLOYMENT=gpt-4-deployment
AZURE_OPENAI_API_KEY=1234567890abcdef1234567890abcdef
AZURE_INSIGHTS_ENABLED=true
```

## Troubleshooting

### App can't find .env file

Make sure:

- `.env` file is in the project root (same level as `pubspec.yaml`)
- The file is named exactly `.env` (no extra extensions)
- You've run `flutter pub get` after adding flutter_dotenv

### API calls failing

Check:

- Endpoint URL is correct and includes `https://`
- Deployment name matches your Azure deployment exactly
- API key is valid and has permissions
- `AZURE_INSIGHTS_ENABLED=true` is set

### Variables showing as empty

Verify:

- `.env` file has no spaces around `=` signs
- Values don't have quotes (unless needed)
- File encoding is UTF-8
- You've restarted the app after changing .env

## Future Configuration Options

The `.env` file supports additional variables for future features:

```env
# Database Configuration
LOCAL_DB_PATH=/custom/path/to/db
BACKUP_ENABLED=true

# App Configuration
APP_ENV=development
DEBUG_MODE=true
LOG_LEVEL=debug
```

## Development vs Production

### Development

```env
APP_ENV=development
DEBUG_MODE=true
AZURE_INSIGHTS_ENABLED=false  # Use test keys if needed
```

### Production

```env
APP_ENV=production
DEBUG_MODE=false
AZURE_INSIGHTS_ENABLED=true
```

## Testing Without Azure

The app works perfectly **without** Azure configuration:

1. Leave `.env` empty or set `AZURE_INSIGHTS_ENABLED=false`
2. All core features work offline
3. Azure insights are optional enhancements only

---

**Need Help?** Check the app's Settings screen for Azure configuration status and testing.
