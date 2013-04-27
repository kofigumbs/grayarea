package com.loofahcs.grayarea;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.Stack;

import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.MarkerOptions;

import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.media.AsyncPlayer;
import android.media.AudioManager;
import android.net.Uri;
import android.support.v4.app.FragmentActivity;
import android.util.SparseArray;
import android.view.HapticFeedbackConstants;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.widget.ImageButton;
import android.widget.Toast;

/**
 * Parent class that defines behavior that will be shared among all Activities
 * in this application. Mainly devoted to implementing the Menu, Music, and
 * Book.
 * 
 * @author Loofah Computer Systems
 * 
 */
public abstract class MyActivity extends FragmentActivity {

	// Variables that track progress in the Book
	static int chapter;
	static Stack<Integer> path;
	static boolean cheat;
	static boolean completed;

	// Lists of files that contain information for the Book
	static ArrayList<ArrayList<String>> book;
	static ArrayList<SparseArray<MarkerOptions>> decisions;

	// Where story will take place and where to center map
	static LatLng setting;

	// Music player and its state
	static AsyncPlayer mp;
	static boolean playing;

	// Tracks state of Menu Icon within Panel
	private static boolean pulsing;

	@Override
	// Stores state variables when for app restart
	public void onPause() {
		super.onPause();

		SharedPreferences.Editor editor = getSharedPreferences("ga_data",
				Context.MODE_PRIVATE).edit();

		editor.putBoolean("cheat", cheat);
		editor.putBoolean("completed", completed);
		editor.putBoolean("music", playing);

		editor.apply();
	}

	@Override
	// "Checks" active boxes and displays Cheat (if applicable) for
	// onCreateOptionsMenu
	public boolean onPrepareOptionsMenu(Menu menu) {
		super.onPrepareOptionsMenu(menu);

		menu.findItem(R.id.music).setTitle(
				playing ? R.string.music_checked : R.string.music_unchecked);

		menu.findItem(R.id.cheat)
				.setVisible(completed)
				.setTitle(
						cheat ? R.string.cheat_checked
								: R.string.cheat_unchecked);

		return true;
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {

		MenuInflater inflater = getMenuInflater();
		inflater.inflate(R.menu.activity_main, menu);

		return true;
	}

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		switch (item.getItemId()) {

		case R.id.about:
			goAbout(null);
			return true;

		case R.id.title:
			goTitle(null);
			return true;

		case R.id.music:
			playing = !playing;
			setMusic();
			return true;

		case R.id.history:
			goHistory(null);
			return true;

		case R.id.cheat:
			cheat = !cheat;

			if (cheat)
				Toast.makeText(MyActivity.this,
						"Location no longer necessary for decisions",
						Toast.LENGTH_SHORT).show();

			else
				Toast.makeText(MyActivity.this,
						"Location is now necessary for decisions",
						Toast.LENGTH_SHORT).show();

			return true;

		}

		return true;
	}

	/**
	 * In-app Menu Icon was pressed
	 * 
	 * @param v
	 *            Menu Icon
	 */
	public void showMenu(final View v) {
		v.performHapticFeedback(HapticFeedbackConstants.VIRTUAL_KEY);
		openOptionsMenu();
	}

	protected void setMusic() {

		if (!playing)
			mp.stop();
		else
			mp.play(this,
					Uri.parse("android.resource://com.loofahcs.grayarea/"
							+ R.raw.music), true, AudioManager.STREAM_MUSIC);

	}

	/**
	 * Shows and hides in-app Menu Icon in Panel
	 * 
	 * @param v
	 *            Anywhere on screen
	 */
	public void pulseIcons(View v) {

		if (!pulsing) {
			pulsing = true;

			final ImageButton options = (ImageButton) findViewById(R.id.options);

			Animation in = AnimationUtils.loadAnimation(this,
					android.R.anim.fade_in);

			options.startAnimation(in);
			options.setVisibility(View.VISIBLE);

			options.postDelayed(new Runnable() {
				public void run() {

					Animation out = AnimationUtils.loadAnimation(
							MyActivity.this, android.R.anim.fade_out);
					options.startAnimation(out);
					options.setVisibility(View.INVISIBLE);

					pulsing = false;
				}
			}, 3500);
		}
	}

	/**
	 * "Title Screen" was selected in the menu
	 * 
	 * @param v
	 *            "Title Screen"
	 */
	public void goTitle(final View v) {

		if (!(this instanceof MainActivity)) {
			Intent i = new Intent(this, MainActivity.class);
			i.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
			startActivity(i);
		}
	}

	/**
	 * "About" was selected in the menu
	 * 
	 * @param v
	 *            "About"
	 */
	public void goAbout(final View v) {

		if (!(this instanceof About)) {
			Intent i = new Intent(this, About.class);
			i.setFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT);
			startActivity(i);
		}
	}

	/**
	 * "History" was selected in the menu
	 * 
	 * @param v
	 *            "History"
	 */
	public void goHistory(final View v) {

		if (!(this instanceof History)) {
			Intent i = new Intent(this, History.class);
			i.setFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT);
			startActivity(i);
		}
	}

	/*
	 * Initializes book, decisions, and setting
	 */
	protected void populate() {

		decisions = new ArrayList<SparseArray<MarkerOptions>>();
		book = new ArrayList<ArrayList<String>>();

		// Read in from .txt files
		try {
			BufferedReader reader = new BufferedReader(new InputStreamReader(
					getAssets().open("pages.txt")));

			try {

				String line = reader.readLine();

				while (line != null && !line.equals("")) {
					line = line.replace(" ", "");

					if (line.startsWith("--"))
						book.add(new ArrayList<String>());

					else
						book.get(book.size() - 1).add(line);

					line = reader.readLine();
				}

				reader = new BufferedReader(new InputStreamReader(getAssets()
						.open("decisions.txt")));
				line = reader.readLine();

				while (line != null && !line.equals("")) {

					// gets rid of --# line
					line = reader.readLine();
					line = line.replace("{", "");
					line = line.replace("}", "");
					line = line.replace(" ", "");

					SparseArray<MarkerOptions> s = new SparseArray<MarkerOptions>();

					while (line.indexOf(',') != -1) {

						int j = Integer.valueOf(line.substring(0,
								line.indexOf(',')));
						s.put(j, null);

						line = line.substring(line.indexOf(',') + 1);
					}
					s.put(Integer.valueOf(line), null);

					for (int j = 0; j < s.size(); j++) {

						MarkerOptions m = new MarkerOptions();
						m.title(reader.readLine());
						m.snippet(reader.readLine());

						line = reader.readLine();
						double lat = Double.valueOf(line.substring(0,
								line.indexOf(',')));
						double lng = Double.valueOf(line.substring(line
								.indexOf(',') + 1));

						m.position(new LatLng(lat, lng));
						m.draggable(false);

						s.put(s.keyAt(j), m);
					}

					decisions.add(s);
					line = reader.readLine();
				}

				reader = new BufferedReader(new InputStreamReader(getAssets()
						.open("setting.txt")));

				setting = new LatLng(Double.valueOf(reader.readLine()),
						Double.valueOf(reader.readLine()));

				reader.close();

			} catch (IOException e) {
				e.printStackTrace();
			}
		} catch (IOException e) {
			e.printStackTrace();
		}

	}
}
