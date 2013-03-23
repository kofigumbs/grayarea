package id.com.example.grayarea;

import java.io.FileOutputStream;
import java.io.IOException;
import id.com.example.grayarea.Screen.*;
import android.content.Context;
import android.content.Intent;
import android.location.LocationManager;
import android.os.Bundle;
import android.support.v4.view.ViewPager;
import android.util.Log;
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
			Log.d("ENDOFBOOK", "ENDOFBOOK"); // END OF BOOK
			completed = true;
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
	
	@Override
	public void onPause() {
		super.onPause();

		try {
			FileOutputStream fos = openFileOutput("path_file",
					Context.MODE_PRIVATE);
			fos.write(path.toString().getBytes());
			fos.close();

		} catch (IOException e) {
			e.printStackTrace();
		}

	}

}
