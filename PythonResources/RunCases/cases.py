def get_cases(how : str):
    ''' Return the simulation cases to be run.

        how (case insensitive):
          handwrite = explictly written in cases.handwrite_cases()
          construct = use cases.construct_cases() to construct a batch of cases
    '''
    # import copy
    
    hup = how.upper()
    cases = list()
    if hup == 'HANDWRITE':
        cases = handwrite_cases()
    elif hup == 'CONSTRUCT':
        cases = construct_cases()

    return cases

def handwrite_cases():
    """ Manually write out cases.
    """
    
    cases = list()
    buil = '1065'
    cases.append( \
        {"model": "ThermalGridJBA.Hubs.Validation.ConnectedETSNoDHW",
          "name": f"no_dhw_{buil}_transit",
          "building": buil,
          "start_time": 90*24*3600,
          "stop_time":  100*24*3600,
          "modifiers": f"bui(redeclare ThermalGridJBA.Data.Individual.B{buil} datBui(have_hotWat=false))"})
    buil = '1065'
    cases.append( \
        {"model": "ThermalGridJBA.Hubs.Validation.ConnectedETSWithDHW",
          "name": f"wi_dhw_{buil}_transit",
          "building": buil,
          "start_time": 90*24*3600,
          "stop_time":  100*24*3600,
          "modifiers": f"bui(redeclare ThermalGridJBA.Data.Individual.B{buil} datBui(have_hotWat=true))"})
    
    return cases

def construct_cases():
    """ Construct a batch of cases
    """

    cases = list()

    # buil_nos = ['1045',
    #             '1058x1060',
    #             '1065',
    #             '1345',
    #             '1349',
    #             '1359',
    #             '1380',
    #             '1500',
    #             '1560',
    #             '1569',
    #             '1631',
    #             '1657',
    #             '1676',
    #             '1690',
    #             '1691',
    #             '1692',
    #             '1800'] # list of all building numbers, forcing no DHW
    # for buil in buil_nos:
    #     cases.append( \
    #         {"model": "ThermalGridJBA.Hubs.Validation.ConnectedETSNoDHW",
    #           "name": f"no_dhw_{buil}_transit",
    #           "building": buil,
    #           "start_time": 90*24*3600,
    #           "stop_time":  100*24*3600,
    #           "modifiers": f"bui(redeclare ThermalGridJBA.Data.Individual.B{buil} datBui(have_hotWat=false))"})

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
              "start_time": 90*24*3600,
              "stop_time":  100*24*3600,
              "modifiers": f"bui(redeclare ThermalGridJBA.Data.Individual.B{buil} datBui(have_hotWat=false))"})

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
              "start_time": 90*24*3600,
              "stop_time":  100*24*3600,
              "modifiers": f"bui(redeclare ThermalGridJBA.Data.Individual.B{buil} datBui(have_hotWat=true))"})    
    
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
