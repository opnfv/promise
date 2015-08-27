import datetime
import sys
import os

needs_sphinx = '1.3'

# plantuml
extensions = ['sphinxcontrib.plantuml']
plantuml = ['java', '-jar', 'plantuml.jar']

numfig = True

source_suffix = '.rst'
master_doc = 'index'
pygments_style = 'sphinx'
html_use_index = False

pdf_documents = [('index', u'Promise', u'Promise Project', u'OPNFV')]
pdf_fit_mode = "shrink"
pdf_stylesheets = ['sphinx','kerning','a4']
#latex_domain_indices = False
#latex_use_modindex = False

latex_elements = {
    'printindex': '',
}

project = u'Promise: Resource Management'
copyright = u'%s, OPNFV' % datetime.date.today().year
version = u'1.0.1'
release = u'1.0.1'

# TODO(r-mibu): remove the following line to index.rst
latex_appendices = ['07-schemas','08-revision']
