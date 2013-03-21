package id.com.example.grayarea;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.List;

import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.MarkerOptions;

import android.app.ActivityManager;
import android.app.ActivityManager.RunningTaskInfo;
import android.content.BroadcastReceiver;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.graphics.drawable.Drawable;
import android.location.LocationManager;
import android.media.MediaPlayer;
import android.support.v4.app.FragmentActivity;
import android.util.Log;
import android.util.SparseArray;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.widget.ImageButton;
import android.widget.PopupMenu;
import android.widget.Toast;

// Common elements between by activities 
public abstract class MyActivity extends FragmentActivity {

	// status-trackers
	static int chapter = 0;
	static ArrayList<Integer> path;
	public static boolean cheat = false;

	// Lists of files that contain panel info
	static ArrayList<ArrayList<Drawable>> book;
	static ArrayList<SparseArray<MarkerOptions>> decisions;

	private static PopupMenu popup;
	private ImageButton options;
	private static boolean pulsing = false;

	public static MediaPlayer mp;
	public static boolean playing = true;

	public BroadcastReceiver mReceiver;

	@Override
	public void onResume() {
		super.onResume();

		if (playing && (mp == null || !mp.isPlaying()))
			getMusic(this);
	}

	@Override
	public void onPause() {
		super.onPause();

		endMusic(getApplicationContext());
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		MenuInflater inflater = getMenuInflater();
		inflater.inflate(R.menu.activity_main, menu); // inflate our menu
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
			toggleMusic(MyActivity.this);
			item.setChecked(playing);
			return true;

		case R.id.history:
			goHistory(null);
			return true;
		}

		return true;
	}

	public void showMenu(final View v) {

		popup = new PopupMenu(this, v);
		popup.getMenuInflater().inflate(R.menu.activity_main, popup.getMenu());
		popup.getMenu().findItem(R.id.music).setChecked(playing);
		popup.show();

		popup.setOnMenuItemClickListener(new PopupMenu.OnMenuItemClickListener() {

			@Override
			public boolean onMenuItemClick(MenuItem item) {
				switch (item.getItemId()) {

				case R.id.about:
					goAbout(v);
					return true;

				case R.id.title:
					goTitle(v);
					return true;

				case R.id.music:
					toggleMusic(MyActivity.this);
					return true;

				case R.id.history:
					goHistory(v);
					return true;
				}
				return false;
			}
		});
	}

	public static void toggleMusic(Context c) {

		if (mp.isPlaying())
			mp.stop();

		else {
			getMusic(c);
		}

		playing = mp.isPlaying();
	}

	public static void getMusic(Context c) {
		try {
			if (mp != null)
				mp.release();
			mp = MediaPlayer.create(c, R.raw.music);
			mp.seekTo(4000);
			mp.start();
			mp.setLooping(true);

		} catch (IllegalArgumentException e) {
			e.printStackTrace();
		} catch (SecurityException e) {
			e.printStackTrace();
		} catch (IllegalStateException e) {
			e.printStackTrace();
		}
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

	public void goDecision(View v) {

		if (decisions.size() <= chapter)
			Log.d("ENDOFBOOK", "ENDOFBOOK"); // END OF BOOK

		else if (((LocationManager) this.getSystemService(LOCATION_SERVICE))
				.isProviderEnabled(LocationManager.GPS_PROVIDER))
			startActivity(new Intent(this, Decision.class));

		else
			Toast.makeText(
					this,
					"Please enable data and GPS so we can track your decision.",
					Toast.LENGTH_LONG).show();
	}

	public void goTitle(final View v) {

		if (!(this instanceof MainActivity)) {
			Intent i = new Intent(this, MainActivity.class);
			i.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
			startActivity(i);
		} else
			popup.dismiss();
	}

	public void goAbout(final View v) {

		if (!(this instanceof About)) {
			Intent i = new Intent(this, About.class);
			i.setFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT);
			startActivity(i);
		} else
			popup.dismiss();
	}

	public void goHistory(final View v) {

		if (!(this instanceof History)) {
			Intent i = new Intent(this, History.class);
			i.setFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT);
			startActivity(i);
		} else
			popup.dismiss();
	}

	public static void endMusic(Context c) {

		ActivityManager am = (ActivityManager) c
				.getSystemService(Context.ACTIVITY_SERVICE);

		List<RunningTaskInfo> taskInfo = am.getRunningTasks(1);

		if (!taskInfo.isEmpty()) {
			ComponentName topActivity = taskInfo.get(0).topActivity;

			if (!topActivity.getPackageName().equals(c.getPackageName()))
				mp.stop();

		}
	}

	/*
	 * initializes pages and decisions
	 */
	protected void populate() {

		decisions = new ArrayList<SparseArray<MarkerOptions>>();
		book = new ArrayList<ArrayList<Drawable>>();
		path = new ArrayList<Integer>();

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
