
%start statements
%%

statements -> Result<Vec<AstNode>, ()>:
    statements statement { append($1.map_err(|_| ())?, $2.map_err(|_| ())?)  }
  | { Ok(vec![]) }
  ;


statement -> Result<AstNode, ()>:
  expression_statement { $1 }
	;

expression_statement -> Result<AstNode, ()>:
  ';' { Ok(AstNode::Empty{}) }
  |	expression ';' { $1 }
	;

expression -> Result<AstNode, ()>:
	assignment_expression { $1 }
  | expression ',' assignment_expression { $1 }
	;

assignment_expression -> Result<AstNode, ()>:
	additive_expression { $1 }
	| "LET" unary_expression "=" assignment_expression {
    match $2.map_err(|_| ())? {
      AstNode::ID { value } => {
        Ok(AstNode::Assign { id: value, rhs: Box::new($4?) })
      },
      _ => Err(())
    }
  }
	;

additive_expression -> Result<AstNode, ()>:
	multiplicative_expression { $1 }
	| additive_expression '+' multiplicative_expression { 
    Ok(AstNode::Add{ lhs: Box::new($1?), rhs: Box::new($3?) })
  }
	;

multiplicative_expression -> Result<AstNode, ()>: 
  unary_expression { $1 }
	| multiplicative_expression '*' unary_expression { 
      Ok(AstNode::Mul{ lhs: Box::new($1?), rhs: Box::new($3?) })
    }
	;

unary_expression -> Result<AstNode, ()>: 
	postfix_expression { $1 }
	;


postfix_expression -> Result<AstNode, ()>:
	primary_expression { $1 }
  | postfix_expression '(' ')' { 
    match $1.map_err(|_| ())? {
      AstNode::ID { value } => Ok(AstNode::FunctionCall{ id: value, args: vec![] }),
      _ => Err(())
    }
   }
  ;

primary_expression -> Result<AstNode, ()>:
    "IDENTIFIER" { Ok(AstNode::ID { value: $lexer.span_str(($1.map_err(|_| ())?).span()).to_string() }) }
    |  '(' expression ')' { $2 }
    | literals { $1 }
    ;

literals -> Result<AstNode, ()>:
    "INTEGER_LITERAL" { parse_int($lexer.span_str(($1.map_err(|_| ())?).span())) }
    | "BOOLEAN_LITERAL" { parse_boolean($lexer.span_str(($1.map_err(|_| ())?).span())) }
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


fn parse_boolean(s: &str) -> Result<AstNode, ()> {
    match s.parse::<bool>() {
        Ok(n_val) => Ok(AstNode::Boolean{ value: n_val }),
        Err(_) => {
            eprintln!("{} cannot be represented as a boolean", s);
            Err(())
        }
    }
}

fn append(mut lhs: Vec<AstNode>, rhs: AstNode ) -> Result<Vec<AstNode>, ()>{
    lhs.push(rhs);
    Ok(lhs)
}
