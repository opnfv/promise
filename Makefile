BUILDDIR := build

.PHONY: clean html pdf default

default: pdf

clean:
	rm -rf $(BUILDDIR) plantuml.jar

html: plantuml.jar | $(BUILDDIR)
	sphinx-build -b html -c etc -d $(BUILDDIR)/doctrees \
	    requirements $(BUILDDIR)/requirements/html

pdf: plantuml.jar | $(BUILDDIR)
	sphinx-build -b latex -c etc -d $(BUILDDIR)/doctrees \
	    requirements $(BUILDDIR)/requirements/latex
	$(MAKE) -C $(BUILDDIR)/requirements/latex \
	    LATEXOPTS='--interaction=nonstopmode' all-pdf

$(BUILDDIR):
	mkdir -p $(BUILDDIR)

plantuml.jar:
	wget 'http://downloads.sourceforge.net/project/plantuml/plantuml.jar'
