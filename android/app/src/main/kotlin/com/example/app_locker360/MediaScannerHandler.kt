package com.example.app_locker360

import android.content.Context
import android.media.MediaScannerConnection
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import java.io.File

object MediaScannerHandler {
    
    /**
     * Delete a file from MediaStore database (Android API 29+)
     * For older versions, this just triggers a media scan after file deletion
     */
    fun deleteFromMediaStore(context: Context, filePath: String): Boolean {
        return try {
            val file = File(filePath)
            
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                // For Android 10+ (API 29+), use MediaStore to delete
                val contentUri = when {
                    filePath.contains("/DCIM/") || filePath.contains("/Pictures/") -> 
                        MediaStore.Images.Media.EXTERNAL_CONTENT_URI
                    filePath.contains("/Movies/") || filePath.contains("/Video/") -> 
                        MediaStore.Video.Media.EXTERNAL_CONTENT_URI
                    filePath.contains("/Music/") || filePath.contains("/Audio/") -> 
                        MediaStore.Audio.Media.EXTERNAL_CONTENT_URI
                    else -> 
                        MediaStore.Files.getContentUri("external")
                }
                
                // Query for the file in MediaStore
                val projection = arrayOf(MediaStore.MediaColumns._ID)
                val selection = "${MediaStore.MediaColumns.DATA} = ?"
                val selectionArgs = arrayOf(filePath)
                
                context.contentResolver.query(
                    contentUri,
                    projection,
                    selection,
                    selectionArgs,
                    null
                )?.use { cursor ->
                    if (cursor.moveToFirst()) {
                        val id = cursor.getLong(cursor.getColumnIndexOrThrow(MediaStore.MediaColumns._ID))
                        val uri = Uri.withAppendedPath(contentUri, id.toString())
                        
                        // Delete from MediaStore
                        val deleted = context.contentResolver.delete(uri, null, null) > 0
                        
                        if (deleted) {
                            // Also delete the physical file if it still exists
                            if (file.exists()) {
                                file.delete()
                            }
                            return true
                        }
                    }
                }
            } else {
                // For older Android versions, delete file and trigger media scan
                if (file.exists()) {
                    val deleted = file.delete()
                    if (deleted) {
                        // Notify media scanner that file was deleted
                        MediaScannerConnection.scanFile(
                            context,
                            arrayOf(filePath),
                            null
                        ) { path, uri ->
                            // File deletion notification sent
                        }
                        return true
                    }
                }
            }
            
            false
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }
    
    /**
     * Trigger media scanner for a specific file
     * Used for older Android versions or when manual scanning is needed
     */
    fun scanMediaFile(context: Context, filePath: String, callback: (Boolean) -> Unit) {
        try {
            MediaScannerConnection.scanFile(
                context,
                arrayOf(filePath),
                null
            ) { path, uri ->
                callback(uri != null)
            }
        } catch (e: Exception) {
            e.printStackTrace()
            callback(false)
        }
    }
}
