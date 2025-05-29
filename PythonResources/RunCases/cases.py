def get_cases():

        def _add(case, cases):
            # Specification that is common to all cases
            common = {
                'model': 'ThermalGridJBA.Networks.Validation.DetailedPlantFiveHubs',
                'start_time' : 0 * 24 * 3600,
                'stop_time'  : 365* 24 * 3600,
                'number_of_intervals' : 365 * 24,
                'solver'     : 'radau',
                'simulate': True
            }
            # Combine the dictonaries
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
            'parameters': {
                'datDis.filNamInd' : [
                    "modelica://ThermalGridJBA/Resources/Data/Consumptions/CA_heat.mos",
                    "modelica://ThermalGridJBA/Resources/Data/Consumptions/CB_heat.mos",
                    "modelica://ThermalGridJBA/Resources/Data/Consumptions/CC_heat.mos",
                    "modelica://ThermalGridJBA/Resources/Data/Consumptions/CD_heat.mos",
                    "modelica://ThermalGridJBA/Resources/Data/Consumptions/CE_heat.mos"],
                         'datDis.filNamCom' :
                    "modelica://ThermalGridJBA/Resources/Data/Consumptions/All_heat.mos"}
        }
        _add(case, cases)

        case = {
            'name': 'cold',
            'parameters': {
                'datDis.filNamInd' : [
                    "modelica://ThermalGridJBA/Resources/Data/Consumptions/CA_cold.mos",
                    "modelica://ThermalGridJBA/Resources/Data/Consumptions/CB_cold.mos",
                    "modelica://ThermalGridJBA/Resources/Data/Consumptions/CC_cold.mos",
                    "modelica://ThermalGridJBA/Resources/Data/Consumptions/CD_cold.mos",
                    "modelica://ThermalGridJBA/Resources/Data/Consumptions/CE_cold.mos"],
                         'datDis.filNamCom' :
                    "modelica://ThermalGridJBA/Resources/Data/Consumptions/All_cold.mos"}
        }
        _add(case, cases)

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
