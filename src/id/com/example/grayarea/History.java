package id.com.example.grayarea;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import android.os.Bundle;
import android.widget.TextView;

/*
 * Shows a running text log, so users can view past 
 * chapters without swiping through the images
 */
public class History extends MyActivity {

	TextView text;

	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.history);

		text = (TextView) findViewById(R.id.history_description);
		text.setClickable(false);
	}

	@Override
	public void onResume() {
		super.onResume();

		String history = "\n";

		if (path.isEmpty())
			history = history
					.concat("There is currently nothing to display because "
							+ "you are still in the first chapter.\nCheck "
							+ "back as you move on!");
		else
			for (int i : path)
				history = history.concat(getMyText(i) + "\n");

		text.setText(history);
	}

	private String getMyText(int i) {

		String toDisplay = "";

		try {
			BufferedReader br = new BufferedReader(new InputStreamReader(
					getAssets().open("history/" + i + ".txt")));

			try {
				String line = br.readLine();

				while (line != null) {
					toDisplay = toDisplay.concat(line + "\n");
					line = br.readLine();
				}

				br.close();

			} catch (IOException e) {
				e.printStackTrace();
			}
		} catch (IOException e) {
			e.printStackTrace();
		}

		return toDisplay;
	}
}
