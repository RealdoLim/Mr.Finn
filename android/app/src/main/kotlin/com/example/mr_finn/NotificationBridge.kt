package com.example.mr_finn

import android.content.Context
import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.EventChannel
import org.json.JSONArray
import org.json.JSONObject

object NotificationBridge {
    private const val PREFS_NAME = "mr_finn_notification_buffer"
    private const val KEY_BUFFER = "buffer"
    private val mainHandler = Handler(Looper.getMainLooper())

    @Volatile
    private var eventSink: EventChannel.EventSink? = null

    fun setEventSink(sink: EventChannel.EventSink?) {
        eventSink = sink
    }

    fun emitOrBuffer(context: Context, payload: JSONObject) {
        val sink = eventSink
        if (sink != null) {
            mainHandler.post {
                sink.success(jsonToMap(payload))
            }
        } else {
            bufferPayload(context, payload)
        }
    }

    fun consumeBuffered(context: Context): List<Map<String, Any?>> {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val raw = prefs.getString(KEY_BUFFER, "[]") ?: "[]"
        prefs.edit().remove(KEY_BUFFER).apply()

        val array = JSONArray(raw)
        val result = mutableListOf<Map<String, Any?>>()

        for (i in 0 until array.length()) {
            result.add(jsonToMap(array.getJSONObject(i)))
        }

        return result
    }

    private fun bufferPayload(context: Context, payload: JSONObject) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val existing = prefs.getString(KEY_BUFFER, "[]") ?: "[]"
        val array = JSONArray(existing)
        array.put(payload)
        prefs.edit().putString(KEY_BUFFER, array.toString()).apply()
    }

    private fun jsonToMap(obj: JSONObject): Map<String, Any?> {
        val map = mutableMapOf<String, Any?>()
        val keys = obj.keys()

        while (keys.hasNext()) {
            val key = keys.next()
            val value = obj.opt(key)
            map[key] = if (value == JSONObject.NULL) null else value
        }

        return map
    }
}
