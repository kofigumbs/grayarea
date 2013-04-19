package com.loofahcs.grayarea;

import java.util.Stack;

import android.media.AsyncPlayer;
import android.os.AsyncTask;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.Toast;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;

public class MainActivity extends MyActivity {

	Button start;
	Button load;
	Button cont;

	static SharedPreferences sp;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_main);

		start = (Button) findViewById(R.id.start);
		load = (Button) findViewById(R.id.load);
		cont = (Button) findViewById(R.id.cont);

		// Setup music
		if (mp == null)
			mp = new AsyncPlayer("mp");

		// Load splash screen
		new AsyncTask<Void, Void, Void>() {
			private final ProgressDialog dialog = new ProgressDialog(
					MainActivity.this);

			@Override
			protected void onPreExecute() {

				if (sp == null) {
					dialog.setMessage("Initializing...");
					dialog.setCancelable(false);
					dialog.setCanceledOnTouchOutside(false);
					dialog.show();
				}

			}

			@Override
			protected Void doInBackground(Void... params) {

				if (sp == null) {
					sp = getPreferences(Context.MODE_PRIVATE);
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

					MainActivity.this.populate();
				}

				return null;
			}

			@Override
			protected void onPostExecute(Void result) {

				if (dialog.isShowing()) {
					dialog.dismiss();
				}
			}

		}.execute();

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
		else
			load.setVisibility(View.INVISIBLE);

	}

	@Override
	public void onPause() {

		if (isFinishing()) {
			playing = false;
			setMusic();
		}

		super.onPause();
	}

	// called by start button on home screen
	public void goStart(View v) {
		final View view = v;

		if (completed || chapter != 0)
			new AlertDialog.Builder(MainActivity.this)
					.setMessage(
							"Do you really want to start a new story?\n"
									+ "All achievements will be lost!")
					.setPositiveButton(android.R.string.yes,
							new DialogInterface.OnClickListener() {

								public void onClick(DialogInterface dialog,
										int whichButton) {

									if (cheat)
										Toast.makeText(
												MainActivity.this,
												"Location is now necessary for decisions",
												Toast.LENGTH_SHORT).show();

									chapter = 0;
									path.clear();
									completed = false;
									cheat = false;

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
