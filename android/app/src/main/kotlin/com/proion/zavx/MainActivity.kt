package com.proion.zavx

import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.webkit.MimeTypeMap
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {

    private val FILE_MANAGER_CHANNEL = "com.proion.zavx/file_manager"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MediaStorePlugin.registerWith(flutterEngine, this)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, FILE_MANAGER_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "openFolder" -> {
                        val path = call.argument<String>("path")
                        if (path != null) openFolder(path, result)
                        else result.error("INVALID_PATH", "Path is null", null)
                    }
                    "openFile" -> {
                        val path = call.argument<String>("path")
                        if (path != null) openFile(path, result)
                        else result.error("INVALID_PATH", "Path is null", null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun openFolder(path: String, result: MethodChannel.Result) {
        try {
            val folder = File(path)

            if (!folder.exists() || !folder.isDirectory) {
                result.error("FOLDER_NOT_FOUND", "Carpeta no existe: $path", null)
                return
            }

            val latestFile = folder.listFiles()
                ?.filter { it.isFile }
                ?.maxByOrNull { it.lastModified() }

            if (latestFile != null && latestFile.exists()) {
                openFile(latestFile.absolutePath, result)
            } else {
                val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE).apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
                startActivity(intent)
                result.success("Selector de carpetas abierto")
            }
        } catch (e: Exception) {
            result.error("ERROR", "Error: ${e.message}", null)
        }
    }

    private fun openFile(path: String, result: MethodChannel.Result) {
        try {
            val file = File(path)

            if (!file.exists()) {
                result.error("FILE_NOT_FOUND", "Archivo no existe: $path", null)
                return
            }

            val uri = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                FileProvider.getUriForFile(
                    this,
                    "${applicationContext.packageName}.fileprovider",
                    file
                )
            } else {
                Uri.fromFile(file)
            }

            val mimeType = getMimeType(file.absolutePath) ?: "*/*"

            val intent = Intent(Intent.ACTION_SEND).apply {
                type = mimeType
                putExtra(Intent.EXTRA_STREAM, uri)
                putExtra(Intent.EXTRA_SUBJECT, "Backup - ${file.name}")
                putExtra(Intent.EXTRA_TEXT, "Archivo exportado desde Proïon")
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }

            val chooser = Intent.createChooser(intent, "Compartir archivo")
            chooser.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            
            startActivity(chooser)
            result.success("Archivo compartido: ${file.name}")

        } catch (e: Exception) {
            result.error("ERROR", "Error: ${e.message}", null)
        }
    }

    private fun getMimeType(path: String): String? {
        val extension = MimeTypeMap.getFileExtensionFromUrl(path)
        return MimeTypeMap.getSingleton()
            .getMimeTypeFromExtension(extension?.lowercase())
    }
}
