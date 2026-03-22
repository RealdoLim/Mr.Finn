package com.example.mr_finn

import android.app.Notification
import android.content.ComponentName
import android.os.Bundle
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Log
import org.json.JSONObject

class MaybankNotificationListenerService : NotificationListenerService() {

    override fun onListenerConnected() {
        super.onListenerConnected()
        Log.d("MrFinnListener", "Notification listener connected")
    }

    override fun onListenerDisconnected() {
        super.onListenerDisconnected()
        Log.w("MrFinnListener", "Notification listener disconnected, requesting rebind")
        requestRebind(ComponentName(this, MaybankNotificationListenerService::class.java))
    }

    override fun onNotificationPosted(sbn: StatusBarNotification) {
        val notification = sbn.notification ?: return
        val extras: Bundle = notification.extras ?: Bundle.EMPTY

        val title = extras.getCharSequence(Notification.EXTRA_TITLE)?.toString()?.trim().orEmpty()
        val text = extras.getCharSequence(Notification.EXTRA_TEXT)?.toString()?.trim().orEmpty()
        val subText = extras.getCharSequence(Notification.EXTRA_SUB_TEXT)?.toString()?.trim().orEmpty()
        val packageName = sbn.packageName.orEmpty()

        if (!looksLikeMaybank(packageName, title, text)) return

        val payload = JSONObject().apply {
            put("packageName", packageName)
            put("title", title)
            put("text", text)
            put("subText", subText)
            put("postTime", sbn.postTime)
            put("notificationKey", sbn.key ?: "")
        }

        Log.d("MrFinnListener", "Captured notification: $payload")
        NotificationBridge.emitOrBuffer(applicationContext, payload)
    }

    private fun looksLikeMaybank(
        packageName: String,
        title: String,
        text: String
    ): Boolean {
        val p = packageName.lowercase()
        val t = title.lowercase()
        val x = text.lowercase()

        return p.contains("maybank") ||
            t.contains("maybank2u") ||
            x.contains("maybank2u")
    }
}