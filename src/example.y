
%start Statements
%%

Statements -> Result<Vec<AstNode>, ()>:
    Statements Expr { append($1.map_err(|_| ())?, $2.map_err(|_| ())?)  }
  | ";" { Ok(vec![]) }
  | { Ok(vec![]) }
  ;

Expr -> Result<AstNode, ()>:
    "LET" "T_VAR" "=" Expr ";" {  Ok(AstNode::Assign { id: $lexer.span_str(($2.map_err(|_| ())?).span()).to_string(), rhs: Box::new($4?) }) }
    // Shift/Reduce conflict - RUST_LOG=debug cargo run "let abc = 2; abc (2,3) "
    // | "T_VAR" { Ok(AstNode::ID { value: $lexer.span_str(($1.map_err(|_| ())?).span()).to_string() }) }
    | "T_VAR" "(" ")"  {
        let id = $1.map_err(|_| ())?;
        Ok(AstNode::FunctionCall{ id: $lexer.span_str(id.span()).to_string(), args: vec![] })
    }
    | "T_VAR" "(" ArgList ")" { 
        let id = $1.map_err(|_| ())?;
        Ok(AstNode::FunctionCall{ id: $lexer.span_str(id.span()).to_string(), args: $3.map_err(|_| ())? })
    }
    | Expr '+' Term { Ok(AstNode::Add{ lhs: Box::new($1?), rhs: Box::new($3?) }) }
    | Term { $1 }
    ;

Term -> Result<AstNode, ()>:
      Term '*' Factor { Ok(AstNode::Mul{ lhs: Box::new($1?), rhs: Box::new($3?) }) }
    | Factor { $1 }
    ;

Factor -> Result<AstNode, ()>:
      '(' Expr ')' { $2 }
    | 'INT'
      {
          let v = $1.map_err(|_| ())?;
          parse_int($lexer.span_str(v.span()))
      }
    ;

ArgList -> Result<Vec<AstNode>, ()>:
    ArgList ',' Expr { append($1.map_err(|_| ())?, $3.map_err(|_| ())?) }
    | Expr {  Ok(vec![$1.map_err(|_| ())?]) }
    ;

%%
use crate::ast::AstNode;

fn parse_int(s: &str) -> Result<AstNode, ()> {
    match s.parse::<u64>() {
        Ok(n_val) => Ok(AstNode::Number{ value: n_val }),
        Err(_) => {
            eprintln!("{} cannot be represented as a u64", s);
            Err(())
        }
    }
}

fn append(mut lhs: Vec<AstNode>, rhs: AstNode ) -> Result<Vec<AstNode>, ()>{
    lhs.push(rhs);
    Ok(lhs)
}
