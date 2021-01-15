//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

private let logger = Cornucopia.Core.Logger(category: "Cache")

public protocol _CornucopiaCoreUrlCache {

    typealias DataCompletionHandler = (Data?) -> ()

    func loadDataFor(url: URL, then: @escaping(DataCompletionHandler))

}

public extension Cornucopia.Core {

    typealias UrlCache = _CornucopiaCoreUrlCache

    /// A simple cache for data gathered using a HTTP GET call
    class Cache: UrlCache {

        var memoryCache = ThreadSafeDictionary<String, Data>()
        let name: String
        let path: String
        let urlSession: URLSession = URLSession(configuration: URLSessionConfiguration.ephemeral)

        public func loadDataFor(url: URL, then: @escaping (DataCompletionHandler)) {
            let urlRequest = URLRequest(url: url)
            self.loadDataFor(urlRequest: urlRequest, then: then)
        }

        /// Loads the data for the specified `URLRequest` and calls the completion handler with the data unless all cache levels fail.
        /// The completion handler will be called in a background thread context.
        public func loadDataFor(urlRequest: URLRequest, then: @escaping (DataCompletionHandler)) {

            print("urlRequest: \(urlRequest)")

            DispatchQueue.global().async {

                let url = urlRequest.url!
                let md5 = url.absoluteString.CC_md5
                if let data = self.memoryCache[md5] {
                    logger.debug("Memory HIT for \(url)")
                    then(data)
                    return
                }
                logger.debug("Memory MISS \(url)")
                let pathInCache = self.path + "/\(md5)"
                let urlInCache = URL(fileURLWithPath: pathInCache)
                if FileManager.default.fileExists(atPath: pathInCache) {
                    logger.debug("Disk HIT for \(url)")
                    do {
                        let data = try Data(contentsOf: urlInCache, options: .alwaysMapped)
                        then(data)
                        self.memoryCache[md5] = data
                        return
                    } catch {
                        logger.error("Can't load \(pathInCache): \(error)")
                    }
                }
                logger.debug("Disk MISS for \(url)")
                let task = self.urlSession.dataTask(with: urlRequest) { data, urlResponse, error in
                    guard error == nil else {
                        logger.notice("Network MISS for \(url): \(error!)")
                        then(nil)
                        return
                    }
                    let httpUrlResponse = urlResponse as! HTTPURLResponse
                    guard 199...299 ~= httpUrlResponse.statusCode else {
                        logger.notice("Network MISS for \(url): \(httpUrlResponse.statusCode)")
                        then(nil)
                        return
                    }
                    guard let data = data, data.count > 0 else {
                        logger.notice("Network MISS (0 bytes received) for \(url)")
                        then(nil)
                        return
                    }
                    logger.debug("Network HIT for \(url)")
                    then(data)
                    do {
                        try data.write(to: urlInCache, options: .atomic)
                    } catch {
                        logger.error("Can't write to \(urlInCache): \(error)")
                    }
                    self.memoryCache[md5] = data
                }
                task.resume()
            }
        }

        public init(name: String) {
            self.name = name
            self.path = FileManager.CC_pathInCachesDirectory(suffix: "Cornucopia.Core.Cache/\(name)/")
            do {
                try FileManager.default.createDirectory(atPath: self.path, withIntermediateDirectories: true)
                logger.info("Created directory for cache \(self.name) at \(self.path)")
            } catch {
                logger.error("Can't create directory \(self.path): \(error)")
            }
        }

    }

}
