# WebSocket Signaling Server Setup Guide

## Overview
Complete guide to set up and deploy a WebSocket signaling server for WebRTC connections in the AirDrop app.

## Server Implementation

### 1. Create Server Directory
```bash
mkdir signaling-server
cd signaling-server
npm init -y
```

### 2. Install Dependencies
```bash
npm install ws express cors dotenv uuid
npm install --save-dev nodemon
```

### 3. Create server.js

```javascript
const WebSocket = require('ws');
const express = require('express');
const cors = require('cors');
const { v4: uuidv4 } = require('uuid');
require('dotenv').config();

const app = express();
app.use(cors());
app.use(express.json());

const PORT = process.env.PORT || 8080;

// Store active rooms and clients
const rooms = new Map();
const clients = new Map();

// Create HTTP server
const server = app.listen(PORT, () => {
  console.log(`🚀 Signaling server running on port ${PORT}`);
});

// Create WebSocket server
const wss = new WebSocket.Server({ server });

// Room class to manage room state
class Room {
  constructor(code) {
    this.code = code;
    this.host = null;
    this.peers = new Set();
    this.createdAt = Date.now();
  }

  addPeer(clientId, ws) {
    if (!this.host) {
      this.host = clientId;
    }
    this.peers.add(clientId);
    clients.set(clientId, { ws, roomCode: this.code });
  }

  removePeer(clientId) {
    this.peers.delete(clientId);
    clients.delete(clientId);
    
    // If host leaves, assign new host
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

// WebSocket connection handler
wss.on('connection', (ws) => {
  const clientId = uuidv4();
  console.log(`✅ Client connected: ${clientId}`);

  ws.on('message', (data) => {
    try {
      const message = JSON.parse(data);
      handleMessage(clientId, ws, message);
    } catch (error) {
      console.error('❌ Error parsing message:', error);
      ws.send(JSON.stringify({ type: 'error', message: 'Invalid message format' }));
    }
  });

  ws.on('close', () => {
    handleDisconnect(clientId);
    console.log(`❌ Client disconnected: ${clientId}`);
  });

  ws.on('error', (error) => {
    console.error(`❌ WebSocket error for ${clientId}:`, error);
  });

  // Send welcome message
  ws.send(JSON.stringify({
    type: 'connected',
    clientId,
    timestamp: Date.now()
  }));
});

// Handle incoming messages
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

    case 'device-info':
      handleDeviceInfo(clientId, roomCode, data);
      break;

    case 'ping':
      ws.send(JSON.stringify({ type: 'pong', timestamp: Date.now() }));
      break;

    default:
      console.warn(`⚠️ Unknown message type: ${type}`);
  }
}

// Create new room
function handleCreateRoom(clientId, ws, roomCode) {
  if (rooms.has(roomCode)) {
    ws.send(JSON.stringify({
      type: 'error',
      message: 'Room already exists'
    }));
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

  console.log(`🏠 Room created: ${roomCode} by ${clientId}`);
}

// Join existing room
function handleJoinRoom(clientId, ws, roomCode) {
  const room = rooms.get(roomCode);

  if (!room) {
    ws.send(JSON.stringify({
      type: 'error',
      message: 'Room not found'
    }));
    return;
  }

  room.addPeer(clientId, ws);

  // Notify new peer
  ws.send(JSON.stringify({
    type: 'room-joined',
    roomCode,
    clientId,
    isHost: false,
    peerCount: room.peers.size
  }));

  // Notify existing peers
  room.broadcast({
    type: 'peer-joined',
    clientId,
    peerCount: room.peers.size
  }, clientId);

  console.log(`👥 Client ${clientId} joined room: ${roomCode}`);
}

// Leave room
function handleLeaveRoom(clientId) {
  const client = clients.get(clientId);
  if (!client) return;

  const room = rooms.get(client.roomCode);
  if (!room) return;

  room.removePeer(clientId);

  // Notify remaining peers
  room.broadcast({
    type: 'peer-left',
    clientId,
    peerCount: room.peers.size
  });

  // Delete room if empty
  if (room.isEmpty()) {
    rooms.delete(client.roomCode);
    console.log(`🗑️ Room deleted: ${client.roomCode}`);
  }

  console.log(`👋 Client ${clientId} left room: ${client.roomCode}`);
}

// Handle disconnect
function handleDisconnect(clientId) {
  handleLeaveRoom(clientId);
}

// Forward signaling messages
function handleSignaling(clientId, roomCode, message) {
  const room = rooms.get(roomCode);
  if (!room) return;

  const { targetId } = message;

  if (targetId) {
    // Send to specific peer
    const targetClient = clients.get(targetId);
    if (targetClient && targetClient.ws.readyState === WebSocket.OPEN) {
      targetClient.ws.send(JSON.stringify({
        ...message,
        fromId: clientId
      }));
    }
  } else {
    // Broadcast to all peers except sender
    room.broadcast({
      ...message,
      fromId: clientId
    }, clientId);
  }
}

// Handle device info
function handleDeviceInfo(clientId, roomCode, deviceInfo) {
  const room = rooms.get(roomCode);
  if (!room) return;

  room.broadcast({
    type: 'device-info',
    clientId,
    data: deviceInfo
  }, clientId);
}

// REST API endpoints
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

  res.json({
    rooms: roomList,
    total: rooms.size
  });
});

app.get('/rooms/:code', (req, res) => {
  const { code } = req.params;
  const room = rooms.get(code);

  if (!room) {
    return res.status(404).json({ error: 'Room not found' });
  }

  res.json({
    code: room.code,
    peerCount: room.peers.size,
    createdAt: room.createdAt
  });
});

// Cleanup old rooms (every 5 minutes)
setInterval(() => {
  const now = Date.now();
  const maxAge = 24 * 60 * 60 * 1000; // 24 hours

  rooms.forEach((room, code) => {
    if (now - room.createdAt > maxAge && room.isEmpty()) {
      rooms.delete(code);
      console.log(`🧹 Cleaned up old room: ${code}`);
    }
  });
}, 5 * 60 * 1000);

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM received, closing server...');
  server.close(() => {
    console.log('Server closed');
    process.exit(0);
  });
});

console.log('📡 WebSocket Signaling Server Ready');
console.log(`📍 Health check: http://localhost:${PORT}/health`);
console.log(`📊 Rooms list: http://localhost:${PORT}/rooms`);
```

### 4. Create .env file

```env
PORT=8080
NODE_ENV=production
```

### 5. Update package.json scripts

```json
{
  "scripts": {
    "start": "node server.js",
    "dev": "nodemon server.js"
  }
}
```

## Deployment Options

### Option 1: Deploy to Heroku

#### 1. Install Heroku CLI
```bash
# Download from https://devcenter.heroku.com/articles/heroku-cli
```

#### 2. Login to Heroku
```bash
heroku login
```

#### 3. Create Heroku app
```bash
cd signaling-server
heroku create airdrop-signaling-server
```

#### 4. Add Procfile
```bash
echo "web: node server.js" > Procfile
```

#### 5. Deploy
```bash
git init
git add .
git commit -m "Initial commit"
git push heroku master
```

#### 6. Get your server URL
```bash
heroku open
# Your URL: https://airdrop-signaling-server.herokuapp.com
```

### Option 2: Deploy to AWS (EC2)

#### 1. Launch EC2 Instance
- Choose Ubuntu Server 22.04 LTS
- Instance type: t2.micro (free tier)
- Configure security group: Allow ports 80, 443, 8080

#### 2. Connect to instance
```bash
ssh -i your-key.pem ubuntu@your-ec2-ip
```

#### 3. Install Node.js
```bash
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs
```

#### 4. Install PM2
```bash
sudo npm install -g pm2
```

#### 5. Upload server files
```bash
scp -i your-key.pem -r signaling-server ubuntu@your-ec2-ip:~/
```

#### 6. Start server
```bash
cd signaling-server
npm install
pm2 start server.js --name airdrop-signaling
pm2 startup
pm2 save
```

#### 7. Setup Nginx (optional)
```bash
sudo apt install nginx
sudo nano /etc/nginx/sites-available/signaling
```

Add configuration:
```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

Enable site:
```bash
sudo ln -s /etc/nginx/sites-available/signaling /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

### Option 3: Deploy to Railway.app

#### 1. Sign up at railway.app
#### 2. Create new project
#### 3. Connect GitHub repository
#### 4. Railway auto-detects Node.js and deploys
#### 5. Get your URL from Railway dashboard

### Option 4: Deploy to Render.com

#### 1. Sign up at render.com
#### 2. Create new Web Service
#### 3. Connect GitHub repository
#### 4. Build Command: `npm install`
#### 5. Start Command: `npm start`
#### 6. Get your URL from Render dashboard

## Testing the Server

### Local Testing

```bash
# Start server
npm run dev

# Test health endpoint
curl http://localhost:8080/health

# Test WebSocket connection
# Use a WebSocket client or the Flutter app
```

### Production Testing

```bash
# Test health
curl https://your-server-url.com/health

# Test rooms endpoint
curl https://your-server-url.com/rooms
```

## Server URL Configuration

After deploying, update your Flutter app with the server URL:

### File: `lib/services/signaling_service.dart`

```dart
class SignalingService {
  // Replace with your deployed server URL
  static const String SIGNALING_SERVER_URL = 'wss://your-server-url.com';
  
  // For local testing
  // static const String SIGNALING_SERVER_URL = 'ws://localhost:8080';
}
```

## Monitoring

### Heroku
```bash
heroku logs --tail
```

### AWS/PM2
```bash
pm2 logs airdrop-signaling
pm2 monit
```

### Health Check
```bash
curl https://your-server-url.com/health
```

## Security Considerations

1. **Rate Limiting**: Add rate limiting to prevent abuse
2. **Authentication**: Implement token-based authentication
3. **HTTPS**: Always use WSS (WebSocket Secure) in production
4. **CORS**: Configure CORS properly for your domain
5. **Room Expiration**: Automatically clean up old rooms

## Scaling

### Horizontal Scaling
- Use Redis for shared state across multiple server instances
- Implement sticky sessions or use Redis Pub/Sub

### Vertical Scaling
- Increase server resources (CPU, RAM)
- Optimize WebSocket connections

## Troubleshooting

### Connection Issues
- Check firewall settings
- Verify WebSocket upgrade headers
- Test with `wscat` tool

### Room Not Found
- Check room cleanup interval
- Verify room code format

### High Latency
- Check server location vs. client location
- Consider using CDN or edge locations

---

**Status**: Ready for Deployment
**Version**: 1.0.0
**Team**: Team Narcos
