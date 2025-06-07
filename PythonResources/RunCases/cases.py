def get_cases():

        def _add(case, cases):
            # Specification that is common to all cases
            common = {
                'model': 'ThermalGridJBA.Networks.Validation.DetailedPlantFiveHubs',
                'start_time' : 0 * 24 * 3600,
                'stop_time'  : 365* 24 * 3600,
                'number_of_intervals' : 365 * 24,
                'solver'     : 'cvode',
                'simulate': True
            }
            # Combine the dictionaries
            case.update(common)
            cases.append(case)

        # Build list of cases to be simulated
        cases = list()
        case = {
            'name': "base"
        }
        _add(case, cases)

        case = {
            'name': "base_hBor_1.2",
            'parameters': {
                'cenPla.borFie.hBor': 91*1.2,
            }
        }
        _add(case, cases)

        case = {
            'name': "base_hBor_0.8",
            'parameters': {
                'cenPla.borFie.hBor': 91*0.8
            }
        }
        _add(case, cases)

        case = {
            'name': "base_dDis_1.2",
            'parameters': {
                'datDis.dhDisSizFac': 1.2
            }
        }
        _add(case, cases)

        case = {
            'name': "base_dDis_0.8",
            'parameters': {
                'datDis.dhDisSizFac': 0.8
            }
        }
        _add(case, cases)

        case = {
            'name': 'heat',
            'modifiers': 'datDis.sce = ThermalGridJBA.Types.Scenario.HeatWave'
        }
        _add(case, cases)

        case = {
            'name': 'cold',
            'modifiers': 'datDis.sce = ThermalGridJBA.Types.Scenario.ColdSnap'
        }
        _add(case, cases)

        case = {
            'name': "base_heaPumSizFac_0.8",
            'parameters': {
                'datDis.heaPumSizFac': 0.8
            }
        }
        _add(case, cases)

        case = {
            'name': "base_heaPumSizFac_0.9",
            'parameters': {
                'datDis.heaPumSizFac': 0.9
            }
        }
        _add(case, cases)

        # The commented cases below are for pre-ECM base case and the post-ECM with TMY3.
        # They are supported but not part of the regular batch of runs
        # case = {
        #     'name': 'pree',
        #     'modifiers': 'datDis.sce = ThermalGridJBA.Types.Scenario.Baseline'
        # }
        # _add(case, cases)

        # case = {
        #     'name': 'post',
        #     'modifiers': 'datDis.sce = ThermalGridJBA.Types.Scenario.PostECM'
        # }
        # _add(case, cases)

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
