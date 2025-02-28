import SwiftUI
// test
struct ContentView: View {
    @State private var droppedFileURL: URL?
    @State private var outputFolder: URL? = FileManager.default.urls(for: .moviesDirectory, in: .userDomainMask).first
    @State private var outputFileName: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Drop your video file here")
                .font(.headline)
            
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(Color.blue, lineWidth: 2)
                .frame(width: 300, height: 150)
                .overlay(
                    Text(droppedFileURL != nil ? "File: \(droppedFileURL!.lastPathComponent)" : "Drag & Drop Here")
                        .foregroundColor(.gray)
                )
                .onDrop(of: ["public.file-url"], isTargeted: nil, perform: handleFileDrop)
            
            if droppedFileURL != nil {
                VStack(spacing: 10) {
                    TextField("Output File Name", text: $outputFileName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    HStack {
                        Button("Select Output Folder") {
                            selectOutputFolder()
                        }
                        if let folder = outputFolder {
                            Text("Folder: \(folder.path)")
                                .lineLimit(1)
                                .truncationMode(.middle)
                                .font(.footnote)
                        }
                    }
                    
                    Button("Clean Metadata") {
                        processVideo(url: droppedFileURL!)
                    }
                    .padding()
                }
            }
        }
        .frame(width: 500, height: 400)
    }
    
    // Detect drag and drop files
    private func handleFileDrop(_ providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first else { return false }
        provider.loadItem(forTypeIdentifier: "public.file-url", options: nil) { item, error in
            DispatchQueue.main.async {
                if let data = item as? Data,
                   let url = URL(dataRepresentation: data, relativeTo: nil) {
                    self.droppedFileURL = url
                    // Set the default output file name: Cleaned _ + original file name
                    if self.outputFileName.isEmpty {
                        self.outputFileName = "Cleaned_" + url.lastPathComponent
                    }
                }
            }
        }
        return true
    }
    
    // Let the user select the output folder
    private func selectOutputFolder() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.begin { response in
            if response == .OK {
                self.outputFolder = panel.urls.first
            }
        }
    }
    
    // Copy ffmpeg packaged in the Bundle to the Application Support directory and give execution permissions
    private func copyFFmpegToAppSupportDirectory() -> URL? {
        guard let ffmpegBundleURL = Bundle.main.url(forResource: "ffmpeg", withExtension: nil) else {
            print("FFmpeg not found in bundle.")
            return nil
        }
        
        let fileManager = FileManager.default
        guard let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            print("Application Support directory not found.")
            return nil
        }
        
        do {
            try fileManager.createDirectory(at: appSupport, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Failed to create Application Support directory: \(error)")
            return nil
        }
        
        let ffmpegAppSupportURL = appSupport.appendingPathComponent("ffmpeg")
        
        do {
            if fileManager.fileExists(atPath: ffmpegAppSupportURL.path) {
                try fileManager.removeItem(at: ffmpegAppSupportURL)
            }
            try fileManager.copyItem(at: ffmpegBundleURL, to: ffmpegAppSupportURL)
            let attributes = [FileAttributeKey.posixPermissions: 0o755]
            try fileManager.setAttributes(attributes, ofItemAtPath: ffmpegAppSupportURL.path)
            print("FFmpeg copied to \(ffmpegAppSupportURL.path)")
            return ffmpegAppSupportURL
        } catch {
            print("Error copying ffmpeg: \(error)")
            return nil
        }
    }
    
    // Call ffmpeg to process video
    private func processVideo(url: URL) {
        guard let ffmpegExecURL = copyFFmpegToAppSupportDirectory() else {
            print("Failed to prepare ffmpeg.")
            return
        }
        guard let folder = outputFolder else {
            print("No output folder selected.")
            return
        }
        
        let outputURL = folder.appendingPathComponent(outputFileName)
        print("Using FFmpeg at: \(ffmpegExecURL.path)")
        print("Saving cleaned video to: \(outputURL.path)")
        
        let process = Process()
        process.executableURL = ffmpegExecURL
        process.arguments = ["-y", "-i", url.path, "-map_metadata", "-1", "-c:v", "copy", "-c:a", "copy", outputURL.path]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try process.run()
                process.waitUntilExit()
            } catch {
                print("Error running ffmpeg: \(error)")
            }
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                print("FFmpeg Output: \n\(output)")
            }
            
            DispatchQueue.main.async {
                let alert = NSAlert()
                alert.messageText = "Processing Complete"
                alert.informativeText = "Cleaned video saved to:\n\(outputURL.path)"
                alert.runModal()
            }
        }
    }
}

#Preview {
    ContentView()
}
