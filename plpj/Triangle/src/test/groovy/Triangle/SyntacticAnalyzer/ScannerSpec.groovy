package Triangle.SyntacticAnalyzer

import spock.lang.Specification
import spock.lang.Title

@Title('Syntactic analyzer')
class ScannerSpec extends Specification {

    private static final String SIMPLE_TRIANGLE_FILE = 'src/test/resources/sample.tri'
    private static final String COMMENT = '!Sample'
    private static final String FUNC = 'func leap (yr: Integer) : Boolean ~'
    private static final String ASSIGNMENT = 'i := -42'
    private static final String CHAR_LITERAL = " ord('a') "

    def 'How tokens are created'() {

        given: 'Triangle source file reader and scanner'
        SourceFile sf = new SourceFile(SIMPLE_TRIANGLE_FILE)
        Scanner scanner = new Scanner(sf)
        scanner.withDebugging()

        when: 'Start reading file, like compiler do'

        then: 'First token should be displayed'
        Token letToken = new Token(13, 'let', new SourcePosition(1, 1))
        assert scanner.scan() == letToken
    }

    def 'Comments snippets'() {

        given: 'Scanner and source that contains only one comment'
        SourceFile sourceFile = new SourceFile(COMMENT, false)
        Scanner scanner = new Scanner(sourceFile)

        when: 'Scanning starts'
        Token currentToken = scanner.scan()

        then: 'All comment should be skip'
        assert currentToken.kind == Token.EOT
    }

    def 'func declaration'() {
        given: 'Scanner and source that contains functions declaration'
        SourceFile sourceFile = new SourceFile(FUNC, false)
        Scanner scanner = new Scanner(sourceFile)

        when: 'Scanning starts'
        Token func = scanner.scan()
        Token funcName = scanner.scan()
        Token leftParen = scanner.scan()
        Token paramName = scanner.scan()
        Token colon = scanner.scan()
        Token typeName = scanner.scan()
        Token rightParen = scanner.scan()
        Token colon2 = scanner.scan()
        Token typeName2 = scanner.scan()
        Token is = scanner.scan()

        then: 'Token types are'
        assert func.kind == Token.FUNC
        assert funcName.kind == Token.IDENTIFIER
        assert leftParen.kind == Token.LPAREN
        assert paramName.kind == Token.IDENTIFIER
        assert colon.kind == Token.COLON
        assert typeName.kind == Token.IDENTIFIER
        assert rightParen.kind == Token.RPAREN
        assert colon2.kind == Token.COLON
        assert typeName2.kind == Token.IDENTIFIER
        assert is.kind == Token.IS
    }

    def ':= and minus'() {
        given: 'Scanner and source that contains assignment'
        SourceFile sourceFile = new SourceFile(ASSIGNMENT, false)
        Scanner scanner = new Scanner(sourceFile)

        when: 'Scanning starts'
        Token varName = scanner.scan()
        Token becomes = scanner.scan()
        Token minus = scanner.scan()
        Token digit = scanner.scan()

        then: 'Tokens are'
        assert varName.kind == Token.IDENTIFIER
        assert becomes.kind == Token.BECOMES
        assert minus.kind == Token.OPERATOR
        assert digit.kind == Token.INTLITERAL
    }

    def 'char literal'() {
        given: 'Scanner and source that contains char literal'
        SourceFile sourceFile = new SourceFile(CHAR_LITERAL, false)
        Scanner scanner = new Scanner(sourceFile)

        when: 'Scanning starts'
        Token literal = scanner.scan()
        Token leftParen = scanner.scan()
        Token stringLiteral = scanner.scan()
        Token rightParen = scanner.scan()

        then: 'Token is'
        assert literal.kind == Token.IDENTIFIER
        assert leftParen.kind == Token.LPAREN
        assert stringLiteral.kind == Token.CHARLITERAL
        assert rightParen.kind == Token.RPAREN
    }
}