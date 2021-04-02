package com.taluxi.driver.activities;

import android.app.NotificationManager;
import android.content.IntentFilter;
import android.os.Bundle;
import android.util.Log;

import androidx.annotation.NonNull;

import com.taluxi.driver.R;
import com.taluxi.driver.broadcast_receivers.HangUpReceiver;
import com.taluxi.driver.utils.IncomingCallNotificationBuilder;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.FlutterEngineCache;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    public static final String METHOD_CHANNEL = "INCOMING_CALL_CHANNEL";
    private NotificationManager notificationManager;
    private final HangUpReceiver hangUpReceiver = new HangUpReceiver();
    private IncomingCallNotificationBuilder incomingCallNotificationBuilder;

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        FlutterEngineCache.getInstance().put(getString(R.string.flutter_engine_id), flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), METHOD_CHANNEL)
                .setMethodCallHandler((call, result) -> {
                    if(call.method.equals("displayIncomingCall")){
                        Log.i("MainActivity", "displayIncomingCall() invoked");
                        displayIncomingCallNotification();
                    }
                });
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        incomingCallNotificationBuilder = new IncomingCallNotificationBuilder(this);
        notificationManager = (NotificationManager) getSystemService(NOTIFICATION_SERVICE);
        setUpHangUpReceiver();
    }

    private void setUpHangUpReceiver(){
        hangUpReceiver.setAnsweredCallHangUpHandler(this::handleAnsweredCallHangUp);
        hangUpReceiver.setIncomingCallHangUpHandler(this::handleIncomingCallHangUp);
        final IntentFilter hangUpBroadcastFilter = new IntentFilter();
        hangUpBroadcastFilter.addAction(HangUpReceiver.ACTION_HANG_UP_INCOMING_CALL);
        hangUpBroadcastFilter.addAction(HangUpReceiver.ACTION_HANG_UP_ANSWERED_CALL);
        registerReceiver(hangUpReceiver, hangUpBroadcastFilter);
    }

    private void handleAnsweredCallHangUp() {
        Log.i(getLocalClassName(), "ANSWERED CALL HANGED UP");
    }

    private void handleIncomingCallHangUp() {
        cancelNotification();
    }

    private void displayIncomingCallNotification() {
        notificationManager.notify(R.integer.incoming_call_notification_id, incomingCallNotificationBuilder.build());
    }

    private void cancelNotification() {
        notificationManager.cancel(R.integer.incoming_call_notification_id);
    }

    @Override
    protected void onDestroy() {
        unregisterReceiver(hangUpReceiver);
        super.onDestroy();
    }
}
