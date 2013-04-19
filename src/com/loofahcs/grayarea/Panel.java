package com.loofahcs.grayarea;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.location.LocationManager;
import android.os.Bundle;
import android.support.v4.view.ViewPager;
import android.support.v4.view.ViewPager.OnPageChangeListener;
import android.view.View;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.widget.ImageButton;
import android.widget.Toast;
import com.loofahcs.grayarea.Screen.*;

/*
 * Class to describe behavior of each page
 */
public class Panel extends MyActivity {

	private MyAdapter mAdapter;
	private ViewPager mPager;

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.pager);

		mAdapter = new MyAdapter(getSupportFragmentManager());

		mPager = (ViewPager) findViewById(R.id.pager);
		mPager.setAdapter(mAdapter);
		mPager.setPageTransformer(true, new DepthPageTransformer());
		mPager.setOnPageChangeListener(new OnPageChangeListener() {

			boolean visible = false;

			@Override
			public void onPageScrollStateChanged(int arg0) {

			}

			@Override
			public void onPageScrolled(int arg0, float arg1, int arg2) {

			}

			@Override
			public void onPageSelected(int p) {

				if (!visible
						&& p == MyActivity.book.get(MyActivity.chapter).size() - 1) {

					visible = true;
					ImageButton ib = (ImageButton) findViewById(decisions
							.size() <= chapter ? R.id.stop : R.id.decision);

					Animation in = AnimationUtils.loadAnimation(Panel.this,
							android.R.anim.fade_in);

					ib.startAnimation(in);
					ib.setVisibility(View.VISIBLE);

				}

			}

		});

		if (saved) {
			Toast.makeText(this, "Your progress has been saved!",
					Toast.LENGTH_SHORT).show();
			saved = false;
		}

	}

	public void onPause() {
		super.onPause();

		SharedPreferences.Editor editor = getPreferences(Context.MODE_PRIVATE)
				.edit();

		String s = "";
		while (!s.isEmpty())
			s = s.concat(path.pop() + ",");

		editor.putInt("chapter", chapter);
		editor.putBoolean("cheat", cheat);
		editor.putBoolean("completed", completed);
		editor.putString("path", s);

		editor.apply();
	}

	public void goDecision(View v) {

		if (decisions.size() <= chapter) {

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

			else {
				goTitle(null);
				Toast.makeText(this,
						"Congratulations! You've completed this story path.",
						Toast.LENGTH_LONG).show();
			}

		}

		else if (cheat
				|| ((LocationManager) this.getSystemService(LOCATION_SERVICE))
						.isProviderEnabled(LocationManager.GPS_PROVIDER))
			startActivity(new Intent(this, Decision.class));

		else
			Toast.makeText(
					this,
					"Please enable data and GPS so Gray Area can register your decision.",
					Toast.LENGTH_LONG).show();
	}

}
