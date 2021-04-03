package com.taluxi.driver.activities;

import android.app.NotificationManager;
import android.os.Bundle;
import android.text.format.DateUtils;
import android.view.View;
import android.widget.TextView;

import com.google.android.material.floatingactionbutton.FloatingActionButton;
import com.taluxi.driver.R;

import java.text.DecimalFormat;
import java.util.Timer;
import java.util.TimerTask;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.FlutterEngineCache;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class AnsweredCallActivity extends FullScreenActivity {

  private class CallTimerTask extends TimerTask {

    public static final int HOUR_IN_SECONDS = 3600;
    private int counter = 0;

    @Override
    public void run() {
      if (++counter == HOUR_IN_SECONDS)
        counter = 0; // for the taluxi app a call must not be longer than 1h.
      final DecimalFormat formatter = new DecimalFormat("00");
      final String timerText =
          formatter.format(counter / 60) + ":" + formatter.format(counter % 60);
      runOnUiThread(() -> callTimerText.setText(timerText));
    }
  }

  public static final String METHOD_CHANNEL = "CALL_EVENTS_CHANNEL";

  private Timer callTimer;
  private TextView callTimerText;
  private FloatingActionButton toggleSpeakerBtn;
  private FloatingActionButton toggleMicrophoneBtn;

  private boolean microphoneEnabled = true;
  private boolean speakerEnabled = false;

  private MethodChannel methodChannel;

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.activity_answered_call);
    ((NotificationManager) getSystemService(NOTIFICATION_SERVICE))
        .cancel(R.integer.incoming_call_notification_id);
    startCallTimer();
    setUpMethodChannel();
    setUpActions();
  }

  private void setUpActions() {
    findViewById(R.id.activity_hang_up_button).setOnClickListener(this::hangUp);
    toggleMicrophoneBtn = findViewById(R.id.activity_microphone_button);
    toggleSpeakerBtn = findViewById(R.id.activity_speaker_button);
    toggleSpeakerBtn.setOnClickListener(this::toggleSpeaker);
    toggleMicrophoneBtn.setOnClickListener(this::toggleMicrophone);
  }

  private void toggleSpeaker(View v) {
    speakerEnabled = !speakerEnabled;
    methodChannel.invokeMethod("toggleSpeaker", speakerEnabled);
    updateSpeakerIcon();
  }

  private void updateSpeakerIcon() {
    if (speakerEnabled) {
      toggleSpeakerBtn.setImageResource(R.drawable.ic_volume_down_24);
    } else toggleSpeakerBtn.setImageResource(R.drawable.ic_volume_up_24);
  }

  private void toggleMicrophone(View v) {
    microphoneEnabled = !microphoneEnabled;
    methodChannel.invokeMethod("toggleMicrophone", microphoneEnabled);
    updateMicrophoneIcon();
  }

  private void updateMicrophoneIcon() {
    if (microphoneEnabled) {
      toggleMicrophoneBtn.setImageResource(R.drawable.ic_mic_off_24);
    } else {
      toggleMicrophoneBtn.setImageResource(R.drawable.ic_mic_24);
    }
  }

  private void setUpMethodChannel() {
    final FlutterEngine flutterEngine =
        FlutterEngineCache.getInstance().get(getString(R.string.flutter_engine_id));
    methodChannel =
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), METHOD_CHANNEL);
    methodChannel.setMethodCallHandler(this::methodCallHandler);
    methodChannel.invokeMethod("answerCall", null);
  }

  private void methodCallHandler(MethodCall call, MethodChannel.Result result) {
    if (call.method.equals("hangUpAnsweredCall")) finish();
  }

  private void hangUp(View v) {
    methodChannel.invokeMethod("callHangedUp", null);
    finish();
  }

  private void startCallTimer() {
    callTimerText = findViewById(R.id.call_timer);
    callTimer = new Timer();
    callTimer.scheduleAtFixedRate(new CallTimerTask(), 0, DateUtils.SECOND_IN_MILLIS);
  }

  @Override
  protected void onDestroy() {
    callTimer.cancel();
    super.onDestroy();
  }
}
