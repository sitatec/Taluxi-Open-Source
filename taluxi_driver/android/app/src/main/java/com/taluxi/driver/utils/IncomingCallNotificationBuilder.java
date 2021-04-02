package com.taluxi.driver.utils;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.ContentResolver;
import android.content.Context;
import android.content.Intent;
import android.media.AudioAttributes;
import android.net.Uri;
import android.os.Build;
import android.widget.RemoteViews;

import androidx.core.app.NotificationCompat;

import com.taluxi.driver.R;
import com.taluxi.driver.activities.AnsweredCallActivity;
import com.taluxi.driver.activities.IncomingCallActivity;
import com.taluxi.driver.broadcast_receivers.HangUpReceiver;

public class IncomingCallNotificationBuilder{

    private static final int INCOMING_CALL_HANG_UP_REQUEST_ID = 1100;
    private static final String NOTIFICATION_CHANEL_ID = "INCOMING_CALL_NOTIFICATION_CHANEL_ID";
    public static final int INCOMING_CALL_REQUEST_ID = 11;
    public static final int ANSWER_CALL_REQUEST_ID = 22;
    private final Context context;
    final long[] vibrationPattern = {1000, 1000};
    private final Uri soundUri;

    public IncomingCallNotificationBuilder(Context context){
        this.context = context;
        soundUri = new Uri.Builder()
                .scheme(ContentResolver.SCHEME_ANDROID_RESOURCE)
                .authority(context.getPackageName())
                .path(Integer.toString(R.raw.incoming_call_ringtone))
                .build();
        createNotificationChannel();
   }

    private void createNotificationChannel(){
        final NotificationManager notificationManager = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O){
            final NotificationChannel notificationChannel = new NotificationChannel(NOTIFICATION_CHANEL_ID, "Appel entrant", NotificationManager.IMPORTANCE_HIGH);
            notificationChannel.setDescription("Notification des appels entrants");
            notificationChannel.setVibrationPattern(vibrationPattern);
            notificationChannel.enableVibration(true);
            notificationChannel.setSound(soundUri,new  AudioAttributes.Builder().setUsage(AudioAttributes.USAGE_NOTIFICATION_RINGTONE).build());
            notificationManager.createNotificationChannel(notificationChannel);
        }
    }

    public Notification build(){
        final Intent incomingCallIntent = new Intent(context, IncomingCallActivity.class);
        final PendingIntent incomingCallPendingIntent = PendingIntent.getActivity(context, INCOMING_CALL_REQUEST_ID, incomingCallIntent, PendingIntent.FLAG_ONE_SHOT);
        final Notification notification = new NotificationCompat.Builder(context, NOTIFICATION_CHANEL_ID)
                .setSmallIcon(R.drawable.ic_notification)
                .setPriority(NotificationCompat.PRIORITY_HIGH)
                .setOngoing(true)
                .setCategory(NotificationCompat.CATEGORY_CALL)
                .setContentIntent(incomingCallPendingIntent)
                .setFullScreenIntent(incomingCallPendingIntent, true)
                .setSound(soundUri)
                .setVibrate(vibrationPattern)
                .setDefaults(NotificationCompat.DEFAULT_LIGHTS)
                .setCustomContentView(getIncomingCallNotificationView())
                .build();
        notification.flags |= NotificationCompat.FLAG_INSISTENT;
        return notification;
    }

    private RemoteViews getIncomingCallNotificationView(){
        final RemoteViews incomingCallNotificationView = new RemoteViews(context.getPackageName(), R.layout.notification_incoming_call);
        final Intent answerCallIntent = new Intent(context, AnsweredCallActivity.class);
        final Intent hangUpIntent = new Intent(HangUpReceiver.ACTION_HANG_UP_INCOMING_CALL);
        final PendingIntent hangUpPendingIntent = PendingIntent.getBroadcast(
                context, INCOMING_CALL_HANG_UP_REQUEST_ID, hangUpIntent,
                PendingIntent.FLAG_UPDATE_CURRENT
        );
        final PendingIntent answerCallPendingIntent = PendingIntent.getActivity(
                context, ANSWER_CALL_REQUEST_ID, answerCallIntent, PendingIntent.FLAG_UPDATE_CURRENT
        );
        hangUpIntent.setAction(HangUpReceiver.ACTION_HANG_UP_INCOMING_CALL);
        incomingCallNotificationView.setOnClickPendingIntent(R.id.answer_call_button, answerCallPendingIntent);
        incomingCallNotificationView.setOnClickPendingIntent(R.id.hang_up_button, hangUpPendingIntent);
        return incomingCallNotificationView;
    }

}

