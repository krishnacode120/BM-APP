package com.example.bm

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                "bm_order_updates",
                "BM order updates",
                NotificationManager.IMPORTANCE_DEFAULT,
            ).apply {
                description = "Order and delivery updates from BM"
            }
            getSystemService(NotificationManager::class.java).createNotificationChannel(channel)
        }
    }
}
