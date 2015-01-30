NAME=lxc-wrapper
VERSION=
LISP_FILES=$(shell find . -name '*.lisp')
ASDF_TREE ?= ~/quicklisp/
BIN=dist/usr/bin/lxc-wrapper
DESTDIR=

$(BIN): $(LISP_FILES) quickload
	mkdir -p dist/usr/bin
	buildapp --load-system lxc-wrapper --entry lxc-wrapper:main --output $(BIN) --asdf-tree $(ASDF_TREE) --asdf-tree . --compress-core

quickload:
	sbcl --eval "(ql:quickload 'lxc-wrapper)" --quit

clean:
	rm -rf dist/

install: $(BIN)
	cp $(BIN) $(DESTDIR)/usr/bin

release: deb rpm

deb: $(BIN)
	fpm -p dist/ -s dir -t deb -n $(NAME) -v $(VERSION) -C dist/ usr/bin

rpm: $(BIN)
	fpm -p dist/ -s dir -t rpm -n $(NAME) -v $(VERSION) -C dist/ usr/bin

.PHONY: clean install dist
