package com.taluxi.driver.activities;


import android.app.NotificationManager;
import android.content.Intent;
import android.os.Bundle;
import android.widget.TextView;

import com.taluxi.driver.R;
import com.taluxi.driver.broadcast_receivers.HangUpReceiver;

import java.text.DecimalFormat;
import java.util.Timer;
import java.util.TimerTask;

public class AnsweredCallActivity extends FullScreenActivity {

    public static final String METHOD_CHANNEL = "CALL_EVENTS_CHANNEL";
    private Timer callTimer;
    private TextView callTimerText;
    private int counter = 0;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_answered_call);
        ((NotificationManager) getSystemService(NOTIFICATION_SERVICE)).cancel(R.integer.incoming_call_notification_id);
        findViewById(R.id.activity_hang_up_button).setOnClickListener((__) -> {
            sendBroadcast(new Intent(HangUpReceiver.ACTION_HANG_UP_ANSWERED_CALL));
            finish();
        });
        callTimerText =  findViewById(R.id.call_timer);
        callTimer = new Timer();
        startCallTimer();
    }

    private void startCallTimer(){
        callTimer.scheduleAtFixedRate(new TimerTask() {
            @Override
            public void run() {
                if(++counter == 1600) counter = 0; // for the taluxi app a call must not be longer than 1h.
                final DecimalFormat formatter = new DecimalFormat("00");
                final String timerText =  formatter.format(counter/60) + ":" + formatter.format(counter % 60);
                runOnUiThread(() -> callTimerText.setText(timerText));
            }
        }, 0, 1000);
    }

    @Override
    protected void onDestroy() {
        callTimer.cancel();
        super.onDestroy();
    }
}