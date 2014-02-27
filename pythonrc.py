
import os
import sys
import inspect
import readline
from rlcompleter import Completer
import atexit
from os.path import getsize

class PersCompleter(Completer):
	def __init__(self):
		Completer.__init__(self)

	def complete(self,text,state):
		if text.endswith(".__doc__"):
			new_text = text.replace(".__doc__","")
			help(eval(new_text))
			readline.redisplay()
			readline.insert_text(new_text)
		else:
			value = Completer.complete(self,text,state)
		return value

	def _imp(self,name):
	    try:
	        return __import__(name)
	    except:
	        if '.' in name:
	            sub = name[0:name.rfind('.')]
	            return _imp(sub)
	        else:
	            s = 'Unable to import module: %s - sys.path: %s' % (str(name), sys.path)
	            raise RuntimeError(s)

	def GetFile(self,mod):
	    f = None
	    try:
	        f = inspect.getsourcefile(mod) or inspect.getfile(mod)
	    except:
	        if hasattr(mod,'__file__'):
	            f = mod.__file__
	            if string.lower(f[-4:]) in ['.pyc', '.pyo']:
	                filename = f[:-4] + '.py'
	                if os.path.exists(filename):
	                    f = filename

	    return f

class Shell:
	def ls(self):
		print(os.list_dir("/"))

s = Shell()



readline.set_completer(PersCompleter().complete)
readline.parse_and_bind("tab: complete")






def info(object, spacing=30, collapse=1):
    """Print methods and doc strings.

    Takes module, class, list, dictionary, or string."""
    methodList = [method for method in dir(object) if callable(getattr(object, method))]
    processFunc = collapse and (lambda s: " ".join(s.split())) or (lambda s: s)
    print("\n".join(["%s %s" %
                      (method.ljust(spacing),
                       processFunc(str(getattr(object, method).__doc__)))
                     for method in methodList]))


# HISTORIQUE

hist_file = os.path.expanduser("~/.py_history")
max_size_bytes = 1000000
max_size_lines = 10000

#Code section, no need to modify this

def reset_file(size,max_size,reason):
        try:
                print("Resetting history file %s because it exceeded %s %s; it has %s.\n" % (hist_file,max_size,reason,size,))
                f = open(hist_file,'w')
                f.close()
        except IOError as e:
                print("Couldn't reset history file %s [%s].\n" % (hist_file,e,))

def safe_getsize(hist_file):
        try:
                size = getsize(hist_file)
        except OSError:
                size = 0
        return size

lines = 0
size = safe_getsize(hist_file)

if size > max_size_bytes:
        reset_file(size,max_size_bytes,"bytes")
else:
        try:
                readline.read_history_file(hist_file)
                lines = readline.get_current_history_length()
                if lines > max_size_lines:
                        try:
                                readline.clear_history()
                        except NameError as e:
                                print("readline.clear_history() not supported (%s), please delete history file %s by hand.\n" % (e,hist_file,))
                        reset_file(lines,max_size_lines,"lines")
        except IOError:
                try:
                        f = open(hist_file,'a')
                        f.close()
                except IOError:
                        print("The file %s can't be created, check your hist_file variable.\n" % hist_file)

size = safe_getsize(hist_file)

print("Current history file (%s) size: %s bytes, %s lines.\n" % (hist_file,size,readline.get_current_history_length(),))

atexit.register(readline.write_history_file,hist_file)

