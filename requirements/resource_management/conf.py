import datetime

extensions = ['sphinxcontrib.plantuml']
plantuml = ['java', '-jar', 'plantuml.jar']

source_suffix = '.rst'
master_doc = 'index'
pygments_style = 'sphinx'
html_use_index = False

pdf_documents = [('index', u'Promise', u'Promise Project', u'OPNFV')]
plantuml_latex_output_format = 'eps'
pdf_fit_mode = "shrink"
pdf_stylesheets = ['sphinx','kerning','a4']
latex_elements = {'printindex': ''}
latex_appendices = ['07-schemas']

project = u'Promise: Resource Management'
copyright = u'%s, OPNFV' % datetime.date.today().year
version = u'0.0.1'
release = u'0.0.1'
