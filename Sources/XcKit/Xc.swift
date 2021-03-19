import Combine
import Foundation

public final class Xc {

    public class var `default`: Self {
        return unsafeDowncast(_defaultXcInstance, to: self)
    }

    private let _query = NSMetadataQuery()
    private let _dsema = DispatchSemaphore(value: 0)
    private var _subscribers = Set<AnyCancellable>(minimumCapacity: 1)
    private var _xcodesPublisher: AnyPublisher<Set<Xcode>, Never>?

    private var _xcodes = Set<Xcode>()

    public var xcodes: Set<Xcode> {
        return self._xcodes
    }

    public init() {
        self._query.operationQueue = OperationQueue()
        let predicateString =
            String(format: "(%@ == %@) && (%@ == %@)",
                   NSMetadataItemContentTypeKey,
                   "'com.apple.application-bundle'",
                   NSMetadataItemCFBundleIdentifierKey,
                   "'com.apple.dt.Xcode'")
        self._query.predicate = NSPredicate(fromMetadataQueryString: predicateString)
        self._query.valueListAttributes = [NSMetadataItemPathKey]
    }

    public convenience init(reload: Bool, operationQueue: OperationQueue? = nil) {
        self.init()
        if let operationQueue = operationQueue {
            self._query.operationQueue = operationQueue
        }
        if reload {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(_metadataQueryDidFinishGathering(_:)),
                name: .NSMetadataQueryDidFinishGathering, object: nil)
            self._query.operationQueue!.addOperation {
                self._query.start()
            }
            self._dsema.wait()
        }
    }

    public convenience init(operationQueue: OperationQueue) {
        self.init()
        self._query.operationQueue = operationQueue
    }

    public func reload() -> AnyPublisher<Set<Xcode>, Never> {
        if self._subscribers.isEmpty {
            let metadataQueryDidFinishGatheringNotificationPublisher =
                NotificationCenter.default.publisher(for: .NSMetadataQueryDidFinishGathering)
            metadataQueryDidFinishGatheringNotificationPublisher
            .sink(receiveValue: self._metadataQueryDidFinishGathering(_:))
            .store(in: &self._subscribers)
        }
        let xcodesPublisher: AnyPublisher<Set<Xcode>, Never>
        if let _xcodesPublisher = self._xcodesPublisher {
            xcodesPublisher = _xcodesPublisher
        }
        else {
            let futurePublisher =
                Future<Set<Xcode>, Never> {
                    (promise) in
                    if !self._query.isStarted {
                        self._query.operationQueue!.addOperation {
                            self._query.start()
                        }
                    }
                    defer {
                        self._subscribers.removeAll(keepingCapacity: true)
                        self._xcodesPublisher = nil
                    }
                    self._dsema.wait()
                    promise(.success(self.xcodes))
                }
                .share()
            xcodesPublisher =
                futurePublisher
                .eraseToAnyPublisher()
            self._xcodesPublisher = xcodesPublisher
        }
        return xcodesPublisher
    }

    @objc
    private func _metadataQueryDidFinishGathering(_ notification: Notification) {
        NotificationCenter.default.removeObserver(self, name: notification.name, object: nil)
        self._query.operationQueue!.addOperation {
            var xcodes = Set<Xcode>()
            for result in self._query.results {
                guard let item = result as? NSMetadataItem
                else {
                    continue
                }
                let _kMDItemAppStoreIsAppleSigned = "kMDItemAppStoreIsAppleSigned"
                let attributes = (item.values(forAttributes: [_kMDItemAppStoreIsAppleSigned, NSMetadataItemFSNameKey, NSMetadataItemVersionKey, NSMetadataItemPathKey]) ?? [:]).mapValues({$0 as AnyObject})
                let isAppleSigned = unsafeDowncast(attributes[_kMDItemAppStoreIsAppleSigned]!, to: NSNumber.self).boolValue
                guard isAppleSigned
                else {
                    continue
                }
                let fsName = unsafeDowncast(attributes[NSMetadataItemFSNameKey]!, to: NSString.self) as String
                let path = unsafeDowncast(attributes[NSMetadataItemPathKey]!, to: NSString.self) as String
                let version = Xcode.Version(string: unsafeDowncast(attributes[NSMetadataItemVersionKey]!, to: NSString.self) as String)
                xcodes.insert(Xcode(name: fsName, path: path, version: version))
            }
            self._xcodes = xcodes
            self._dsema.signal()
        }
    }

    deinit {
        self._query.stop()
        NotificationCenter.default.removeObserver(self, name: nil, object: nil)
        self._subscribers.forEach({$0.cancel()})
        self._xcodesPublisher = nil
    }
}

private let _defaultXcInstance = Xc(reload: true)
