package com.taluxi.driver.broadcast_receivers;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

import com.taluxi.driver.BuildConfig;


public class HangUpReceiver extends BroadcastReceiver {

    public static final String ACTION_HANG_UP_INCOMING_CALL =
            BuildConfig.APPLICATION_ID + "ACTION_HANG_UP_INCOMING_CALL";
//    public static final String ACTION_HANG_UP_ANSWERED_CALL =
//            BuildConfig.APPLICATION_ID + "ACTION_HANG_UP_ANSWERED_CALL";

    private IncomingCallHangUpHandler incomingCallHangUpHandler;
//    private AnsweredCallHangUpHandler answeredCallHangUpHandler;

    public interface IncomingCallHangUpHandler{
        void handle();
    }

//    public interface AnsweredCallHangUpHandler{
//        void handle();
//    }

    public void setIncomingCallHangUpHandler(IncomingCallHangUpHandler incomingCallHangUpHandler) {
        this.incomingCallHangUpHandler = incomingCallHangUpHandler;
    }

//    public void setAnsweredCallHangUpHandler(AnsweredCallHangUpHandler answeredCallHangUpHandler) {
//        this.answeredCallHangUpHandler = answeredCallHangUpHandler;
//    }

    @Override
    public void onReceive(Context context, Intent intent) {
        assert incomingCallHangUpHandler != null;
        if(intent.getAction().equals(ACTION_HANG_UP_INCOMING_CALL)){
            incomingCallHangUpHandler.handle();
        }
//        else if (intent.getAction().equals(ACTION_HANG_UP_ANSWERED_CALL)){
//            answeredCallHangUpHandler.handle();
//        }
    }
}