# -*- coding: utf-8 -*-
"""
Created on Thu Apr  4 22:44:54 2024

@author: remi

Conversion_ini is different from the API
Compared to the original:
    - customSeasonalityValues removed
    - outputEfficiencyProfileFile removed
"""

conversion_ini = {
    "advancedPVModel": True,
    "capacity": 0,
    "comesFromDb": "string",
    "conversionTechnologyModes":
        [{
            "energyCarriers": 
                [{
                    "customInputEfficiencyActivated": True,
                    "customOutputEfficiencyActivated": True,
                    "energyCarrierGuid": "string",
                    "fixedInputShare": 0,
                    "outputEfficiency": 0,
                    "primary": True,
                    "type": "string"
                }],
            "primary": True,
            "seasonalOperation": "string"
        }],
    "costComponents": 
        [{
            "category": "string",
            "complexityFactor": 0,
            "dataPoints": 0,
            "interestRate": 0,
            "length": 0,
            "lifetime": 0,
            "name": "string",
            "numberOfPumps": 0,
            "value": 0
        }],
    "curtailmentLimitation": 0,
    "efficiencyPVCell": 0,
    "exchangeCurrency": "string",  
    "exchangeRate": 0,
    "fixedEmbodiedCo2": 0,
    "fixedInvestmentCost": 0,
    "fixedOmCostChf": 0,
    "fixedOmCostPercent": 0,
    "hubGuids": ["string"],
    "lifetime": 0,
    "maximumAnnualOutput": 0,
    "maximumCapacity": 0,
    "minimumAnnualOutput": 0,
    "minimumCapacity": 0,
    "mustBeInstalledInHubs": "string",
    "mutuallyExclusiveGroup": "string",
    "notes": "string",
    "processName": "string",
    "pvSizingFactorWpeakM2": 0,
    "safetyMargin": 0,
    "source": "string",
    "suggested": True,
    "systemEfficiency": 0,
    "technologyCapacity": "string",
    "technologyCategory": "string",
    "variableCapturedCo2": 0,
    "variableEmbodiedCo2": 0,
    "variableEmittedCo2": 0,
    "variableInvestmentCost": 0,
    "variableOmCost": 0,
    "variableOmCostYear": 0,
    "virtual": True
}
    
    

storage_ini = {
  "capacity": 0,
  "comesFromDb": "string",
  "costComponents": [
    {
      "category": "string",
      "complexityFactor": 0,
      "dataPoints": 0,
      "interestRate": 0,
      "length": 0,
      "lifetime": 0,
      "name": "string",
      "numberOfPumps": 0,
      "value": 0
    }
  ],
  "drivingDistanceKms": 0,
  "energyCarrierGuid": "string",
  "evAverageKWhPerKm": 0,
  "evBatterySizeKWh": 0,
  "evPlugInDurationHours": 0,
  "evPlugInPowerKW": 0,
  "evPlugInTime": {
    "hour": 0,
    "minute": 0,
    "nano": 0,
    "second": 0
  },
  "evPlugOutTime": {
    "hour": 0,
    "minute": 0,
    "nano": 0,
    "second": 0
  },
  "evSocStartPercent": 0,
  "exchangeCurrency": "string",
  "exchangeRate": 0,
  "fixedEmbodiedCo2": 0,
  "fixedInvestmentCost": 0,
  "fixedOmCostChf": 0,
  "fixedOmCostPercent": 0,
  "hubGuids": [
    "string"
  ],
  "isEvBattery": True,
  "lifetime": 0,
  "maximumCapacity": 0,
  "maximumChargingRate": 0,
  "maximumDischargingRate": 0,
  "maximumSocPercent": 0,
  "minimumCapacity": 0,
  "minimumSoc": 0,
  "mustBeInstalled": "string",
  "mutuallyExclusiveGroup": "string",
  "notes": "string",
  "source": "string",
  "standByLossProfileId": 0,
  "standbyLoss": 0,
  "storageChargingEfficiency": 0,
  "storageDischargingEfficiency": 0,
  "storageName": "string",
  "suggested": True,
  "technologyCapacity": "string",
  "technologyCategory": "string",
  "typeOfCharging": "Smart",
  "variableEmbodiedCo2": 0,
  "variableInvestmentCost": 0,
  "variableOmCost": 0
}