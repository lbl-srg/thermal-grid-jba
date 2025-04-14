def get_cases(case_list : str,
              case_specs,
              case_scenarios = ['futu']):
    ''' Return the simulation cases to be run.

        For inputs see `run_simulations.py`.
    '''
    # import copy
    
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
    elif hup == 'FIVEHUBSNOPLANT':
        cases_ns = fivehubsnoplant()
    elif hup == 'FIVEHUBSMULTIFLOW':
        cases_ns = fivehubsmultiflow()
    
    cases = list() # cases with scenarios specified
    for scenario in case_scenarios:
        cases +=[
                    {
                        **cas,
                        "name": cas["name"].replace('_SCENARIO', f'_{scenario}'),
                        "parameters": {
                            **cas["parameters"],
                            **({
                                "filNam": cas["parameters"]["filNam"].replace('_SCENARIO', f'_{scenario}')
                            } if "filNam" in cas["parameters"] and isinstance(cas["parameters"]["filNam"], str) else {}),
                            **({
                                "datDis.filNam": [fn.replace('_SCENARIO', f'_{scenario}') for fn in cas["parameters"]["datDis.filNam"]]
                            } if "datDis.filNam" in cas["parameters"] and isinstance(cas["parameters"]["datDis.filNam"], list) else {})
                        }
                    }
                    for cas in cases_ns
                ]
    
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
          "name": f"nodhw_{buil}_SCENARIO",
          "building": buil,
          "parameters": {'filNam': "modelica://ThermalGridJBA/Resources/Data/Consumptions/B1045_futu.mos"},
          'start_time' : 99 * 24 * 3600,
          'stop_time'  : 100 * 24 * 3600})
    
    return cases

def handwrite_cases():
    """ Manually write out cases.
    """
    
    cases = list()
    buil = '1045'
    cases.append( \
        {"model": "ThermalGridJBA.Hubs.Validation.ConnectedETSNoDHW",
          "name": f"nodhw_{buil}_SCENARIO",
          "building": buil,
          "parameters": {'filNam': f"modelica://ThermalGridJBA/Resources/Data/Consumptions/B{buil}_SCENARIO.mos"}})
         
    buil = '1065'
    cases.append( \
        {"model": "ThermalGridJBA.Hubs.Validation.ConnectedETSWithDHW",
          "name": f"widhw_{buil}_SCENARIO",
          "building": buil,
          "parameters": {'filNam' : f"modelica://ThermalGridJBA/Resources/Data/Consumptions/B{buil}_SCENARIO.mos"}})
    
    return cases

def fivehubsmultiflow():
    
    cases = list()
    cases.append( \
        {"model": "ThermalGridJBA.Networks.Validation.FiveHubsPlantMultiFlow",
          "name": "fivehubsmultiflow_SCENARIO",
          "building": 'FiveHubs',
          "parameters": {'datDis.filNam' : [
      "modelica://ThermalGridJBA/Resources/Data/Consumptions/CA_SCENARIO.mos",
      "modelica://ThermalGridJBA/Resources/Data/Consumptions/CB_SCENARIO.mos",
      "modelica://ThermalGridJBA/Resources/Data/Consumptions/CC_SCENARIO.mos",
      "modelica://ThermalGridJBA/Resources/Data/Consumptions/CD_SCENARIO.mos",
      "modelica://ThermalGridJBA/Resources/Data/Consumptions/CE_SCENARIO.mos"]}})
    
    return cases 


def fivehubsnoplant():
    
    cases = list()
    cases.append( \
        {"model": "ThermalGridJBA.Networks.Validation.SinglePlantFiveHubs",
          "name": "fivehubsnoplant_SCENARIO",
          "building": 'FiveHubs',
          "parameters": {'datDis.filNam' : [
      "modelica://ThermalGridJBA/Resources/Data/Consumptions/CA_SCENARIO.mos",
      "modelica://ThermalGridJBA/Resources/Data/Consumptions/CB_SCENARIO.mos",
      "modelica://ThermalGridJBA/Resources/Data/Consumptions/CC_SCENARIO.mos",
      "modelica://ThermalGridJBA/Resources/Data/Consumptions/CD_SCENARIO.mos",
      "modelica://ThermalGridJBA/Resources/Data/Consumptions/CE_SCENARIO.mos"]}})
    
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
              "name": f"nodhw_{buil}_SCENARIO",
              "building": buil,
              "parameters": {'filNam' : f"modelica://ThermalGridJBA/Resources/Data/Consumptions/B{buil}_SCENARIO.mos"}})

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
              "name": f"widhw_{buil}_SCENARIO",
              "building": buil,
              "parameters": {'filNam' : f"modelica://ThermalGridJBA/Resources/Data/Consumptions/B{buil}_SCENARIO.mos"}})    
    
    return cases

def construct_clusters():
    """ Construct a batch of cases for each cluster
        Cluster A does not have DHW. All others do.
    """

    cases = list()
    
    cases.append( \
            {"model": "ThermalGridJBA.Hubs.Validation.ConnectedETSNoDHW",
              "name": "cluster_A_SCENARIO",
              "building": 'A',
              "parameters": {'filNam' : "modelica://ThermalGridJBA/Resources/Data/Consumptions/CA_SCENARIO.mos"}})

    clusters = ['B',
                'C',
                'D',
                'E']
    for buil in clusters:
        cases.append( \
            {"model": "ThermalGridJBA.Hubs.Validation.ConnectedETSWithDHW",
              "name": f"cluster_{buil}_SCENARIO",
              "building": buil,
              "parameters": {'filNam' : f"modelica://ThermalGridJBA/Resources/Data/Consumptions/C{buil}_SCENARIO.mos"}})
    
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
