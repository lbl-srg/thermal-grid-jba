def PFan(QCoo, QCoo_nominal):
   '''
   Python function to approximate the energy use of the fan
   in the air handler unit.

   Args:
     QCoo (double): Actual cooling demand in Watt.
     QCoo_nominal (double): Design cooling demand in Watt.
   '''
   # Design temperature difference betweeen mixed air and cooling supply temp
   dT0 = 10.
   # Design flow rate
   V0 = QCoo_nominal /  1006. / dT0
   # Minimum flow rate ratio
   ratVMin = 0.2
   # Current design flow rate, assumed to be based on air flow reset
   # with minimum air flow rate up to 70% of design cooling load, and then
   # linearly increasing to the maximum cooling heat flow rate.
   # At heating, assume we are at minimum flow rate.
   ratQ = QCoo/QCoo_nominal
   if ratQ < 0.7:
       V = ratVMin*V0
   else:
       # Linear increase from ratVMin to 1
       V = (ratVMin + (ratQ-0.7)/(1-0.7) * (1-ratVMin)) * V0

   # Fan pressure rise.
   # Assume dpStaPre static pressure at minimum volume flow rate
   dpFanMax = 2000
   dpStaPre = 400
   dp = dpStaPre + (dpFanMax-dpStaPre)* (V/V0) * (V/V0)

   # Fan power use
   etaFan = 0.7
   P = V*dp/etaFan

   return P
