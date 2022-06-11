#if canImport(Combine)
import Combine
#endif
import Dispatch
import Foundation

public final class Xc {

    public class var `default`: Self {
        return unsafeDowncast(_defaultXcInstance, to: self)
    }
    private let _query: NSMetadataQuery = .init()
    private let _dsema: DispatchSemaphore = .init(value: 0)
    private let _operationQueue: OperationQueue
    private lazy var _observer: _Observer = .init(owner: self)

#if canImport(Combine)
    private var _subscribers: Set<AnyCancellable> = .init(minimumCapacity: 1)
    private var _xcodesPublisher: AnyPublisher<Set<Xcode>, Never>?
#endif

    private var _xcodes: Set<Xcode> = .init()

    public var xcodes: Set<Xcode> {
        self._xcodes
    }

    public init(operationQueue: OperationQueue = .init()) {
        self._operationQueue = .init()
        self._operationQueue.maxConcurrentOperationCount = 1
        let query = self._query
        query.operationQueue = operationQueue
        let predicateString =
            String(format: "(%@ == %@) && (%@ == %@)",
                   NSMetadataItemContentTypeKey,
                   "'com.apple.application-bundle'",
                   NSMetadataItemCFBundleIdentifierKey,
                   "'com.apple.dt.Xcode'")
        query.predicate = .init(fromMetadataQueryString: predicateString)
        query.valueListAttributes = [NSMetadataItemPathKey]
    }

    public func reload(completionHandler: @escaping (Set<Xcode>) -> Void) {
        let query = self._query
        if !query.isStarted {
            _defaultNotificationCenter.addObserver(
                self._observer,
                selector: #selector(_Observer.metadataQueryDidFinishGathering(_:)),
                name: .NSMetadataQueryDidFinishGathering,
                object: nil)
            query.operationQueue.unsafelyUnwrapped.addOperation {
                self._query.start()
            }
            self._operationQueue.addOperation {
                self._dsema.wait()
            }
        }
        self._operationQueue.addOperation {
            completionHandler(self._xcodes)
        }
    }

#if swift(>=5.5) && canImport(_Concurrency)
    @discardableResult
    public func reload() async -> Set<Xcode> {
        await withCheckedContinuation {
            (continuation) in
            self.reload {
                continuation.resume(returning: $0)
            }
        }
    }
#endif

#if canImport(Combine)
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
                    $0(.success(self.xcodes))
                }
                .share()
            xcodesPublisher =
                futurePublisher
                .eraseToAnyPublisher()
            self._xcodesPublisher = xcodesPublisher
        }
        return xcodesPublisher
    }
#endif

    deinit {
        _defaultNotificationCenter.removeObserver(
            self._observer,
            name: nil,
            object: nil)
        self._query.stop()
#if canImport(Combine)
        self._subscribers.removeAll()
        self._xcodesPublisher = nil
#endif
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
                        if var _version = Xcode.Version(string: unsafeDowncast(_version, to: NSString.self) as String) {
                            if _version.patch == nil {
                                _version.patch = 0
                            }
                            version = _version
                        }
                        else {
                            continue
                        }
                    }
                    else {
                        continue
                    }
                    let fsName = unsafeDowncast(attributes[NSMetadataItemFSNameKey]!, to: NSString.self) as String
                    let path = unsafeDowncast(attributes[NSMetadataItemPathKey]!, to: NSString.self) as String
                    if let xcode = Xcode(name: fsName, path: path, version: version) {
                        xcodes.update(with: xcode)
                    }
                }
                self?.owner._xcodes = xcodes
                dsema.signal()
            }
        }
    }
}

private let _defaultNotificationCenter = NotificationCenter.default
