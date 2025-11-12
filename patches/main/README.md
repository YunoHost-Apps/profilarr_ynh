# Patches for YunoHost Compatibility

These patches are applied automatically during installation and upgrade to make Profilarr compatible with YunoHost deployments.

## Patches

### 01-config-dir-env-var.patch
**File:** `backend/app/config/config.py`

Makes the `CONFIG_DIR` configurable via environment variable instead of being hardcoded to `/config`. This allows YunoHost to place configuration files in standard locations like `/home/yunohost.app/profilarr/config`.

**Changes:**
- `CONFIG_DIR = '/config'` → `CONFIG_DIR = os.getenv('CONFIG_DIR', '/config')`
- Maintains Docker compatibility with default `/config` path

### 02-cli-arguments.patch
**File:** `backend/app/main.py`

Adds command-line argument parsing to allow configuring the server without modifying code or relying solely on environment variables.

**New arguments:**
- `--config-dir`: Path to configuration directory
- `--host`: Host to bind to (default: 0.0.0.0)
- `--port`: Port to bind to (default: 5000)
- `--debug`: Enable debug mode

All arguments support environment variable fallbacks (CONFIG_DIR, HOST, PORT, DEBUG).

### 03-vite-base-url.patch
**File:** `frontend/vite.config.js`

Adds support for sub-path deployments (e.g., `/profilarr` instead of `/`) by reading the `BASE_URL` environment variable during the build process.

**Changes:**
- Adds `base: process.env.BASE_URL || '/'` to Vite config
- Allows building the frontend with correct asset paths for sub-path installations

**Usage during build:**
```bash
BASE_URL=/profilarr npm run build
```

### 04-react-router-basename.patch
**File:** `frontend/src/App.jsx`

Configures React Router to use the correct base path for sub-path deployments. This ensures internal navigation links work correctly when the app is installed on a sub-path.

**Changes:**
- Adds `basename={import.meta.env.BASE_URL}` prop to the `<Router>` component
- React Router will prefix all routes with the base path (e.g., `/profilarr`)

**Why this is needed:**
- Vite's `base` config (patch 03) only affects asset loading (JS/CSS files)
- React Router needs `basename` to correctly generate navigation URLs
- Without this, clicking "Media Management" redirects to `/media-management` instead of `/profilarr/media-management`

## Why Patches?

These patches allow us to use the official upstream Profilarr releases without maintaining a fork. When Profilarr updates, YunoHost can automatically pull the latest version and apply these patches.

## Upstreaming

These changes could be contributed upstream to make Profilarr more deployment-flexible for all users, not just YunoHost.

