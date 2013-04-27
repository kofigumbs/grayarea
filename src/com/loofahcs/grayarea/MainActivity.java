package com.loofahcs.grayarea;

import java.io.IOException;
import java.util.Stack;

import android.media.AsyncPlayer;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.Toast;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.drawable.Drawable;

/**
 * Home page Activity.
 * 
 * @author Loofah Computer Systems
 * 
 */
public class MainActivity extends MyActivity {

	Button load;
	Button cont;
	ImageView background;

	static SharedPreferences sp;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_main);

		load = (Button) findViewById(R.id.load);
		cont = (Button) findViewById(R.id.cont);
		background = (ImageView) findViewById(R.id.gray);

		try {
			background.setImageDrawable(Drawable.createFromStream(getAssets()
					.open("titlescreen.jpg"), null));
		} catch (IOException e) {
			e.printStackTrace();
		}

		// indicates files not loaded
		if (sp == null) {

			MainActivity.this.populate();

			mp = new AsyncPlayer("mp");

			sp = getSharedPreferences("ga_data", Context.MODE_PRIVATE);

			chapter = sp.getInt("chapter", 0);
			completed = sp.getBoolean("completed", false);
			cheat = sp.getBoolean("cheat", false);

			playing = sp.getBoolean("music", true);
			setMusic();

			path = new Stack<Integer>();

			for (int i = 0; i < sp.getInt("path_size", 0); i++)
				path.push(sp.getInt(Integer.toString(i), 0));

		}
	}

	@Override
	public void onResume() {
		super.onResume();

		cont.setEnabled(getSharedPreferences("ga_data", Context.MODE_PRIVATE)
				.getBoolean("started", false));

		load.setVisibility(completed ? View.VISIBLE : View.INVISIBLE);

	}

	@Override
	public void onPause() {
		super.onPause();

		if (isFinishing()) {
			playing = false;
			setMusic();
		}

	}

	/**
	 * Start button was pressed
	 * 
	 * @param v
	 *            Start button
	 */
	public void goStart(View v) {
		final View view = v;

		// Restarting progress case
		if (cont.isEnabled())
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

									SharedPreferences.Editor editor = getSharedPreferences(
											"ga_data", Context.MODE_PRIVATE)
											.edit();

									editor.putInt("page", 0);
									editor.putBoolean("can_split", false);
									editor.apply();

									goContinue(view);
								}
							}).setNegativeButton(android.R.string.no, null)
					.show();

		else {

			SharedPreferences.Editor editor = getSharedPreferences("ga_data",
					Context.MODE_PRIVATE).edit();
			editor.putBoolean("started", true);
			editor.apply();

			goContinue(v);
		}
	}

	/**
	 * Continue button was pressed
	 * 
	 * @param v
	 *            Continue button
	 */
	public void goContinue(View v) {

		Intent i = new Intent(this, Panel.class);
		i.setFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT);
		startActivity(i);
	}

	/**
	 * Jump button was pressed
	 * 
	 * @param v
	 *            Jump button
	 */
	public void goJump(View v) {

		Intent i = new Intent(this, Jumper.class);
		i.setFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT);
		startActivity(i);
	}

}
