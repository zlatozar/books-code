package Triangle.ContextualAnalyzer

import Triangle.AbstractSyntaxTrees.Program
import Triangle.ErrorReporter
import Triangle.SyntacticAnalyzer.Parser
import Triangle.SyntacticAnalyzer.Scanner
import Triangle.SyntacticAnalyzer.SourceFile
import spock.lang.Specification

class CheckerSpec extends Specification {

    private static final String SIMPLE_TRIANGLE_FILE = 'src/test/resources/sample.tri'

    def 'How checker works'() {

        given: 'Triangle source file reader, scanner, parser and checker'
        SourceFile sf = new SourceFile(SIMPLE_TRIANGLE_FILE)
        Scanner scanner = new Scanner(sf)
        ErrorReporter errorReporter = new ErrorReporter()

        Parser parser = new Parser(scanner, errorReporter)
        Checker checker = new Checker(errorReporter)

        when: 'Start reading file, like compiler do'

        then: 'First token should be displayed'
        Program programAST = parser.parseProgram()

        checker.check(programAST)

        assert programAST
    }

}