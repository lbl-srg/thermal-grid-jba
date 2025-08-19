# -*- coding: utf-8 -*-
"""
Created on Fri Mar 29 17:41:50 2024

@author: remi

Step by step script:
    1- Delete + Create a new scenario based on "single_hub"
    2- Populate the scenario with the different hubs
    3- Add the energy demands (based on xlsx files) for Cooling + Space heating + Domestic hot water + Electricity
    4- Add the supply technologies (extend the existing one to all the hubs)    
"""

import json
import requests
import copy
import os
import pandas as pd
import base64
from ESTCP.dict_sympheny import conversion_v2, storage_v2
import io
from xlsxwriter import Workbook


#%% Functions

def open_target_file(target_path):
    with open(target_path,"rb") as excel_file:
        return excel_file.read()

def decode_excel_profile(path_to_file):
    excel_file = open_target_file(path_to_file)
    encoded_excel = base64.b64encode(excel_file)
    decoded = encoded_excel.decode('utf-8')
    return decoded

def create_excel_file(values: list[float]) -> str:
    excel_data = io.BytesIO()
    workbook = Workbook(excel_data)
    worksheet = workbook.add_worksheet("Demand Profiles")
    writer = worksheet._write

    columns=[range(1, len(values) + 1), values]
    results = [writer(r, c, c_v) for c, c_v in enumerate(columns) for r, c_v in enumerate(c_v)]
    if any(result != 0 for result in results):
        raise Exception("Failed writing rows in excel")

    workbook.close()
    excel_data.seek(0)
    base64_encoded_excel = base64.b64encode(excel_data.read()).decode('utf-8')

    return f"data:application/vnd.openxmlformats-officedocument.spreadsheetml.sheet;base64,{base64_encoded_excel}"

def hub_naming(k, pos_ele):
    for j in range(pos_ele):
        if j == 0:
            hub_temp = k.split('_')[j]
        else:
            hub_temp = f"{hub_temp}_{k.split('_')[j]}"
    return hub_temp


#%% Initialisation

sympheny_username = "" # Username to connect to Sympheny
sympheny_password = "" # Password to connect to Sympheny
sympheny_data = r'PythonResources\Data\Consumption\test_sympheny'
additional_values = r'additional_inputs.xlsx'

url = "https://eu-north-1-api.sympheny.com/backoffice/auth/ext/token"

payload = json.dumps({
  "email": sympheny_username,
  "password": sympheny_password
})
headers = { 
  'accept': 'application/json',
  'Content-Type': 'application/json'
}

response = requests.request("POST", url, headers=headers, data=payload)
response_json = json.loads(response.text)
access_token = response_json["access_token"]

headers = {
  'accept': 'application/json',
  'authorization': 'Bearer ' + access_token,
  'content-type': 'application/json',
}

base_url = "https://eu-north-1-api.sympheny.com/sympheny-app"

#%% Getting scenarios GUID + creating Scenario

url = f"{base_url}/projects"
response = requests.get(url, headers=headers, data=payload)

project_name = "JBA_ESTCP_V3"
analysis_name = "jba_future"
scenario_name = "ind"

new_name = {'single_hub':'multi_hub', 
            'gas':'gas_multi', 
            'a2w':'a2w_multi',
            'w2w':'w2w_multi',
            'ets':'ets_multi',
            'ind':'ind_multi'}
scenario_new = new_name[scenario_name]

# Getting the Scenario GUID to copy

for project in json.loads(response.text)["data"]["projects"]:
    if project['projectName'] == project_name:
        projectGuid = project['projectGuid']

url_project = f"{base_url}/projects/{projectGuid}"
response = requests.get(url_project, headers=headers, data=payload)

# Delete the destination scenario if it already exists

projectDetails = json.loads(response.text)["data"]["analyses"]
for analysis in projectDetails:
    if analysis['analysisName'] == analysis_name:
        analysisGuid = analysis['analysisGuid']
        for scenario in analysis['scenarios']:
            if scenario['scenarioName'] == scenario_name:
                scenarioGuid_ini = scenario['scenarioGuid']
            if scenario['scenarioName'] == scenario_new:
                scenariodel = scenario['scenarioGuid']
                response = requests.delete(f"{base_url}/scenario/{scenariodel}", headers=headers)
            
# Copy of the initial scenario

response = requests.put(f"{base_url}/scenarios/copy/{scenarioGuid_ini}", headers=headers)
scenarioGuid = json.loads(response.text)["data"]['scenarioGuid']

#Once copied, modifying the name of the new scenario

payload = json.dumps(
    {
      "scenarioName": scenario_new
      }
    )
response = requests.put(f"{base_url}/scenarios/{scenarioGuid}", headers=headers, data=payload)


#%% Get the stages

url_demand = f"{base_url}/scenarios/{scenarioGuid}/stages"

response = requests.get(url_demand, headers=headers)
stage0 = json.loads(response.text)['data'][0]['guid']


#%% New hubs 

response = requests.get(f"{base_url}/scenarios/{scenarioGuid}/hubs", headers=headers)
hub_rp = json.loads(response.text)

hub_current = {}
for k in json.loads(response.text)['data']:
    hub_current[k['hubName']] = k['hubGuid']


ini_name = [k for k in os.listdir(sympheny_data) if 'ele' in k][0].split('_')
for k in enumerate(ini_name):
    if 'ele' in k[1]:
        pos_ele = k[0]
hubs = []
for k in os.listdir(sympheny_data):
    hubs.append(hub_naming(k, pos_ele))
hubs = list(set(hubs))

# Make sure the initial hub contains DHW energy carrier (to get the full model as initial in Sympheny)

hubs_add = hubs.copy()
hubs_dhw = [k.replace('_dhw.xlsx', '') for k in os.listdir(sympheny_data) if 'dhw' in k]

if 'ini' not in hubs:
    payload = json.dumps(
        {
          "hubName": hubs_dhw[0]
          }
        )
    response = requests.put(f"{base_url}/scenarios/hubs/{hub_current['ini']}", headers=headers, data=payload)
    hubs_add.remove(hubs_dhw[0])
else:
    hubs_add.remove('ini')

if len(hubs_add) > 0:
    for k in hubs_add:
        payload = json.dumps(
            {
             "hubName": k
             }
            )
        response = requests.post(f"{base_url}/scenarios/{scenarioGuid}/hubs", headers=headers, data=payload)

response = requests.get(f"{base_url}/scenarios/{scenarioGuid}/hubs", headers=headers)
hub_rp = json.loads(response.text)

hub_current = {}
for k in json.loads(response.text)['data']:
    hub_current[k['hubName']] = k['hubGuid']


#%% Delete energy demands (if exist)

response = requests.get(f"{base_url}/scenarios/{scenarioGuid}/energy-demands", headers=headers)
rp = json.loads(response.text)['data']['energyDemands']
energyDemandGuid = [k['energyDemandGuid'] for k in rp]

if len(energyDemandGuid) > 0:
    for k in energyDemandGuid:
        response = requests.delete(f"{base_url}/scenarios/energy-demands/{k}", headers=headers)


#%% Delete existing energy profiles (demand related, not import nor on-site)

response = requests.get(f"{base_url}/scenarios/{scenarioGuid}/profiles", headers=headers)
rp = json.loads(response.text)['data']
if len(rp) > 0:
    for k in rp:
        response = requests.delete(f"{base_url}/scenarios/{scenarioGuid}/profiles/{k['id']}", headers=headers)

#%% Upload energy profiles

files = os.listdir(sympheny_data)
for k in files:
    temp = pd.read_excel(os.path.join(sympheny_data, k), header=None)[1].to_list()
    payload = {
        "name": k.replace('.xlsx', ''),
        "values": {
            "encodedFile": create_excel_file(temp),
            "fileName": k
        }
    }
    response = requests.post(f"{base_url}/scenarios/{scenarioGuid}/profiles", json=payload, headers=headers)

#%% Get energy carriers

response = requests.get(f"{base_url}/scenarios/{scenarioGuid}/carriers", headers=headers)
energy_scenario = json.loads(response.text)["data"]["energyCarriers"]
energy_carrier = {}
for k in energy_scenario:
    energy_carrier[k['energyCarrierName']] = k['energyCarrierGuid']


#%% Add new energy demands

response = requests.get(f"{base_url}/scenarios/{scenarioGuid}/profiles", headers=headers)
rp = json.loads(response.text)['data']

carrier_name = {'ele': 'Electricity', 'coo':'Cooling final', 
                'hea': 'SH final', 'dhw':'DHW final'}

for k in rp:
    name = k['name'].replace('.xlsx', '')
    if any(k in name for k in hub_current.keys()):
        payload = {
            "demandProfileId": k['id'],
            "energyCarrierGuid": energy_carrier[carrier_name[name.split('_')[-1]]],
            "hubGuids": [hub_current[j] for j in hub_current.keys() if j == name.split('_')[0]],
            "name": name,
            "reverse": False,
            "stages": [stage0],
            "demandSalePrice":0
        }
        response = requests.post(f"{base_url}/v2/scenarios/{scenarioGuid}/energy-demands", json=payload, headers=headers)

files = os.listdir(sympheny_data)
hubs_dhw = [k.replace('_dhw.xlsx', '') for k in os.listdir(sympheny_data) if 'dhw' in k]
hubs_without_dhw = [k for k in hubs if k not in hubs_dhw]


#%% Upload imports/exports

"Imports and exports are global (all hubs) so manually added for now"

pre_payload = {"capacityPriceCHFkWMonth":None,
  "capacityPriceCHFkWYear":None,
  "co2IntensityKgCo2kWhCo2CompensationKgCo2kWh":None,
  "dynamicCo2ProfileId":154767,
  "energyPriceCHFkWh":0.143,
  "fixedOmPriceCHFYear":None,
  "hourlyEnergyPriceProfileId":None,
  "maxCapacityKW":None,
  "maximumHourlyEnergyAvailableProfileId":None,
  "name":"Electricity",
  "priceComponents":[],
  "stages":[],
  "totalAnnualEnergyAvailableKWhA":None,
  "type":None,
  "energyCarrierGuid":None,
  "hubs":[],
  "timeOfUses":[]}

response = requests.get(f"{base_url}/v2/scenarios/{scenarioGuid}/impexes", headers=headers)
rp = json.loads(response.text)['data']

for k in rp:
    if k['name'] != 'export_electricity':
        payload = copy.deepcopy(pre_payload)
        for j in k:
            if j in payload.keys():
                payload[j] = k[j]
        payload["energyCarrierGuid"]= k['energyCarrier']['energyCarrierGuid']
        flag_plant = False
        if 'plant' in hub_current.keys():
            for h in payload['hubs']:
                if h['hubGuid'] == hub_current['plant']:
                    flag_plant = True
        hubs_demand = [{"hubGuid":hub_current[m]} for m in hubs]
        if flag_plant == True:
            hubs_demand.append({"hubGuid": hub_current['plant']})
        payload['hubs'] = hubs_demand
        payload['type'] = payload['type'].upper()
        response = requests.put(f"{base_url}/v2/scenarios/impex/{k['guid']}", headers=headers, json=payload)


#%% Getting scenarios GUID + creating Scenario


response = requests.get(f"{base_url}/scenarios/{scenarioGuid_ini}/carriers", headers=headers)
energy_scenario = json.loads(response.text)["data"]["energyCarriers"]
energy_carrier_ini = {}
for k in energy_scenario:
    energy_carrier_ini[k['energyCarrierName']] = k['energyCarrierGuid']


#%% Update conversion technologies

response = requests.get(f"{base_url}/scenarios/{scenarioGuid_ini}/carriers", headers=headers)
energy_scenario = json.loads(response.text)["data"]["energyCarriers"]
energy_carrier_ini = {}
for k in energy_scenario:
    energy_carrier_ini[k['energyCarrierName']] = k['energyCarrierGuid']

response = requests.get(f"{base_url}/v2/scenarios/{scenarioGuid}/conversion-technologies", headers=headers)
rp = json.loads(response.text)['data']

response = requests.get(f"{base_url}/v2/scenarios/{scenarioGuid_ini}/conversion-technologies", headers=headers)
rp_ini = json.loads(response.text)['data']['conversionTechnologies']

converting_list = [k['conversionTechnologyGuid'] for k in rp['conversionTechnologies'] if (k['hubs'][0]['hubName'] != 'plant')]
dhw_carrier = [energy_carrier[k] for k in energy_carrier if 'dhw' in k.lower()]

for tech in converting_list:
    dhw_flag = False
    url_tech = f"{base_url}/v2/scenarios/conversion-technologies/{tech}"
    response = requests.get(url_tech, headers=headers)
    rp = json.loads(response.text)['data']
    summary = copy.deepcopy(conversion_v2)
    ll = []
    for k in rp.keys():
        if k in summary.keys():
            ll.append(k)
            summary[k] = rp[k]
    
    ll.append('hubGuids')
    l_mode = []
    l_mode_without = []
    for num, k in enumerate(rp['technologyModes']):
        dhw_current = False
        mode = copy.deepcopy(summary['conversionTechnologyModes'][0])
        for j in k.keys():
            if j in mode.keys():
                mode[j] = k[j]
        mode['seasonalOperation'] = k['seasonalOperationValue']
        l_ene = []
        for n in ['input', 'output']:
            for m in k[f'{n}EnergyCarriers']:
                ene = copy.deepcopy(summary['conversionTechnologyModes'][0]['energyCarriers'][0])
                for j in m.keys():
                    if j in ene.keys():
                        ene[j] = m[j]
                ene['type'] = n.upper()
                
                if ene['customInputShareActivated'] == True:
                    for r in rp_ini:
                        if rp['processName'] == r['processName']:
                            for l_b in r['conversionTechnologyModes'][num]['inputEnergyCarriers']:
                                if l_b['energyCarrierName'] == next((label for label, item in energy_carrier.items() if item == ene['energyCarrierGuid']), None):
                                    ene['customSeasonalityValues'] = l_b['customSeasonalityValues']
                if ene['customOutputEfficiencyActivated'] == True:
                    for r in rp_ini:
                        if rp['processName'] == r['processName']:
                            for l_b in r['conversionTechnologyModes'][num]['outputEnergyCarriers']:
                                if l_b['energyCarrierName'] == next((label for label, item in energy_carrier.items() if item == ene['energyCarrierGuid']), None):
                                    ene['customSeasonalityValues'] = l_b['customSeasonalityValues']
                                    
                if ene['energyCarrierGuid'] in dhw_carrier:
                    dhw_current = True
                    dhw_flag = True
                l_ene.append(ene)
        mode['energyCarriers'] = l_ene
        l_mode.append(mode)
        if dhw_current == False:
            l_mode_without.append(mode)
    ll.append('conversionTechnologyModes')
    
    to_del = []
    to_del = [k for k in summary.keys() if k not in ll]
    for k in to_del:
        del summary[k]
    
    if dhw_flag == True:
        summary['hubGuids'] = [hub_current[hub] for hub in hubs_dhw]
        summary['conversionTechnologyModes'] = l_mode

        payload = json.dumps(summary)
        response = requests.put(url_tech, headers=headers, data=payload)
            
        if len(hubs_without_dhw) > 0:
            summary['hubGuids'] = [hub_current[hub] for hub in hubs_without_dhw]
            summary['conversionTechnologyModes'] = l_mode_without
            summary['processName'] = f"{summary['processName']} (no DHW)"
            if len(l_mode_without) > 0:
                payload = json.dumps(summary)
                response = requests.post(f"{base_url}/v2/scenarios/{scenarioGuid}/conversion-technologies", headers=headers, data=payload)

    else:
        summary['hubGuids'] = [hub_current[hub] for hub in hubs]
        summary['conversionTechnologyModes'] = l_mode
        payload = json.dumps(summary)
        response = requests.put(url_tech, headers=headers, data=payload)


#%% Update storage technologies

response = requests.get(f"{base_url}/v2/scenarios/{scenarioGuid}/storage-technologies", headers=headers)
rp = json.loads(response.text)['data']
storage_dict = {k['storageTechnologyGuid']: k['storageName'] for k in rp['storageTechnologies']}
dhw_carrier = [energy_carrier[k] for k in energy_carrier if 'dhw' in k.lower()]
max_capacity = pd.read_excel(additional_values, sheet_name='storage_capacity', index_col=0)

for n in storage_dict.keys():
    url_sto = f"{base_url}/v2/scenarios/storage-technologies/{n}"
    response = requests.get(url_sto, headers=headers)
    rp = json.loads(response.text)['data']
    if any(k['hubGuid'] in hub_current[hub] for hub in hubs for k in rp['hubs']):
        summary = copy.deepcopy(storage_v2)
        ll = []
        for k in rp.keys():
            if k in summary.keys():
                summary[k] = rp[k]
                ll.append(k)
        summary['energyCarrierGuid'] = rp['storageCarrier']['energyCarrierGuid']
        ll.append('energyCarrierGuid')
        
        if storage_dict[n] in max_capacity.columns:
            requests.delete(f"{base_url}/scenarios/storage-technologies/{n}", headers=headers)
            nouv = max_capacity[pd.notna(max_capacity[storage_dict[n]])]
            ll.append('hubGuids')
            storage_ini = summary['storageName']
            for h in nouv.index:
                summary['storageName'] = f'{storage_ini} {h}'
                summary['hubGuids'] = [hub_current[h]]
                summary['maximumCapacity'] = int(nouv.loc[h, storage_dict[n]])
            
                to_del = []
                to_del = [k for k in summary.keys() if k not in ll]
                for k in to_del:
                    del summary[k]
                
                payload = json.dumps(summary)
                response = requests.post(f"{base_url}/v2/scenarios/{scenarioGuid}/storage-technologies", headers=headers, data=payload)
                rp = json.loads(response.text)


        
#%% Complete the network

if 'plant' in hub_current.keys(): 
    response = requests.get(f"{base_url}/v2/scenarios/{scenarioGuid}/network-links", headers=headers)
    rp = json.loads(response.text)['data']
    
    response = requests.get(f"{base_url}/v2/scenarios/{scenarioGuid}/network-technologies", headers=headers)
    rpb = json.loads(response.text)['data']['networkTechnologies']
    
    if len(rp) > 0:
        for k in rp:
            requests.delete(f"{base_url}/scenarios/{scenarioGuid}/network-links/{k['networkLinkGuid']}", headers=headers)
        
    network = pd.read_excel(additional_values, sheet_name='connections')
    
    for j in rpb:
        for k in network.index:
            payload = {"mustBeInstalled": False,
                        "length": int(network.loc[k, 'length']),
                        "technologyCapacity": "optimize",
                        "uniDirectionalFlow": False,
                        "node1Guid": hub_current[network.loc[k, 'hub1']],
                        "node2Guid": hub_current[network.loc[k, 'hub2']],
                        "networkTechnologyGuid": j['networkTechnologyGuid'],
                        "costComponents": [],
                        "name": f"{network.loc[k, 'name']}_{j['networkTechnologyName']}"
                        }
        
            response = requests.post(f"{base_url}/v2/scenarios/{scenarioGuid}/network-links", headers=headers, json=payload)