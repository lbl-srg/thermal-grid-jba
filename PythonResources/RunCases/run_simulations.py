#!/usr/bin/env python
#
# Start the script for the directory that contains the package
# with your model
#############################################################
import os
BRANCH="master"
ONLY_SHORT_TIME=False
FROM_GIT_HUB = False
CASE_LIST = 'construct'
""" case lists (case insensitive), see `cases.py`:
        handwrite: explicitly listed cases
        construct: rule-constructed list of cases
"""
KEEP_MAT_FILES = False # Set false to delete result mat files to save space

CWD = os.getcwd()

def sh(cmd, path):
    ''' Run the command ```cmd``` command in the directory ```path```
    '''
    import subprocess
    import sys
#    if args.verbose:
#        print("*** " + path + "> " + '%s' % ' '.join(map(str, cmd)))
    p = subprocess.Popen(cmd, cwd = path)
    p.communicate()
    if p.returncode != 0:
        print("Error: %s." % p.returncode)
        sys.exit(p.returncode)

def create_working_directory():
    ''' Create working directory
    '''
    import os
    import tempfile
    import getpass
    worDir = tempfile.mkdtemp( prefix='tmp-simulator-jbacases-' + getpass.getuser() )
#    print("Created directory {}".format(worDir))
    return worDir

def checkout_repository(working_directory):
# def checkout_repository(working_directory, from_git_hub):
    import os
    # from git import Repo
    # import git
    d = {}
    # if from_git_hub:
    #     print("Checking out repository branch {}".format(BRANCH))
    #     git_url = "https://github.com/lbl-srg/modelica-buildings"
    #     r = Repo.clone_from(git_url, working_directory)
    #     g = git.Git(working_directory)
    #     g.checkout(BRANCH)
    #     # Print commit
    #     d['branch'] = BRANCH
    #     d['commit'] = str(r.active_branch.commit)
    # else:
    # This is a hack to get the local copy of the repository

    des = os.path.join(working_directory, "ThermalGridJBA")
    print("*** Copying ThermalGridJBA library to {}".format(des))
    shutil.copytree("/home/casper/gitRepo/thermal-grid-jba/ThermalGridJBA", des)
    
    ### Test code using Buildings
    # des = os.path.join(working_directory, "Buildings")
    # print("*** Copying Buildings library to {}".format(des))
    # shutil.copytree("/home/casper/gitRepo/modelica-buildings/Buildings", des)

    return d

def _simulate(spec):
    import os
    import glob

    from buildingspy.simulate.Dymola import Simulator
    if not spec["simulate"]:
        return

    wor_dir = create_working_directory()

    out_dir = os.path.join(wor_dir, "simulations", spec["name"])
    os.makedirs(out_dir)

    # Update MODELICAPATH to get the right library version
    os.environ["MODELICAPATH"] = ":".join([spec['lib_dir'], out_dir])

    # Copy the models
#    print("Copying models from {} to {}".format(CWD, wor_dir))
    shutil.copytree(os.path.join(CWD, "JBACases"), os.path.join(wor_dir, "JBACases"))
    # Change the working directory so that the right checkout is loaded
    os.chdir(os.path.join(wor_dir, "JBACases"))

    # Write git information if the simulation is based on a github checkout
    #print(spec)
    # if 'git' in spec:
    if 'git' in spec and spec['git'] != {}:
        with open(os.path.join(out_dir, "version.txt"), "w+") as text_file:
            text_file.write("branch={}\n".format(spec['git']['branch']))
            text_file.write("commit={}\n".format(spec['git']['commit']))
        
    print(out_dir)
    # s=Simulator(spec["model"], packagePath="/home/casper/gitRepo/modelica-buildings/Buildings")
    s=Simulator(spec["model"], packagePath="/home/casper/gitRepo/thermal-grid-jba/ThermalGridJBA")
    s.setOutputDirectory(out_dir)
    s.addPreProcessingStatement("OutputCPUtime:= true;")
    s.addPreProcessingStatement("Advanced.ParallelizeCode = false;")
#    s.addPreProcessingStatement("Advanced.EfficientMinorEvents = true;")
    if not 'solver' in spec:
        s.setSolver("Cvode")
    if 'modifiers' in spec:
        s.addModelModifier(spec['modifiers'])
    if 'parameters' in spec:
        s.addParameters(spec['parameters'])
    s.setStartTime(spec["start_time"])
    s.setStopTime(spec["stop_time"])
    s.setTolerance(1E-6)
    s.showGUI(False)
    s.exitSimulator(True)
    print("Starting simulation in {}".format(out_dir))
    
    flag = False 
    """
    This flag checks if the try-except block ran without raising an exception.
    This avoids wrapping additional code inside the try block and potentially
        raises exceptions which would get mixed up with the code to be tested.
    """
    try:
        s.simulate()
        flag = True
    except:
        print(f"Simulation failed: {spec['name']}")
    if flag:
        # Copy results back
        res_des = os.path.join(CWD, "simulations", spec["name"])
        if os.path.isdir(res_des):
           shutil.rmtree(res_des)
        print("Copying results to {}".format(res_des))
        shutil.move(out_dir, res_des)
    
        # Delete the working directory
        shutil.rmtree(wor_dir)
        
        # Delete mat files if asked to
        if not KEEP_MAT_FILES:
            pattern = os.path.join(res_des,"*.mat")
            for f in glob.glob(pattern):
                os.remove(f)

def check_tests():
    
    import os
    
    directory = os.path.join(CWD, "simulations")
    nfolders = [entry for entry in os.listdir(directory) if os.path.isdir(os.path.join(directory, entry))]
        # names of folders
    numcases = len(list_of_cases) # number of cases
    numfail = 0 # number of failed tests
    listfail = list()
    
    print("")
    print("="*30)
    for casename in [item['name'] for item in list_of_cases]:
        if not casename in nfolders:
            numfail += 1
            listfail.append([casename])
        else:
            with open(os.path.join(directory,casename,"dslog.txt"),'r') as f:
                for line in f:
                    if "Warning" in line:
                        warning_line = line.strip()
                        print(" "*4+f"There are warnings from {casename}. First occurance:")
                        print(" "*8+warning_line)
                        break
    if numfail == 0:
        print(f"All {numcases} cases simulated successfully.")
    else:
        print(f"{numfail} out of {numcases} cases failed. Failed cases:")
        print(listfail)

################################################################################
if __name__=='__main__':
    from multiprocessing import Pool
    import multiprocessing
    import shutil
    import cases

    list_of_cases = cases.get_cases(CASE_LIST)

    for iEle in range(len(list_of_cases)):
        if ONLY_SHORT_TIME:
            if "annual" in list_of_cases[iEle]['name']:
                print("Warning: Deleting {} from list of cases.".format(list_of_cases[iEle]['name']))
                list_of_cases[iEle]['simulate'] = False
            else:
                list_of_cases[iEle]['simulate'] = True
        else:
            list_of_cases[iEle]['simulate'] = True


    # Number of parallel processes
    nPro = multiprocessing.cpu_count()
    po = Pool(nPro)

    lib_dir = create_working_directory()
    #d = checkout_repository(lib_dir, from_git_hub = FROM_GIT_HUB)
    d = checkout_repository(lib_dir)
    # Add the directory where the library has been checked out
    for case in list_of_cases:
        case['lib_dir'] = lib_dir
        if FROM_GIT_HUB:
            case['git'] = d

    # Run all cases
    po.map(_simulate, list_of_cases)
    # Delete the checked out repository
    shutil.rmtree(lib_dir)

    check_tests()
    if not KEEP_MAT_FILES:
        print("All mat files deleted because KEEP_MAT_FILES=False")