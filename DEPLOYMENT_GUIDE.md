# Quick Deployment Guide - Signaling Server

## Option 1: Deploy to Heroku (Easiest - FREE)

### Step 1: Install Heroku CLI

**Download and install from**: https://devcenter.heroku.com/articles/heroku-cli

Or use PowerShell:
```powershell
# Download installer
Invoke-WebRequest -Uri https://cli-assets.heroku.com/heroku-x64.exe -OutFile heroku-installer.exe

# Run installer
.\heroku-installer.exe
```

### Step 2: Create Server Files

**Navigate to your directory:**
```powershell
cd C:\Users\Abhijeet Nardele\signaling-server
```

**Create package.json:**
```powershell
@"
{
  "name": "airdrop-signaling-server",
  "version": "1.0.0",
  "description": "WebSocket signaling server for AirDrop",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "engines": {
    "node": "18.x"
  },
  "dependencies": {
    "ws": "^8.14.2",
    "express": "^4.18.2",
    "cors": "^2.8.5",
    "uuid": "^9.0.1"
  }
}
"@ | Out-File -FilePath package.json -Encoding utf8
```

**Create server.js:**
```powershell
@"
const WebSocket = require('ws');
const express = require('express');
const cors = require('cors');
const { v4: uuidv4 } = require('uuid');

const app = express();
app.use(cors());
app.use(express.json());

const PORT = process.env.PORT || 8080;
const rooms = new Map();
const clients = new Map();

class Room {
  constructor(code) {
    this.code = code;
    this.host = null;
    this.peers = new Set();
    this.createdAt = Date.now();
  }

  addPeer(clientId, ws) {
    if (!this.host) this.host = clientId;
    this.peers.add(clientId);
    clients.set(clientId, { ws, roomCode: this.code });
  }

  removePeer(clientId) {
    this.peers.delete(clientId);
    clients.delete(clientId);
    if (this.host === clientId && this.peers.size > 0) {
      this.host = Array.from(this.peers)[0];
    }
  }

  broadcast(message, excludeId = null) {
    this.peers.forEach(peerId => {
      if (peerId !== excludeId) {
        const client = clients.get(peerId);
        if (client && client.ws.readyState === WebSocket.OPEN) {
          client.ws.send(JSON.stringify(message));
        }
      }
    });
  }

  isEmpty() {
    return this.peers.size === 0;
  }
}

const server = app.listen(PORT, () => {
  console.log(\`🚀 Server running on port \${PORT}\`);
});

const wss = new WebSocket.Server({ server });

wss.on('connection', (ws) => {
  const clientId = uuidv4();
  console.log(\`✅ Client connected: \${clientId}\`);

  ws.on('message', (data) => {
    try {
      const message = JSON.parse(data);
      handleMessage(clientId, ws, message);
    } catch (error) {
      console.error('❌ Error:', error);
    }
  });

  ws.on('close', () => {
    handleDisconnect(clientId);
    console.log(\`❌ Client disconnected: \${clientId}\`);
  });

  ws.send(JSON.stringify({
    type: 'connected',
    clientId,
    timestamp: Date.now()
  }));
});

function handleMessage(clientId, ws, message) {
  const { type, roomCode, data } = message;

  switch (type) {
    case 'create-room':
      handleCreateRoom(clientId, ws, roomCode);
      break;
    case 'join-room':
      handleJoinRoom(clientId, ws, roomCode);
      break;
    case 'leave-room':
      handleLeaveRoom(clientId);
      break;
    case 'offer':
    case 'answer':
    case 'ice-candidate':
      handleSignaling(clientId, roomCode, message);
      break;
    case 'ping':
      ws.send(JSON.stringify({ type: 'pong', timestamp: Date.now() }));
      break;
  }
}

function handleCreateRoom(clientId, ws, roomCode) {
  if (rooms.has(roomCode)) {
    ws.send(JSON.stringify({ type: 'error', message: 'Room exists' }));
    return;
  }
  const room = new Room(roomCode);
  room.addPeer(clientId, ws);
  rooms.set(roomCode, room);
  ws.send(JSON.stringify({
    type: 'room-created',
    roomCode,
    clientId,
    isHost: true
  }));
  console.log(\`🏠 Room created: \${roomCode}\`);
}

function handleJoinRoom(clientId, ws, roomCode) {
  const room = rooms.get(roomCode);
  if (!room) {
    ws.send(JSON.stringify({ type: 'error', message: 'Room not found' }));
    return;
  }
  room.addPeer(clientId, ws);
  ws.send(JSON.stringify({
    type: 'room-joined',
    roomCode,
    clientId,
    isHost: false,
    peerCount: room.peers.size
  }));
  room.broadcast({
    type: 'peer-joined',
    clientId,
    peerCount: room.peers.size
  }, clientId);
  console.log(\`👥 Client joined: \${roomCode}\`);
}

function handleLeaveRoom(clientId) {
  const client = clients.get(clientId);
  if (!client) return;
  const room = rooms.get(client.roomCode);
  if (!room) return;
  room.removePeer(clientId);
  room.broadcast({
    type: 'peer-left',
    clientId,
    peerCount: room.peers.size
  });
  if (room.isEmpty()) {
    rooms.delete(client.roomCode);
    console.log(\`🗑️ Room deleted: \${client.roomCode}\`);
  }
}

function handleDisconnect(clientId) {
  handleLeaveRoom(clientId);
}

function handleSignaling(clientId, roomCode, message) {
  const room = rooms.get(roomCode);
  if (!room) return;
  const { targetId } = message;
  if (targetId) {
    const targetClient = clients.get(targetId);
    if (targetClient && targetClient.ws.readyState === WebSocket.OPEN) {
      targetClient.ws.send(JSON.stringify({ ...message, fromId: clientId }));
    }
  } else {
    room.broadcast({ ...message, fromId: clientId }, clientId);
  }
}

app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    uptime: process.uptime(),
    rooms: rooms.size,
    clients: clients.size,
    timestamp: Date.now()
  });
});

app.get('/rooms', (req, res) => {
  const roomList = Array.from(rooms.values()).map(room => ({
    code: room.code,
    peerCount: room.peers.size,
    createdAt: room.createdAt
  }));
  res.json({ rooms: roomList, total: rooms.size });
});

setInterval(() => {
  const now = Date.now();
  const maxAge = 24 * 60 * 60 * 1000;
  rooms.forEach((room, code) => {
    if (now - room.createdAt > maxAge && room.isEmpty()) {
      rooms.delete(code);
    }
  });
}, 5 * 60 * 1000);

console.log('📡 WebSocket Signaling Server Ready');
"@ | Out-File -FilePath server.js -Encoding utf8
```

**Create Procfile (tells Heroku how to run):**
```powershell
"web: node server.js" | Out-File -FilePath Procfile -Encoding utf8 -NoNewline
```

**Create .gitignore:**
```powershell
@"
node_modules/
.env
*.log
"@ | Out-File -FilePath .gitignore -Encoding utf8
```

### Step 3: Initialize Git Repository

```powershell
git init
git add .
git commit -m "Initial commit - Signaling server"
```

### Step 4: Deploy to Heroku

**Login to Heroku:**
```powershell
heroku login
```
*This will open a browser window - login with your Heroku account*

**Create Heroku app:**
```powershell
heroku create airdrop-signaling-server
```
*Note: If this name is taken, use a different name like `airdrop-signaling-yourname`*

**Deploy:**
```powershell
git push heroku master
```

**Get your server URL:**
```powershell
heroku open
```

Your server URL will be something like:
```
https://airdrop-signaling-server.herokuapp.com
```

**Test it:**
```powershell
curl https://airdrop-signaling-server.herokuapp.com/health
```

Should return:
```json
{
  "status": "healthy",
  "uptime": 123,
  "rooms": 0,
  "clients": 0
}
```

---

## Option 2: Deploy to Railway.app (Even Easier!)

### Step 1: Sign Up

Go to: https://railway.app
- Sign up with GitHub

### Step 2: Create New Project

1. Click "New Project"
2. Select "Deploy from GitHub repo"
3. Connect your GitHub account
4. Select your repository

### Step 3: Configure

Railway will auto-detect Node.js and deploy automatically!

### Step 4: Get URL

- Click on your deployment
- Copy the URL (e.g., `https://your-app.railway.app`)

---

## Option 3: Deploy to Render.com (Free Tier)

### Step 1: Sign Up

Go to: https://render.com
- Sign up with GitHub

### Step 2: Create Web Service

1. Click "New +" → "Web Service"
2. Connect GitHub repository
3. Configure:
   - **Name**: airdrop-signaling
   - **Environment**: Node
   - **Build Command**: `npm install`
   - **Start Command**: `npm start`
   - **Plan**: Free

### Step 3: Deploy

Click "Create Web Service" - it will deploy automatically!

### Step 4: Get URL

Your URL will be: `https://airdrop-signaling.onrender.com`

---

## Update Flutter App with Server URL

### Step 1: Find SignalingService

Open: `lib/services/signaling_service.dart`

### Step 2: Update URL

Find this line:
```dart
static const String SIGNALING_SERVER_URL = 'ws://localhost:8080';
```

Replace with your deployed URL:
```dart
static const String SIGNALING_SERVER_URL = 'wss://airdrop-signaling-server.herokuapp.com';
```

**Important**: Use `wss://` (WebSocket Secure) not `ws://`

### Step 3: Test Connection

Run your Flutter app and check the console for:
```
✅ Connected to signaling server
```

---

## Testing Your Deployment

### Test 1: Health Check

```powershell
curl https://your-server-url.com/health
```

Expected response:
```json
{
  "status": "healthy",
  "uptime": 123,
  "rooms": 0,
  "clients": 0
}
```

### Test 2: WebSocket Connection

Use a WebSocket testing tool:
- **Online**: https://www.websocket.org/echo.html
- **Desktop**: Download "WebSocket King" or "Postman"

Connect to: `wss://your-server-url.com`

Send:
```json
{"type": "ping"}
```

Should receive:
```json
{"type": "pong", "timestamp": 1234567890}
```

### Test 3: Room Creation

Send:
```json
{"type": "create-room", "roomCode": "TEST123"}
```

Should receive:
```json
{
  "type": "room-created",
  "roomCode": "TEST123",
  "clientId": "uuid-here",
  "isHost": true
}
```

---

## Troubleshooting

### Issue: "Application error" on Heroku

**Solution**:
```powershell
# Check logs
heroku logs --tail

# Restart dyno
heroku restart
```

### Issue: WebSocket connection fails

**Solutions**:
1. Make sure you're using `wss://` not `ws://`
2. Check if server is running: `curl https://your-url.com/health`
3. Check firewall settings
4. Verify SSL certificate is valid

### Issue: "Cannot find module 'ws'"

**Solution**:
```powershell
# Make sure package.json has dependencies
# Redeploy
git add .
git commit -m "Fix dependencies"
git push heroku master
```

---

## Monitoring Your Server

### Heroku

**View logs:**
```powershell
heroku logs --tail
```

**View metrics:**
```powershell
heroku ps
```

**Open dashboard:**
```powershell
heroku open
```

### Railway

- Go to railway.app dashboard
- Click on your project
- View "Deployments" tab for logs

### Render

- Go to render.com dashboard
- Click on your service
- View "Logs" tab

---

## Cost Comparison

| Platform | Free Tier | Limits | Best For |
|----------|-----------|--------|----------|
| **Heroku** | 550 hours/month | Sleeps after 30min inactivity | Development |
| **Railway** | $5 credit/month | ~500 hours | Small projects |
| **Render** | 750 hours/month | Slower cold starts | Production |

**Recommendation**: Start with **Railway** or **Render** for always-on free hosting.

---

## Quick Commands Reference

```powershell
# Heroku
heroku login
heroku create app-name
git push heroku master
heroku logs --tail
heroku open

# Test server
curl https://your-url.com/health
curl https://your-url.com/rooms

# Update Flutter app
# Edit lib/services/signaling_service.dart
# Change SIGNALING_SERVER_URL to your deployed URL
```

---

## Next Steps After Deployment

1. ✅ Server deployed and running
2. ✅ Health check passes
3. ✅ Flutter app updated with server URL
4. 🎯 Test connection from Flutter app
5. 🎯 Test file transfer between two devices
6. 🎯 Monitor server logs during testing

---

**Need Help?**
- Heroku Docs: https://devcenter.heroku.com/
- Railway Docs: https://docs.railway.app/
- Render Docs: https://render.com/docs

**Your server is ready to handle WebRTC signaling for your AirDrop app!** 🚀
