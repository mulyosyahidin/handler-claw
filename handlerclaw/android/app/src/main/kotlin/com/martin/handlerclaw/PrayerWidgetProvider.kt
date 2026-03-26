package com.martin.handlerclaw

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import com.martin.handlerclaw.R

class PrayerWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.prayer_widget).apply {
                val count = widgetData.getString("widget_count", "0")
                setTextViewText(R.id.widget_count, count)

                val lastUpdate = widgetData.getString("last_update", "--:--")
                setTextViewText(R.id.widget_last_update, lastUpdate)

                // Set dots
                updateDot(this, R.id.dot_subuh, widgetData.getBoolean("subuh_done", false))
                updateDot(this, R.id.dot_dzuhur, widgetData.getBoolean("dzuhur_done", false))
                updateDot(this, R.id.dot_ashar, widgetData.getBoolean("ashar_done", false))
                updateDot(this, R.id.dot_maghrib, widgetData.getBoolean("maghrib_done", false))
                updateDot(this, R.id.dot_isya, widgetData.getBoolean("isya_done", false))
            }
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }

    private fun updateDot(views: RemoteViews, viewId: Int, isDone: Boolean) {
        views.setImageViewResource(
            viewId,
            if (isDone) R.drawable.widget_dot_on else R.drawable.widget_dot_off
        )
    }
}
