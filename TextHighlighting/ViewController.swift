import UIKit

class ViewController: UIViewController {

    private lazy var rootView = View()
    private var textViewHandler: TextViewHandler?
    private var rangeToCheck: NSRange?

    override func loadView() {
        view = rootView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    private func setup() {
        textViewHandler = TextViewHandlerImpl(textView: rootView.textView)

        textViewHandler?.onURLInteraction = { url in
            print("Do smth with URL: \(url)")
        }

        rootView.textView.becomeFirstResponder()
    }
}
