""" Plot fan energy use
"""
import matplotlib.pyplot as plt
import numpy as np

from fanEnergyUse import PFan

# Cooling design flow rate
QCooMax = 10000.0

QCoo = np.linspace(0.0, QCooMax, num=50)
PFan = np.array([PFan(Q, QCooMax) for Q in QCoo])

plt.plot(QCoo/max(QCoo), PFan/max(PFan))
plt.xlabel("$Q_{coo}$/$Q_{coo,0}$")
plt.ylabel("$P_{fan}/P_{fan,0}$")
plt.grid()
plt.savefig("fanEnergy.pdf", format="pdf", bbox_inches="tight")
plt.show()
