package org.tensorflow.lite.examples.detection.trial;

import androidx.appcompat.app.AppCompatActivity;

import android.annotation.SuppressLint;
import android.os.Build;
import android.os.Bundle;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.Toast;

import org.tensorflow.lite.examples.detection.R;
import org.tensorflow.lite.examples.detection.env.Logger;

public class DragAndDropActivity extends AppCompatActivity {


    private static final org.tensorflow.lite.examples.detection.env.Logger LOGGER = new Logger();
//    ImageView imageView;
//
//    DisplayMetrics displayMetrics = Resources.getSystem().getDisplayMetrics();
//    int screenHeight = displayMetrics.heightPixels;
//    int screenWidth = displayMetrics.widthPixels;
//    int width, height;
//    private float dy;

    int windowwidth; // Actually the width of the RelativeLayout.
    int windowheight; // Actually the height of the RelativeLayout.
    private ImageView mImageView;
    private ViewGroup mRrootLayout;
    private int _xDelta;
    private int _yDelta;
    private int lastTop, lastBtm, lastLeft, lastRight;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_drag_and_drop);

//        imageView = findViewById(R.id.iv_test);
//
//        imageView.measure(View.MeasureSpec.UNSPECIFIED, View.MeasureSpec.UNSPECIFIED);
//        width = imageView.getMeasuredWidth();
//        height = imageView.getMeasuredHeight();

        mRrootLayout = (ViewGroup) findViewById(R.id.root);
        mImageView = (ImageView) mRrootLayout.findViewById(R.id.iv_test);

        mImageView.setOnTouchListener(new View.OnTouchListener() {
            @SuppressLint("ClickableViewAccessibility")
            @Override
            public boolean onTouch(View view, MotionEvent event) {
                final int X = (int) event.getRawX();
                final int Y = (int) event.getRawY();

                // Check if the image view is out of the parent view and report it if it is.
                // Only report once the image goes out and don't stack toasts.
//                if (isOut(view)) {
//                    if (!isOutReported) {
//                        isOutReported = true;
//                        Toast.makeText(DragAndDropActivity.this, "OUT", Toast.LENGTH_SHORT).show();
//                    }
//
//                } else {
//                    isOutReported = false;
//                }
                switch(isOut(view)) {
                    case "left" :
                        isOutReported = true;
                        Toast.makeText(DragAndDropActivity.this, "LEFT", Toast.LENGTH_SHORT).show();
                        break;
                    case "right" :
                        isOutReported = true;
                        Toast.makeText(DragAndDropActivity.this, "RIGHT", Toast.LENGTH_SHORT).show();
                        break;
                    case "top" :
                        isOutReported = true;
                        Toast.makeText(DragAndDropActivity.this, "TOP", Toast.LENGTH_SHORT).show();
                        break;
                    case "btm" :
                        isOutReported = true;
                        Toast.makeText(DragAndDropActivity.this, "BOTTOM", Toast.LENGTH_SHORT).show();
                        break;
                    default:
                        isOutReported = false;
                        break;
                }

                RelativeLayout.LayoutParams lp = (RelativeLayout.LayoutParams) view
                        .getLayoutParams();
                switch (event.getAction() & MotionEvent.ACTION_MASK) {
                    case MotionEvent.ACTION_DOWN:
                        // _xDelta and _yDelta record how far inside the view we have touched. These
                        // values are used to compute new margins when the view is moved.
//                        _xDelta = X - view.getLeft();
                        _yDelta = Y - view.getTop();
                        break;
                    case MotionEvent.ACTION_UP:
                        if (isOut(view) == "top") {
//                            lp.leftMargin = X - _xDelta;
                            lp.topMargin = 0;
                            LOGGER.d("top call => topMargin: " + (lp.topMargin));
//                            lp.rightMargin = view.getWidth() - lp.leftMargin - windowwidth;
                            lp.bottomMargin = view.getHeight() - lp.topMargin - windowheight;
                        } else if (isOut(view) == "btm") {
                            lp.topMargin = windowheight - view.getHeight() - 200;
                            LOGGER.d("btm call => topMargin: " + (lp.topMargin));
                            lp.bottomMargin = view.getHeight() - lp.topMargin - windowheight;
                        }
                        view.setLayoutParams(lp);
                        break;
                    case MotionEvent.ACTION_MOVE:

//                        LOGGER.d("Y: " + Y + "  view.getTop(): " + view.getTop() + " _yDelta : " + _yDelta + "  event.getRawY(): " + event.getRawY() + "  topMargin: " + (Y - _yDelta));
                        // Image is centered to start, but we need to unhitch it to move it around.
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
                            lp.removeRule(RelativeLayout.CENTER_HORIZONTAL);
                            lp.removeRule(RelativeLayout.CENTER_VERTICAL);
                        } else {
                            lp.addRule(RelativeLayout.CENTER_HORIZONTAL, 0);
                            lp.addRule(RelativeLayout.CENTER_VERTICAL, 0);
                        }

//                        if (isOutReported) {
////                            lp.leftMargin = lastLeft;
////                            lp.topMargin = lastTop;
////                            lp.rightMargin = lastRight;
////                            lp.bottomMargin = lastBtm;
////                            view.setLayoutParams(lp);
////                            isOutReported = false;
////                            break;
////                        }
//                        if (isOut(view) == "top") {
////                            lp.leftMargin = X - _xDelta;
//                            lp.topMargin = 100 - view.getHeight() / 2;
////                            lp.rightMargin = view.getWidth() - lp.leftMargin - windowwidth;
//                            lp.bottomMargin = view.getHeight() - lp.topMargin - windowheight;
//                        } else if (isOut(view) == "btm") {
//                            lp.topMargin = view.getHeight() / 2;
//                            lp.bottomMargin = view.getHeight() - lp.topMargin - windowheight;
//                        }
                        if (true) {
//                            lp.leftMargin = X - _xDelta; // X -
                            lp.topMargin = Y - _yDelta;
                            // Negative margins here ensure that we can move off the screen to the right
                            // and on the bottom. Comment these lines out and you will see that
                            // the image will be hemmed in on the right and bottom and will actually shrink.
//                            lp.rightMargin = view.getWidth() - lp.leftMargin - windowwidth;
                            lp.bottomMargin = view.getHeight() - lp.topMargin - windowheight;
                            LOGGER.d("windowheight(): " + (windowheight) + "  topMargin: " + (lp.topMargin) + "  btmMargin: " + lp.bottomMargin);
//                        lastLeft = lp.leftMargin;
//                        lastTop = lp.topMargin;
//                        lastRight = lp.rightMargin;
//                        lastBtm = lp.bottomMargin;
                        }
                        view.setLayoutParams(lp);
                        break;
                }
                // invalidate is redundant if layout params are set or not needed if they are not set.
//        mRrootLayout.invalidate();
                return true;
            }
        });

        // Capture the width of the RelativeLayout once it is laid out.
        mRrootLayout.post(new Runnable() {
            @Override
            public void run() {
                windowwidth = mRrootLayout.getWidth();
                windowheight = mRrootLayout.getHeight();
            }
        });



    }

    private boolean isOutReported = false;

//    public boolean onTouch(View view, MotionEvent event) {
//        final int X = (int) event.getRawX();
//        final int Y = (int) event.getRawY();
//
//        // Check if the image view is out of the parent view and report it if it is.
//        // Only report once the image goes out and don't stack toasts.
//        if (isOut(view)) {
//            if (!isOutReported) {
//                isOutReported = true;
//                Toast.makeText(this, "OUT", Toast.LENGTH_SHORT).show();
//            }
//        } else {
//            isOutReported = false;
//        }
//        switch (event.getAction() & MotionEvent.ACTION_MASK) {
//            case MotionEvent.ACTION_DOWN:
//                // _xDelta and _yDelta record how far inside the view we have touched. These
//                // values are used to compute new margins when the view is moved.
//                _xDelta = X - view.getLeft();
//                _yDelta = Y - view.getTop();
//                break;
//            case MotionEvent.ACTION_UP:
//            case MotionEvent.ACTION_POINTER_DOWN:
//            case MotionEvent.ACTION_POINTER_UP:
//                // Do nothing
//                break;
//            case MotionEvent.ACTION_MOVE:
//                RelativeLayout.LayoutParams lp = (RelativeLayout.LayoutParams) view
//                        .getLayoutParams();
//                // Image is centered to start, but we need to unhitch it to move it around.
//                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
//                    lp.removeRule(RelativeLayout.CENTER_HORIZONTAL);
//                    lp.removeRule(RelativeLayout.CENTER_VERTICAL);
//                } else {
//                    lp.addRule(RelativeLayout.CENTER_HORIZONTAL, 0);
//                    lp.addRule(RelativeLayout.CENTER_VERTICAL, 0);
//                }
//                lp.leftMargin = X - _xDelta;
//                lp.topMargin = Y - _yDelta;
//                // Negative margins here ensure that we can move off the screen to the right
//                // and on the bottom. Comment these lines out and you will see that
//                // the image will be hemmed in on the right and bottom and will actually shrink.
//                lp.rightMargin = view.getWidth() - lp.leftMargin - windowwidth;
//                lp.bottomMargin = view.getHeight() - lp.topMargin - windowheight;
//                view.setLayoutParams(lp);
//                break;
//        }
//        // invalidate is redundant if layout params are set or not needed if they are not set.
////        mRrootLayout.invalidate();
//        return true;
//    }

    private String isOut(View view) {
        // Check to see if the view is out of bounds by calculating how many pixels
        // of the view must be out of bounds to and checking that at least that many
        // pixels are out.
        float percentageOut = 0.50f;
        int viewPctWidth = (int) (view.getWidth() * percentageOut);
        int viewPctHeight = (int) (view.getHeight() * percentageOut);

        if (-view.getTop() >= viewPctHeight)
            return "top";
        else if ((view.getBottom() - windowheight) > viewPctHeight)
            return "btm";
        else if (-view.getLeft() >= viewPctWidth)
            return "left";
        else if ((view.getRight() - windowwidth) > viewPctWidth)
            return "right";
        else
            return "in";

//        return ((-view.getLeft() >= viewPctWidth) ||
//                (view.getRight() - windowwidth) > viewPctWidth ||
//                (-view.getTop() >= viewPctHeight) ||
//                (view.getBottom() - windowheight) > viewPctHeight);
    }

//    float x, y;
//    float dx, dy;
//
//    @Override
//    public boolean onTouchEvent(MotionEvent event) {
//
//        switch (event.getAction()) {
//
//            case MotionEvent.ACTION_DOWN:
//                x = event.getX();
//                y = event.getY();
//                break;
//
//
//            case MotionEvent.ACTION_MOVE:
//                //            dx = event.getX() - x;
//                dy = event.getY() - y;
//
//                LOGGER.d("y: " + y + " Screen Height: " + height);
//                if (y <= 0 || y >= height)
//                    break;
//
//                //            imageView.setX(imageView.getX() + dx);
//                imageView.setY(imageView.getY() + dy);
//
//                x = event.getX();
//                y = event.getY();
//
//
//                break;
//
//        }
//        return super.onTouchEvent(event);
//    }
}