def get_cases(case_list : str, case_specs):
    ''' Return the simulation cases to be run.

        case_list (case insensitive):
          handwrite = explictly written in cases.handwrite_cases()
          construct = use cases.construct_buildings() to construct a batch of cases
    '''
    # import copy
    
    hup = case_list.upper()
    cases = list()
    if hup == 'HANDWRITE':
        cases = handwrite_cases()
    elif hup == 'EACHBUILDING':
        cases = construct_buildings()
    elif hup == 'EACHCLUSTER':
        cases = construct_clusters()
    
    for cas in cases:
        cas.update({key: value for key, value in case_specs.items() if key not in cas})
    
    return cases

def handwrite_cases():
    """ Manually write out cases.
    """
    
    cases = list()
    buil = '1045'
    cases.append( \
        {"model": "ThermalGridJBA.Hubs.Validation.ConnectedETSNoDHW",
          "name": f"no_dhw_{buil}_transit",
          "building": buil,
          "parameters": {'filNam': f"modelica://ThermalGridJBA/Resources/Data/Consumptions/B{buil}.mos"}})
         
    buil = '1065'
    cases.append( \
        {"model": "ThermalGridJBA.Hubs.Validation.ConnectedETSWithDHW",
          "name": f"wi_dhw_{buil}_transit",
          "building": buil,
          "parameters": {'filNam' : f"modelica://ThermalGridJBA/Resources/Data/Consumptions/B{buil}.mos"}})
    
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
              "name": f"no_dhw_{buil}_transit",
              "building": buil,
              "parameters": {'filNam' : f"modelica://ThermalGridJBA/Resources/Data/Consumptions/B{buil}.mos"}})

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
              "name": f"wi_dhw_{buil}_transit",
              "building": buil,
              "parameters": {'filNam' : f"modelica://ThermalGridJBA/Resources/Data/Consumptions/B{buil}.mos"}})    
    
    return cases

def construct_clusters():
    """ Construct a batch of cases for each cluster
        Cluster A does not have DHW. All others do.
    """

    cases = list()
    
    cases.append( \
            {"model": "ThermalGridJBA.Hubs.Validation.ConnectedETSNoDHW",
              "name": "cluster_A_transit",
              "building": 'A',
              "parameters": {'filNam' : "modelica://ThermalGridJBA/Resources/Data/Consumptions/CA.mos"}})

    clusters = ['B',
                'C',
                'D',
                'E']
    for buil in clusters:
        cases.append( \
            {"model": "ThermalGridJBA.Hubs.Validation.ConnectedETSWithDHW",
              "name": f"cluster_{buil}_transit",
              "building": buil,
              "parameters": {'filNam' : f"modelica://ThermalGridJBA/Resources/Data/Consumptions/C{buil}.mos"}})
    
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
