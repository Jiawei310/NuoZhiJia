/*******************************************************************************
 * Copyright (c) 2014 Nordic Semiconductor. All Rights Reserved.
 * 
 * The information contained herein is property of Nordic Semiconductor ASA.
 * Terms and conditions of usage are described in detail in NORDIC SEMICONDUCTOR STANDARD SOFTWARE LICENSE AGREEMENT.
 * Licensees are granted free, non-transferable use of the information. NO WARRANTY of ANY KIND is provided. 
 * This heading must NOT be removed from the file.
 ******************************************************************************/
package no.nordicsemi.android.nrftoolbox.dfu.settings;

import no.nordicsemi.android.dfu.DfuSettingsConstants;
import no.nordicsemi.android.nrftoolbox.R;
import android.app.AlertDialog;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.preference.PreferenceFragment;
import android.preference.PreferenceScreen;

public class SettingsFragment extends PreferenceFragment implements DfuSettingsConstants, SharedPreferences.OnSharedPreferenceChangeListener {

	@Override
	public void onCreate(final Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		addPreferencesFromResource(R.xml.settings_dfu);

		// set initial values
		updateNumberOfPacketsSummary();
		updateMBRSize();
	}

	@Override
	public void onResume() {
		super.onResume();

		// attach the preference change listener. It will update the summary below interval preference
		getPreferenceScreen().getSharedPreferences().registerOnSharedPreferenceChangeListener(this);
	}

	@Override
	public void onPause() {
		super.onPause();

		// unregister listener
		getPreferenceScreen().getSharedPreferences().unregisterOnSharedPreferenceChangeListener(this);
	}

	@Override
	public void onSharedPreferenceChanged(final SharedPreferences sharedPreferences, final String key) {
		final SharedPreferences preferences = getPreferenceManager().getSharedPreferences();

		if (SETTINGS_PACKET_RECEIPT_NOTIFICATION_ENABLED.equals(key)) {
			final boolean disabled = !preferences.getBoolean(SETTINGS_PACKET_RECEIPT_NOTIFICATION_ENABLED, true);
			if (disabled) {
				new AlertDialog.Builder(getActivity()).setMessage(R.string.dfu_settings_dfu_number_of_packets_info).setTitle(R.string.dfu_settings_dfu_information)
						.setNeutralButton(R.string.ok, null).show();
			}
		} else if (SETTINGS_NUMBER_OF_PACKETS.equals(key)) {
			updateNumberOfPacketsSummary();
		} else if (SETTINGS_MBR_SIZE.equals(key)) {
			updateMBRSize();
		}
	}

	private void updateNumberOfPacketsSummary() {
		final PreferenceScreen screen = getPreferenceScreen();
		final SharedPreferences preferences = getPreferenceManager().getSharedPreferences();

		final String value = preferences.getString(SETTINGS_NUMBER_OF_PACKETS, String.valueOf(SETTINGS_NUMBER_OF_PACKETS_DEFAULT));
		screen.findPreference(SETTINGS_NUMBER_OF_PACKETS).setSummary(value);

		final int valueInt = Integer.parseInt(value);
		if (valueInt > 200) {
			new AlertDialog.Builder(getActivity()).setMessage(R.string.dfu_settings_dfu_number_of_packets_info).setTitle(R.string.dfu_settings_dfu_information)
					.setNeutralButton(R.string.ok, null)
					.show();
		}
	}

	private void updateMBRSize() {
		final PreferenceScreen screen = getPreferenceScreen();
		final SharedPreferences preferences = getPreferenceManager().getSharedPreferences();

		final String value = preferences.getString(SETTINGS_MBR_SIZE, String.valueOf(SETTINGS_DEFAULT_MBR_SIZE));
		screen.findPreference(SETTINGS_MBR_SIZE).setSummary(value);
	}
}
