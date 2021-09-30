import Foundation
import XcKit

extension Xcode {

    var url: URL {
        .init(fileURLWithPath: path, isDirectory: true)
    }
}
