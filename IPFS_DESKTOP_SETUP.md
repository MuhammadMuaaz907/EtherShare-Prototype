# IPFS Desktop Configuration Guide

## Current Configuration
- **Gateway**: `http://127.0.0.1:8081`
- **Kubo RPC**: `http://192.168.0.35:5001/api/v0`

## Required IPFS Desktop Settings

### 1. Enable API Access
1. Open **IPFS Desktop**
2. Go to **Settings** → **Advanced**
3. Enable **"Enable API"**
4. Set **API Address** to: `0.0.0.0:5001` (to allow network access)

### 2. Configure CORS (Cross-Origin Resource Sharing)
1. In IPFS Desktop, go to **Settings** → **Advanced**
2. Add these CORS origins:
   ```
   http://localhost:*
   http://127.0.0.1:*
   http://192.168.0.35:*
   ```

### 3. Alternative: Command Line Configuration
If you have IPFS CLI installed, run these commands:

```bash
# Enable API access
ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin '["http://localhost:3000", "http://127.0.0.1:3000", "http://192.168.0.35:3000"]'

# Allow all origins (for development only)
ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin '["*"]'

# Allow all methods
ipfs config --json API.HTTPHeaders.Access-Control-Allow-Methods '["PUT", "POST", "GET"]'

# Restart IPFS daemon
ipfs daemon
```

### 4. Verify Configuration
Test the API access:

```bash
# Test API access
curl -X POST "http://192.168.0.35:5001/api/v0/id"

# Should return JSON with node information
```

## Troubleshooting

### Issue: "IPFS Desktop is not running"
**Solution**: 
1. Ensure IPFS Desktop is running
2. Check if API is enabled in settings
3. Verify the API address is `0.0.0.0:5001`

### Issue: "403 Forbidden" or "405 Method Not Allowed"
**Solution**:
1. Enable CORS in IPFS Desktop settings
2. Add your app's origin to allowed origins
3. Restart IPFS Desktop after configuration changes

### Issue: "Connection refused"
**Solution**:
1. Check if IPFS Desktop is running
2. Verify the API port (should be 5001)
3. Check firewall settings

## App Configuration
The Flutter app is configured to use:
- **API Endpoint**: `http://192.168.0.35:5001/api/v0`
- **Gateway**: `http://127.0.0.1:8081/ipfs`

## Testing
After configuration:
1. Restart IPFS Desktop
2. Run the Flutter app
3. Check the IPFS status in the app
4. Try uploading/downloading files

## Security Note
The above configuration allows network access to IPFS API. For production use, consider:
- Restricting API access to specific IPs
- Using authentication
- Running IPFS behind a reverse proxy
