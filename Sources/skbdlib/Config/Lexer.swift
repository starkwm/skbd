import Alicia

class Lexer {
    private var buffer = ""
    private var current = Character("\0")
    private var readPos = 0

    init(_ buffer: String) {
        self.buffer = buffer

        advance()
    }

    func getToken() -> Token {
        skipWhitespace()

        var token: Token

        switch current {
        case "\0":
            token = Token(type: .endOfStream)
        case "+":
            token = Token(type: .plus)
        case "-":
            token = Token(type: .dash)
        case "#":
            skipComment()
            token = Token(type: .comment)
        case ":":
            advance()
            skipWhitespace()
            let cmd = readCommand()
            token = Token(type: .command, text: cmd)
        default:
            if current.isLetter || current.isNumber {
                let text = readIdentifier()
                let type = resolveIdentifierType(identifier: text)
                return Token(type: type, text: text)
            } else if ["`", "=", "[", "]", ";", "'", "\\", ",", ".", "/"].contains(current) {
                token = Token(type: .key, text: String(current))
            } else {
                token = Token(type: .unknown, text: String(current))
            }
        }

        advance()

        return token
    }

    private func advance() {
        current = readPos >= buffer.count ? Character("\0") : buffer[readPos]
        readPos += 1
    }

    private func skipWhitespace() {
        while current.isWhitespace {
            advance()
        }
    }

    private func skipComment() {
        while !current.isNewline, current != "\0" {
            advance()
        }
    }

    private func readCommand() -> String {
        let start = readPos - 1

        while !current.isNewline, current != "\0" {
            if current == "\\" {
                advance()
            }

            advance()
        }

        return buffer[start ..< readPos - 1]
    }

    private func readIdentifier() -> String {
        let start = readPos - 1

        while current.isLetter || current == "_" {
            advance()
        }

        while current.isNumber {
            advance()
        }

        return buffer[start ..< readPos - 1]
    }

    private func resolveIdentifierType(identifier: String) -> TokenType {
        if identifier.count == 1 || keyToCode.keys.contains(identifier) {
            return .key
        }

        if modifierIdentifiers.contains(identifier) {
            return .modifier
        }

        return .unknown
    }
}
