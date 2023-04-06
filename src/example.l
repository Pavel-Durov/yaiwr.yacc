%%
[0-9]+ "INTEGER_LITERAL"
(true|false) "BOOLEAN_LITERAL"
\+ "+"
\* "*"
\( "("
\) ")"
\{ "{"
\} "}"

fun "FUNCTION"
; ";"
, ","
= "="
let "LET" 
[a-zA-Z0-9_]+ "IDENTIFIER"
[\t ]+ ;