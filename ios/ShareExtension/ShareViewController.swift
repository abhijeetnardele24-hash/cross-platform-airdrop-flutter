//
//  ShareViewController.swift
//  ShareExtension
//
//  Created on 2024
//

import UIKit
import Social
import MobileCoreServices
import UniformTypeIdentifiers

class ShareViewController: UIViewController {

    private var sharedItems: [Any] = []
    private var sharedFiles: [URL] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Get the shared items
        if let extensionItems = extensionContext?.inputItems as? [NSExtensionItem] {
            for item in extensionItems {
                if let attachments = item.attachments {
                    for attachment in attachments {
                        handleAttachment(attachment)
                    }
                }
            }
        }

        // Process the shared files
        processSharedFiles()
    }

    private func handleAttachment(_ attachment: NSItemProvider) {
        // Handle URLs
        if attachment.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
            attachment.loadItem(forTypeIdentifier: UTType.url.identifier, options: nil) { [weak self] (url, error) in
                if let url = url as? URL {
                    self?.sharedItems.append(url)
                }
            }
        }

        // Handle text
        if attachment.hasItemConformingToTypeIdentifier(UTType.text.identifier) {
            attachment.loadItem(forTypeIdentifier: UTType.text.identifier, options: nil) { [weak self] (text, error) in
                if let text = text as? String {
                    self?.sharedItems.append(text)
                }
            }
        }

        // Handle images
        if attachment.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
            attachment.loadItem(forTypeIdentifier: UTType.image.identifier, options: nil) { [weak self] (imageData, error) in
                if let imageData = imageData as? Data {
                    self?.saveDataToTempFile(imageData, extension: "jpg")
                } else if let imageURL = imageData as? URL {
                    self?.sharedFiles.append(imageURL)
                }
            }
        }

        // Handle videos
        if attachment.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
            attachment.loadItem(forTypeIdentifier: UTType.movie.identifier, options: nil) { [weak self] (videoData, error) in
                if let videoData = videoData as? Data {
                    self?.saveDataToTempFile(videoData, extension: "mp4")
                } else if let videoURL = videoData as? URL {
                    self?.sharedFiles.append(videoURL)
                }
            }
        }

        // Handle generic files
        if attachment.hasItemConformingToTypeIdentifier(UTType.data.identifier) {
            attachment.loadItem(forTypeIdentifier: UTType.data.identifier, options: nil) { [weak self] (fileData, error) in
                if let fileData = fileData as? Data {
                    self?.saveDataToTempFile(fileData, extension: "dat")
                } else if let fileURL = fileData as? URL {
                    self?.sharedFiles.append(fileURL)
                }
            }
        }
    }

    private func saveDataToTempFile(_ data: Data, extension: String) {
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = UUID().uuidString + "." + extension
        let fileURL = tempDir.appendingPathComponent(fileName)

        do {
            try data.write(to: fileURL)
            sharedFiles.append(fileURL)
        } catch {
            print("Error saving temp file: \(error)")
        }
    }

    private func processSharedFiles() {
        // Prepare data to send to main app
        var sharedData: [String: Any] = [:]
        sharedData["files"] = sharedFiles.map { $0.absoluteString }
        sharedData["items"] = sharedItems.map { String(describing: $0) }

        // Send data to main app via UserDefaults (shared container)
        let sharedDefaults = UserDefaults(suiteName: "group.com.crossplatformairdrop.shared")
        sharedDefaults?.set(sharedData, forKey: "sharedItems")
        sharedDefaults?.synchronize()

        // Open main app
        if let url = URL(string: "crossplatformairdrop://share") {
            extensionContext?.open(url, completionHandler: { success in
                self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
            })
        } else {
            // Fallback: just complete the extension
            extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
        }
    }
}
