package Triangle.SyntacticAnalyzer

import Triangle.ErrorReporter
import spock.lang.Specification
import spock.lang.Title

@Title('Syntactic analyzer')
class ParserSpec extends Specification {

    private static final String SIMPLE_TRIANGLE_FILE = 'src/test/resources/sample.tri'

    def 'How parser works'() {

        given: 'Triangle source file reader, scanner and parser'
        SourceFile sf = new SourceFile(SIMPLE_TRIANGLE_FILE)
        Scanner scanner = new Scanner(sf)

        Parser parser = new Parser(scanner, new ErrorReporter())

        when: 'Start reading file, like compiler do'

        then: 'First token should be displayed'
        def programAST = parser.parseProgram()
        assert programAST
//
//        Here is how AST looks like:
//
//        programAST = {Program}
//           C = {LetCommand}
//              D = {SequentialDeclaration}
//                 D1 = {SequentialDeclaration}
//                    D1 = {SequentialDeclaration}
//                       D1 = {TypeDeclaration}
//                          I = {Identifier}
//                          T = {RecordTypeDenoter}
//                          duplicated = false
//                          position = {SourcePosition} "(2, 6)"
//                          entity = null
//                       D2 = {ProcDeclaration}
//                          I = {Identifier}
//                          FPS = {SingleFormalParameterSequence}
//                          C = {SequentialCommand}
//                          duplicated = false
//                          position = {SourcePosition} "(8, 17)"
//                          entity = null
//                          duplicated = false
//                       position = {SourcePosition} "(2, 33)"
//                       entity = null
//                    D2 = {ProcDeclaration}
//                       I = {Identifier}
//                       FPS = {SingleFormalParameterSequence}
//                       C = {LetCommand}
//                       duplicated = false
//                       position = {SourcePosition} "(19, 30)"
//                       entity = null
//                       duplicated = false
//                       position = {SourcePosition} "(2, 33)"
//            C = {WhileCommand}
//            E = {UnaryExpression}
//            C = {SequentialCommand}
//            position = {SourcePosition} "(35, 39)"
//            entity = null
    }
}