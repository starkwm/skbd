import Foundation

let defaultOpen = { open($0, $1, $2) }

let defaultFcntl: (Int32) -> Int32 = {
  var lockfd = flock()
  lockfd.l_start = 0
  lockfd.l_len = 0
  lockfd.l_pid = getpid()
  lockfd.l_type = Int16(F_WRLCK)
  lockfd.l_whence = Int16(SEEK_SET)

  return fcntl($0, F_SETLK, &lockfd)
}

let defaultFlock = { flock($0, LOCK_EX | LOCK_NB) }

let defaultWrite: (Int32) -> Int = {
  var pid = getpid()
  return write($0, &pid, MemoryLayout<pid_t>.size)
}

let defaultRead: (Int32) -> (Int, pid_t) = {
  var pid: pid_t = 0
  return (read($0, &pid, MemoryLayout<pid_t>.size), pid)
}

public enum LockFile {
  static var open = defaultOpen
  static var fcntl = defaultFcntl
  static var flock = defaultFlock
  static var write = defaultWrite
  static var read = defaultRead

  public static func acquire() throws {
    let handle = open(try path(), O_CREAT | O_WRONLY, 0o600)

    if handle == -1 {
      throw LockFileError.failedToOpenFile
    }

    if fcntl(handle) == -1 {
      throw LockFileError.failedToLockFile
    }

    if write(handle) == -1 {
      throw LockFileError.failedToWriteFile
    }
  }

  public static func readPid() throws -> pid_t {
    let handle = open(try path(), O_RDONLY, 0x600)

    if handle == -1 {
      throw LockFileError.failedToOpenFile
    }

    defer { close(handle) }

    if flock(handle) == 0 {
      throw LockFileError.failedToLockFile
    }

    let (res, pid) = read(handle)

    if res == -1 {
      throw LockFileError.failedToReadFile
    }

    return pid
  }

  static func path() throws -> String {
    guard let user = ProcessInfo.processInfo.environment["USER"] else {
      throw LockFileError.userEnvVarMissing
    }

    return FileManager
      .default
      .temporaryDirectory
      .appendingPathComponent("skbd_\(user).pid", isDirectory: false)
      .path
  }
}
