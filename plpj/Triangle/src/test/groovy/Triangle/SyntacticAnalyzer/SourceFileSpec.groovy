package Triangle.SyntacticAnalyzer

import spock.lang.Specification
import spock.lang.Title

@Title('Syntactic analyzer')
class SourceFileSpec extends Specification {

    private static final String SIMPLE_TRIANGLE_FILE = 'src/test/resources/sample.tri'

    def 'How source file is read'() {

        given: 'Triangle source file reader'
        SourceFile sf = new SourceFile(SIMPLE_TRIANGLE_FILE)

        when: 'Start reading file, like compiler do'
        char source = sf.getSource()
        int currentLine = sf.getCurrentLineNumber()

        then: 'Character should be given one by one'
        assert source == 'l' as char
        assert currentLine == 1
    }

}