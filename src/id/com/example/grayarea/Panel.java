package id.com.example.grayarea;

import java.io.FileOutputStream;
import java.io.IOException;
import id.com.example.grayarea.Screen.*;
import android.content.Context;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.support.v4.view.ViewPager;

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

	@Override
	public void onPause() {

		SharedPreferences.Editor editor = getPreferences(Context.MODE_PRIVATE)
				.edit();
		editor.putInt("chapter", chapter);
		editor.putBoolean("cheat", cheat);
		editor.putBoolean("music", mp.isPlaying());
		editor.commit();

		try {
			FileOutputStream fos = openFileOutput("path_file",
					Context.MODE_PRIVATE);
			fos.write(path.toString().getBytes());
			fos.close();

		} catch (IOException e) {
			e.printStackTrace();
		}

		super.onPause();
	}

}
