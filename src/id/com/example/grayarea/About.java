package id.com.example.grayarea;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import android.os.Bundle;
import android.widget.TextView;

/*
 * Controls About screen
 */
public class About extends MyActivity {

	TextView text;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.about);

		// Manipulate TextView
		text = (TextView) findViewById(R.id.about_description);
		text.setText(getMyText());
		text.setClickable(false);
	}

	/*
	 * Reads from about.txt
	 */
	private String getMyText() {

		String toDisplay = "\n";

		try {
			BufferedReader br = new BufferedReader(new InputStreamReader(
					getAssets().open("about.txt")));

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
