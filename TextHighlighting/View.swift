import UIKit
import SnapKit

final class View: UIView {

    let textView: UITextView = {
        let textView = UITextView()

        textView.linkTextAttributes = Constants.linkTextAttributes
        textView.typingAttributes = Constants.typingAttributes
        textView.dataDetectorTypes = UIDataDetectorTypes.all
        textView.layer.cornerRadius = 8
        textView.autocorrectionType = .no

        return textView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        backgroundColor = .lightGray
        
        addSubview(textView)
        textView.backgroundColor = .white
        textView.snp.makeConstraints { make in
            make.leading.trailing
                .equalToSuperview()
            make.top
                .equalTo(safeAreaLayoutGuide.snp.top)
                .offset(Constants.verticalSpacing)
            make.bottom
                .equalTo(safeAreaLayoutGuide.snp.bottom)
                .inset(Constants.verticalSpacing)
        }
    }
}

private extension View {

    struct Constants {
        static let horizontalSpacing: CGFloat = 32
        static let verticalSpacing: CGFloat = 16

        static let linkTextAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.blue,
            .underlineStyle: NSNumber(value: 0)
        ]

        static let typingAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.black,
        ]
    }
}
