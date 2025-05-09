scenario_placeholder = "%%SCENARIO%%"

def get_cases(case_list : str,
              case_specs,
              case_scenarios = ['futu']):
    ''' Return the simulation cases to be run.

        For inputs see `run_simulations.py`.
    '''

    hup = case_list.upper()
    cases_ns = list() # cases without scenarios specified
    if hup == 'MINIMUM':
        cases_ns = minimum_test()
    elif hup == 'HANDWRITE':
        cases_ns = handwrite_cases()
    elif hup == 'EACHBUILDING':
        cases_ns = construct_buildings()
    elif hup == 'EACHCLUSTER':
        cases_ns = construct_clusters()
    elif hup == 'IDEALPLANTFIVEHUBS':
        cases_ns = ideal_plant_five_hubs()
    elif hup == 'DETAILEDPLANTFIVEHUBS':
        cases_ns = detailed_plant_five_hubs()
    
    def replace_scenario(d : dict, scenario : str):
        to_replace = scenario_placeholder
        replace_by = f"{scenario}"
        if isinstance(d, dict):
            return {k: replace_scenario(v, replace_by) for k, v in d.items()}
        elif isinstance(d, list):
            return [replace_scenario(item, replace_by) for item in d]
        elif isinstance(d, str):
            return d.replace(to_replace, replace_by)
        else:
            return d
    cases = list() # cases with scenarios specified
    for scenario in case_scenarios:
        cases +=[replace_scenario(cas, scenario) for cas in cases_ns]

    # add global specifications but does not override any existing ones
    for cas in cases:
        cas.update({key: value for key, value in case_specs.items() if key not in cas})

    return cases

def minimum_test():
    """ Minimum test case to see if things work.
    """

    cases = list()
    buil = 'minimum-test'
    cases.append( \
        {"model": "ThermalGridJBA.Hubs.Validation.ConnectedETSNoDHW",
          "name": f"nodhw_{buil}_{scenario_placeholder}",
          "building": buil,
          "parameters": {'filNam': f"modelica://ThermalGridJBA/Resources/Data/Consumptions/B1045_{scenario_placeholder}.mos"},
          'start_time' : 99 * 24 * 3600,
          'stop_time'  : 100 * 24 * 3600})

    return cases

def handwrite_cases():
    """ Manually write out cases.
    """

    cases = list()
    cases.append( \
        {"model": "ThermalGridJBA.Hubs.Validation.ConnectedETSWithDHW",
          "name": f"ETS_All_{scenario_placeholder}",
          "building": 'All',
          "parameters": {'filNam' : f"modelica://ThermalGridJBA/Resources/Data/Consumptions/All_{scenario_placeholder}.mos"}})

#     cases = list()
#     buil = '1045'
#     cases.append( \
#         {"model": "ThermalGridJBA.Hubs.Validation.ConnectedETSNoDHW",
#           "name": f"nodhw_{buil}_{scenario_placeholder}",
#           "building": buil,
#           "parameters": {'filNam': f"modelica://ThermalGridJBA/Resources/Data/Consumptions/B{buil}_{scenario_placeholder}.mos"}})

#     buil = '1065'
#     cases.append( \
#         {"model": "ThermalGridJBA.Hubs.Validation.ConnectedETSWithDHW",
#           "name": f"widhw_{buil}_{scenario_placeholder}",
#           "building": buil,
#           "parameters": {'filNam' : f"modelica://ThermalGridJBA/Resources/Data/Consumptions/B{buil}_{scenario_placeholder}.mos"}})

    return cases

def detailed_plant_five_hubs():

    cases = list()
    cases.append( \
        {"model": "ThermalGridJBA.Networks.Validation.DetailedPlantFiveHubs",
          "name": f"detailed_plant_five_hubs_{scenario_placeholder}",
          "building": 'FiveHubs',
          "parameters": {'datDis.filNamInd' : [
      f"modelica://ThermalGridJBA/Resources/Data/Consumptions/CA_{scenario_placeholder}.mos",
      f"modelica://ThermalGridJBA/Resources/Data/Consumptions/CB_{scenario_placeholder}.mos",
      f"modelica://ThermalGridJBA/Resources/Data/Consumptions/CC_{scenario_placeholder}.mos",
      f"modelica://ThermalGridJBA/Resources/Data/Consumptions/CD_{scenario_placeholder}.mos",
      f"modelica://ThermalGridJBA/Resources/Data/Consumptions/CE_{scenario_placeholder}.mos"],
                         'datDis.filNamCom' :
      f"modelica://ThermalGridJBA/Resources/Data/Consumptions/All_{scenario_placeholder}.mos"}})

    return cases


def ideal_plant_five_hubs():

    cases = list()
    cases.append( \
        {"model": "ThermalGridJBA.Networks.Validation.IdealPlantFiveHubs",
          "name": f"ideal_plant_five_hubs_{scenario_placeholder}",
          "building": 'FiveHubs',
          "parameters": {'datDis.filNamInd' : [
      f"modelica://ThermalGridJBA/Resources/Data/Consumptions/CA_{scenario_placeholder}.mos",
      f"modelica://ThermalGridJBA/Resources/Data/Consumptions/CB_{scenario_placeholder}.mos",
      f"modelica://ThermalGridJBA/Resources/Data/Consumptions/CC_{scenario_placeholder}.mos",
      f"modelica://ThermalGridJBA/Resources/Data/Consumptions/CD_{scenario_placeholder}.mos",
      f"modelica://ThermalGridJBA/Resources/Data/Consumptions/CE_{scenario_placeholder}.mos"],
                         'datDis.filNamCom' :
      f"modelica://ThermalGridJBA/Resources/Data/Consumptions/All_{scenario_placeholder}.mos"}})

    return cases

def construct_buildings():
    """ Construct a batch running each building,
            differentiating buildings with or without DHW integration
    """

    cases = list()

    buil_nos = ['1045',
                '1345',
                '1349',
                '1359',
                '1500',
                '1560',
                '1569',
                '1676'] # list of all building numbers without DHW load
    for buil in buil_nos:
        cases.append( \
            {"model": "ThermalGridJBA.Hubs.Validation.ConnectedETSNoDHW",
              "name": f"nodhw_{buil}_{scenario_placeholder}",
              "building": buil,
              "parameters": {'filNam' : f"modelica://ThermalGridJBA/Resources/Data/Consumptions/B{buil}_{scenario_placeholder}.mos"}})

    buil_nos = ['1058x1060',
                '1065',
                '1380',
                '1631',
                '1657',
                '1690',
                '1691',
                '1692',
                '1800'] # list of all DHW-integrated building numbers
    for buil in buil_nos:
        cases.append( \
            {"model": "ThermalGridJBA.Hubs.Validation.ConnectedETSWithDHW",
              "name": f"widhw_{buil}_{scenario_placeholder}",
              "building": buil,
              "parameters": {'filNam' : f"modelica://ThermalGridJBA/Resources/Data/Consumptions/B{buil}_{scenario_placeholder}.mos"}})

    return cases

def construct_clusters():
    """ Construct a batch of cases for each cluster
        Cluster A does not have DHW. All others do.
    """

    cases = list()

    cases.append( \
            {"model": "ThermalGridJBA.Hubs.Validation.ConnectedETSNoDHW",
              "name": f"cluster_A_{scenario_placeholder}",
              "building": 'A',
              "parameters": {'filNam' : f"modelica://ThermalGridJBA/Resources/Data/Consumptions/CA_{scenario_placeholder}.mos"}})

    clusters = ['B',
                'C',
                'D',
                'E']
    factors = [1.3,
               1.3,
               1.0,
               1.0]
    for buil, fac in zip(clusters, factors):
        cases.append( \
            {"model": "ThermalGridJBA.Hubs.Validation.ConnectedETSWithDHW",
              "name": f"cluster_{buil}_{scenario_placeholder}",
              "building": buil,
              "parameters": {'filNam' : f"modelica://ThermalGridJBA/Resources/Data/Consumptions/C{buil}_{scenario_placeholder}.mos",
                             'bui.facTerUniSizHea' : fac}})

    return cases

def get_case(name):
    ''' Return the case with the specified `name`
    '''
    for c in get_cases():
        if c['name'] == name:
            return c
    raise(ValueError('Did not find case {}'.format(name)))

def get_result_file_name(name):
    ''' Return the result file name
    '''
    import os.path
    case = get_case(name)
    model_name = (os.path.splitext(case['model'])[1])[1:]
    mat_name = "{}.mat".format( model_name )
    return os.path.join("simulations", name, mat_name)
