from vunit import VUnit
from glob import glob
import os
from os.path import join, dirname, abspath

def create_test_suite(lib):
    print("Create test suite ")
    save_dir = os.getcwd()
    curr_dir = os.path.dirname( os.path.realpath(__file__) )
    os.chdir(curr_dir);

    lib.add_source_files("../*.vhd")
    lib.add_source_files("*.vhd")


    os.chdir(save_dir)



def run_test() :
    prj = VUnit.from_argv()
    lib = prj.add_library("work_lib")
    create_test_suite(lib)
    prj.main()

if __name__ == "__main__":
    os.environ["VUNIT_SIMULATOR"] = "modelsim"
    run_test()

