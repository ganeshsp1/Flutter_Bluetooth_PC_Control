# Flutter Bluetooth PC Control 
## Control your PC by using Flutter app

## Prerequisites
    1) Java 1.8
    2) Flutter

## Getting Started
  - Go to PC Settings and turn on Bluetooth and make it discoverable
  - Download the [bluetooth_pc_control.jar](https://github.com/ganeshsp1/Flutter_Bluetooth_PC_Control/blob/master/BluetoothServerJava/bluetooth_pc_control.jar)
  - If Java is installed and mentioned in environment variable as path then it should either work if you give open with java or else you can open Command Prompt point to the location where the jar is installed and run the command
  ```java -jar bluetooth_pc_control.jar```
  
  A new screen appears as shown below
  
  ![Server](https://github.com/ganeshsp1/Flutter_Bluetooth_PC_Control/blob/master/screenshots/ServerLaunch.png)
  
 - Click on Start to start the server
and then you can see the screen changing to as shown below

  ![Server Started](https://github.com/ganeshsp1/Flutter_Bluetooth_PC_Control/blob/master/screenshots/ServerStart.png)
  
  
  Open the App
  
  - Turn on bluetooth
  ![App Launch](https://github.com/ganeshsp1/Flutter_Bluetooth_PC_Control/blob/master/screenshots/App_launch.jpg)
  *NOTE*-**Manually turn on location**
  - If you have already paired your PC with phone or skip next steps
  - Click on *Explore discovered devices*
    ![App Pair](https://github.com/ganeshsp1/Flutter_Bluetooth_PC_Control/blob/master/screenshots/App_pair.jpg)
  - It will show the nearest bluetooth device in green, choose your laptop and pair with it
      ![App_pair_code](https://github.com/ganeshsp1/Flutter_Bluetooth_PC_Control/blob/master/screenshots/App_pair_code.jpg)
      ![blutooth_pin_pc](https://github.com/ganeshsp1/Flutter_Bluetooth_PC_Control/blob/master/screenshots/blutooth_pin_pc.png)
      ![App_pair_success](https://github.com/ganeshsp1/Flutter_Bluetooth_PC_Control/blob/master/screenshots/App_pair_success.jpg)
      ![bluetooth_pairing_success_pc](https://github.com/ganeshsp1/Flutter_Bluetooth_PC_Control/blob/master/screenshots/bluetooth_pairing_success_pc.png)

  - Next in main screen click *Connect to paired PC to Control* and choose the paired laptop 
    *NOTE*- Only laptops with the server running will be enabled in the list to choose
      ![App_connect](https://github.com/ganeshsp1/Flutter_Bluetooth_PC_Control/blob/master/screenshots/App_connect.jpg)
      
  - TaDa !!! Now you can control your PC using your phone !!!
        ![App_connected](https://github.com/ganeshsp1/Flutter_Bluetooth_PC_Control/blob/master/screenshots/App_connected.jpg)
