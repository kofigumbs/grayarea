package com.loofahcs.grayarea;

import java.io.IOException;
import java.io.InputStream;

import android.content.res.AssetManager;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentPagerAdapter;
import android.support.v4.view.ViewPager;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;

/**
 * Container class for swipe transitions. Based heavily on examples from Google.
 * 
 * @author Loofah Computer Systems
 * 
 */
public class Screen {

	public static class ScreenSlidePageFragment extends Fragment {

		ImageView iv;
		int position;

		// Allows for dynamic page loading
		static AssetManager am;

		@Override
		public View onCreateView(LayoutInflater inflater, ViewGroup container,
				Bundle savedInstanceState) {

			ViewGroup rootView = (ViewGroup) inflater.inflate(R.layout.panel,
					container, false);

			try {
				InputStream is = am.open(MyActivity.book
						.get(MyActivity.chapter).get(position));
				Drawable d = Drawable.createFromStream(is, null);
				iv = (ImageView) rootView.findViewById(R.id.image);
				iv.setImageDrawable(d);

			} catch (IOException e) {
				e.printStackTrace();
			}

			return rootView;
		}

		public ScreenSlidePageFragment() {
			super();
		}

		public static Fragment create(int p, AssetManager am) {

			ScreenSlidePageFragment s = new ScreenSlidePageFragment();
			ScreenSlidePageFragment.am = am;
			s.position = p;

			return s;
		}
	}

	public static class MyAdapter extends FragmentPagerAdapter {

		AssetManager am;

		public MyAdapter(android.support.v4.app.FragmentManager fm) {
			super(fm);
		}

		public MyAdapter(android.support.v4.app.FragmentManager fm,
				AssetManager am) {
			super(fm);
			this.am = am;
		}

		@Override
		public int getCount() {
			return MyActivity.book.get(MyActivity.chapter).size();
		}

		@Override
		public Fragment getItem(int position) {

			return ScreenSlidePageFragment.create(position, am);
		}
	}

	public static class DepthPageTransformer implements
			ViewPager.PageTransformer {
		private static final float MIN_SCALE = 0.75f;

		public void transformPage(View view, float position) {

			int pageWidth = view.getWidth();
			view.setTranslationX(-1 * view.getWidth() * position);

			if (position < -1) { // [-Infinity,-1)
				// This page is way off-screen to the left.
				view.setAlpha(0);

			} else if (position <= 0) { // [-1,0]
				// Use the default slide transition when moving to the left page
				view.setAlpha(1);
				view.setTranslationX(0);
				view.setScaleX(1);
				view.setScaleY(1);

			} else if (position <= 1) { // (0,1]
				// Fade the page out.
				view.setAlpha(1 - position);

				// Counteract the default slide transition
				view.setTranslationX(pageWidth * -position);

				// Scale the page down (between MIN_SCALE and 1)
				float scaleFactor = MIN_SCALE + (1 - MIN_SCALE)
						* (1 - Math.abs(position));
				view.setScaleX(scaleFactor);
				view.setScaleY(scaleFactor);

			} else { // (1,+Infinity]
				// This page is way off-screen to the right.
				view.setAlpha(0);
			}
		}
	}
}
