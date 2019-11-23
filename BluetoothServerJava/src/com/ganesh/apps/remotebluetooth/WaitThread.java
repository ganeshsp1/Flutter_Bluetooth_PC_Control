package com.ganesh.apps.remotebluetooth;

import java.io.IOException;

import javax.bluetooth.DiscoveryAgent;
import javax.bluetooth.LocalDevice;
import javax.bluetooth.UUID;
import javax.microedition.io.Connector;
import javax.microedition.io.StreamConnection;
import javax.microedition.io.StreamConnectionNotifier;

public class WaitThread implements Runnable {

	private boolean threadStop = false;

	ProcessConnectionThread processConnectionThread;

	/** Constructor */
	public WaitThread() {
	}

	void setThreadStopper(boolean threadStop) {
		this.threadStop = threadStop;
		if (processConnectionThread != null)
			processConnectionThread.setThreadStopper(threadStop);
		if (threadStop) {
			try {
				notifier.close();
				if (connection != null) {
					connection.close();
				}
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
	}

	@Override
	public void run() {
		waitForConnection();
	}

	private StreamConnection connection = null;
	private StreamConnectionNotifier notifier;
	LocalDevice local = null;

	/** Waiting for connection from devices */
	private void waitForConnection() {
		// retrieve the local Bluetooth device object

		// setup the server to listen for connection
		try {
			local = LocalDevice.getLocalDevice();
			if (local.getDiscoverable() != DiscoveryAgent.GIAC) {
				local.setDiscoverable(DiscoveryAgent.GIAC);
			}

			UUID uuid = new UUID(80087355); // "04c6093b-0000-1000-8000-00805f9b34fb"
			String url = "btspp://localhost:" + uuid.toString() + ";name=RemoteBluetooth";
			notifier = (StreamConnectionNotifier) Connector.open(url);
		} catch (Exception e) {
			e.printStackTrace();
			return;
		}
		// waiting for connection
//        while(true) {
		try {
			System.out.println("waiting for connection...");
			connection = notifier.acceptAndOpen();
			processConnectionThread = new ProcessConnectionThread(connection);
			Thread processThread = new Thread(processConnectionThread);
			processThread.start();
		} catch (Exception e) {
			e.printStackTrace();
			return;
		}
//        }
	}
}