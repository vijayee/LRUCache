build:
	mkdir -p build
test: build
	mkdir -p build/test
test/LRUCache: test LRUCache/*.pony LRUCache/test/*.pony
	stable env ponyc LRUCache/test -o build/test --debug
test/execute: test/LRUCache
	./build/test/test
clean:
	rm -rf build

.PHONY: clean test
