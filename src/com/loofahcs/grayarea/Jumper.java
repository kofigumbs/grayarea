package com.loofahcs.grayarea;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.view.Gravity;
import android.view.View.OnClickListener;
import android.view.HapticFeedbackConstants;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup.LayoutParams;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.ScrollView;
import android.widget.TextView;
import android.widget.Toast;

/**
 * Load Activity.
 * 
 * Allows users to jump back to previous chapters to explore other options
 * without starting over from the beginning.
 * 
 * @author Loofah Computer Systems
 * 
 */
public class Jumper extends MyActivity {

	@Override
	protected void onCreate(Bundle b) {
		super.onCreate(b);

		Toast.makeText(this, "Tap any chapter to jump back to it.",
				Toast.LENGTH_LONG).show();

	}

	@Override
	public void onResume() {
		super.onResume();

		LayoutInflater inflater = (LayoutInflater) getSystemService(Context.LAYOUT_INFLATER_SERVICE);
		LinearLayout jump = (LinearLayout) inflater
				.inflate(R.layout.list, null);

		for (int i : path) {

			final int newChapter = i;
			ImageView iv = new ImageView(this);
			TextView tv = new TextView(this);

			try {
				InputStream is = getAssets().open(book.get(i).get(0));
				Drawable d = Drawable.createFromStream(is, null);
				iv.setImageDrawable(d);
			} catch (IOException e1) {
				e1.printStackTrace();
			}

			iv.setOnClickListener(new OnClickListener() {

				@Override
				public void onClick(View v) {
					v.performHapticFeedback(HapticFeedbackConstants.VIRTUAL_KEY);

					new AlertDialog.Builder(Jumper.this)
							.setMessage(
									"Do you really want to jump back to this chapter?")
							.setPositiveButton(android.R.string.yes,
									new DialogInterface.OnClickListener() {

										public void onClick(
												DialogInterface dialog,
												int whichButton) {

											chapter = newChapter;

											SharedPreferences.Editor editor = getSharedPreferences(
													"ga_data",
													Context.MODE_PRIVATE)
													.edit();

											editor.putInt("page", 0);
											editor.putBoolean("can_split",
													false);
											editor.apply();

											Intent in = new Intent(Jumper.this,
													Panel.class);
											in.setFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT);
											startActivity(in);

											while (path.pop() != chapter)
												;

											Jumper.this.finish();

											Intent i = new Intent(Jumper.this,
													Panel.class);
											i.setFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT);
											startActivity(i);
										}
									})
							.setNegativeButton(android.R.string.no, null)
							.show();

				}

			});

			try {

				BufferedReader br = new BufferedReader(new InputStreamReader(
						getAssets().open("history/" + i + ".txt")));
				tv.setText(br.readLine() + "\n\n");
				tv.setGravity(Gravity.CENTER);
				tv.setWidth(iv.getWidth());

			} catch (IOException e) {
				e.printStackTrace();
			}

			jump.addView(iv);
			jump.addView(tv);

		}

		RelativeLayout r = (RelativeLayout) inflater.inflate(R.layout.jumper,
				null);

		RelativeLayout.LayoutParams params = new RelativeLayout.LayoutParams(
				LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT);
		params.addRule(RelativeLayout.BELOW, R.id.jump_title);
		params.addRule(RelativeLayout.ALIGN_LEFT, R.id.jump_title);

		if (!path.isEmpty()) {

			ScrollView scroll = new ScrollView(this);
			scroll.addView(jump);

			r.addView(scroll, params);
		}

		else {
			TextView tv = new TextView(this);
			tv.setText("\nThere is currently nothing to display because "
					+ "you are still in Chapter 0.\nCheck "
					+ "back as you move on!");
			r.addView(tv, params);
		}

		setContentView(r);
	}
}
