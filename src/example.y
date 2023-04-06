
%start statement_list
%%

statement_list -> Result<Vec<AstNode>, ()>:
    statement_list statement { append($1.map_err(|_| ())?, $2.map_err(|_| ())?)  }
  | { Ok(vec![]) }
  ;


statement -> Result<AstNode, ()>:
  expression_statement { $1 }
  | function_definition { $1 }
  | jump_statement { $1 }
	;

jump_statement -> Result<AstNode, ()>:
	"RETURN" expression ";" { Ok(AstNode::Return{ block: Box::new($2?) }) }
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
      AstNode::ID { value: id } => Ok(AstNode::FunctionCall{ id, args: vec![] }),
      _ => Err(())
    }
   }
  | postfix_expression '(' argument_expression_list ')' { 
    match $1.map_err(|_| ())? {
      AstNode::ID { value: id } => Ok(AstNode::FunctionCall{ id, args: $3.map_err(|_| ())? }),
      _ => Err(())
    }
   }
  ;

argument_expression_list -> Result<Vec<AstNode>, ()>:
	assignment_expression {  Ok(vec![$1.map_err(|_| ())?]) }
	| argument_expression_list ',' assignment_expression { append($1.map_err(|_| ())?, $3.map_err(|_| ())?)  }
	;
  
id -> Result<AstNode, ()>:
  "IDENTIFIER" { Ok(AstNode::ID { value: $lexer.span_str(($1.map_err(|_| ())?).span()).to_string() }) }
  ;

primary_expression -> Result<AstNode, ()>:
    id { $1 }
    |  '(' expression ')' { $2 }
    | literals { $1 }
    ;

literals -> Result<AstNode, ()>:
    "INTEGER_LITERAL" { parse_int($lexer.span_str(($1.map_err(|_| ())?).span())) }
    | "BOOLEAN_LITERAL" { parse_boolean($lexer.span_str(($1.map_err(|_| ())?).span())) }
    ;

param_list -> Result<Vec<AstNode>, ()>:
    param_list ',' id { append($1.map_err(|_| ())?, $3.map_err(|_| ())?) }
    | id { Ok(vec![$1.map_err(|_| ())?]) }
    ;

function_definition -> Result<AstNode, ()>:
    "FUNCTION" "IDENTIFIER" "(" ")" "{" statement_list "}" { 
        let id = $2.map_err(|_| ())?;
        Ok(AstNode::Function{ 
            id: $lexer.span_str(id.span()).to_string(),
            params: vec![],
            block: $6?
        }) 
     }
    | 
    "FUNCTION" "IDENTIFIER" "(" param_list ")" "{" statement_list "}" { 
        let id = $2.map_err(|_| ())?;
        Ok(AstNode::Function{ 
            id: $lexer.span_str(id.span()).to_string(),
            params: $4.map_err(|_| ())?,
            block: $7?
        }) 
     }
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
