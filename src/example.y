
%start Expr
%%

Expr -> Result<i128, ()>:
      Expr '+' Term { Ok($1? + $3?) }
    | Term { $1 }
    ;

Term -> Result<i128, ()>:
      Term '*' Factor { Ok($1? * $3?) }
    | Factor { $1 }
    ;

Factor -> Result<i128, ()>:
      '(' Expr ')' { $2 }
    | 'INT'
      {
          let v = $1.map_err(|_| ())?;
          parse_int($lexer.span_str(v.span()))
      }
    ;
%%

fn parse_int(s: &str) -> Result<i128, ()> {
    match s.parse::<i128>() {
        Ok(val) => Ok(val),
        _ => Err(()),
    }
}