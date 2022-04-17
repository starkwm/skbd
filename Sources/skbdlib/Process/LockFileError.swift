enum LockFileError: Error {
    case userEnvVarMissing
    case failedToOpenFile
    case failedToReadFile
    case failedToWriteFile
    case failedToLockFile
}

extension LockFileError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .userEnvVarMissing:
            return "USER environment variable is not set"
        case .failedToOpenFile:
            return "failed to open .pid file"
        case .failedToReadFile:
            return "failed to read .pid file"
        case .failedToWriteFile:
            return "failed to write .pid file"
        case .failedToLockFile:
            return "failed to lock .pid file"
        }
    }
}
