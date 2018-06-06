package no.nordicsemi.android.nrftoolbox.uart;

import no.nordicsemi.android.nrftoolbox.profile.BleManagerCallbacks;

public interface UARTManagerCallbacks extends BleManagerCallbacks {

	public void onDataReceived(final String data);

	public void onDataSent(final String data);
}
