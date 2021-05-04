//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

fileprivate var defaultLogger = Cornucopia.Core.Logger(category: "@Logged")

public extension Cornucopia.Core {

#if DEBUG
    /// Write access to the wrapped property is logged in DEBUG builds. In RELEASE builds, this does nothing.
    @propertyWrapper
    struct DebugLogged<T> {

        private(set) var value: T
        public var name: String
        public var level: Logger.Level
        public var logger: Logger

        public var wrappedValue: T {
            get { value }
            set {
                value = newValue
                self.logger.log("Property \(self.name) has been set to \(self.value)", level: self.level)
            }
        }

        public init(wrappedValue: T, name: String, logger: Logger? = nil, level: Logger.Level = .debug) {
            self.value = wrappedValue
            self.name = name
            self.level = level
            self.logger = logger ?? defaultLogger
            self.logger.log("Property \(self.name) has been initialized with \(self.value)", level: self.level)
        }
    }
#else
    @propertyWrapper
    struct Logged<T> {
        public var wrappedValue: T
        public init(wrappedValue: T, name: String, logger: Logger? = nil, level: Logger.Level = .debug) {
            self.wrappedValue = wrappedValue
        }
    }
#endif

    /// Write access to the wrapped property is logged.
    @propertyWrapper
    struct Logged<T> {

        private(set) var value: T
        public var name: String
        public var level: Logger.Level
        public var logger: Logger

        public var wrappedValue: T {
            get { value }
            set {
                value = newValue
                self.logger.log("Property \(self.name) has been set to \(self.value)", level: self.level)
            }
        }

        public init(wrappedValue: T, name: String, logger: Logger? = nil, level: Logger.Level = .debug) {
            self.value = wrappedValue
            self.name = name
            self.level = level
            self.logger = logger ?? defaultLogger
            self.logger.log("Property \(self.name) has been initialized with \(self.value)", level: self.level)
        }
    }
}
