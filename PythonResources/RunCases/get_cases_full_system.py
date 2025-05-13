def get_cases_full_system():

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
