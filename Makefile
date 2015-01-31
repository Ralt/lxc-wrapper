APP_NAME=lxc-wrapper
VERSION=
LISP_FILES=$(shell find . -name '*.lisp')
ASDF_TREE ?= ~/quicklisp/
DIST_FOLDER=dist/usr/bin
APP_OUT=dist/usr/bin/lxc-wrapper
QL_LOCAL=$(PWD)/.quicklocal/quicklisp
QUICKLISP_SCRIPT=http://beta.quicklisp.org/quicklisp.lisp
LOCAL_OPTS=--noinform --noprint --disable-debugger --no-sysinit --no-userinit
QL_OPTS=--load $(QL_LOCAL)/setup.lisp
LISP ?= sbcl
SOURCES := $(wildcard *.lisp) $(wildcard *.asd)
BUILDAPP = ./bin/buildapp

.PHONY: clean install release deb rpm

all: $(APP_OUT)

release: deb rpm

deb: $(APP_OUT)
	@fpm -p dist/ -s dir -t deb -n $(APP_NAME) -v $(VERSION) -C dist/ usr/bin

rpm: $(APP_OUT)
	@fpm -p dist/ -s dir -t rpm -n $(APP_NAME) -v $(VERSION) -C dist/ usr/bin

install: $(APP_OUT)
	install $(APP_OUT) $(DESTDIR)/usr/bin

bin:
	@mkdir bin

clean:
	@-yes | rm -rf $(QL_LOCAL)
	@-rm -f $(APP_OUT) deps install-deps

$(QL_LOCAL)/setup.lisp:
	@curl -O $(QUICKLISP_SCRIPT)
	@sbcl $(LOCAL_OPTS) \
		--load quicklisp.lisp \
		--eval '(quicklisp-quickstart:install :path "$(QL_LOCAL)")' \
		--eval '(quit)'

deps:
	@sbcl $(LOCAL_OPTS) $(QL_OPTS) \
             --eval '(push "$(PWD)/" asdf:*central-registry*)' \
             --eval '(ql:quickload :lxc-wrapper)' \
             --eval '(quit)'
	@touch $@

install-deps: $(QL_LOCAL)/setup.lisp deps
	@touch $@

bin/buildapp: bin $(QL_LOCAL)/setup.lisp
	@cd $(shell sbcl $(LOCAL_OPTS) $(QL_OPTS) \
				--eval '(ql:quickload :buildapp :silent t)' \
				--eval '(format t "~A~%" (asdf:system-source-directory :buildapp))' \
				--eval '(quit)') && \
	$(MAKE) DESTDIR=$(PWD) install

$(APP_OUT): $(SOURCES) bin/buildapp $(QL_LOCAL)/setup.lisp install-deps
	@mkdir -p $(DIST_FOLDER)
	@$(BUILDAPP) --logfile /tmp/build.log \
			--sbcl sbcl \
			--asdf-path . \
			--asdf-tree $(QL_LOCAL)/local-projects \
			--asdf-tree $(QL_LOCAL)/dists \
			--asdf-path . \
			--load-system $(APP_NAME) \
			--entry $(APP_NAME):main \
			--compress-core \
			--output $(APP_OUT)
