import datetime
import sys
import os

needs_sphinx = '1.3'

extensions = ['sphinxcontrib.httpdomain']

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
version = u'1.0.2'
release = u'1.0.2'

