import datetime
import sys
import os

try:
    __import__('imp').find_module('sphinx.ext.numfig')
    extensions = ['sphinx.ext.numfig']
except ImportError:
    # 'pip install sphinx_numfig'
    extensions = ['sphinx_numfig']

# plantuml
extensions.append('sphinxcontrib.plantuml')
plantuml = ['java', '-jar', 'plantuml.jar']

# numfig:
number_figures = True
figure_caption_prefix = "Fig."

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
version = u'1.0.0'
release = u'1.0.0'

# TODO(r-mibu): remove the following line to index.rst
latex_appendices = ['07-schemas']
