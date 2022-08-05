/*
 * Copyright 2019 The TensorFlow Authors. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.tensorflow.lite.examples.detection;

import android.Manifest;
import android.app.Activity;
import android.app.AlertDialog;
import android.app.Fragment;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.content.pm.PackageManager;
import android.content.res.AssetManager;
import android.content.res.Resources;
import android.graphics.drawable.AnimationDrawable;
import android.hardware.Camera;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.hardware.camera2.CameraAccessException;
import android.hardware.camera2.CameraCharacteristics;
import android.hardware.camera2.CameraManager;
import android.hardware.camera2.params.StreamConfigurationMap;
import android.media.Image;
import android.media.Image.Plane;
import android.media.ImageReader;
import android.media.ImageReader.OnImageAvailableListener;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.IBinder;
import android.os.Trace;
import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;
import androidx.appcompat.app.AppCompatActivity;

import android.util.Base64;
import android.util.DisplayMetrics;
import android.util.Size;
import android.view.MotionEvent;
import android.view.Surface;
import android.view.SurfaceHolder;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewTreeObserver;
import android.view.WindowManager;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.CompoundButton;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.RelativeLayout;
import android.widget.SeekBar;
import android.widget.Switch;
import android.widget.TextView;
import android.widget.Toast;
import com.google.android.material.bottomsheet.BottomSheetBehavior;
import com.pedro.rtplibrary.rtsp.RtspCamera1;
import com.pedro.rtplibrary.view.OpenGlView;
import com.pedro.rtsp.utils.ConnectCheckerRtsp;

import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.charset.Charset;
import java.nio.charset.CharsetEncoder;
import java.util.ArrayList;
import java.util.List;

import org.tensorflow.lite.examples.detection.compass.Compass;
import org.tensorflow.lite.examples.detection.display.DisplayService;
import org.tensorflow.lite.examples.detection.env.ImageUtils;
import org.tensorflow.lite.examples.detection.env.Logger;
import org.tensorflow.lite.examples.detection.position.DrawView;

public abstract class CameraActivity extends AppCompatActivity
    implements OnImageAvailableListener,
        Camera.PreviewCallback,
        View.OnClickListener,
        View.OnLongClickListener,
        View.OnTouchListener,
        CompoundButton.OnCheckedChangeListener,
        SeekBar.OnSeekBarChangeListener{

  // Logging
  private static final Logger LOGGER = new Logger();

  // Camera Preview & Detector Setup
  private static final int PERMISSIONS_REQUEST = 1;
  private static final String PERMISSION_CAMERA = Manifest.permission.CAMERA;
  private static final String ASSET_PATH = "";
  public static int previewWidth = 0;
  public static int previewHeight = 0;
  private boolean debug = false;
  protected Handler handler;
  private HandlerThread handlerThread;
  private boolean useCamera2API;
  private boolean isProcessingFrame = false;
  private byte[][] yuvBytes = new byte[3][];
  private int[] rgbBytes = null;
  private int yRowStride;
  protected int defaultModelIndex = 0;
  protected int defaultDeviceIndex = 0;
  private Runnable postInferenceCallback;
  private Runnable imageConverter;
  protected ArrayList<String> modelStrings = new ArrayList<String>();
  public static float confThresh = 0.3f;
  public static boolean startDetector;
  protected SeekBar seekBar;
  protected Switch detectorSwitch;

  // Bottom Sheet Menu
  private LinearLayout bottomSheetLayout;
  private LinearLayout gestureLayout;
  private BottomSheetBehavior<LinearLayout> sheetBehavior;
  protected TextView frameValueTextView, cropValueTextView, inferenceTimeTextView, confidenceThreshTextView;
  protected ImageView bottomSheetArrowImageView;
  private ImageView plusImageView, minusImageView;
  protected ListView deviceView;
  protected TextView threadsTextView;
  protected ListView modelView;
  /** Current indices of device and model. */
  int currentDevice = -1;
  int currentModel = -1;
  int currentNumThreads = -1;
  ArrayList<String> deviceStrings = new ArrayList<String>();

  // Redline for detection cutoff zone
  // Screen size excluding navigation bar
  DisplayMetrics displayMetrics = Resources.getSystem().getDisplayMetrics();
  int screenWidth = displayMetrics.widthPixels;   // Width of the device's screen
  int screenHeight = displayMetrics.heightPixels; // Height of the device's screen
  int windowwidth;                                // Width of the RelativeLayout.
  int windowheight;                               // Height of the RelativeLayout.
  private TextView liveTextView;
  private ImageView mImageView;
  private ViewGroup mRrootLayout;
  protected Switch redLineSwitch;
  private int _xDelta, _yDelta;
  public static int imageSize = 640;
  public static int cutOffY, lastCutOffY;
  public static boolean setCutOff;


  // RTSP Streaming Setup
  private String rtspLink = "rtsp://192.168.1.26:8554/stream/"; // Home Workstation
//  private String rtspLink = "rtsp://192.168.56.1:8554/stream/"; // Office Workstation
//  private RtspCamera2 rtspCamera2; // Can explore the use of RtspCamera2 for higher camera preview resolution
  private RtspCamera1 rtspCamera1;
  private OpenGlView openGlView;
  private Button button;
  private Button button_mirror;
  private final int REQUEST_CODE_STREAM = 179; //random num
  private final int REQUEST_CODE_RECORD = 180; //random num
  // Attempted Hardcoded values to initiate RTSP Stream with TFLite running
  private byte[] spsData = Base64.decode("Z0LAKY1oHgUaQgAAAwAPCIRq", Base64.NO_WRAP);
  private byte[] ppsData = Base64.decode("aM4BqDXI", Base64.NO_WRAP);
  public static Charset charset = Charset.forName("UTF-16");
  public static CharsetEncoder encoder = charset.newEncoder();

  // Sensor Setup
  private Compass compass;
  public static float currentAzimuth;
  public static double phoneTiltAngle;
  public double zAccel;

  // Capture Detection Results Setup
  protected boolean captureWorldOffsets = false;
  protected int initDataSize = 0;
  public static List<String> worldOffsetResults = new ArrayList<>();

  // Device Calibration for Range Estimation Setup
  private DrawView drawView;
  private Button calibrate_button;
  private boolean isCalibrating = false;
  private int[] rectDim;
  private int boxWidth = 0 , boxHeight = 0;
  protected double drone_distance_calibration = 5;
  protected double boxWidth_calibration = 56;
  protected double boxHeight_calibration = 24;
  private AlertDialog.Builder dialogBuilder;
  private AlertDialog dialog;
  private EditText et_drone_distance, et_box_width, et_box_height;
  private Button save_calibration_button, cancel_calibration_button;
  protected Switch calibrationSwitch;

  // W-I-P Service to run Object Detector in background
  MyForegroundService myForegroundService;
  private boolean bound = false;
  ServiceConnection serviceConnection = new ServiceConnection() {
    @Override
    public void onServiceConnected(ComponentName componentName, IBinder iBinder) {
      myForegroundService = ((MyForegroundService.MyForegroundServiceBinder) iBinder).getService();
    }
    @Override
    public void onServiceDisconnected(ComponentName componentName) {
      myForegroundService = null;
    }
  };

  private void doBindService() {
    bindService(new Intent(CameraActivity.this, MyForegroundService.class), serviceConnection, Context.BIND_AUTO_CREATE);
    bound = true;
  }

  private void doUnbindService() {
    if (bound) {
      unbindService(serviceConnection);
      bound = false;
    }
  }

  @Override
  protected void onDestroy() {
    super.onDestroy();
    doUnbindService();
  }

  @RequiresApi(api = Build.VERSION_CODES.O)
  @Override
  protected void onCreate(final Bundle savedInstanceState) {
    LOGGER.d("onCreate " + this);
    super.onCreate(null);
    getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
    setContentView(R.layout.tfe_od_activity_camera);
//    Toolbar toolbar = findViewById(R.id.toolbar);
//    setSupportActionBar(toolbar);
//    getSupportActionBar().setDisplayShowTitleEnabled(false);
    getSupportActionBar().hide();

    // New lines of code for starting a service
    Intent serviceIntent = new Intent(this, MyForegroundService.class);
    startForegroundService(serviceIntent);

    // Check if permission granted to access camera
    if (hasPermission()) {
      setFragment();
    } else {
      requestPermission();
    }

    seekBar = findViewById(R.id.seekBar);
    detectorSwitch = findViewById(R.id.switchDetector);
    liveTextView = findViewById(R.id.liveTextView);
    liveTextView.setText("Live "); //set text for text view
    liveTextView.setVisibility(View.INVISIBLE);
    AnimationDrawable animationDrawable = (AnimationDrawable) getResources().getDrawable(R.drawable.blinking);
    liveTextView.setCompoundDrawablesWithIntrinsicBounds(null, null, animationDrawable, null);
    animationDrawable.start();
    seekBar.setOnSeekBarChangeListener(this);

    detectorSwitch.setOnCheckedChangeListener(this);

    threadsTextView = findViewById(R.id.threads);
    currentNumThreads = Integer.parseInt(threadsTextView.getText().toString().trim());
    plusImageView = findViewById(R.id.plus);
    minusImageView = findViewById(R.id.minus);
    deviceView = findViewById(R.id.device_list);
    deviceStrings.add("CPU");
    deviceStrings.add("GPU");
    deviceStrings.add("NNAPI");
    deviceView.setChoiceMode(ListView.CHOICE_MODE_SINGLE);
    ArrayAdapter<String> deviceAdapter =
            new ArrayAdapter<>(
                    CameraActivity.this , R.layout.deviceview_row, R.id.deviceview_row_text, deviceStrings);
    deviceView.setAdapter(deviceAdapter);
    deviceView.setItemChecked(defaultDeviceIndex, true);
    currentDevice = defaultDeviceIndex;
    deviceView.setOnItemClickListener(
            new AdapterView.OnItemClickListener() {
              @Override
              public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                updateActiveModel();
              }
            });

    bottomSheetLayout = findViewById(R.id.bottom_sheet_layout);
    gestureLayout = findViewById(R.id.gesture_layout);
    sheetBehavior = BottomSheetBehavior.from(bottomSheetLayout);
    bottomSheetArrowImageView = findViewById(R.id.bottom_sheet_arrow);
    modelView = findViewById((R.id.model_list));

    modelStrings = getModelStrings(getAssets(), ASSET_PATH);
    modelView.setChoiceMode(ListView.CHOICE_MODE_SINGLE);
    ArrayAdapter<String> modelAdapter =
            new ArrayAdapter<>(
                    CameraActivity.this , R.layout.listview_row, R.id.listview_row_text, modelStrings);
    modelView.setAdapter(modelAdapter);
    modelView.setItemChecked(defaultModelIndex, true);
    currentModel = defaultModelIndex;
    modelView.setOnItemClickListener(
            new AdapterView.OnItemClickListener() {
              @Override
              public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                updateActiveModel();
              }
            });

    ViewTreeObserver vto = gestureLayout.getViewTreeObserver();
    vto.addOnGlobalLayoutListener(
        new ViewTreeObserver.OnGlobalLayoutListener() {
          @Override
          public void onGlobalLayout() {
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.JELLY_BEAN) {
              gestureLayout.getViewTreeObserver().removeGlobalOnLayoutListener(this);
            } else {
              gestureLayout.getViewTreeObserver().removeOnGlobalLayoutListener(this);
            }
            //                int width = bottomSheetLayout.getMeasuredWidth();
            int height = gestureLayout.getMeasuredHeight();

            sheetBehavior.setPeekHeight(height);
          }
        });
    sheetBehavior.setHideable(false);

    sheetBehavior.setBottomSheetCallback(
        new BottomSheetBehavior.BottomSheetCallback() {
          @Override
          public void onStateChanged(@NonNull View bottomSheet, int newState) {
            switch (newState) {
              case BottomSheetBehavior.STATE_HIDDEN:
                break;
              case BottomSheetBehavior.STATE_EXPANDED:
                {
                  bottomSheetArrowImageView.setImageResource(R.drawable.icn_chevron_down);
                }
                break;
              case BottomSheetBehavior.STATE_COLLAPSED:
                {
                  bottomSheetArrowImageView.setImageResource(R.drawable.icn_chevron_up);
                }
                break;
              case BottomSheetBehavior.STATE_DRAGGING:
                break;
              case BottomSheetBehavior.STATE_SETTLING:
                bottomSheetArrowImageView.setImageResource(R.drawable.icn_chevron_up);
                break;
            }
          }

          @Override
          public void onSlide(@NonNull View bottomSheet, float slideOffset) {}
        });

    frameValueTextView = findViewById(R.id.frame_info);
    cropValueTextView = findViewById(R.id.crop_info);
    inferenceTimeTextView = findViewById(R.id.inference_info);
    confidenceThreshTextView = findViewById(R.id.confidence_info);

    plusImageView.setOnClickListener(this);
    minusImageView.setOnClickListener(this);

    // Redline Detection Cutoff

    setCutOff = true;
    cutOffY = screenToCrop(2960/2);

    redLineSwitch = findViewById(R.id.switchRedLine);
    mRrootLayout = (ViewGroup) findViewById(R.id.root2);
    mImageView = (ImageView) mRrootLayout.findViewById(R.id.iv_redline);
    mImageView.setOnTouchListener(this);
    redLineSwitch.setOnCheckedChangeListener(this);

    // Capture the width of the RelativeLayout once it is laid out.
    mRrootLayout.post(new Runnable() {
      @Override
      public void run() {
        windowwidth = mRrootLayout.getWidth();
        windowheight = mRrootLayout.getHeight();
      }
    });

    openGlView = findViewById(R.id.surfaceView);
    button = findViewById(R.id.b_start_stop);
    button_mirror = findViewById(R.id.b_start_stop_mirror);

    // Capture Detection Results
    button.setOnClickListener(this);
    button.setOnLongClickListener(this);

    rtspCamera1 = new RtspCamera1(openGlView, new ConnectCheckerRtsp() {
      @Override
      public void onConnectionStartedRtsp(@NonNull String s) {

      }

      @Override
      public void onConnectionSuccessRtsp() {
        runOnUiThread(new Runnable() {
          @Override
          public void run() {
            Toast.makeText(CameraActivity.this, "Connection successful", Toast.LENGTH_SHORT).show();
          }
        });
      }

      @Override
      public void onConnectionFailedRtsp(final String reason) {
        runOnUiThread(new Runnable() {
          @Override
          public void run() {
            if (rtspCamera1.reTry(5000, reason, null)) {
              Toast.makeText(CameraActivity.this, "Retry", Toast.LENGTH_SHORT).show();
            } else {
              Toast.makeText(CameraActivity.this, "Connection failed. " + reason, Toast.LENGTH_SHORT).show();
              rtspCamera1.stopStream();
              button.setText("Start Stream");
            }
          }
        });
      }

      @Override
      public void onNewBitrateRtsp(long l) {

      }

      @Override
      public void onDisconnectRtsp() {
        runOnUiThread(new Runnable() {
          @Override
          public void run() {
            Toast.makeText(CameraActivity.this, "Disconnected", Toast.LENGTH_SHORT).show();
          }
        });
      }

      @Override
      public void onAuthErrorRtsp() {
        runOnUiThread(new Runnable() {
          @Override
          public void run() {
            Toast.makeText(CameraActivity.this, "Auth error", Toast.LENGTH_SHORT).show();
            rtspCamera1.stopStream();
            button.setText("Start Stream");
          }
        });
      }

      @Override
      public void onAuthSuccessRtsp() {
        runOnUiThread(new Runnable() {
          @Override
          public void run() {
            Toast.makeText(CameraActivity.this, "Auth success", Toast.LENGTH_SHORT).show();
          }
        });
      }
    });

    rtspCamera1.setReTries(5);

    openGlView.getHolder().addCallback(new SurfaceHolder.Callback() {
      @Override
      public void surfaceCreated(SurfaceHolder surfaceHolder) {

      }

      @Override
      public void surfaceChanged(SurfaceHolder surfaceHolder, int i, int i1, int i2) {
        rtspCamera1.startPreview();
      }

      @Override
      public void surfaceDestroyed(SurfaceHolder surfaceHolder) {
        if (rtspCamera1.isStreaming()) {
          rtspCamera1.stopStream();
          button.setText("Start Stream");
        }
        rtspCamera1.stopPreview();
      }
    });

    button_mirror.setOnClickListener(this);

    ConnectCheckerRtsp connectCheckerRtsp = new ConnectCheckerRtsp() {
      @Override
      public void onConnectionStartedRtsp(@NonNull String s) {

      }

      @Override
      public void onConnectionSuccessRtsp() {
        runOnUiThread(new Runnable() {
          @Override
          public void run() {
            Toast.makeText(CameraActivity.this, "Connection success", Toast.LENGTH_SHORT).show();
          }
        });
      }

      @Override
      public void onConnectionFailedRtsp(final String reason) {
        runOnUiThread(new Runnable() {
          @Override
          public void run() {
            Toast.makeText(CameraActivity.this, "Connection failed. " + reason, Toast.LENGTH_SHORT)
                    .show();
            DisplayService displayService = DisplayService.Companion.getINSTANCE();
            if (displayService != null) {
              displayService.stopStream();
            }
            button.setText("Start Mirror");
          }
        });
      }

      @Override
      public void onNewBitrateRtsp(long l) {

      }

      @Override
      public void onDisconnectRtsp() {
        runOnUiThread(new Runnable() {
          @Override
          public void run() {
            Toast.makeText(CameraActivity.this, "Disconnected", Toast.LENGTH_SHORT).show();
          }
        });
      }

      @Override
      public void onAuthErrorRtsp() {
        runOnUiThread(new Runnable() {
          @Override
          public void run() {
            Toast.makeText(CameraActivity.this, "Auth error", Toast.LENGTH_SHORT).show();
          }
        });
      }

      @Override
      public void onAuthSuccessRtsp() {
        runOnUiThread(new Runnable() {
          @Override
          public void run() {
            Toast.makeText(CameraActivity.this, "Auth success", Toast.LENGTH_SHORT).show();
          }
        });
      }
    };

    // Accelerometer
    SensorManager sensorManager = (SensorManager) getSystemService(Context.SENSOR_SERVICE);
    List<Sensor> accelerometer = sensorManager.getSensorList(Sensor.TYPE_ACCELEROMETER);

    SensorEventListener eventListener = new SensorEventListener() {
      @Override
      public void onSensorChanged(SensorEvent sensorEvent) {
        float[] values = sensorEvent.values;
        float x = values[0];
        float y = values[1];
        float z = values[2];
        zAccel = z;
        double ang = Math.toDegrees(Math.atan(Math.abs(y/z)));
        phoneTiltAngle = 90 - ang;
//        if (z < 0) {
//          if (currentAzimuth >= 180)
//            currentAzimuth -= 180;
//          else
//            currentAzimuth += 180;
//        }
      }

      @Override
      public void onAccuracyChanged(Sensor sensor, int i) {

      }
    };
    sensorManager.registerListener(eventListener, accelerometer.get(0), SensorManager.SENSOR_DELAY_NORMAL);
    setupCompass();

    // Calibrate Device
    drawView = findViewById(R.id.draw_view);
    rectDim = new int[2];
    calibrate_button = findViewById(R.id.b_calibrate);
    calibrationSwitch = findViewById(R.id.switchCalibration);
    calibrate_button.setOnClickListener(this);
    calibrationSwitch.setOnCheckedChangeListener(this);

    // W-I-P Service
    doBindService();
  }

  @Override
  protected void onPause() {
    super.onPause();
    compass.stop();
  }

  @Override
  protected void onStop() {
    super.onStop();
    compass.stop();
  }

  private void setupCompass() {
    compass = new Compass(this);
    Compass.CompassListener compassListener = getCompassListner();
    compass.setListener(compassListener);
  }

  private Compass.CompassListener getCompassListner() {
    return new Compass.CompassListener() {
      @Override
      public void onNewAzimuth(float azimuth) {
        runOnUiThread(new Runnable() {
          @Override
          public void run() {
            currentAzimuth = azimuth;
            if (zAccel < 0) {
              if (currentAzimuth >= 180)
                currentAzimuth -= 180;
              else
                currentAzimuth += 180;
            }
          }
        });
      }
    };
  }

  public void createCalibrationDialog(){
    dialogBuilder = new AlertDialog.Builder(this);
    final View calibrationPopupView = getLayoutInflater().inflate(R.layout.popup, null);

    et_drone_distance = (EditText) calibrationPopupView.findViewById(R.id.et_drone_distance);
    et_box_width = (EditText) calibrationPopupView.findViewById(R.id.et_box_width);
    et_box_height = (EditText) calibrationPopupView.findViewById(R.id.et_box_height);
    et_box_width.setText(String.valueOf(boxWidth));
    et_box_height.setText(String.valueOf(boxHeight));

    save_calibration_button = (Button) calibrationPopupView.findViewById(R.id.save_calibration_button);
    cancel_calibration_button = (Button) calibrationPopupView.findViewById(R.id.cancel_calibration_button);

    dialogBuilder.setView(calibrationPopupView);
    dialog = dialogBuilder.create();
    dialog.show();

    save_calibration_button.setOnClickListener(new View.OnClickListener() {
      @Override
      public void onClick(View view) {
        // Save the calibration
        drone_distance_calibration = Double.parseDouble(et_drone_distance.getText().toString());
        boxWidth_calibration = Integer.parseInt(et_box_width.getText().toString());
        boxHeight_calibration = Integer.parseInt(et_box_height.getText().toString());

        Toast.makeText(CameraActivity.this, "Distance: " + drone_distance_calibration + "\nWidth: " + boxWidth_calibration + "\nHeight: " + boxHeight_calibration, Toast.LENGTH_SHORT).show();

        // Dismiss the popup dialog after saving the calibraion
        dialog.dismiss();
      }
    });

    cancel_calibration_button.setOnClickListener(new View.OnClickListener() {
      @Override
      public void onClick(View view) {
        // Dismiss the popup dialog
        dialog.dismiss();
      }
    });
  }

  @Override
  protected void onActivityResult(int requestCode, int resultCode, Intent data) {
    super.onActivityResult(requestCode, resultCode, data);
    if (data != null && (requestCode == REQUEST_CODE_STREAM
            || requestCode == REQUEST_CODE_RECORD && resultCode == Activity.RESULT_OK)) {
      DisplayService displayService = DisplayService.Companion.getINSTANCE();
      if (displayService != null) {
        String endpoint =  rtspLink;
        displayService.prepareStreamRtp(endpoint, resultCode, data);
        displayService.startStreamRtp(endpoint);
      }
    } else {
      Toast.makeText(this, "No permissions available", Toast.LENGTH_SHORT).show();
      button.setText("Start Mirror");
    }
  }

  private boolean isOutReported = false;

  private String isOut(View view, int upperBound, int lowerBound) {
    // Check to see if the view is out of bounds by calculating how many pixels
    // of the view must be out of bounds to and checking that at least that many
    // pixels are out.
    float percentageOut = 0.000001f;
    int viewPctWidth = (int) (view.getWidth() * percentageOut);
    int viewPctHeight = (int) (view.getHeight() * percentageOut);

    if (-view.getTop() >= viewPctHeight - upperBound)
      return "top";
    else if ((view.getBottom() - windowheight) > viewPctHeight - lowerBound)
      return "btm";
    else if (-view.getLeft() >= viewPctWidth)
      return "left";
    else if ((view.getRight() - windowwidth) > viewPctWidth)
      return "right";
    else
      return "in";
  }

  /**
   * Call this function to find the cutoff y point to reject detections
   * @param yPos
   * @return
   */

  private int screenToCrop(int yPos) {
    LOGGER.d("Image Size in ScreenToCrop: " + imageSize);
    return yPos / (screenHeight / imageSize);
  }


  public static void setImageSize(int inputSize){
    imageSize = inputSize;
  }

  /**
   * WIP foreground service to allow app to continue running even when:
   *  - screen is off / device is locked / switched to flutter map view
   * @return
   */
//  public boolean foregroundServiceRunning() {
//    ActivityManager activityManager = (ActivityManager) getSystemService(Context.ACTIVITY_SERVICE);
//
//    for (ActivityManager.RunningServiceInfo service : activityManager.getRunningServices(Integer.MAX_VALUE)) {
//      if (MyForegroundService.class.getName().equals(service.service.getClassName())){
//        return true;
//      }
//    }
//    return false;
//  }

  protected ArrayList<String> getModelStrings(AssetManager mgr, String path){
    ArrayList<String> res = new ArrayList<String>();
    try {
      String[] files = mgr.list(path);
      for (String file : files) {
        String[] splits = file.split("\\.");
        if (splits[splits.length - 1].equals("tflite")) {
          res.add(file);
        }
      }

    }
    catch (IOException e){
      System.err.println("getModelStrings: " + e.getMessage());
    }
    return res;
  }

  protected int[] getRgbBytes() {
    imageConverter.run();
    return rgbBytes;
  }

  protected int getLuminanceStride() {
    return yRowStride;
  }

  protected byte[] getLuminance() {
    return yuvBytes[0];
  }


  /** Callback for android.hardware.Camera API */
  @Override
  public void onPreviewFrame(final byte[] bytes, final Camera camera) {

    if (isProcessingFrame) {
      LOGGER.w("Dropping frame!");
      return;
    }
    try {
      // Initialize the storage bitmaps once when the resolution is known.
      if (rgbBytes == null) {
        Camera.Size previewSize = camera.getParameters().getPreviewSize();
        previewHeight = previewSize.height;
        previewWidth = previewSize.width;
        rgbBytes = new int[previewWidth * previewHeight];
        onPreviewSizeChosen(new Size(previewSize.width, previewSize.height), 0); // Rotation should be 0
      }
    } catch (final Exception e) {
      LOGGER.e(e, "Exception!");
      return;
    }

    isProcessingFrame = true;
    yuvBytes[0] = bytes;
    yRowStride = previewWidth;

    imageConverter =
            new Runnable() {
              @Override
              public void run() {
                ImageUtils.convertYUV420SPToARGB8888(bytes, previewWidth, previewHeight, rgbBytes);
              }
            };

    postInferenceCallback =
            new Runnable() {
              @Override
              public void run() {
                camera.addCallbackBuffer(bytes);
                isProcessingFrame = false;
              }
            };
    processImage();
  }

  /** Callback for Camera2 API */
  @Override
  public void onImageAvailable(final ImageReader reader) {
    // We need wait until we have some size from onPreviewSizeChosen
    if (previewWidth == 0 || previewHeight == 0) {
      return;
    }
    if (rgbBytes == null) {
      rgbBytes = new int[previewWidth * previewHeight];
    }
    try {
      final Image image = reader.acquireLatestImage();

      if (image == null) {
        return;
      }

      if (isProcessingFrame || startDetector == false) { // on & off switch for detector
        image.close();
        return;
      }
      isProcessingFrame = true;
      Trace.beginSection("imageAvailable");
      final Plane[] planes = image.getPlanes();
      fillBytes(planes, yuvBytes);
      yRowStride = planes[0].getRowStride();
      final int uvRowStride = planes[1].getRowStride();
      final int uvPixelStride = planes[1].getPixelStride();

      imageConverter =
          new Runnable() {
            @Override
            public void run() {
              ImageUtils.convertYUV420ToARGB8888(
                  yuvBytes[0],
                  yuvBytes[1],
                  yuvBytes[2],
                  previewWidth,
                  previewHeight,
                  yRowStride,
                  uvRowStride,
                  uvPixelStride,
                  rgbBytes);
            }
          };

      postInferenceCallback =
          new Runnable() {
            @Override
            public void run() {
              image.close();
              isProcessingFrame = false;
            }
          };

      processImage();
    } catch (final Exception e) {
      LOGGER.e(e, "Exception!");
      Trace.endSection();
      return;
    }
    Trace.endSection();
  }

  @Override
  public synchronized void onStart() {

    LOGGER.d("onStart " + this);
    super.onStart();
    compass.start();
  }

  @Override
  public synchronized void onResume() {
    LOGGER.d("onResume " + this);
    super.onResume();
    compass.start();

    handlerThread = new HandlerThread("inference");
    handlerThread.start();
    handler = new Handler(handlerThread.getLooper());
  }

//  @Override
//  public synchronized void onPause() {
//    LOGGER.d("onPause " + this);
//
//    handlerThread.quitSafely();
//    try {
//      handlerThread.join();
//      handlerThread = null;
//      handler = null;
//    } catch (final InterruptedException e) {
//      LOGGER.e(e, "Exception!");
//    }
//
//    super.onPause();
//  }
//
//  @Override
//  public synchronized void onStop() {
//    LOGGER.d("onStop " + this);
//    super.onStop();
//  }
//
//  @Override
//  public synchronized void onDestroy() {
//    LOGGER.d("onDestroy " + this);
//    super.onDestroy();
//    DisplayService displayService = DisplayService.Companion.getINSTANCE();
//    if (displayService != null && !displayService.isStreaming() && !displayService.isRecording()) {
//      //stop service only if no streaming or recording
//      stopService(new Intent(this, DisplayService.class));
//    }
//  }

  protected synchronized void runInBackground(final Runnable r) {
    if (handler != null) {
      handler.post(r);
    }
  }

  @Override
  public void onRequestPermissionsResult(
      final int requestCode, final String[] permissions, final int[] grantResults) {
    super.onRequestPermissionsResult(requestCode, permissions, grantResults);
    if (requestCode == PERMISSIONS_REQUEST) {
      if (allPermissionsGranted(grantResults)) {
        setFragment();
      } else {
        requestPermission();
      }
    }
  }

  private static boolean allPermissionsGranted(final int[] grantResults) {
    for (int result : grantResults) {
      if (result != PackageManager.PERMISSION_GRANTED) {
        return false;
      }
    }
    return true;
  }

  private boolean hasPermission() {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
      return checkSelfPermission(PERMISSION_CAMERA) == PackageManager.PERMISSION_GRANTED;
    } else {
      return true;
    }
  }

  private void requestPermission() {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
      if (shouldShowRequestPermissionRationale(PERMISSION_CAMERA)) {
        Toast.makeText(
                CameraActivity.this,
                "Camera permission is required for this demo",
                Toast.LENGTH_LONG)
            .show();
      }
      requestPermissions(new String[] {PERMISSION_CAMERA}, PERMISSIONS_REQUEST);
    }
  }

  // Returns true if the device supports the required hardware level, or better.
  private boolean isHardwareLevelSupported(
      CameraCharacteristics characteristics, int requiredLevel) {
    int deviceLevel = characteristics.get(CameraCharacteristics.INFO_SUPPORTED_HARDWARE_LEVEL);
    if (deviceLevel == CameraCharacteristics.INFO_SUPPORTED_HARDWARE_LEVEL_LEGACY) {
      return requiredLevel == deviceLevel;
    }
    // deviceLevel is not LEGACY, can use numerical sort
    return requiredLevel <= deviceLevel;
  }

  private String chooseCamera() {
    final CameraManager manager = (CameraManager) getSystemService(Context.CAMERA_SERVICE);
    try {
      for (final String cameraId : manager.getCameraIdList()) {
        final CameraCharacteristics characteristics = manager.getCameraCharacteristics(cameraId);

        // We don't use a front facing camera in this sample.
        final Integer facing = characteristics.get(CameraCharacteristics.LENS_FACING);
        if (facing != null && facing == CameraCharacteristics.LENS_FACING_FRONT) {
          continue;
        }

        final StreamConfigurationMap map =
            characteristics.get(CameraCharacteristics.SCALER_STREAM_CONFIGURATION_MAP);

        if (map == null) {
          continue;
        }

        // Fallback to camera1 API for internal cameras that don't have full support.
        // This should help with legacy situations where using the camera2 API causes
        // distorted or otherwise broken previews.
        useCamera2API =
            (facing == CameraCharacteristics.LENS_FACING_EXTERNAL) || (facing == CameraCharacteristics.LENS_FACING_BACK) // Added Back Facing Camera to enable Camera2API
                || isHardwareLevelSupported(
                    characteristics, CameraCharacteristics.INFO_SUPPORTED_HARDWARE_LEVEL_FULL);
        LOGGER.i("Camera API lv2?: %s", useCamera2API);
        return cameraId;
      }
    } catch (CameraAccessException e) {
      LOGGER.e(e, "Not allowed to access camera");
    }

    return null;
  }

  protected void setFragment() {
    String cameraId = chooseCamera();

    Fragment fragment;
    if (useCamera2API) {
      CameraConnectionFragment camera2Fragment =
          CameraConnectionFragment.newInstance(
              new CameraConnectionFragment.ConnectionCallback() {
                @Override
                public void onPreviewSizeChosen(final Size size, final int rotation) {
                  previewHeight = size.getHeight();
                  previewWidth = size.getWidth();
                  CameraActivity.this.onPreviewSizeChosen(size, rotation);
                }
              },
              this,
              getLayoutId(),
              getDesiredPreviewFrameSize());

      camera2Fragment.setCamera(cameraId);
      fragment = camera2Fragment;
    } else {
      fragment =
          new LegacyCameraConnectionFragment(this, getLayoutId(), getDesiredPreviewFrameSize());
    }
    getFragmentManager().beginTransaction().replace(R.id.container, fragment).commit();
  }

  protected void fillBytes(final Plane[] planes, final byte[][] yuvBytes) {
    // Because of the variable row stride it's not possible to know in
    // advance the actual necessary dimensions of the yuv planes.
    for (int i = 0; i < planes.length; ++i) {
      final ByteBuffer buffer = planes[i].getBuffer();
      if (yuvBytes[i] == null) {
        LOGGER.d("Initializing buffer %d at size %d", i, buffer.capacity());
        yuvBytes[i] = new byte[buffer.capacity()];
      }
      buffer.get(yuvBytes[i]);
    }
  }

  public boolean isDebug() {
    return debug;
  }

  protected void readyForNextImage() {
    if (postInferenceCallback != null) {
      postInferenceCallback.run();
    }
  }

  protected int getScreenOrientation() {
    switch (getWindowManager().getDefaultDisplay().getRotation()) {
      case Surface.ROTATION_270:
        return 270;
      case Surface.ROTATION_180:
        return 180;
      case Surface.ROTATION_90:
        return 90;
      default:
        return 0;
    }
  }

//  @Override
//  public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
//    setUseNNAPI(isChecked);
//    if (isChecked) apiSwitchCompat.setText("NNAPI");
//    else apiSwitchCompat.setText("TFLITE");
//  }

  @Override
  public void onClick(View v) {
    String threads;
    int numThreads;
    switch(v.getId()) {
      case R.id.plus: // Increase the number of running threads
        threads = threadsTextView.getText().toString().trim();
        numThreads = Integer.parseInt(threads);
        if (numThreads >= 9) return;
        numThreads++;
        threadsTextView.setText(String.valueOf(numThreads));
        setNumThreads(numThreads);
        break;
      case R.id.minus: // Decrease the number of running threads
        threads = threadsTextView.getText().toString().trim();
        numThreads = Integer.parseInt(threads);
        if (numThreads == 1) {
          return;
        }
        numThreads--;
        threadsTextView.setText(String.valueOf(numThreads));
        setNumThreads(numThreads);
        break;
      case R.id.b_start_stop: // Start & Stop Capturing of Detection Results
        if (!captureWorldOffsets) {
          captureWorldOffsets = true;
          initDataSize = worldOffsetResults.size();
          button.setText("Stop Record");
        } else {
          captureWorldOffsets = false;
          if (initDataSize == worldOffsetResults.size()) {
            Toast.makeText(CameraActivity.this, "No new locations", Toast.LENGTH_SHORT).show();
          } else if (initDataSize < worldOffsetResults.size()) {
            Toast.makeText(CameraActivity.this, "Results updated", Toast.LENGTH_SHORT).show();
          }
          button.setText("Record Data");
        }
        break;
      case R.id.b_start_stop_mirror: // RTSP Stream for Screen Mirror
        DisplayService displayService = DisplayService.Companion.getINSTANCE();
        if (displayService != null) {
          if (!displayService.isStreaming()) {
            button_mirror.setText("Stop Mirror");
            startActivityForResult(displayService.sendIntent(), REQUEST_CODE_STREAM);
          } else {
            button_mirror.setText("Start Mirror");
            displayService.stopStream();
          }
        }
        break;
      case R.id.b_calibrate: // Create a popup dialog window to save calibration data
        if (isCalibrating) {
          int[] boxDim = CameraConnectionFragment.calibrate();
          CameraConnectionFragment.setDrawViewVisibility(isCalibrating);
          boxWidth = boxDim[0];
          boxHeight = boxDim[1];
          LOGGER.d("Box Width: " + boxWidth +
                  "\nBox Height: " + boxHeight);
          Toast.makeText(CameraActivity.this, "Width: " + boxWidth + " Height: " + boxHeight, Toast.LENGTH_SHORT).show();
          createCalibrationDialog();
          boxWidth_calibration = boxWidth;
          boxHeight_calibration = boxHeight;
        } else {
          Toast.makeText(CameraActivity.this, "Turn on calibration mode first!", Toast.LENGTH_SHORT).show();
        }
        break;
      default:
        break;
    }
  }

  @Override
  public boolean onLongClick(View view){
    switch (view.getId()) {
      case R.id.b_start_stop: // Cleared all the saved detection instances
        worldOffsetResults.clear();
        Toast.makeText(CameraActivity.this, "Results cleared", Toast.LENGTH_SHORT).show();
        return true;
      default:
        return true;
    }
  }

  @Override
  public boolean onTouch(View view, MotionEvent event){
    switch (view.getId()) {
      case R.id.iv_redline:
        final int X = (int) event.getRawX();
        final int Y = (int) event.getRawY();
        // For debugging purposes to check if the imageView has crossed the boundaries
//        switch(isOut(view)) {
//          case "left" :
//            isOutReported = true;
//            Toast.makeText(CameraActivity.this, "LEFT", Toast.LENGTH_SHORT).show();
//            break;
//          case "right" :
//            isOutReported = true;
//            Toast.makeText(CameraActivity.this, "RIGHT", Toast.LENGTH_SHORT).show();
//            break;
//          case "top" :
//            isOutReported = true;
//            Toast.makeText(CameraActivity.this, "TOP", Toast.LENGTH_SHORT).show();
//            break;
//          case "btm" :
//            isOutReported = true;
//            Toast.makeText(CameraActivity.this, "BOTTOM", Toast.LENGTH_SHORT).show();
//            break;
//          default:
//            isOutReported = false;
//            break;
//        }
        RelativeLayout.LayoutParams lp = (RelativeLayout.LayoutParams) view
                .getLayoutParams();
        if (!setCutOff)
          return true;
        switch (event.getAction() & MotionEvent.ACTION_MASK) {
          case MotionEvent.ACTION_DOWN:
            // _xDelta and _yDelta record how far inside the view we have touched. These
            // values are used to compute new margins when the view is moved.
            _yDelta = Y - view.getTop();
            mImageView.setAlpha(127);
            break;
          case MotionEvent.ACTION_UP:
            int upperBound = 50;
            int lowerBound = 150;
            if (isOut(view, upperBound, 0) == "top") {
              lp.topMargin = upperBound;
              LOGGER.d("top call => topMargin: " + (lp.topMargin));
              lp.bottomMargin = view.getHeight() - lp.topMargin - windowheight;
            } else if (isOut(view, 0, lowerBound) == "btm") {
              lp.topMargin = windowheight - view.getHeight() - lowerBound;
              LOGGER.d("btm call => topMargin: " + (lp.topMargin));
              lp.bottomMargin = view.getHeight() - lp.topMargin - windowheight;
            }

            view.setLayoutParams(lp);
            mImageView.setAlpha(255);
//            LOGGER.d("cutOffY: " + cutOffY);
//            cutOffY = screenToCrop(Y);
            break;
          case MotionEvent.ACTION_MOVE:
            LOGGER.d("Y: " + Y + "  cropY: " + screenToCrop(Y) + "  screenWidth: " + screenWidth + "  view.getTop(): " + view.getTop() + " _yDelta : " + _yDelta + "  event.getRawY(): " + event.getRawY() + "  topMargin: " + (Y - _yDelta));

            // Image is centered to start, but we need to unhitch it to move it around.
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
              lp.removeRule(RelativeLayout.CENTER_HORIZONTAL);
              lp.removeRule(RelativeLayout.CENTER_VERTICAL);
            } else {
              lp.addRule(RelativeLayout.CENTER_HORIZONTAL, 0);
              lp.addRule(RelativeLayout.CENTER_VERTICAL, 0);
            }
            if (true){
              lp.topMargin = Y - _yDelta;
              // Negative margins here ensure that we can move off the screen to the right and on the bottom.
              // Comment these lines out and you will see that the image will be hemmed in on the right and bottom and will actually shrink.
              lp.bottomMargin = view.getHeight() - lp.topMargin - windowheight;

            }
            view.setLayoutParams(lp);
            LOGGER.d("cutOffY: " + cutOffY);
            cutOffY = screenToCrop(Y);
            break;
        }
        return true;
      default:
        return true;

    }
  }

  @Override
  public void onCheckedChanged(CompoundButton compoundButton, boolean b) {
    switch(compoundButton.getId()) {
      case R.id.switchDetector: // Detection On/Off Switch
        startDetector = b;
        if (startDetector) {
          liveTextView.setVisibility(View.VISIBLE);
          detectorSwitch.setText("Detector : On");
          LOGGER.i("startDetector is True");
        } else {
          liveTextView.setVisibility(View.INVISIBLE);
          detectorSwitch.setText("Detector : Off");
          LOGGER.i("startDetector is False");
        }
        break;
      case R.id.switchRedLine: // Redline Switch
        setCutOff = b;
        if (setCutOff) {
          cutOffY = lastCutOffY;
          mImageView.setAlpha(255);
          redLineSwitch.setText("Cutoff Area : On");
          LOGGER.i("Red line is on screen");
        } else {
          lastCutOffY = cutOffY;
          cutOffY = 2000;
          mImageView.setAlpha(0);
          redLineSwitch.setText("Cutoff Area : Off");
          LOGGER.i("Red line is removed");
        }
      case R.id.switchCalibration: // Calibration Mode Switch
        isCalibrating = b;
        if (isCalibrating) {
          CameraConnectionFragment.setDrawViewVisibility(isCalibrating);
          calibrationSwitch.setText("Calibration Mode : On");
        } else {
          CameraConnectionFragment.setDrawViewVisibility(isCalibrating);
          calibrationSwitch.setText("Calibration Mode : Off");
        }
        break;
      default:
        break;
    }
  }

  // Confidence Threshold Settings
  @Override
  public void onProgressChanged(SeekBar seekBar, int i, boolean b) {
    confidenceThreshTextView.setText(""+i+"%");
    float j = i;
    confThresh = j/100;
  }

  @Override
  public void onStartTrackingTouch(SeekBar seekBar) {
  }

  @Override
  public void onStopTrackingTouch(SeekBar seekBar) {
  }

  protected void showFrameInfo(String frameInfo) {
    frameValueTextView.setText(frameInfo);
  }

  protected void showCropInfo(String cropInfo) {
    cropValueTextView.setText(cropInfo);
  }

  protected void showInference(String inferenceTime) {
    inferenceTimeTextView.setText(inferenceTime);
  }

  protected abstract void updateActiveModel();

  protected abstract void processImage();

  protected abstract void onPreviewSizeChosen(final Size size, final int rotation);

  protected abstract int getLayoutId();

  protected abstract Size getDesiredPreviewFrameSize();

  protected abstract void setNumThreads(int numThreads);

  protected abstract void setUseNNAPI(boolean isChecked);

  @Override
  public void onBackPressed(){
    finish();
    overridePendingTransition(R.anim.enter_from_left, R.anim.exit_out_right);
  }
}
