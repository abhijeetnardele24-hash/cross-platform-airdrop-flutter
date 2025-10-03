# 🔧 Services Directory Documentation

## 📁 Service Files Organization

### 🔄 **Background Services**
- **`background_service.dart`** - Main background service with full functionality
- **`background_service_simple.dart`** - Simplified version for build compatibility

### 🌐 **Network & Communication**
- **`connection_manager.dart`** - Manages device connections and network state
- **`device_discovery_service.dart`** - Discovers nearby devices for file sharing
- **`room_connectivity_service.dart`** - Handles room-based connections
- **`room_discovery_service.dart`** - Discovers available rooms
- **`room_socket_service.dart`** - WebSocket communication for rooms
- **`signaling_service.dart`** - WebRTC signaling for peer connections
- **`webrtc_service.dart`** - WebRTC implementation for direct connections

### 📁 **File Operations**
- **`file_transfer_service.dart`** - Core file transfer functionality
- **`share_service.dart`** - File sharing and platform integration

### 💾 **Data & Storage**
- **`database_service.dart`** - Local database operations
- **`trusted_device_service.dart`** - Manages trusted device list

### ☁️ **Cloud & External**
- **`cloud_relay_service.dart`** - Cloud relay for remote transfers
- **`notification_service.dart`** - Push notifications and local alerts

## 🎯 **Service Purposes**

### **Core Transfer Flow:**
1. `device_discovery_service.dart` - Find nearby devices
2. `connection_manager.dart` - Establish connections
3. `webrtc_service.dart` / `room_socket_service.dart` - Handle communication
4. `file_transfer_service.dart` - Transfer files
5. `notification_service.dart` - Notify users

### **Background Operations:**
- `background_service.dart` - Handle transfers when app is backgrounded
- `background_service_simple.dart` - Fallback for build compatibility

### **Data Management:**
- `database_service.dart` - Store transfer history and settings
- `trusted_device_service.dart` - Manage device trust relationships

## 🔧 **Usage Notes**

### **Background Services:**
- Use `background_service.dart` for full functionality
- Use `background_service_simple.dart` when complex dependencies cause build issues

### **Connection Types:**
- **Direct WebRTC**: Use `webrtc_service.dart` + `signaling_service.dart`
- **Room-based**: Use `room_socket_service.dart` + `room_connectivity_service.dart`
- **Cloud relay**: Use `cloud_relay_service.dart` for remote transfers

### **File Operations:**
- `file_transfer_service.dart` - Main transfer logic
- `share_service.dart` - Platform-specific sharing integration

## ✅ **Service Status**

| Service | Status | Purpose |
|---------|--------|---------|
| `background_service.dart` | ✅ Working | Main background operations |
| `background_service_simple.dart` | ✅ Working | Simplified background service |
| `connection_manager.dart` | ✅ Working | Connection management |
| `device_discovery_service.dart` | ✅ Working | Device discovery |
| `file_transfer_service.dart` | ✅ Working | File transfer core |
| `webrtc_service.dart` | ✅ Working | WebRTC connections |
| `notification_service.dart` | ✅ Working | Notifications |
| `database_service.dart` | ✅ Working | Data storage |
| `share_service.dart` | ✅ Working | Platform sharing |
| All others | ✅ Working | Specialized functions |

## 🚀 **No Duplicate Issues**

All duplicate service files have been cleaned up:
- ✅ Removed `background_service_backup_old.dart`
- ✅ Renamed `background_service_backup.dart` → `background_service_simple.dart`
- ✅ Clear, descriptive naming for all services
- ✅ No naming conflicts or confusion
