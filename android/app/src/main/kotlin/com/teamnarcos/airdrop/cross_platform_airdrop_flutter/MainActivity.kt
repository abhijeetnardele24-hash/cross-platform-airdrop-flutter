package com.teamnarcos.airdrop.cross_platform_airdrop_flutter

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.crossplatformairdrop.share"
    private var pendingSharedFiles: MutableList<String> = mutableListOf()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getSharedFiles" -> {
                    result.success(pendingSharedFiles.toList())
                    pendingSharedFiles.clear()
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleIntent(intent)
    }

    private fun handleIntent(intent: Intent?) {
        intent?.let {
            when (it.action) {
                Intent.ACTION_SEND -> {
                    handleSendIntent(it)
                }
                Intent.ACTION_SEND_MULTIPLE -> {
                    handleSendMultipleIntent(it)
                }
            }
        }
    }

    private fun handleSendIntent(intent: Intent) {
        val uri = intent.getParcelableExtra<Uri>(Intent.EXTRA_STREAM)
        uri?.let {
            val filePath = copyUriToCache(it)
            filePath?.let { path ->
                pendingSharedFiles.add(path)
            }
        }

        val text = intent.getStringExtra(Intent.EXTRA_TEXT)
        text?.let {
            // Handle shared text
            pendingSharedFiles.add("text:$it")
        }
    }

    private fun handleSendMultipleIntent(intent: Intent) {
        val uris = intent.getParcelableArrayListExtra<Uri>(Intent.EXTRA_STREAM)
        uris?.forEach { uri ->
            val filePath = copyUriToCache(uri)
            filePath?.let { path ->
                pendingSharedFiles.add(path)
            }
        }
    }

    private fun copyUriToCache(uri: Uri): String? {
        return try {
            val inputStream = contentResolver.openInputStream(uri)
            inputStream?.use { input ->
                val fileName = getFileNameFromUri(uri) ?: "shared_file_${System.currentTimeMillis()}"
                val cacheFile = File(cacheDir, fileName)
                FileOutputStream(cacheFile).use { output ->
                    input.copyTo(output)
                }
                cacheFile.absolutePath
            }
        } catch (e: Exception) {
            e.printStackTrace()
            null
        }
    }

    private fun getFileNameFromUri(uri: Uri): String? {
        val cursor = contentResolver.query(uri, null, null, null, null)
        cursor?.use {
            if (it.moveToFirst()) {
                val displayNameIndex = it.getColumnIndex("_display_name")
                if (displayNameIndex != -1) {
                    return it.getString(displayNameIndex)
                }
            }
        }
        return uri.lastPathSegment
    }
}
