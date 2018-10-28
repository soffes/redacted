import AppKit
import RedactedKit

final class AboutViewController: NSViewController {

	// MARK: - Properties

	@IBOutlet var versionLabel: NSTextField!
	@IBOutlet var creditsLabel: NSTextField!
	@IBOutlet var copyrightLabel: NSTextField!


	// MARK: - NSViewController

	override func viewDidLoad() {
		super.viewDidLoad()

		let bundle = Bundle.main
		let info = bundle.localizedInfoDictionary ?? bundle.infoDictionary!
		let shortVersion = info["CFBundleShortVersionString"] as! String
		let version = info["CFBundleVersion"] as! String

		versionLabel.stringValue = String(format: string("VERSION_FORMAT"), "\(shortVersion) (\(version))")
		creditsLabel.stringValue = string("CREDITS")
        copyrightLabel.stringValue = info["NSHumanReadableCopyright"] as? String ?? ""
	}
}
