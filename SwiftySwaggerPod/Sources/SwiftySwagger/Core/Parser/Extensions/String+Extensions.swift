import Foundation

extension String {

    // MARK: - Instance Methods

    internal func suffix(from index: Int) -> String {
        return String(suffix(from: self.index(startIndex, offsetBy: max(0, min(index, count)))))
    }

		public var firstUppercased: String {
			prefix(1).uppercased().appending(dropFirst())
		}

		public var firstLowercased: String {
			prefix(1).lowercased().appending(dropFirst())
		}

		public var firstCapitalized: String {
			prefix(1).capitalized.appending(dropFirst())
		}

		public var camelized: String {
			components(separatedBy: CharacterSet.alphanumerics.inverted)
				.map { $0.firstUppercased }
				.joined()
		}
	}
