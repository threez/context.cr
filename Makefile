.PHONY: fmt lint docs spec

all: fmt lint docs spec

fmt:
	crystal tool format

spec:
	crystal spec -v

AMEBA=./lib/ameba/bin/ameba

$(AMEBA): $(AMEBA).cr
	crystal build -o $@ $(AMEBA).cr

lint: $(AMEBA)
	$(AMEBA)

docs:
	crystal docs
