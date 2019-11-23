package com.ganesh.apps.remotebluetooth;

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.net.URL;

import javax.swing.ImageIcon;
import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JLabel;

public class BluetoothMainGUI {
	public static void main(String[] args) {
		JFrame f = new JFrame();// creating instance of JFrame
		WaitThread waitThreada = new WaitThread();
        
		JLabel currentStatus = new JLabel("Current Status: Stopped");
		currentStatus.setBounds(80, 40, 200, 40);// x axis, y axis, width, height
		f.add(currentStatus);

		JButton startServer = new JButton("Start");// creating instance of JButton
		startServer.setBounds(80, 100, 100, 40);// x axis, y axis, width, height
		f.add(startServer);// adding button in JFrame

	
		JButton stopServer = new JButton("Stop");// creating instance of JButton
		stopServer.setBounds(200, 100, 100, 40);// x axis, y axis, width, height
		f.add(stopServer);// adding button in JFrame
		stopServer.setEnabled(false);
		startServer.addActionListener(new ActionListener() {

			@Override
			public void actionPerformed(ActionEvent e) {
				startServer.setEnabled(false);
				stopServer.setEnabled(true);
				currentStatus.setText("Current Status: Running");
				Thread waitThread = new Thread(waitThreada);
				waitThread.start();
			}
		});
		stopServer.addActionListener(new ActionListener() {

			@Override
			public void actionPerformed(ActionEvent e) {
				startServer.setEnabled(true);
				stopServer.setEnabled(false);
				currentStatus.setText("Current Status: Stopped");
				waitThreada.setThreadStopper(true);
			}
		});

		f.setTitle("Android Bluetooth Server");

        URL url = BluetoothMainGUI.class.getResource(
                             "/resources/android-bluetooth-icon-11.jpg");
		ImageIcon img = new ImageIcon(url);
		f.setIconImage(img.getImage());

		f.setSize(400, 200);// 400 width and 500 height
		f.setLayout(null);// using no layout managers
		f.setVisible(true);// making the frame visible
		f.setLocationRelativeTo(null);
		f.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
	}
}
