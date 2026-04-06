import SwiftUI
import UIKit
import AVFoundation

/**
 CameraCapture provides a SwiftUI interface for capturing photos.
 Uses UIImagePickerController under the hood.
 */
struct CameraCapture: UIViewControllerRepresentable {
    var onCapture: (UIImage) -> Void
    var onCancel: () -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.cameraFlashMode = .auto
        picker.allowsEditing = false
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onCapture: onCapture, onCancel: onCancel)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var onCapture: (UIImage) -> Void
        var onCancel: () -> Void

        init(onCapture: @escaping (UIImage) -> Void, onCancel: @escaping () -> Void) {
            self.onCapture = onCapture
            self.onCancel = onCancel
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            if let image = info[.originalImage] as? UIImage {
                onCapture(image)
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            onCancel()
            picker.dismiss(animated: true)
        }
    }
}

/**
 PhotoGalleryPicker allows selecting existing photos from the device.
 Uses PHPickerViewController for modern iOS 14+ photo selection.
 */
struct PhotoGalleryPicker: UIViewControllerRepresentable {
    var onSelect: (UIImage) -> Void
    var onCancel: () -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.mediaTypes = ["public.image"]
        picker.allowsEditing = false
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onSelect: onSelect, onCancel: onCancel)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var onSelect: (UIImage) -> Void
        var onCancel: () -> Void

        init(onSelect: @escaping (UIImage) -> Void, onCancel: @escaping () -> Void) {
            self.onSelect = onSelect
            self.onCancel = onCancel
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            if let image = info[.originalImage] as? UIImage {
                onSelect(image)
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            onCancel()
            picker.dismiss(animated: true)
        }
    }
}

/**
 CameraPermissionManager handles camera access permissions.
 */
@MainActor
class CameraPermissionManager: NSObject {
    static let shared = CameraPermissionManager()

    func requestCameraPermission() async -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .video)

        switch status {
        case .authorized:
            return true
        case .notDetermined:
            return await AVCaptureDevice.requestAccess(for: .video)
        case .denied, .restricted:
            return false
        @unknown default:
            return false
        }
    }

    func checkCameraAvailable() -> Bool {
        UIImagePickerController.isSourceTypeAvailable(.camera)
    }
}

#if DEBUG
struct CameraCapture_Previews: PreviewProvider {
    static var previews: some View {
        Text("Camera preview not available in simulator")
    }
}
#endif
