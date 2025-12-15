package com.proion.zavx

import android.content.ContentValues
import android.content.Context
import android.media.MediaScannerConnection
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.util.Log
import java.io.File
import java.io.FileOutputStream

class MediaStorePlugin {
    companion object {
        private const val CHANNEL = "com.proion.zavx/media_store"
        private const val TAG = "MediaStorePlugin"

        fun registerWith(flutterEngine: FlutterEngine, context: Context) {
            val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            
            channel.setMethodCallHandler { call, result ->
                when (call.method) {
                    "saveToPublicStorage" -> {
                        try {
                            val fileName = call.argument<String>("fileName") ?: ""
                            val mimeType = call.argument<String>("mimeType") ?: "image/png"
                            val bytes = call.argument<ByteArray>("bytes") ?: ByteArray(0)
                            
                            val savedPath = saveToPublicStorage(context, fileName, mimeType, bytes)
                            result.success(savedPath)
                        } catch (e: Exception) {
                            Log.e(TAG, "Error saving file", e)
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
            mimeType: String,
            bytes: ByteArray
        ): String {
            val isPdf = mimeType.contains("pdf")
            
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                // ✅ IMÁGENES → Pictures/Proïon
                // ✅ PDFs → Documents/Proïon
                val relativePath = if (isPdf) {
                    "${Environment.DIRECTORY_DOCUMENTS}/Proïon"
                } else {
                    "${Environment.DIRECTORY_PICTURES}/Proïon"
                }
                
                val contentValues = ContentValues().apply {
                    put(MediaStore.MediaColumns.DISPLAY_NAME, fileName)
                    put(MediaStore.MediaColumns.MIME_TYPE, mimeType)
                    put(MediaStore.MediaColumns.RELATIVE_PATH, relativePath)
                    put(MediaStore.MediaColumns.IS_PENDING, 1)
                }

                val collection = if (isPdf) {
                    MediaStore.Files.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY)
                } else {
                    MediaStore.Images.Media.EXTERNAL_CONTENT_URI
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

                // ✅ FORZAR ACTUALIZACIÓN DE LA GALERÍA
                try {
                    val filePath = getFilePathFromUri(context, uri)
                    if (filePath != null) {
                        MediaScannerConnection.scanFile(
                            context,
                            arrayOf(filePath),
                            arrayOf(mimeType)
                        ) { path, scanUri ->
                            Log.d(TAG, "✅ Archivo escaneado: $path")
                        }
                    }
                } catch (e: Exception) {
                    Log.w(TAG, "Media scanner warning: ${e.message}")
                }

                return uri.toString()
                
            } else {
                // ✅ ANDROID 9 O MENOS
                val baseDir = if (isPdf) {
                    Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOCUMENTS)
                } else {
                    Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES)
                }
                
                val proionDir = File(baseDir, "Proïon")
                
                if (!proionDir.exists()) {
                    proionDir.mkdirs()
                }
                
                val file = File(proionDir, fileName)
                FileOutputStream(file).use { outputStream ->
                    outputStream.write(bytes)
                    outputStream.flush()
                }
                
                try {
                    MediaScannerConnection.scanFile(
                        context,
                        arrayOf(file.absolutePath),
                        arrayOf(mimeType),
                        null
                    )
                } catch (e: Exception) {
                    Log.w(TAG, "Media scanner warning: ${e.message}")
                }
                
                return file.absolutePath
            }
        }

        private fun getFilePathFromUri(context: Context, uri: Uri): String? {
            return try {
                context.contentResolver.query(
                    uri,
                    arrayOf(MediaStore.MediaColumns.DATA),
                    null,
                    null,
                    null
                )?.use { cursor ->
                    if (cursor.moveToFirst()) {
                        val columnIndex = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.DATA)
                        cursor.getString(columnIndex)
                    } else null
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error getting file path", e)
                null
            }
        }
    }
}
