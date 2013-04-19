package com.loofahcs.grayarea;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.Stack;

import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.MarkerOptions;

import android.content.Intent;
import android.graphics.drawable.Drawable;
import android.media.AsyncPlayer;
import android.media.AudioManager;
import android.net.Uri;
import android.support.v4.app.FragmentActivity;
import android.util.SparseArray;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.widget.ImageButton;
import android.widget.Toast;

// Common elements between by activities 
public abstract class MyActivity extends FragmentActivity {

	// Status-trackers
	static int chapter;
	static Stack<Integer> path;
	public static boolean cheat;
	public static boolean completed;
	public static boolean saved = false;

	// Lists of files that contain panel info
	static ArrayList<ArrayList<Drawable>> book;
	static ArrayList<SparseArray<MarkerOptions>> decisions;

	// Menu stuff
	private ImageButton options;
	private static boolean pulsing = false;

	// Music stuff
	public static AsyncPlayer mp;
	public static boolean playing = false;

	@Override
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

	public void showMenu(final View v) {
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

	public void pulseIcons(View v) {

		if (!pulsing) {
			pulsing = true;

			options = (ImageButton) findViewById(R.id.options);

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

	public void goTitle(final View v) {

		if (!(this instanceof MainActivity)) {
			Intent i = new Intent(this, MainActivity.class);
			i.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
			startActivity(i);
		}
	}

	public void goAbout(final View v) {

		if (!(this instanceof About)) {
			Intent i = new Intent(this, About.class);
			i.setFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT);
			startActivity(i);
		}
	}

	public void goHistory(final View v) {

		if (!(this instanceof History)) {
			Intent i = new Intent(this, History.class);
			i.setFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT);
			startActivity(i);
		}
	}

	/*
	 * initializes pages and decisions
	 */
	protected void populate() {

		decisions = new ArrayList<SparseArray<MarkerOptions>>();
		book = new ArrayList<ArrayList<Drawable>>();

		// Read in from .txt files
		try {
			BufferedReader pageReader = new BufferedReader(
					new InputStreamReader(getAssets().open("pages.txt")));
			BufferedReader decisionReader = new BufferedReader(
					new InputStreamReader(getAssets().open("decisions.txt")));

			try {

				String line = pageReader.readLine();

				while (line != null && !line.equals("")) {
					line = line.replace(" ", "");

					if (line.startsWith("--"))
						book.add(new ArrayList<Drawable>());

					else {
						InputStream is = getAssets().open(line);
						Drawable d = Drawable.createFromStream(is, null);
						book.get(book.size() - 1).add(d);
					}

					line = pageReader.readLine();
				}

				line = decisionReader.readLine();

				while (line != null && !line.equals("")) {

					// gets rid of --# line
					line = decisionReader.readLine();
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
						m.title(decisionReader.readLine());
						m.snippet(decisionReader.readLine());

						line = decisionReader.readLine();
						double lat = Double.valueOf(line.substring(0,
								line.indexOf(',')));
						double lng = Double.valueOf(line.substring(line
								.indexOf(',') + 1));

						m.position(new LatLng(lat, lng));
						m.draggable(false);

						s.put(s.keyAt(j), m);
					}

					decisions.add(s);
					line = decisionReader.readLine();
				}

				pageReader.close();
				decisionReader.close();

			} catch (IOException e) {
				e.printStackTrace();
			}
		} catch (IOException e) {
			e.printStackTrace();
		}

	}
}
