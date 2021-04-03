package com.taluxi.driver.activities;

import android.content.Intent;
import android.os.Bundle;

import com.taluxi.driver.R;
import com.taluxi.driver.broadcast_receivers.HangUpReceiver;

public class IncomingCallActivity extends FullScreenActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_incoming_call);
        thisActivity = this;
        findViewById(R.id.activity_answer_call_button).setOnClickListener(__ -> {
            startActivity(new Intent(this, AnsweredCallActivity.class));
            finish();
        });
        findViewById(R.id.activity_hang_up_button).setOnClickListener(__ -> {
            sendBroadcast(new Intent(HangUpReceiver.ACTION_HANG_UP_INCOMING_CALL));
            finish();
        });
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        thisActivity = null;
    }

    private static IncomingCallActivity thisActivity;

    public static void destroy(){
        if (thisActivity != null) {
          thisActivity.finish();
        }
    }
}