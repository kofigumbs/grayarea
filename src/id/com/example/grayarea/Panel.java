package id.com.example.grayarea;

import id.com.example.grayarea.Screen.*;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.location.LocationManager;
import android.os.Bundle;
import android.support.v4.view.ViewPager;
import android.view.View;
import android.widget.Toast;

/*
 * Class to describe behavior of each page
 */
public class Panel extends MyActivity {

	private MyAdapter mAdapter;
	private ViewPager mPager;

	public static boolean canDecide;

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.pager);

		canDecide = false;
		mAdapter = new MyAdapter(getSupportFragmentManager());

		mPager = (ViewPager) findViewById(R.id.pager);
		mPager.setAdapter(mAdapter);
		mPager.setPageTransformer(true, new DepthPageTransformer());

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

			else
				goTitle(null);

		}

		else if (((LocationManager) this.getSystemService(LOCATION_SERVICE))
				.isProviderEnabled(LocationManager.GPS_PROVIDER))
			startActivity(new Intent(this, Decision.class));

		else
			Toast.makeText(
					this,
					"Please enable data and GPS so we can track your decision.",
					Toast.LENGTH_LONG).show();
	}

}
