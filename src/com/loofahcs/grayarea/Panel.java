package com.loofahcs.grayarea;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.location.LocationManager;
import android.net.wifi.WifiManager;
import android.os.Bundle;
import android.support.v4.view.ViewPager;
import android.support.v4.view.ViewPager.OnPageChangeListener;
import android.util.Log;
import android.view.HapticFeedbackConstants;
import android.view.View;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.widget.ImageButton;
import android.widget.Toast;
import com.loofahcs.grayarea.Screen.*;

/**
 * Activity that controls viewing the pages of book.
 * 
 * @author Loofah Computer Systems
 * 
 */
public class Panel extends MyActivity {

	// For the mechanics of the Swipe Transition
	private MyAdapter mAdapter;
	private ViewPager mPager;

	static boolean saved;
	static boolean canSplit;

	ImageButton ib;

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.pager);

		ib = (ImageButton) findViewById(decisions.size() <= chapter ? R.id.stop
				: R.id.decision);

		mAdapter = new MyAdapter(getSupportFragmentManager(), getAssets());

		mPager = (ViewPager) findViewById(R.id.pager);
		mPager.setAdapter(mAdapter);
		mPager.setPageTransformer(true, new DepthPageTransformer());
		mPager.setCurrentItem(
				getSharedPreferences("ga_data", Context.MODE_PRIVATE).getInt(
						"page", 0), false);

		mPager.setOnPageChangeListener(new OnPageChangeListener() {

			@Override
			public void onPageScrollStateChanged(int arg0) {

			}

			@Override
			public void onPageScrolled(int arg0, float arg1, int arg2) {

			}

			@Override
			// Fade the decision button in if user has reached the last page in
			// chapter
			public void onPageSelected(int p) {

				if (!canSplit
						&& p == MyActivity.book.get(MyActivity.chapter).size() - 1) {

					canSplit = true;
					Panel.this.showSplit();
				}

			}

		});

		// Commits progress to SharedPreferences
		SharedPreferences.Editor editor = getSharedPreferences("ga_data",
				Context.MODE_PRIVATE).edit();

		editor.putInt("chapter", chapter);
		editor.putInt("path_size", path.size());

		for (int i = 0; i < path.size(); i++)
			editor.putInt(Integer.toString(i), path.get(i));

		editor.apply();

		if (saved) {

			Toast.makeText(Panel.this, "Your progress has been saved!",
					Toast.LENGTH_SHORT).show();
			saved = false;
		}

	}

	@Override
	public void onResume() {
		super.onResume();

		canSplit = getSharedPreferences("ga_data", Context.MODE_PRIVATE)
				.getBoolean("can_split", false);

		if (canSplit)
			showSplit();

		Log.d("canSplit", canSplit ? "TRUE" : "False");
	}

	@Override
	// Used to store page number
	public void onPause() {
		super.onPause();

		SharedPreferences.Editor editor = getSharedPreferences("ga_data",
				Context.MODE_PRIVATE).edit();

		editor.putBoolean("can_split", canSplit);
		editor.putInt("page", mPager.getCurrentItem());
		editor.apply();

	}

	@Override
	public void onStop() {
		super.onStop();

		ib.setVisibility(View.INVISIBLE);
	}

	private void showSplit() {

		ib.postDelayed(new Runnable() {

			@Override
			public void run() {

				Animation in = AnimationUtils.loadAnimation(Panel.this,
						android.R.anim.fade_in);

				ib.startAnimation(in);
				ib.setVisibility(View.VISIBLE);
			}

		}, 1000);

	}

	/**
	 * If user is at the end of a story line, this will end the book. Otherwise,
	 * if the user has enabled Wifi and GPS, this will take them to the decision
	 * map.
	 * 
	 * @param v
	 *            Decision Icon
	 */
	public void goDecision(View v) {
		v.performHapticFeedback(HapticFeedbackConstants.VIRTUAL_KEY);

		WifiManager wifi = (WifiManager) getSystemService(Context.WIFI_SERVICE);
		LocationManager gps = (LocationManager) this
				.getSystemService(LOCATION_SERVICE);

		// Book completed case
		if (decisions.size() <= chapter) {

			// for the first time (Cheat and Jump unlocked)
			if (!completed) {
				completed = true;

				new AlertDialog.Builder(this)
						.setTitle("Congratulations!")
						.setMessage(
								"You've unlocked 2 new features:\n\n - Jump) go back to "
										+ "the Title Screen at any point to load a previous chapter\n\n "
										+ "- Cheat) go to the Menu to disable the location "
										+ "gameplay and progress without physically moving")
						.setPositiveButton(android.R.string.yes,
								new DialogInterface.OnClickListener() {

									public void onClick(DialogInterface dialog,
											int whichButton) {

										goTitle(null);
									}
								}).show();

			}

			// for the (n>1)th time
			else {
				goTitle(null);
				Toast.makeText(this,
						"Congratulations! You've completed this story path.",
						Toast.LENGTH_LONG).show();
			}

		}

		// Launch Decision map case
		else if (cheat
				|| (gps.isProviderEnabled(LocationManager.GPS_PROVIDER) && wifi
						.isWifiEnabled()))
			startActivity(new Intent(this, Decision.class));

		// Wifi or GPS not enabled case
		else
			Toast.makeText(
					this,
					"Please enable Wifi and GPS so Gray Area can register your decision.",
					Toast.LENGTH_LONG).show();
	}
}
