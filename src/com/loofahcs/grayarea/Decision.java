package com.loofahcs.grayarea;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.util.SparseArray;
import android.widget.Toast;

import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.GoogleMap.OnInfoWindowClickListener;
import com.google.android.gms.maps.MapFragment;
import com.google.android.gms.maps.model.BitmapDescriptorFactory;
import com.google.android.gms.maps.model.CameraPosition;
import com.google.android.gms.maps.model.Marker;
import com.google.android.gms.maps.model.MarkerOptions;

/**
 * Map Activity.
 * 
 * @author Loofah Computer Systems
 * 
 */
public class Decision extends Activity {

	// Tolerance of decision making engine
	private static final double THRESHOLD = .001;

	private MapFragment mf;
	private GoogleMap map;
	private SparseArray<Marker> marks;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.decision);

		mf = (MapFragment) getFragmentManager().findFragmentById(R.id.map);
		map = mf.getMap();

		map.setMapType(GoogleMap.MAP_TYPE_SATELLITE);
		map.setMyLocationEnabled(true);
		map.getUiSettings().setCompassEnabled(false);
		map.getUiSettings().setZoomControlsEnabled(false);
		map.getUiSettings().setRotateGesturesEnabled(true);

		SparseArray<MarkerOptions> s = MyActivity.decisions
				.get(MyActivity.chapter);
		marks = new SparseArray<Marker>(s.size());

		for (int i = 0; i < s.size(); i++) {

			if (i % 2 == 1)
				s.valueAt(i)
						.icon(BitmapDescriptorFactory
								.defaultMarker(BitmapDescriptorFactory.HUE_YELLOW));

			marks.put(s.keyAt(i), map.addMarker(s.valueAt(i)));
		}

		map.moveCamera(CameraUpdateFactory.newCameraPosition(CameraPosition
				.builder().target(MyActivity.setting).zoom((float) 14.4)
				.tilt((float) 50).build()));

		map.setOnInfoWindowClickListener(new OnInfoWindowClickListener() {

			@Override
			public void onInfoWindowClick(Marker m) {

				if (MyActivity.cheat || isNear(map, m)) {
					int n = -1;
					for (int i = 0; i < marks.size(); i++)
						if (m.getPosition().equals(
								marks.valueAt(i).getPosition())) {
							n = marks.keyAt(i);
							break;
						}

					final int next = n;

					new AlertDialog.Builder(Decision.this)
							.setMessage(
									"Do you really want to move to "
											+ m.getSnippet() + "?")
							.setPositiveButton(android.R.string.yes,
									new DialogInterface.OnClickListener() {

										public void onClick(
												DialogInterface dialog,
												int whichButton) {

											MyActivity.path
													.push(MyActivity.chapter);
											MyActivity.chapter = next;
											Panel.saved = true;

											SharedPreferences.Editor editor = getSharedPreferences(
													"ga_data",
													Context.MODE_PRIVATE)
													.edit();

											editor.putInt("page", 0);
											editor.putBoolean("can_split",
													false);
											editor.apply();

											Intent intent = new Intent(
													Decision.this, Panel.class);
											intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);

											startActivity(intent);

											finish();
										}
									})
							.setNegativeButton(android.R.string.no, null)
							.show();
				}

				else
					Toast.makeText(
							mf.getActivity(),
							"Go to " + m.getSnippet()
									+ " to make this decision!",
							Toast.LENGTH_LONG).show();
			}

		});
	}

	private static boolean isNear(GoogleMap map, Marker m) {

		if (Math.abs(map.getMyLocation().getLatitude()
				- m.getPosition().latitude) < THRESHOLD
				&& Math.abs(map.getMyLocation().getLongitude()
						- m.getPosition().longitude) < THRESHOLD)
			return true;

		else
			return false;
	}

}
