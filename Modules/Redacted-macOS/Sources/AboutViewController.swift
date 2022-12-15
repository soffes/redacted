import AppKit
import RedactedKit

final class AboutViewController: NSViewController {

	// MARK: - Properties

	@IBOutlet private var versionLabel: NSTextField!
	@IBOutlet private var copyrightLabel: NSTextField!

	// MARK: - NSViewController

	override func viewDidLoad() {
		super.viewDidLoad()

		let bundle = Bundle.main
		let info = bundle.localizedInfoDictionary ?? bundle.infoDictionary!
		let shortVersion = info["CFBundleShortVersionString"] as? String ?? "0"
		let version = info["CFBundleVersion"] as? String ?? "0"

		versionLabel.stringValue = String(format: string("VERSION_FORMAT"), "\(shortVersion) (\(version))")
        copyrightLabel.stringValue = info["NSHumanReadableCopyright"] as? String ?? ""
	}
}
