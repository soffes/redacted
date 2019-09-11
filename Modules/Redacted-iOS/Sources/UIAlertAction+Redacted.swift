import UIKit

extension UIAlertAction {
	static let ok = UIAlertAction(title: LocalizedString.ok.string, style: .cancel)

	static let cancel = UIAlertAction(title: LocalizedString.cancel.string, style: .cancel)

	static let openSettings = UIAlertAction(title: LocalizedString.openSettingsButton.string, style: .default) { _ in
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

		UIApplication.shared.open(url)
	}
}
