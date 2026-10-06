package app.hydrowflow

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class HydroWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val premium = widgetData.getBoolean("premium", false)
        val consumedMl = widgetData.getInt("consumed_ml", 0)
        val goalMl = widgetData.getInt("goal_ml", 0)
        val cupMl = widgetData.getInt("cup_ml", 250)
        val progress = if (goalMl > 0) (consumedMl * 100 / goalMl).coerceIn(0, 100) else 0

        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.hydro_widget).apply {
                setOnClickPendingIntent(
                    R.id.widget_root,
                    HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java),
                )

                if (premium) {
                    setViewVisibility(R.id.widget_content, View.VISIBLE)
                    setViewVisibility(R.id.widget_locked, View.GONE)
                    setTextViewText(R.id.widget_amount, "$consumedMl / $goalMl ml")
                    setTextViewText(R.id.widget_percent, "$progress%")
                    setProgressBar(R.id.widget_progress, 100, progress, false)
                    setTextViewText(R.id.widget_add, "+ $cupMl ml")
                    setOnClickPendingIntent(
                        R.id.widget_add,
                        HomeWidgetBackgroundIntent.getBroadcast(
                            context,
                            Uri.parse("hydroflow://addcup"),
                        ),
                    )
                } else {
                    setViewVisibility(R.id.widget_content, View.GONE)
                    setViewVisibility(R.id.widget_locked, View.VISIBLE)
                }
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
