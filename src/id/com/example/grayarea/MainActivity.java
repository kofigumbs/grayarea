package id.com.example.grayarea;

import java.util.List;

import android.os.Bundle;
import android.view.MotionEvent;
import android.view.View;
import android.webkit.WebView;
import android.widget.Button;
import android.app.ActivityManager;
import android.app.ActivityManager.RunningTaskInfo;
import android.app.AlertDialog;
import android.content.ComponentName;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;

public class MainActivity extends MyActivity {

	Button start;
	Button save;
	Button cont;

	WebView wv;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_main);

		start = (Button) findViewById(R.id.start);
		save = (Button) findViewById(R.id.load);
		cont = (Button) findViewById(R.id.cont);
		wv = (WebView) findViewById(R.id.gray);

		wv.loadUrl("file:///android_asset/back.gif");
		wv.setHapticFeedbackEnabled(false);

		// disable scroll on touch
		wv.setOnTouchListener(new View.OnTouchListener() {

			public boolean onTouch(View v, MotionEvent event) {
				return (event.getAction() == MotionEvent.ACTION_MOVE);
			}
		});

		populate();

	}

	@Override
	public void onResume() {
		super.onResume();

		if (chapter == 0)
			cont.setEnabled(false);
		else
			cont.setEnabled(true);

		if (cheat)
			save.setVisibility(View.VISIBLE);
		else
			save.setVisibility(View.INVISIBLE);
	}

	@Override
	public void onPause() {

		if (this.isFinishing()) // BACK was pressed from this activity
			mp.stop();

		Context context = getApplicationContext();

		ActivityManager am = (ActivityManager) context
				.getSystemService(Context.ACTIVITY_SERVICE);

		List<RunningTaskInfo> taskInfo = am.getRunningTasks(1);

		if (!taskInfo.isEmpty()) {
			ComponentName topActivity = taskInfo.get(0).topActivity;

			if (!topActivity.getPackageName().equals(context.getPackageName()))
				mp.stop();
		}

		super.onPause();
	}

	// called by start button on home screen
	public void goStart(View v) {
		final View view = v;

		if (chapter != 0)
			new AlertDialog.Builder(MainActivity.this)
					.setTitle("Confirm")
					.setMessage(
							"Do you really want to start a new story?\nAll "
									+ (cheat ? "unsaved" : "previous")
									+ " progress will be lost!")
					.setIcon(android.R.drawable.ic_dialog_alert)
					.setPositiveButton(android.R.string.yes,
							new DialogInterface.OnClickListener() {

								public void onClick(DialogInterface dialog,
										int whichButton) {

									chapter = 0;
									path.clear();

									goContinue(view);
								}
							}).setNegativeButton(android.R.string.no, null)
					.show();

		else
			goContinue(v);
	}

	public void goContinue(View v) {

		Intent i = new Intent(this, Panel.class);
		i.setFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT);
		startActivity(i);
	}

}
