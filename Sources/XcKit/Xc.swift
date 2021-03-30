import Combine
import Foundation

public final class Xc {

    public class var `default`: Self {
        return unsafeDowncast(_defaultXcInstance, to: self)
    }

    private let _query = NSMetadataQuery()
    private let _dsema = DispatchSemaphore(value: 0)
    private lazy var _observer = _Observer(owner: self)
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
            _defaultNotificationCenter.addObserver(
                self._observer,
                selector: #selector(self._observer.metadataQueryDidFinishGathering(_:)),
                name: .NSMetadataQueryDidFinishGathering,
                object: nil)
            let query = self._query
            query.operationQueue.unsafelyUnwrapped.addOperation {
                query.start()
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
                _defaultNotificationCenter.publisher(for: .NSMetadataQueryDidFinishGathering)
            metadataQueryDidFinishGatheringNotificationPublisher
            .sink(receiveValue: self._observer.metadataQueryDidFinishGathering(_:))
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
                    let query = self._query
                    if !query.isStarted {
                        query.operationQueue.unsafelyUnwrapped.addOperation {
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

    deinit {
        _defaultNotificationCenter.removeObserver(
            self._observer,
            name: nil,
            object: nil)
        self._query.stop()
        self._subscribers.removeAll()
        self._xcodesPublisher = nil
    }
}

private let _defaultXcInstance = Xc(reload: true)

extension Xc {

    private final class _Observer {

        private unowned let owner: Xc

        fileprivate init(owner: Xc) {
            self.owner = owner
        }

        @objc
        fileprivate func metadataQueryDidFinishGathering(_ notification: Notification) {
            let query = self.owner._query
            guard query.isStarted && !query.isGathering
            else {
                return
            }
            query.stop()
            _defaultNotificationCenter.removeObserver(
                self,
                name: notification.name,
                object: nil)
            let dsema = self.owner._dsema
            query.operationQueue.unsafelyUnwrapped.addOperation {
                [weak self] in
                var xcodes = Set<Xcode>()
                for result in query.results {
                    guard let item = result as? NSMetadataItem
                    else {
                        continue
                    }
                    let _kMDItemAppStoreIsAppleSigned = "kMDItemAppStoreIsAppleSigned"
                    let attributes = (item.values(forAttributes: [_kMDItemAppStoreIsAppleSigned, NSMetadataItemFSNameKey, NSMetadataItemVersionKey, NSMetadataItemPathKey]) ?? [:]).mapValues({$0 as AnyObject})
                    if let _isAppleSigned = attributes[_kMDItemAppStoreIsAppleSigned] {
                        guard unsafeDowncast(_isAppleSigned, to: NSNumber.self).boolValue
                        else {
                            continue
                        }
                    }
                    else {
                        continue
                    }
                    var version: Xcode.Version
                    if let _version = attributes[NSMetadataItemVersionKey] {
                        version = .init(string: unsafeDowncast(_version, to: NSString.self) as String)
                        if version.patch == nil {
                            version.patch = 0
                        }
                    }
                    else {
                        continue
                    }
                    let fsName = unsafeDowncast(attributes[NSMetadataItemFSNameKey]!, to: NSString.self) as String
                    let path = unsafeDowncast(attributes[NSMetadataItemPathKey]!, to: NSString.self) as String
                    xcodes.update(with: Xcode(name: fsName, path: path, version: version))
                }
                self?.owner._xcodes = xcodes
                dsema.signal()
            }
        }
    }
}

private let _defaultNotificationCenter = NotificationCenter.default
