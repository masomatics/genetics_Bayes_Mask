import numpy as np
import scipy as sp
import sys
import csv

class gen_util:
    '''
    This class is a utility class that includes methods for the analysis of the
    data provided from Gota Morota.
    '''
    def __init__(self, parentpath, datapath, srcpath):
        self.ppath = parentpath
        self.dpath = parentpath + datapath
        self.spath = parentpath + srcpath

    def readfile(self, filename, env):
        '''
        This file extracts the wheat data in csv extention and returns X and Y in the usual regression form.
        :filename:  name of the file, not path
        :the index of the environment
        '''
        

        return 0
