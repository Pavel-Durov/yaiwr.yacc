run-repl:
	cargo run

run-v-arg:
	RUST_LOG=debug cargo run "2+2"

run-v:
	RUST_LOG=debug cargo run "2+2"
	
lint:
	cargo fmt
	cargo fmt --all -- --check

test:
	cargo test
	cargo test --release
