BUILDDIR := build

.PHONY: default clean

default:
	tox

clean:
	rm -rf .tox build
