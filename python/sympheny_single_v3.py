# -*- coding: utf-8 -*-
"""
Created on Fri Mar 29 17:41:50 2024

@author: remi

Step by step script:
    1- Delete + Create a new scenario based on "single_hub"
    2- Populate the scenario with the different hubs
    3- Add the energy demands (based on xlsx files) for Cooling + Space heating + Domestic hot water + Electricity
    4- Add on-site resources (extend the existing ones to all the hubs)
    5- Add the supply technologies (extend the existing one to all the hubs)
Improvements:
    2- Hubs : import geospatial data
    5- Imports and exports : dynamic price, how to send a file?
    
"""

import json
import requests
import copy
import os
import pandas as pd
from ESTCP.dict_sympheny import conversion_v2, storage_v2

#%% Initialisation

sympheny_username = "hcasperfu@lbl.gov" #@param {type:"string"}
sympheny_password = "DoD!ESTCP" #@param {type:"string"}
sympheny_data = r'C:\git\thermal-grid-jba\Resources\Data\Consumption\test_sympheny'
additional_values = r'C:\drive\ESTCP\Sympheny\additional_9hubs.xlsx'

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
analysis_name = "jba"
scenario_name = "single_hub"
scenario_new = "single_new"

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


#%% Update conversion technologies

response = requests.get(f"{base_url}/scenarios/{scenarioGuid}/carriers", headers=headers)
energy_scenario = json.loads(response.text)["data"]["energyCarriers"]
energy_carrier = {}
for k in energy_scenario:
    energy_carrier[k['energyCarrierName']] = k['energyCarrierGuid']

response = requests.get(f"{base_url}/scenarios/{scenarioGuid_ini}/carriers", headers=headers)
energy_scenario = json.loads(response.text)["data"]["energyCarriers"]
energy_carrier_ini = {}
for k in energy_scenario:
    energy_carrier_ini[k['energyCarrierName']] = k['energyCarrierGuid']

response = requests.get(f"{base_url}/v2/scenarios/{scenarioGuid_ini}/conversion-technologies", headers=headers)
rp_ini = json.loads(response.text)['data']['conversionTechnologies']

response = requests.get(f"{base_url}/v2/scenarios/{scenarioGuid}/conversion-technologies", headers=headers)
rp = json.loads(response.text)['data']

converting_list = [k['conversionTechnologyGuid'] for k in rp['conversionTechnologies'] if (k['hubs'][0]['hubName'] != 'plant')]

for tech in converting_list:
    url_tech = f"{base_url}/v2/scenarios/conversion-technologies/{tech}"
    response = requests.get(url_tech, headers=headers)
    rp = json.loads(response.text)['data']
    summary = copy.deepcopy(conversion_v2)
    ll = []
    for k in rp.keys():
        if k in summary.keys():
            ll.append(k)
            summary[k] = rp[k]
    
    summary['hubGuids'] = [hub['hubGuid'] for hub in rp['hubs']]
    ll.append('hubGuids')
    l_mode = []
    l_mode_without = []
    for num, k in enumerate(rp['technologyModes']):
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

                l_ene.append(ene)
        mode['energyCarriers'] = l_ene
        l_mode.append(mode)
    ll.append('conversionTechnologyModes')
    
    to_del = []
    to_del = [k for k in summary.keys() if k not in ll]
    for k in to_del:
        del summary[k]

    summary['conversionTechnologyModes'] = l_mode
    payload = json.dumps(summary)
    response = requests.put(url_tech, headers=headers, data=payload)

