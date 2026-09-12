[DoraNav - ഡോറയുടെ വഴികാട്ടി]
Basic Details
Team Name: [കാറ്റാടി]

Team Members

Team Lead: [Minha Mariyam C P] - [College Of Engineering,Chengannur]
Member 2: [Muhammed Sufiyan S ] - [College Of Engineering,Chengannur]

Project Description

DoraNav is Dora’s personal map, because even Dora needs GPS when the entire world is trying to stop her.  It finds safe routes and avoids broken bridges, blocked roads, crocodiles, and Kurunari. In short: “Find the way. Stay away. And PLEASE don’t get Swipered.” 

The Problem

  Dora wants to go somewhere, but her world is full of unexpected problems like blocked roads, broken bridges, crocodiles, and Kurunari. So the biggest problem is: How can Dora reach her destination without turning every simple journey into a dangerous adventure?.

The Solution 

We created DoraNav, Dora’s personal navigation app that checks the route and avoids dangerous or blocked areas. It finds a safer alternative route using the A* algorithm, so Dora can reach her destination without getting Swipered, eaten, or stuck.
 
Technical Details
Technologies/Components Used

For Software:

Language-Dart
Framework-Flutter
Libraries-pubspec.yaml
Tools used-Visual Studio Code

For Software:

Installation

DoraNav is a Flutter-based Android application. A new user can follow the steps below to install and run the project.

Requirements

Before installing DoraNav, make sure the computer has:

Windows, macOS, or Linux

Flutter SDK

Android Studio

Android SDK

Visual Studio Code (recommended)

An Android phone or Android Emulator

Note: No special hardware is required to use DoraNav.

1. Install Flutter

Download and install Flutter from:

https://docs.flutter.dev/get-started/install

After installing Flutter, open Command Prompt or Terminal and run:

flutter doctor

This checks whether Flutter and the required development tools are installed correctly.

2. Install Android Studio

Download Android Studio from:

https://developer.android.com/studio

Make sure the following Android components are installed:

Android SDK

Android SDK Platform-Tools

Android SDK Build-Tools

Android SDK Command-line Tools

Android Emulator

After installation, check the Android setup using:

flutter doctor

3. Install Visual Studio Code

Download VS Code from:

https://code.visualstudio.com/

After installing VS Code, install these extensions:

Flutter

Dart

4. Download DoraNav

Download or clone the DoraNav project from the repository.

Using Git:

git clone <YOUR-GITHUB-REPOSITORY-LINK>

Then enter the project folder:

cd doranav

Alternatively, download the project as a ZIP file, extract it, and open the extracted doranav folder in Visual Studio Code.

5. Install Project Dependencies

Open a terminal inside the doranav project folder and run:

flutter pub get

This reads the pubspec.yaml file and downloads the required Flutter packages.

6. Check the Android Device

DoraNav needs an Android device or emulator.

Option A - Android Phone

Connect an Android phone to the computer using a USB cable and enable USB Debugging in Developer Options.

Then run:

flutter devices

The connected phone should appear in the list.

Option B - Android Emulator

Open Android Studio, go to:

Device Manager → Start an Android Emulator

Then check the device using:

flutter devices

Run

Once the installation is complete and an Android device or emulator is available, follow these steps.

1. Open the Project

Open the doranav folder in Visual Studio Code.

Open:

Terminal → New Terminal

Make sure the terminal is inside the DoraNav project folder.

2. Get Dependencies

Run:

flutter pub get

3. Check for Errors

Run:

flutter analyze

This checks the Dart and Flutter code for possible problems.

4. Run DoraNav

Start the Android phone or emulator and run:

flutter run

Flutter will build the application and install it on the selected Android device.

After the build is complete, DoraNav will open on the device. 🗺️📱

5. Run on a Specific Device

If more than one device is connected, first run:

flutter devices

Then use the required device ID:

flutter run -d <device-id>

For example:

flutter run -d emulator-5554

Quick Start

If Flutter and Android Studio are already installed, the basic process is:

git clone <YOUR-GITHUB-REPOSITORY-LINK>
cd doranav
flutter pub get
flutter devices
flutter run
Project Documentation
For Software:

Screenshots (Add at least 3)
![Screenshot1](Add screenshot 1 here with proper name) Add caption explaining what this shows

![Screenshot2](Add screenshot 2 here with proper name) Add caption explaining what this shows

![Screenshot3](Add screenshot 3 here with proper name) Add caption explaining what this shows

Team Contributions
Minha Mariyam C P -  Flutter app development,Documentation and presentation
Muhammed Sufiyan S - UI/UX design,Map interface design