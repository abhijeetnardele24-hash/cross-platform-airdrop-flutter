# Testing Checklist for File Transfer

## Pre-Testing Setup

### Android Device
- [ ] Enable Developer Options
- [ ] Enable USB Debugging
- [ ] Grant Location permission
- [ ] Grant Bluetooth permissions
- [ ] Grant Storage permissions
- [ ] Turn on WiFi and Bluetooth

### iOS Device (if available)
- [ ] Trust developer certificate
- [ ] Grant Local Network permission
- [ ] Grant Bluetooth permission
- [ ] Turn on WiFi and Bluetooth

## Test 1: Basic Connection (Android)

### Device A (Host)
1. [ ] Open app
2. [ ] Go to "Send" tab
3. [ ] Tap "Create Room"
4. [ ] Note the room code (e.g., "ABC123")
5. [ ] Verify "Advertising..." status

### Device B (Guest)
1. [ ] Open app
2. [ ] Go to "Send" tab
3. [ ] Enter room code from Device A
4. [ ] Tap "Join"
5. [ ] Verify "Discovering..." status
6. [ ] Wait for connection
7. [ ] Verify "Device connected" notification

**Expected Result**: ✅ Both devices show connected status

## Test 2: Single File Transfer

### Device A (Sender)
1. [ ] Tap on file type button (e.g., "Images")
2. [ ] Select 1 image file (< 5 MB)
3. [ ] Verify file appears in selected list
4. [ ] Tap "Send Files" button
5. [ ] Observe progress bar
6. [ ] Wait for "Transfer Complete" notification

### Device B (Receiver)
1. [ ] Observe "Receiving file..." notification
2. [ ] Watch progress update
3. [ ] Receive "File received" notification
4. [ ] Tap "Open" in notification
5. [ ] Verify file opens correctly
6. [ ] Check Downloads folder for file

**Expected Result**: ✅ File transferred successfully with progress tracking

## Test 3: Multiple Files Transfer

### Device A (Sender)
1. [ ] Select 3-5 files of different types
2. [ ] Verify all files in list
3. [ ] Tap "Send Files"
4. [ ] Observe sequential transfer
5. [ ] Verify progress for each file

### Device B (Receiver)
1. [ ] Receive all files
2. [ ] Verify all files in Downloads
3. [ ] Check file sizes match
4. [ ] Verify file integrity

**Expected Result**: ✅ All files transferred successfully

## Test 4: Large File Transfer

### Test with 10+ MB file
1. [ ] Select large file (video/PDF)
2. [ ] Send file
3. [ ] Monitor progress (should show incremental updates)
4. [ ] Verify chunked transfer (check console logs)
5. [ ] Confirm successful receipt
6. [ ] Verify file integrity (open and check)

**Expected Result**: ✅ Large file transferred with smooth progress

## Test 5: Error Handling

### Test A: Connection Lost
1. [ ] Start file transfer
2. [ ] Turn off WiFi/Bluetooth mid-transfer
3. [ ] Verify error notification
4. [ ] Check error message in UI

**Expected Result**: ✅ Error handled gracefully

### Test B: Insufficient Storage
1. [ ] Fill device storage (if possible)
2. [ ] Attempt to receive file
3. [ ] Verify error message

**Expected Result**: ✅ Clear error message shown

### Test C: Invalid File
1. [ ] Select non-existent file path
2. [ ] Attempt to send
3. [ ] Verify error handling

**Expected Result**: ✅ Error caught and reported

## Test 6: Encryption Verification

1. [ ] Send encrypted file
2. [ ] Check console logs for encryption messages
3. [ ] Verify decryption on receive
4. [ ] Confirm file opens correctly

**Expected Result**: ✅ Files encrypted/decrypted transparently

## Test 7: UI/UX Testing

### Progress Indicators
- [ ] Progress bar updates smoothly
- [ ] Percentage shown accurately
- [ ] File name displayed
- [ ] File size displayed

### Notifications
- [ ] "Device connected" notification
- [ ] "Sending..." notification
- [ ] "Transfer complete" notification
- [ ] "File received" notification with "Open" action

### Error Messages
- [ ] Clear error descriptions
- [ ] Helpful suggestions
- [ ] No app crashes

**Expected Result**: ✅ Smooth, intuitive user experience

## Test 8: Developer Tools Testing

### WebRTC Test
1. [ ] Go to Settings
2. [ ] Scroll to "Developer Tools"
3. [ ] Tap "Test WebRTC Connection"
4. [ ] Verify all tests pass
5. [ ] Check console for detailed logs

### Nearby Connections Test
1. [ ] Tap "Test Nearby Connections"
2. [ ] Try "Start Advertising"
3. [ ] Try "Start Discovery" (on second device)
4. [ ] Try "Send Test Data"
5. [ ] Verify console logs

**Expected Result**: ✅ All tests pass

## Test 9: Performance Testing

### Metrics to Check
- [ ] Transfer speed (MB/s)
- [ ] CPU usage (should be reasonable)
- [ ] Memory usage (no leaks)
- [ ] Battery drain (acceptable)
- [ ] App responsiveness during transfer

### Tools
- Android Studio Profiler
- Xcode Instruments
- Flutter DevTools

**Expected Result**: ✅ Good performance, no issues

## Test 10: Cross-Platform Testing (if available)

### Android to iOS
1. [ ] Android creates room
2. [ ] iOS joins room
3. [ ] Transfer files both ways
4. [ ] Verify compatibility

### iOS to Android
1. [ ] iOS creates room
2. [ ] Android joins room
3. [ ] Transfer files both ways
4. [ ] Verify compatibility

**Expected Result**: ✅ Cross-platform transfers work

## Bug Reporting Template

If you find a bug, report it with:

```
**Bug Title**: [Short description]

**Steps to Reproduce**:
1. 
2. 
3. 

**Expected Behavior**:


**Actual Behavior**:


**Device Info**:
- Platform: Android/iOS
- OS Version: 
- App Version: 
- Device Model: 

**Console Logs**:
```
[Paste relevant logs]
```

**Screenshots**:
[Attach if applicable]
```

## Success Criteria

All tests must pass with:
- ✅ No crashes
- ✅ No data loss
- ✅ Accurate progress tracking
- ✅ Proper error handling
- ✅ Good performance
- ✅ Intuitive UI/UX

## Notes

- Test on different network conditions (WiFi, mobile data, airplane mode)
- Test with different file sizes (1KB to 100MB+)
- Test with different file types (images, videos, documents, archives)
- Test with multiple concurrent transfers (if supported)
- Monitor console logs for any warnings or errors

---

**Tester Name**: _________________
**Date**: _________________
**Build Version**: _________________
**Test Result**: ☐ PASS  ☐ FAIL  ☐ PARTIAL
