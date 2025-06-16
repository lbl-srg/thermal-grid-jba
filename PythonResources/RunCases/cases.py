def get_cases():

        def _add(case, cases):
            # Specification that is common to all cases
            common = {
                'model': 'ThermalGridJBA.Networks.Validation.DetailedPlantFiveHubs',
                'start_time' : 0 * 24 * 3600,
                'stop_time'  : 365* 24 * 3600,
                'number_of_intervals' : 365 * 24,
                'solver'     : 'cvode',
                'tolerance'  : '1e-7',
                'simulate': True,
                'postProcess': True
            }
            # Combine the dictionaries
            case.update(common)
            cases.append(case)

        # Build list of cases to be simulated
        cases = list()
        case = {
            # Name will be used in output file. Must not contain a period.
            'name': "base",
            # label will be used in plot label
            'label': 'base'
        }
        _add(case, cases)

        case = {
            'name': "base_hBor_0_8",
            'parameters': {
                'cenPla.borFie.hBor': 91*0.8
            },
            'label': '$0.8 \, h_{bor}$'
        }
        _add(case, cases)

        case = {
            'name': "base_hBor_1_2",
            'parameters': {
                'cenPla.borFie.hBor': 91*1.2,
            },
            'label': '$1.2 \, h_{bor}$'
        }
        _add(case, cases)

        case = {
            'name': "base_dDis_0_8",
            'parameters': {
                'datDis.dhDisSizFac': 0.8
            },
            'label': '$0.8 \, d_{dis}$'
        }
        _add(case, cases)

        case = {
            'name': "base_dDis_1_2",
            'parameters': {
                'datDis.dhDisSizFac': 1.2
            },
            'label': '$1.2 \, h_{dis}$'
        }
        _add(case, cases)

        case = {
            'name': "base_TCon_20",
            'parameters': {
                'bui.datHeaPum.TConLvgMin': [293.15, 293.15, 293.15, 293.15, 293.15]
            },
            'label': '$T_{con,min} = 20^\circ \mathrm{C}$ ($68 \, F$)'
        }
        _add(case, cases)

        case = {
            'name': "base_TCon_10",
            'parameters': {
                'bui.datHeaPum.TConLvgMin': [283.15, 283.15, 283.15, 283.15, 283.15]
            },
            'label': '$T_{con,min} = 25^\circ \mathrm{C}$ ($77 \, F$)'
        }
        _add(case, cases)

        case = {
            'name': "base_TCon_20",
            'parameters': {
                'bui.datHeaPum.TConLvgMin': [293.15, 293.15, 293.15, 293.15, 293.15]
            },
            'label': '$T_{con,min} = 35^\circ \mathrm{C}$ ($95 \, F$)'
        }
        _add(case, cases)

        case = {
            'name': "base_heaPumSizFac_0_8",
            'parameters': {
                'datDis.heaPumSizFac': 0.8
            },
            'label': '$0.8 \, \dot Q_{hea,pum,0}$'
        }
        _add(case, cases)

        case = {
            'name': "base_heaPumSizFac_0_9",
            'parameters': {
                'datDis.heaPumSizFac': 0.9
            },
            'label': '$0.9 \, \dot Q_{hea,pum,0}$'
        }
        _add(case, cases)

        # Disable plant economizer by setting a small flow rate (as
        # the flow rate is also used to size the dry cooler) and
        # setting the approach that commands the economizer on to 100 K
        case = {
            'name': "base_noEco",
            'parameters': {
                'datDis.mPlaHexGly_flow_nominal': 1,
                'cenPla.TApp': 100
            },
            'label': 'no economizer'
        }
        _add(case, cases)

        case = {
            'name': 'heat',
            'modifiers': 'datDis.sce = ThermalGridJBA.Types.Scenario.HeatWave',
            'label': 'heat wave'
        }
        _add(case, cases)

        case = {
            'name': 'cold',
            'modifiers': 'datDis.sce = ThermalGridJBA.Types.Scenario.ColdSnap',
            'label': 'cold snap'
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
