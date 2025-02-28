# 🎥 Video Metadata Cleaner

**Video Metadata Cleaner** is a lightweight macOS application designed to remove metadata from video files. It provides a simple drag-and-drop interface, allowing users to clean video files effortlessly while preserving the original quality.

## ✨ Features
- 🖥 **Native macOS App** – Built with SwiftUI, providing a smooth and intuitive user experience.
- 🛠 **Built-in FFmpeg** – No need to install FFmpeg separately; the app includes it for seamless processing.
- 📂 **Drag-and-Drop Support** – Simply drag your video file into the app to clean its metadata.
- 📝 **Custom Output Naming & Folder Selection** – Choose where to save the cleaned video and set a custom filename.
- 🚀 **Fast & Efficient** – Removes metadata without re-encoding, ensuring lossless video quality.

## 📦 Supported Video Formats
Since **FFmpeg** is used for processing, the app supports a wide range of video formats, including:
- **MP4, MKV, AVI, MOV, WEBM, FLV, WMV, TS, MPEG, and more!**
- It works with **both video and audio files**, supporting various codecs.

## 🔧 How It Works
1. **Drag and drop** your video file into the application.
2. (Optional) Set a **custom output filename** and select an **output folder**.
3. Click **"Clean Metadata"**, and the app will process the file using FFmpeg.
4. The cleaned file will be saved in the **selected output folder**.

## 📜 Installation
To download the latest version:
1. Go to the **[Releases](https://github.com/yourusername/Video-Metadata-Cleaner/releases)** page.
2. Download the `.zip` file containing the app.
3. Extract and move the **Video Metadata Cleaner.app** to your Applications folder.
4. Run the app!

## 🏗️ Built With
- **SwiftUI** – Modern UI framework for macOS apps.
- **FFmpeg** – The leading multimedia processing tool for video/audio manipulation.
- **Xcode** – Developed using Xcode on macOS.

## 🛠 Technical Details
The app bundles **FFmpeg** within the macOS application and copies it to the user's `Application Support` directory to allow execution. It then uses `Process()` to run FFmpeg commands for removing metadata.

## 🔮 Future Improvements
- 🎨 **Enhancing the UI for a more polished look.**
- 🖼 **Adding a custom app icon.**

## 📄 License
This project is licensed under the **MIT License** – see the [LICENSE](LICENSE) file for details.
