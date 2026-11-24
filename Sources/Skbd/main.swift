import Darwin
import Foundation
import SkbdCore

let arguments = Arguments.parseOrExit()

if arguments.version {
  print("skbd \(Version.current)")
  exit(EXIT_SUCCESS)
}

let lock = FileLock()

switch lock.acquire() {
case .success:
  break
case .failure(.alreadyLocked):
  fputs("skbd is already running\n", stderr)
  fflush(stderr)
  exit(EXIT_FAILURE)
case .failure(.failed(let reason)):
  fputs("failed to acquire lock: \(reason)\n", stderr)
  fflush(stderr)
  exit(EXIT_FAILURE)
}

do {
  let configuration = try ConfigurationReloader.load(from: arguments.config)
  let eventTap = EventTapManager(configuration: configuration)

  switch eventTap.begin() {
  case .success: break
  case .failure(let error):
    fputs("error starting the event tap: \(error)\n", stderr)
    fputs("\(AccessibilityPermission.guidance())\n", stderr)
    fflush(stderr)
    exit(EXIT_FAILURE)
  }

  let reloader = ConfigurationReloader(
    url: arguments.config,
    onReload: { configuration in
      eventTap.update(configuration: configuration)
    },
    onError: { message in
      fputs("\(message)\n", stderr)
      fflush(stderr)
    }
  )

  reloader.start()

  let terminationSignalSources = [SIGINT, SIGTERM].map { signalNumber in
    signal(signalNumber, SIG_IGN)

    let source = DispatchSource.makeSignalSource(signal: signalNumber, queue: .main)
    source.setEventHandler {
      CFRunLoopStop(CFRunLoopGetMain())
    }
    source.resume()
    return source
  }

  withExtendedLifetime((terminationSignalSources, reloader)) {
    CFRunLoopRun()
  }
} catch let error as ConfigurationReloaderError {
  fputs("\(error.description)\n", stderr)
  fflush(stderr)
  exit(EXIT_FAILURE)
} catch {
  fputs("\(error.localizedDescription)\n", stderr)
  fflush(stderr)
  exit(EXIT_FAILURE)
}
