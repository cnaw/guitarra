In order to make the python wrapper work, one has to add it to the python paths. One
can do this by adding the python wrapper directory to the .bashrc file:

export PYTHONPATH=/path_to_guitarra/python_wrapper/src:$PYTHONPATH
export PATH="/path_to_guitarra_exectuable:$PATH"

Then, one can update the guitarra parameters in guitarra_params.py
and run:

python guitarra_params.py


Any questions and comments please to 
Sandro Tacchella (sandro.tacchella@cfa.harvard.edu)


