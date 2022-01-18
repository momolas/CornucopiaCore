//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

public extension Cornucopia.Core {

    /// A Logger.
    ///
    /// Alright, this might not be the most efficient one. Although os_log (or the more modern os.Logger) is preferred on Apple platforms,
    /// Xcode spoils this with its incredible amount of spam. Setting OS_ACTIVITY_MODE=disable not only mutes the spam, but _all_
    /// of the os_log (and os.Logger) output.
    ///
    /// Two environment variables control the behavior: `LOGLEVEL` and `LOGSINK`.
    /// For a debug build, the following rules apply:
    /// - The default LOGLEVEL is `.info`.
    /// - The default LOGSINK is `print`.
    /// If this is a release build:
    /// - The default LOGSINK is empty, i.e. nothing will be emitted.
    struct Logger {

        public static let dispatchQueue: DispatchQueue = .init(label: "dev.cornucopia.Logger", qos: .background)
        public static let includeDebug: Bool = ProcessInfo.processInfo.environment["LOGLEVEL"] == "DEBUG" || Self.includeTrace
        public static let includeTrace: Bool = ProcessInfo.processInfo.environment["LOGLEVEL"] == "TRACE"
        public static let destination: LogSink? = {

            #if DEBUG
            var sink: LogSink? = PrintLogger()
            #else
            var sink: LogSink? = nil
            #endif

#if os(watchOS) // no BSD sockets on WatchOS
            return PrintLogger()
#endif
            guard let logsink = ProcessInfo.processInfo.environment["LOGSINK"],
                  let sinkurl = URL(string: logsink),
                  let host = sinkurl.host else { return sink }
            switch sinkurl.scheme {
                case "udp.plain":
                    sink = UDPLogger(binary: false, listener: host, port: UInt16(sinkurl.port ?? 5515))
                case "udp":
                    sink = UDPLogger(binary: true, listener: host, port: UInt16(sinkurl.port ?? 5514))
                case "print":
                    sink = PrintLogger()
                default:
                    print("Can't parse LOGSINK url: \(logsink). Using default logger.")
            }
            return sink
        }()

        public typealias Level = Cornucopia.Core.LogLevel
        public let app: String
        public let subsystem: String
        public let category: String

        /// Create the logger with the given `subsystem` and `category`.
        public init(subsystem: String = "none", category: String = #fileID) {
            let category = category.hasSuffix(".swift") ? category.split(separator: "/").last!.replacingOccurrences(of: ".swift", with: "") : category
            self.app = Bundle.main.bundleIdentifier ?? ProcessInfo.processInfo.processName
            self.subsystem = subsystem
            self.category = category
        }

        @_transparent
        public func log(_ message: String, level: Level, sink: LogSink) {
            let entry = LogEntry(level: level, app: self.app, subsystem: self.subsystem, category: self.category, thread: Thread.current.CC_number, message: message)
            Self.dispatchQueue.async { sink.log(entry) }
        }

        /// Log a trace message. Trace messages are only processed, if the environment variable LOGLEVEL is TRACE
        @inlinable
        public func trace(_ message: @autoclosure ()->String ) {
            guard let sink = Self.destination, Self.includeTrace else { return }
            log(message(), level: .trace, sink: sink)
        }

        /// Log a debug message. Debug messages are only processed, if the environment variable LOGLEVEL is DEBUG or TRACE
        @inlinable
        public func debug(_ message: @autoclosure ()->String) {
            guard let sink = Self.destination, Self.includeDebug else { return }
            log(message(), level: .debug, sink: sink)
        }

        /// Log an info message.
        @inlinable
        public func info(_ message: @autoclosure ()->String) {
            guard let sink = Self.destination else { return }
            log(message(), level: .info, sink: sink)
        }

        /// Log a notice (warning) message.
        @inlinable
        public func notice(_ message: @autoclosure ()->String) {
            guard let sink = Self.destination else { return }
            log(message(), level: .notice, sink: sink)
        }

        /// Log an error message.
        @inlinable
        public func error(_ message: @autoclosure ()->String) {
            guard let sink = Self.destination else { return }
            log(message(), level: .error, sink: sink)
        }

        /// Log a fault message.
        @inlinable
        public func fault(_ message: @autoclosure ()->String) {
            guard let sink = Self.destination else { return }
            log(message(), level: .fault, sink: sink)
        }
    }
}
