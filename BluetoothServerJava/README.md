# Bluetooth Server Java Code for PC

## Requirements
 1. java 1.8
 2. eclipse or similar IDE
 
 ## Steps to run
Import this project to eclipse and run as java project.

## Dependencies
It uses the bluetooth cove library to interact with windows bluetooth:
  bluecove-2.1.1
Already packaged in it.

## UI
Java Swing UI is the frontend for the same, BluetoothMainGUI contains all UI related code.

## How it works
 It starts the bluetooth connection and waits for it to be connected, once connected it inteprets the string data send through and then moves the cursor or perform operations on the screen likewise.
