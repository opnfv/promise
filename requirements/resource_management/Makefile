BUILDDIR = build

.PHONY: clean html pdf all

all: html pdf

clean:
	rm -rf $(BUILDDIR)/* plantuml.jar

html: plantuml.jar
	sphinx-build -b html -d $(BUILDDIR)/doctrees . $(BUILDDIR)/html

pdf: plantuml.jar
	sphinx-build -b latex -d $(BUILDDIR)/doctrees . $(BUILDDIR)/latex
	$(MAKE) -C $(BUILDDIR)/latex all-pdf

plantuml.jar:
	wget 'http://downloads.sourceforge.net/project/plantuml/plantuml.jar'
