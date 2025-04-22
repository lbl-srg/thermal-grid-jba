#!/usr/bin/env python
#
# Start the script for the directory that contains the package
# with your model
#
# KNOWN ISSUES:
#   Each run adds an entry to Dymola > Tools > Library Management > Modelica Path,
#       after a point it may fail to add more and the simulation can't find Buildings.
#       Manually deleting paths can help.
#############################################################
import os
BRANCH="main"
ONLY_SHORT_TIME=False
FROM_GIT_HUB = False
CASE_LIST = 'fivehubsmultiflow'
""" This parameter determines which model to run and which load files to load.
    See `cases.py`, case insensitive:
        minimum: minimum test to see if things can run
        handwrite: explicitly listed cases
        eachbuilding: each building, differentiating with or without DHW
        eachcluster: each of the five clusters, all with DHW
        fivehubsnoplant: runs ThermalGridJBA.Networks.Validation.IdealPlantFiveHubs
        fivehubsmultiflow: runs ThermalGridJBA.Networks.Validation.DetailedPlantFiveHubs
"""
CASE_SPECS = {
     'start_time' : 0 * 24 * 3600,
     'stop_time'  : 365* 24 * 3600,
     'number_of_intervals' : 365 * 24,
     'solver'     : 'cvode'}
""" Sets simulation specifications for all cases,
        UNLESS such a specification is already in the case constructor,
        in which case this specification is ignored.
"""
# CASE_SCENARIOS = ['futu']
CASE_SCENARIOS = ['futu', 'heat', 'cold']
""" List of weather scenarios:
        'base', 'post' : TMY3, also chooses baseline or post-retrofit load files
        'futu' : fTMY
        'heat' : heat wave
        'cold' : cold snap
"""
CHECK_LOG_FILES = 'failed'
""" Case insensitive:
        all: check all log files
        failed: check failed cases only
        any other string: skipped
"""
KEEP_MAT_FILES = True # Set false to delete result mat files to save space
if not KEEP_MAT_FILES:
    print("="*10 + "!"*10 + "="*10)
    print("Result mat files will be deleted because KEEP_MAT_FILES = False")
    print("="*10 + "!"*10 + "="*10)
SHOW_DYMOLA_GUI = False
KEEP_DYMOLA_OPEN = False

CWD = os.getcwd()
package_path = os.path.realpath(os.path.join(os.path.realpath(__file__),'../../../ThermalGridJBA'))

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
    shutil.copytree("../../ThermalGridJBA", des)

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
    if "MODELICAPATH" in os.environ:
        modPath = os.environ["MODELICAPATH"]
        patDir = modPath.split(':')
        patDir.append(spec['lib_dir'])
        patDir.append(out_dir)
        newModPath = ":".join(patDir)
        os.environ["MODELICAPATH"] = newModPath
    else:
        os.environ["MODELICAPATH"] = ":".join([spec['lib_dir'], out_dir])

    # Copy the models
#    print("Copying models from {} to {}".format(CWD, wor_dir))
    # shutil.copytree(os.path.join(CWD, "JBACases"), os.path.join(wor_dir, "JBACases"))
    # Change the working directory so that the right checkout is loaded
    # os.chdir(os.path.join(wor_dir, "JBACases"))

    # Write git information if the simulation is based on a github checkout
    #print(spec)
    # if 'git' in spec:
    if 'git' in spec and spec['git'] != {}:
        with open(os.path.join(out_dir, "version.txt"), "w+") as text_file:
            text_file.write("branch={}\n".format(spec['git']['branch']))
            text_file.write("commit={}\n".format(spec['git']['commit']))

    print(out_dir)
    # s=Simulator(spec["model"], packagePath="/home/casper/gitRepo/modelica-buildings/Buildings")
    s=Simulator(spec["model"], packagePath=package_path)
    s.setOutputDirectory(out_dir)
    s.addPreProcessingStatement("OutputCPUtime:= true;")
    s.addPreProcessingStatement("Advanced.ParallelizeCode = false;")
#    s.addPreProcessingStatement("Advanced.EfficientMinorEvents = true;")
    if 'solver' in spec:
        s.setSolver(spec['solver'])
    else:
        s.setSolver("Cvode")
    if 'number_of_intervals' in spec:
        s.setNumberOfIntervals(n=spec['number_of_intervals'])
    if 'modifiers' in spec:
        s.addModelModifier(spec['modifiers'])
    if 'parameters' in spec:
        s.addParameters(spec['parameters'])
    s.setStartTime(spec["start_time"])
    s.setStopTime(spec["stop_time"])
    s.setTolerance(1E-6)
    s.showGUI(SHOW_DYMOLA_GUI)
    s.exitSimulator(not KEEP_DYMOLA_OPEN)
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
    #if flag:
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

    success = {'name' : spec["name"],
               'flag' : flag}
    return success

def summarise_tests(success):

    num_cases = len(list_of_cases)
    num_success = sum(1 for item in success if item['flag'])
    print('='*30)
    if num_success == num_cases:
        print(f"All {num_cases} cases simulated successfully.")
    else:
        print(f"Out of {num_cases} cases, the following {num_cases - num_success} failed:")
        for cas in success:
            if not cas['flag']:
                print(" "*4 + f'The case "{cas["name"]}" failed.')
                if not os.path.exists(os.path.join(CWD,'simulations',cas['name'],'dslog.txt')):
                    print(" "*8 + '"dslog.txt" was not generated, indicating the simulation did not initialise.')

def check_logs(CHECK_LOG_FILES,
               success,
               output_warning_tags=True,
               output_error_vars=True,
               output_unaccounted=False,
               output_warning_blocks=True):

    import whofailed

    flag = False
    if CHECK_LOG_FILES.upper() == "ALL":
        cases = [item['name'] for item in success]
        flag = len(cases)
    elif CHECK_LOG_FILES.upper() == "FAILED":
        cases = [item['name'] for item in success if item['flag'] is False]
        flag = len(cases)

    if flag:
        print("="*30)
        print("Checking log files")
        directory = os.path.join(CWD, "simulations")
        for cas in cases:
            print("="*5 + f" Case: {cas}")
            path_dslog = os.path.join(directory, cas, "dslog.txt")
            path_dsmodelc = os.path.join(directory, cas, "dsmodel.c")
            whofailed.main(path_dslog,
                           path_dsmodelc,
                           output_warning_tags,
                           output_error_vars,
                           output_unaccounted,
                           output_warning_blocks)


    else:
        print("="*30)
        print("Log file checking is skipped.")

################################################################################
if __name__=='__main__':
    from multiprocessing import Pool
    import multiprocessing
    import shutil
    import cases

    list_of_cases = cases.get_cases(CASE_LIST, CASE_SPECS, CASE_SCENARIOS)

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
    success = po.map(_simulate, list_of_cases)
    # Delete the checked out repository
    shutil.rmtree(lib_dir)

    print("="*10 + "TEST SUMMARY" + "="*10)
    summarise_tests(success)
    if CHECK_LOG_FILES.upper() in ['ALL', 'FAILED']:
        check_logs(CHECK_LOG_FILES, success)

    if not KEEP_MAT_FILES:
        print("="*30)
        print("All mat files deleted because KEEP_MAT_FILES=False")
