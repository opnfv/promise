BUILDDIR := build

.PHONY: default clean

default: plantuml.jar
	tox

plantuml.jar:
	wget 'http://downloads.sourceforge.net/project/plantuml/plantuml.jar'

clean:
	rm -rf .tox build plantuml.jar
