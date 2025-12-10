package com.proion.zavx

import android.content.ContentValues
import android.content.Context
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

class MediaStorePlugin {
    companion object {
        private const val CHANNEL = "com.proion.zavx/media_store"

        fun registerWith(flutterEngine: FlutterEngine, context: Context) {
            val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            
            channel.setMethodCallHandler { call, result ->
                when (call.method) {
                    "saveToPublicStorage" -> {
                        try {
                            val fileName = call.argument<String>("fileName") ?: ""
                            val subfolder = call.argument<String>("subfolder") ?: "Invoices"
                            val mimeType = call.argument<String>("mimeType") ?: "application/pdf"
                            val bytes = call.argument<ByteArray>("bytes") ?: ByteArray(0)
                            
                            val savedPath = saveToPublicStorage(context, fileName, subfolder, mimeType, bytes)
                            result.success(savedPath)
                        } catch (e: Exception) {
                            result.error("SAVE_ERROR", e.message, null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
        }

        private fun saveToPublicStorage(
            context: Context,
            fileName: String,
            subfolder: String,
            mimeType: String,
            bytes: ByteArray
        ): String {
            // Determinar si es imagen
            val isImage = mimeType.startsWith("image/")
            
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                // Android 10+ - Usar MediaStore
                val baseFolder = if (isImage) {
                    Environment.DIRECTORY_PICTURES
                } else {
                    Environment.DIRECTORY_DOCUMENTS
                }
                
                val relativePath = "$baseFolder/Proion/$subfolder"
                
                val contentValues = ContentValues().apply {
                    put(MediaStore.MediaColumns.DISPLAY_NAME, fileName)
                    put(MediaStore.MediaColumns.MIME_TYPE, mimeType)
                    put(MediaStore.MediaColumns.RELATIVE_PATH, relativePath)
                    put(MediaStore.MediaColumns.IS_PENDING, 1)
                }

                val collection = if (isImage) {
                    MediaStore.Images.Media.EXTERNAL_CONTENT_URI
                } else {
                    MediaStore.Files.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY)
                }

                val uri = context.contentResolver.insert(collection, contentValues)
                    ?: throw Exception("Failed to create MediaStore entry")

                context.contentResolver.openOutputStream(uri)?.use { outputStream ->
                    outputStream.write(bytes)
                    outputStream.flush()
                } ?: throw Exception("Failed to open output stream")

                contentValues.clear()
                contentValues.put(MediaStore.MediaColumns.IS_PENDING, 0)
                context.contentResolver.update(uri, contentValues, null, null)

                return uri.toString()
            } else {
                // Android 9 o menos - Acceso directo
                val baseDir = if (isImage) {
                    Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES)
                } else {
                    Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOCUMENTS)
                }
                
                val proionDir = File(baseDir, "Proion/$subfolder")
                
                if (!proionDir.exists()) {
                    proionDir.mkdirs()
                }
                
                val file = File(proionDir, fileName)
                FileOutputStream(file).use { outputStream ->
                    outputStream.write(bytes)
                    outputStream.flush()
                }
                
                return file.absolutePath
            }
        }
    }
}
