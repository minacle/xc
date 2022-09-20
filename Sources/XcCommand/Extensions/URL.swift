import Foundation

extension URL {

    func resourceValues(forKeys keys: Set<URLResourceKey>) -> URLResourceValues? {
        do {
            return .some(try resourceValues(forKeys: keys))
        }
        catch let error as NSError {
            NSLog("%@", error)
            return .none
        }
    }
}
