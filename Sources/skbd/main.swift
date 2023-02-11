import Foundation

func main() -> Int32 {
    if arguments.version {
        fputs("skbd version \(Version.current.value)\n", stdout)
        return EXIT_SUCCESS
    }

    return EXIT_SUCCESS
}

exit(main())
