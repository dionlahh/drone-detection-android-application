package org.tensorflow.lite.examples.detection.display;

import static org.tensorflow.lite.examples.detection.utils.AppConfiguration.RTSP_HEIGHT;
import static org.tensorflow.lite.examples.detection.utils.AppConfiguration.RTSP_URL;
import static org.tensorflow.lite.examples.detection.utils.AppConfiguration.RTSP_WIDTH;

import android.hardware.Camera;
import android.os.Build;
import android.os.Bundle;
import android.util.Size;
import android.view.MenuItem;
import android.view.MotionEvent;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.View;
import android.view.WindowManager;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.EditText;
import android.widget.RadioGroup;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;
import androidx.appcompat.app.ActionBarDrawerToggle;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.app.AppCompatDelegate;
import androidx.core.view.GravityCompat;
import androidx.drawerlayout.widget.DrawerLayout;

import com.google.android.material.navigation.NavigationView;
import com.pedro.encoder.input.video.CameraHelper;
import com.pedro.rtplibrary.rtsp.RtspCamera1;
import com.pedro.rtsp.utils.ConnectCheckerRtsp;

import org.tensorflow.lite.examples.detection.R;

import java.util.ArrayList;
import java.util.List;

public class ClientActivity extends AppCompatActivity
        implements View.OnClickListener, ConnectCheckerRtsp, SurfaceHolder.Callback,
        View.OnTouchListener {

    private Integer[] orientations = new Integer[] { 0, 90, 180, 270 };
    private Size desiredSize = new Size(RTSP_WIDTH, RTSP_HEIGHT);
    private int desiredSizeIndex;
    private RtspCamera1 rtspCamera1;
    private SurfaceView surfaceView;
    private Button stream_button;
    //options menu
    private DrawerLayout drawerLayout;
    private NavigationView navigationView;
    private ActionBarDrawerToggle actionBarDrawerToggle;
    private RadioGroup rgChannel;
    //    private RadioButton rbTcp, rbUdp;
    private Spinner spResolution;
    private CheckBox cbEchoCanceler, cbNoiseSuppressor;
    private EditText etVideoBitrate, etFps, etAudioBitrate, etSampleRate, etWowzaUser,
            etWowzaPassword;
    private String lastVideoBitrate;
    private TextView tvBitrate;
    private EditText et_rtsp_link;

    private String rtsp_link = RTSP_URL;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        setContentView(R.layout.activity_client);
        AppCompatDelegate.setDefaultNightMode(AppCompatDelegate.MODE_NIGHT_NO);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setHomeButtonEnabled(true);
        getSupportActionBar().setTitle(R.string.client_app_name);

        surfaceView = findViewById(R.id.surfaceView);
        surfaceView.getHolder().addCallback(this);
        surfaceView.setOnTouchListener(this);
        rtspCamera1 = new RtspCamera1(surfaceView, this);
        prepareOptionsMenuViews();

        tvBitrate = findViewById(R.id.tv_bitrate);
        et_rtsp_link = findViewById(R.id.et_rtsp_link);
        stream_button = findViewById(R.id.b_stream);
        stream_button.setOnClickListener(this);

        et_rtsp_link.setHint(rtsp_link);
    }

    private void prepareOptionsMenuViews() {
        drawerLayout = findViewById(R.id.activity_client);
        navigationView = findViewById(R.id.nv_rtsp_options);
        navigationView.inflateMenu(R.menu.rtsp_options);
        actionBarDrawerToggle = new ActionBarDrawerToggle(this, drawerLayout, R.string.client_app_name, R.string.client_app_name) {

            public void onDrawerOpened(View drawerView) {
                actionBarDrawerToggle.syncState();
                lastVideoBitrate = etVideoBitrate.getText().toString();
            }

            @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
            public void onDrawerClosed(View view) {
                actionBarDrawerToggle.syncState();
                if (lastVideoBitrate != null && !lastVideoBitrate.equals(
                        etVideoBitrate.getText().toString()) && rtspCamera1.isStreaming()) {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
                        int bitrate = Integer.parseInt(etVideoBitrate.getText().toString()) * 1024;
                        rtspCamera1.setVideoBitrateOnFly(bitrate);
                        Toast.makeText(ClientActivity.this, "New bitrate: " + bitrate, Toast.LENGTH_SHORT).
                                show();
                    } else {
                        Toast.makeText(ClientActivity.this, "Bitrate on fly ignored, Required min API 19",
                                Toast.LENGTH_SHORT).show();
                    }
                }
            }
        };
        drawerLayout.addDrawerListener(actionBarDrawerToggle);
        //checkboxs
        cbEchoCanceler =
                (CheckBox) navigationView.getMenu().findItem(R.id.cb_echo_canceler).getActionView();
        cbNoiseSuppressor =
                (CheckBox) navigationView.getMenu().findItem(R.id.cb_noise_suppressor).getActionView();
        //radiobuttons
//        rbTcp = (RadioButton) navigationView.getMenu().findItem(R.id.rb_tcp).getActionView();
//        rbUdp = (RadioButton) navigationView.getMenu().findItem(R.id.rb_udp).getActionView();
        rgChannel = (RadioGroup) navigationView.getMenu().findItem(R.id.channel).getActionView();
//        rbTcp.setChecked(true);
//        rbTcp.setOnClickListener(this);
//        rbUdp.setOnClickListener(this);
        //spinners
        spResolution = (Spinner) navigationView.getMenu().findItem(R.id.sp_resolution).getActionView();

        ArrayAdapter<Integer> orientationAdapter =
                new ArrayAdapter<>(this, androidx.appcompat.R.layout.support_simple_spinner_dropdown_item);
        orientationAdapter.addAll(orientations);

        ArrayAdapter<String> resolutionAdapter =
                new ArrayAdapter<>(this, androidx.appcompat.R.layout.support_simple_spinner_dropdown_item);


        List<String> list = new ArrayList<>();
//        for (Size size : rtspCamera2.getResolutionsBack()) {
//            list.add(size.getWidth() + "X" + size.getHeight());
//        }

        for (Camera.Size size : rtspCamera1.getResolutionsBack()) {
            list.add(size.width + "X" + size.height);
        }
        for (int i = 0; i < list.size(); i++) {
            if (list.get(i).equals("1920X1080"))
                desiredSizeIndex = i;
        }
        resolutionAdapter.addAll(list);
        spResolution.setAdapter(resolutionAdapter);
        spResolution.setSelection(desiredSizeIndex);
        //edittexts
        etVideoBitrate =
                (EditText) navigationView.getMenu().findItem(R.id.et_video_bitrate).getActionView();
        etFps = (EditText) navigationView.getMenu().findItem(R.id.et_fps).getActionView();
        etAudioBitrate =
                (EditText) navigationView.getMenu().findItem(R.id.et_audio_bitrate).getActionView();
        etSampleRate = (EditText) navigationView.getMenu().findItem(R.id.et_samplerate).getActionView();
        etVideoBitrate.setText("2500");
        etFps.setText("30");
        etAudioBitrate.setText("128");
        etSampleRate.setText("44100");
        etWowzaUser = (EditText) navigationView.getMenu().findItem(R.id.et_user).getActionView();
        etWowzaPassword =
                (EditText) navigationView.getMenu().findItem(R.id.et_password).getActionView();
    }

    @Override
    protected void onPostCreate(@Nullable Bundle savedInstanceState) {
        super.onPostCreate(savedInstanceState);
        actionBarDrawerToggle.syncState();
    }

    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()) {
            case android.R.id.home:
                if (!drawerLayout.isDrawerOpen(GravityCompat.START)) {
                    drawerLayout.openDrawer(GravityCompat.START);
                } else {
                    drawerLayout.closeDrawer(GravityCompat.START);
                }
                return true;
            default:
                return false;
        }
    }

    private boolean prepareEncoders() {
//        Size resolution =
//                rtspCamera2.getResolutionsBack().get(spResolution.getSelectedItemPosition());
//        int width = resolution.getWidth();
//        int height = resolution.getHeight();
        Camera.Size resolution =
                rtspCamera1.getResolutionsBack().get(spResolution.getSelectedItemPosition());
        int width = resolution.width;
        int height = resolution.height;

        return rtspCamera1.prepareVideo(width, height, Integer.parseInt(etFps.getText().toString()),
                Integer.parseInt(etVideoBitrate.getText().toString()) * 1024,
                CameraHelper.getCameraOrientation(this)) && rtspCamera1.prepareAudio(
                Integer.parseInt(etAudioBitrate.getText().toString()) * 1024,
                Integer.parseInt(etSampleRate.getText().toString()),
                rgChannel.getCheckedRadioButtonId() == R.id.rb_stereo, cbEchoCanceler.isChecked(),
                cbNoiseSuppressor.isChecked());
    }

    @Override
    public void surfaceCreated(@NonNull SurfaceHolder holder) {

    }

    @Override
    public void surfaceChanged(@NonNull SurfaceHolder holder, int format, int width, int height) {
        rtspCamera1.startPreview();
    }

    @Override
    public void surfaceDestroyed(@NonNull SurfaceHolder holder) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR2) {
            if (rtspCamera1.isStreaming()) {
                rtspCamera1.stopStream();
                stream_button.setText(R.string.start_stream);
//                tv_rtsp_link.setText("");
            }
            rtspCamera1.stopPreview();
        }
    }

    @Override
    public void onClick(View v) {
        switch(v.getId()) {
            case R.id.b_stream:
                if (!rtspCamera1.isStreaming()) {
                    stream_button.setText(getResources().getString(R.string.stop_stream));
                    String user = etWowzaUser.getText().toString();
                    String password = etWowzaPassword.getText().toString();
                    if (!user.isEmpty() && !password.isEmpty()) {
                        rtspCamera1.setAuthorization(user, password);
                    }
                    if (rtspCamera1.isRecording() || prepareEncoders()) {
                        rtspCamera1.startStream(et_rtsp_link.getText().toString());
//                        tv_rtsp_link.setText(rtsp_link);
                    } else {
                        //If you see this all time when you start stream,
                        //it is because your encoder device dont support the configuration
                        //in video encoder maybe color format.
                        //If you have more encoder go to VideoEncoder or AudioEncoder class,
                        //change encoder and try
                        Toast.makeText(this, "Error preparing stream, This device cant do it",
                                Toast.LENGTH_SHORT).show();
                        stream_button.setText(getResources().getString(R.string.start_stream));
                    }
                } else {
                    stream_button.setText(getResources().getString(R.string.start_stream));
                    rtspCamera1.stopStream();
//                    tv_rtsp_link.setText("");
                }
                break;
            default:
                break;
        }
    }

    @Override
    public boolean onTouch(View v, MotionEvent event) {
        switch (v.getId()) {
            case R.id.surfaceView:
                int action = event.getAction();
                if (event.getPointerCount() > 1) {
                    if (action == MotionEvent.ACTION_MOVE) {
                        rtspCamera1.setZoom(event);
                    }
                }
//                else if (action == MotionEvent.ACTION_DOWN) {
//                    rtspCamera2.tapToFocus(event);
//                }
                return true;
            default:
                return true;
        }
    }

    @Override
    public void onAuthErrorRtsp() {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                Toast.makeText(ClientActivity.this, "Authentication Error", Toast.LENGTH_SHORT).show();
                rtspCamera1.stopStream();
                stream_button.setText(R.string.start_stream);
//                tv_rtsp_link.setText("");
            }
        });
    }

    @Override
    public void onAuthSuccessRtsp() {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                Toast.makeText(ClientActivity.this, "Authentication Success", Toast.LENGTH_SHORT).show();
            }
        });
    }

    @Override
    public void onConnectionFailedRtsp(@NonNull String s) {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                Toast.makeText(ClientActivity.this, "Connection failed." + s, Toast.LENGTH_SHORT).show();
                rtspCamera1.stopStream();
                stream_button.setText(R.string.start_stream);
            }
        });
    }

    @Override
    public void onConnectionStartedRtsp(@NonNull String s) {

    }

    @Override
    public void onConnectionSuccessRtsp() {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                Toast.makeText(ClientActivity.this, "Connection success", Toast.LENGTH_SHORT).show();
            }
        });
    }

    @Override
    public void onDisconnectRtsp() {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                Toast.makeText(ClientActivity.this, "Disconnected", Toast.LENGTH_SHORT).show();
            }
        });
    }

    @Override
    public void onNewBitrateRtsp(long bitrate) {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                tvBitrate.setText(bitrate + " bps");
            }
        });
    }

    @Override
    public void onBackPressed(){
        finish();
        overridePendingTransition(R.anim.enter_from_left, R.anim.exit_out_right);
    }
}