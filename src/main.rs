use std::{
    env,
    io::{self, BufRead, Write},
};

use log::debug;
use lrlex::lrlex_mod;
use lrpar::lrpar_mod;

lrlex_mod!("example.l");
lrpar_mod!("example.y");

fn main() {
    env_logger::init();
    let stdin = io::stdin();
    let args: Vec<String> = env::args().collect();
    debug!("cli args {:?}", &args[1..]);
    if args.len() > 1 {
        eval(args[1].as_str())
    } else {
        loop {
            print!("👉 ");
            io::stdout().flush().ok();
            match stdin.lock().lines().next() {
                Some(Ok(ref l)) => eval(l),
                _ => break,
            }
        }
    }
}

fn eval(str: &str) {
    if str.trim().is_empty() {
        return;
    }
    debug!("evaluaing {:?}", str);
    // Get the `LexerDef` for the `calc` language.
    let lexerdef = example_l::lexerdef();
    // Now we create a lexer with the `lexer` method with which
    // we can lex an input.
    let lexer = lexerdef.lexer(str);
    // Pass the lexer to the parser and lex and parse the input.
    let (res, errs) = example_y::parse(&lexer);
    for e in errs {
        println!("{}", e.pp(&lexer, &example_y::token_epp));
    }
    match res {
        Some(Ok(r)) => println!("{:?}", r),
        _ => eprintln!("Unable to evaluate expression."),
    }
}
