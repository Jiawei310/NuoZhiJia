package no.nordicsemi.android.nrftoolbox.uart;

import no.nordicsemi.android.nrftoolbox.R;
import android.content.Context;
import android.content.SharedPreferences;
import android.preference.PreferenceManager;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;

public class UARTButtonAdapter extends BaseAdapter {
	public final static String PREFS_BUTTON_ENABLED = "prefs_uart_enabled_";
	public final static String PREFS_BUTTON_COMMAND = "prefs_uart_command_";
	public final static String PREFS_BUTTON_ICON = "prefs_uart_icon_";

	private final SharedPreferences mPreferences;
	private final int[] mIcons;
	private final boolean[] mEnableFlags;
	private boolean mEditMode;

	public UARTButtonAdapter(final Context context) {
		mPreferences = PreferenceManager.getDefaultSharedPreferences(context);
		mIcons = new int[9];
		mEnableFlags = new boolean[9];
	}

	public void setEditMode(final boolean editMode) {
		mEditMode = editMode;
		notifyDataSetChanged();
	}

	@Override
	public void notifyDataSetChanged() {
		final SharedPreferences preferences = mPreferences;
		for (int i = 0; i < mIcons.length; ++i) {
			mIcons[i] = preferences.getInt(PREFS_BUTTON_ICON + i, -1);
			mEnableFlags[i] = preferences.getBoolean(PREFS_BUTTON_ENABLED + i, false);
		}
		super.notifyDataSetChanged();
	}

	@Override
	public int getCount() {
		return mIcons.length;
	}

	@Override
	public Object getItem(final int position) {
		return mIcons[position];
	}

	@Override
	public long getItemId(final int position) {
		return position;
	}

	@Override
	public boolean hasStableIds() {
		return true;
	}

	@Override
	public boolean areAllItemsEnabled() {
		return false;
	}

	@Override
	public boolean isEnabled(int position) {
		return mEditMode || mEnableFlags[position];
	}

	@Override
	public View getView(final int position, final View convertView, final ViewGroup parent) {
		View view = convertView;
		if (view == null) {
			final LayoutInflater inflater = LayoutInflater.from(parent.getContext());
			view = inflater.inflate(R.layout.feature_uart_button, parent, false);
		}
		view.setEnabled(isEnabled(position));
		view.setActivated(mEditMode);

		// Update image
		final ImageView image = (ImageView) view;
		final int icon = mIcons[position];
		if (mEnableFlags[position] && icon != -1) {
			image.setImageResource(R.drawable.uart_button);
			image.setImageLevel(icon);
		} else
			image.setImageDrawable(null);

		return view;
	}
}
