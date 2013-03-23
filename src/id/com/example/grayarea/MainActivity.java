package id.com.example.grayarea;

import java.util.Stack;

import android.os.Bundle;
import android.view.MotionEvent;
import android.view.View;
import android.webkit.WebView;
import android.widget.Button;
import android.widget.Toast;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;

public class MainActivity extends MyActivity {

	Button start;
	Button load;
	Button cont;

	WebView wv;

	static SharedPreferences sp;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_main);

		start = (Button) findViewById(R.id.start);
		load = (Button) findViewById(R.id.load);
		cont = (Button) findViewById(R.id.cont);
		wv = (WebView) findViewById(R.id.gray);

		if (sp == null) {
			sp = getPreferences(Context.MODE_PRIVATE);
			playing = sp.getBoolean("music", true);
			chapter = sp.getInt("chapter", 0);
			completed = sp.getBoolean("completed", false);
			cheat = sp.getBoolean("cheat", false);

			String s = sp.getString("path", "");
			path = new Stack<Integer>();

			while (!s.equals("")) {
				path.push(Integer.valueOf(s.substring(0, s.indexOf(","))));

				if (s.contains(","))
					s = s.substring(s.indexOf(",") + 1);

				else
					s = "";
			}

		}

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

		if (chapter == 0 && !completed)
			cont.setEnabled(false);
		else
			cont.setEnabled(true);

		if (completed)
			load.setVisibility(View.VISIBLE);
		else {
			load.setVisibility(View.INVISIBLE);
			cheat = false;
		}

		if (saved) {
			Toast.makeText(this, "Save successful!", Toast.LENGTH_SHORT).show();
			saved = false;
		}

	}

	@Override
	public void onPause() {

		if (this.isFinishing() && mp != null) // BACK was pressed from this
			mp.stop();

		endMusic(getApplicationContext());

		SharedPreferences.Editor editor = getPreferences(Context.MODE_PRIVATE)
				.edit();

		String s = "";
		while (!s.isEmpty())
			s = s.concat(path.pop() + ",");

		editor.putInt("chapter", chapter);
		editor.putBoolean("cheat", cheat);
		editor.putBoolean("music", playing);
		editor.putBoolean("completed", completed);
		editor.putString("path", s);

		editor.apply();

		super.onPause();
	}

	// called by start button on home screen
	public void goStart(View v) {
		final View view = v;

		if (completed || chapter != 0)
			new AlertDialog.Builder(MainActivity.this)
					.setMessage(
							"Do you really want to start a new story?\nALL "
									+ "achievements will be lost!")
					.setPositiveButton(android.R.string.yes,
							new DialogInterface.OnClickListener() {

								public void onClick(DialogInterface dialog,
										int whichButton) {

									chapter = 0;
									path.clear();
									completed = false;

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

	public void goJump(View v) {

		Intent i = new Intent(this, Jumper.class);
		i.setFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT);
		startActivity(i);
	}

}
