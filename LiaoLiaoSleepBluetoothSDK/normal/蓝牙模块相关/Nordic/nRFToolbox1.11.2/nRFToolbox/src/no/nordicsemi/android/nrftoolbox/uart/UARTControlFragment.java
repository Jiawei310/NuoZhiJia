package no.nordicsemi.android.nrftoolbox.uart;

import no.nordicsemi.android.nrftoolbox.R;
import android.app.Activity;
import android.app.Fragment;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.GridView;

public class UARTControlFragment extends Fragment implements GridView.OnItemClickListener {
	private final static String TAG = "UARTControlFragment";
	private final static String SIS_EDIT_MODE = "sis_edit_mode";

	private ControlFragmentListener mListener;
	private SharedPreferences mPreferences;
	private UARTButtonAdapter mAdapter;
	private boolean mEditMode;

	public static interface ControlFragmentListener {
		public void setEditMode(final boolean editMode);
	}

	@Override
	public void onAttach(final Activity activity) {
		super.onAttach(activity);

		try {
			mListener = (ControlFragmentListener) activity;
		} catch (final ClassCastException e) {
			Log.e(TAG, "The parten activity must implement EditModeListener");
		}
	}

	@Override
	public void onDetach() {
		super.onDetach();
		mListener = null;
	}

	@Override
	public void onCreate(final Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		mPreferences = PreferenceManager.getDefaultSharedPreferences(getActivity());

		if (savedInstanceState != null) {
			mEditMode = savedInstanceState.getBoolean(SIS_EDIT_MODE);
		}
	}

	@Override
	public void onSaveInstanceState(final Bundle outState) {
		outState.putBoolean(SIS_EDIT_MODE, mEditMode);
	}

	@Override
	public View onCreateView(final LayoutInflater inflater, final ViewGroup container, final Bundle savedInstanceState) {
		final View view = inflater.inflate(R.layout.fragment_feature_uart_control, container, false);

		final GridView grid = (GridView) view.findViewById(R.id.grid);
		grid.setAdapter(mAdapter = new UARTButtonAdapter(getActivity()));
		grid.setOnItemClickListener(this);
		mAdapter.setEditMode(mEditMode);

		setHasOptionsMenu(true);
		return view;
	}

	@Override
	public void onItemClick(final AdapterView<?> parent, final View view, final int position, final long id) {
		if (mEditMode) {
			final UARTEditDialog dialog = UARTEditDialog.getInstance(position);
			dialog.show(getChildFragmentManager(), null);
		} else {
			final UARTInterface uart = (UARTInterface) getActivity();
			uart.send(mPreferences.getString(UARTButtonAdapter.PREFS_BUTTON_COMMAND + position, ""));
		}
	}

	@Override
	public void onCreateOptionsMenu(final Menu menu, final MenuInflater inflater) {
		inflater.inflate(mEditMode ? R.menu.uart_menu_config : R.menu.uart_menu, menu);
	}

	@Override
	public boolean onOptionsItemSelected(final MenuItem item) {
		final int itemId = item.getItemId();
		switch (itemId) {
		case R.id.action_configure:
			setEditMode(!mEditMode);
			return true;
		}
		return false;
	}

	public void setEditMode(final boolean editMode) {
		mEditMode = editMode;
		mAdapter.setEditMode(mEditMode);
		getActivity().invalidateOptionsMenu();
		mListener.setEditMode(mEditMode);
	}

	public void onConfigurationChanged() {
		mAdapter.notifyDataSetChanged();
	}
}
