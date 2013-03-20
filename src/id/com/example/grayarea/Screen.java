package id.com.example.grayarea;

import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentPagerAdapter;
import android.support.v4.view.ViewPager;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.widget.ImageButton;
import android.widget.ImageView;

public class Screen {

	/*
	 * Classes for panel swipe transitions Based heavily on examples from Google
	 */
	public static class ScreenSlidePageFragment extends Fragment {

		ImageView iv;
		ImageButton ib;
		int position;

		@Override
		public View onCreateView(LayoutInflater inflater, ViewGroup container,
				Bundle savedInstanceState) {

			ViewGroup rootView = (ViewGroup) inflater.inflate(R.layout.panel,
					container, false);

			iv = (ImageView) rootView.findViewById(R.id.image);
			iv.setImageDrawable(MyActivity.book.get(MyActivity.chapter).get(
					position));

			ImageButton decision = (ImageButton) getActivity().findViewById(
					R.id.decision);

			if (!Panel.canDecide
					&& position == MyActivity.book.get(MyActivity.chapter)
							.size() - 1) {

				Animation in = AnimationUtils.loadAnimation(getActivity(),
						android.R.anim.fade_in);

				decision.startAnimation(in);
				decision.setVisibility(View.VISIBLE);

				Panel.canDecide = true;

			} else if (!Panel.canDecide)
				decision.setVisibility(View.INVISIBLE);

			return rootView;
		}

		public ScreenSlidePageFragment() {
			super();
		}

		public static Fragment create(int p) {

			ScreenSlidePageFragment s = new ScreenSlidePageFragment();
			s.position = p;

			return s;
		}
	}

	public static class MyAdapter extends FragmentPagerAdapter {
		public MyAdapter(android.support.v4.app.FragmentManager fm) {
			super(fm);
		}

		@Override
		public int getCount() {
			return MyActivity.book.get(MyActivity.chapter).size();
		}

		@Override
		public Fragment getItem(int position) {

			return ScreenSlidePageFragment.create(position);
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
