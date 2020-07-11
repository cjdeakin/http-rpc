SCRIPT = http-rpc
COMPLETION = http-rpc-completion.sh

SOURCES = $(shell find src -type f)

all: ${SCRIPT} ${COMPLETION}

${SCRIPT}: init.sh main.sh ${SOURCES} build.sh
	./build.sh

${COMPLETION}: ${SCRIPT} generate-completion.sh
	./generate-completion.sh
	
.PHONY: clean
clean:
	rm -f "${SCRIPT}" "${COMPLETION}"

.PHONY: test
test: ${SCRIPT}
	./test.sh "${SCRIPT}"


.PHONY: test-completion
test-completion: ${COMPLETION}
	./test-completion.sh "${COMPLETION}"

