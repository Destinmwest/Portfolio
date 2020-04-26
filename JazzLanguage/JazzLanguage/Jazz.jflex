// We are going to be returning java_cup.runtime.Symbol objects from
// yylex() (these are the tokens)
import java_cup.runtime.Symbol;

%%

%class JazzScanner  // name of class to generate
%unicode  // Support Unicode characters
%type Symbol // The return type of yylex(), the method that returns the next token

// Tells JFlex to generate an end-of-file token
// when the end of input is reached (needed by
// JCup)
%eofval{
    return new Symbol(JazzParserSym.EOF);
%eofval}
%eofclose

%{
    StringBuffer string = new StringBuffer();

    private Symbol symbol(int type) {
        return new Symbol(type, yyline, yycolumn);
    }
    private Symbol symbol(int type, Object value) {
        return new Symbol(type, yyline, yycolumn, value);
    }
%}

%state STRING

%%

// What to do when the scanner is in the YYINITIAL state
<YYINITIAL> {
    \+ {
        // What to do when we see a "+" token
        System.out.println("+");
        // Return this token to the parser
        return new Symbol(JazzParserSym.PLUS);
    }

    - {
        System.out.println("-");
        return new Symbol(JazzParserSym.MINUS);
    }

    \* {
        System.out.println("*");
       return new Symbol(JazzParserSym.TIMES);
    }

    \/ {
        System.out.println("/");
        return new Symbol(JazzParserSym.DIVIDE);
    }

    \^ {
        System.out.println("^");
        return new Symbol(JazzParserSym.POWER);

    }

    \( {
        System.out.println("(");
        return new Symbol(JazzParserSym.LPAREN);
    }

    \) {
        System.out.println(")");
        return new Symbol(JazzParserSym.RPAREN);
    }

    [0-9]+(\.[0-9]+)? {
        System.out.println("Number: " + yytext());
        return new Symbol(JazzParserSym.NUMBER);
        //Double.parseDouble(yytext());
    }

    [a-zA-Z_][0-9a-zA-Z_]* {
        System.out.println("Identifier: " + yytext());
        return new Symbol(JazzParserSym.IDENTIFIER, yytext());
    }

    \winput {
	   System.out.println("Keyword: " + yytext());
       return new Symbol(JazzParserSym.INPUT);
    }

    \wprint {
	   System.out.println("Keyword: " + yytext());
       return new Symbol(JazzParserSym.PRINT);
    }

    [a-zA-Z_][0-9a-zA-Z_]*.=.*; {
        System.out.println("Assignment: " + yytext());
        return new Symbol(JazzParserSym.ASSIGNED);
    }

    \, {
	   System.out.println(",");
       return new Symbol(JazzParserSym.COMMA);
    }

    \= {
        System.out.println("=");
        return new Symbol(JazzParserSym.EQUALS);
    }

    ((sqrt)|(cos)|(sin)|(tan))+\([\w\d]+[^,]\) {
        System.out.println("Algebraic Function: " + yytext());
        return new Symbol(JazzParserSym.STATEMENT, yytext());
    }

    // Matches any whitespace
    \s+ {
        // Skip over whitespace
        return yylex();
    }

    . {
        // Lexer error! Invalid character
        System.out.println("Invalid character: " + yytext());
    }
}


       <STRING> {
      \"                             { yybegin(YYINITIAL);
                                       return new Symbol(JazzParserSym.STRING_LITERAL,
                                       string.toString()); }
      [^\n\r\"\\]+                   { string.append( yytext() ); }
      \\t                            { string.append('\t'); }
      \\n                            { string.append('\n'); }

      \\r                            { string.append('\r'); }
      \\\"                           { string.append('\"'); }
      \\                             { string.append('\\'); }

}
