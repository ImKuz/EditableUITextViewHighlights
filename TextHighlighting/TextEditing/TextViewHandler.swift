import UIKit

protocol TextViewHandler: UITextViewDelegate {

    var textView: UITextView { get }
    var onURLInteraction: ((URL) -> Void)? { get set }
}

final class TextViewHandlerImpl: NSObject, TextViewHandler {

    let textView: UITextView
    private var font = UIFont.systemFont(ofSize: 17)
    private var editedRange: NSRange?

    var onURLInteraction: ((URL) -> Void)?

    init(textView: UITextView) {
        self.textView = textView
        super.init()
        textView.delegate = self
    }

    private func processText(_ text: NSAttributedString, at range: NSRange) -> NSAttributedString {
        var string = NSMutableAttributedString(attributedString: text)
        string.addAttribute(.font, value: font, range: range)
        string.removeAttribute(.link, range: range)

        matchEmails(&string, range: range)
        matchPhones(&string, range: range)
        matchLinks(&string, range: range)

        return string
    }

    private func findSegmentEdges(_ attributedString: NSAttributedString, at range: NSRange) -> NSRange? {
        let string = attributedString.string
        guard range.lowerBound >= 0 && range.upperBound <= string.count else {
            return nil
        }

        let lowerIndex = string.index(string.startIndex, offsetBy: range.lowerBound)
        let upperIndex = string.index(string.startIndex, offsetBy: range.upperBound)

        let beforeSubstring = string.prefix(upTo: lowerIndex)
        let beforeWhitespaceIndex = beforeSubstring.lastIndex(of: " ")
        let beforeEdge: String.Index

        if let beforeWhitespaceIndex = beforeWhitespaceIndex {
            beforeEdge = beforeSubstring.index(after: beforeWhitespaceIndex)
        } else {
            beforeEdge = string.startIndex
        }

        let afterSubstring = string.suffix(from: upperIndex)
        let afterWhitespaceIndex = afterSubstring.firstIndex(of: " ")
        let afterEdge: String.Index

        if let afterWhitespaceIndex = afterWhitespaceIndex {
            afterEdge = afterSubstring.index(after: afterWhitespaceIndex)
        } else {
            afterEdge = string.endIndex
        }

        return NSRange(beforeEdge..<afterEdge, in: string)
    }
}

// MARK: - RegExp

private extension TextViewHandlerImpl {

    func matchEmails(_ text: inout NSMutableAttributedString, range: NSRange) {
        matchPattern(
            RegExpPattern.email,
            in: &text,
            apply: [.link: "mailto:"],
            range: range
        )
    }

    func matchPhones(_ text: inout NSMutableAttributedString, range: NSRange) {
        matchPattern(
            RegExpPattern.phone,
            in: &text,
            apply: [.link: "tel:"],
            range: range
        )
    }

    func matchLinks(_ text: inout NSMutableAttributedString, range: NSRange) {
        guard let regExp = try? NSRegularExpression(pattern: RegExpPattern.links) else {
            return
        }

        for match in regExp.matches(
            in: text.string,
            options: .withoutAnchoringBounds,
            range: range
        ) {
            let attributedSubstring = text.attributedSubstring(from: match.range)
            if let url = URL(string: attributedSubstring.string) {
                text.addAttributes([.link: url], range: match.range)
            }
        }
    }

    func matchPattern(
        _ pattern: String,
        in text: inout NSMutableAttributedString,
        apply attributes: [NSAttributedString.Key: Any],
        range: NSRange
    ) { 
        guard let regExp = try? NSRegularExpression(pattern: pattern) else {
            return
        }

        for match in regExp.matches(
            in: text.string,
            options: .withoutAnchoringBounds,
            range: range
        ) {
            text.addAttributes(attributes, range: match.range)
        }
    }
}

// MARK: - UITextViewDelegate

extension TextViewHandlerImpl: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        let outputText = NSMutableAttributedString(attributedString: textView.attributedText)
        if let rangeToCheck = editedRange, let edgedRange = findSegmentEdges(outputText, at: rangeToCheck) {
            textView.attributedText = processText(outputText, at: edgedRange)
        }
    }

    func textView(
        _ textView: UITextView,
        shouldChangeTextIn range: NSRange,
        replacementText text: String
    ) -> Bool {
        let editedLenght: Int = {
            let value = text.count - range.length
            if value > 0 {
                return value
            } else {
                return 0
            }
        }()

        editedRange = NSRange(
            location: range.location,
            length: editedLenght
        )

        return true
    }

    func textView(
        _ textView: UITextView,
        shouldInteractWith URL: URL,
        in characterRange: NSRange,
        interaction: UITextItemInteraction
    ) -> Bool {
        onURLInteraction?(URL)
        
        return false
    }
}
