within ThermalGridJBA.Networks.BaseClasses;
model Generations
  "Cooling and heating generation from the heat pump and heat exchanger"
  package MediumW = Buildings.Media.Water "Water";
//   package MediumG = Modelica.Media.Incompressible.Examples.Glycol47 "Glycol";
  package MediumG = Buildings.Media.Antifreeze.PropyleneGlycolWater(property_T=293.15, X_a=0.40) "Glycol";
  parameter Real TLooMin(
    unit="K",
    displayUnit="degC")=283.65
    "Design minimum district loop temperature";
  parameter Real TLooMax(
    unit="K",
    displayUnit="degC")=297.15
    "Design maximum district loop temperature";
  parameter Real mWat_flow_nominal(unit="kg/s")
    "Nominal water mass flow rate";
  parameter Real dpValve_nominal(unit="Pa")=6000
    "Nominal pressure drop of fully open 2-way valve";
  // Heat exchanger parameters
  parameter Real dpHex_nominal(unit="Pa")=10000
    "Pressure difference across heat exchanger"
    annotation (Dialog(group="Heat exchanger"));
  parameter Real mHexGly_flow_nominal(unit="kg/s")
    "Nominal glycol mass flow rate for heat exchanger"
    annotation (Dialog(group="Heat exchanger"));
  // Heat exchanger parameters
  parameter Real dpDryCoo_nominal(unit="Pa")=10000
    "Nominal pressure drop of dry cooler"
    annotation (Dialog(group="Dry cooler"));
  parameter Real mDryCoo_flow_nominal(unit="kg/s")=mHexGly_flow_nominal +
    mHpGly_flow_nominal
    "Nominal glycol mass flow rate for dry cooler"
    annotation (Dialog(group="Dry cooler"));
  // Heat pump parameters
  parameter Real mWat_flow_min(unit="kg/s")
    "Heat pump minimum water mass flow rate"
    annotation (Dialog(group="Heat pump"));
  parameter Real mHpGly_flow_nominal(unit="kg/s")
    "Nominal glycol mass flow rate for heat pump"
    annotation (Dialog(group="Heat pump"));
  parameter Real QHeaPumHea_flow_nominal(unit="W")=cpWat*mWat_flow_nominal*TApp
                             "Nominal heating capacity"
    annotation (Dialog(group="Heat pump"));
  parameter Real TConHea_nominal(unit="K")=TLooMin + TApp
    "Nominal temperature of the heated fluid in heating mode"
    annotation (Dialog(group="Heat pump"));
  parameter Real TEvaHea_nominal(unit="K")=TLooMin
    "Nominal temperature of the cooled fluid in heating mode"
    annotation (Dialog(group="Heat pump"));
  parameter Real QHeaPumCoo_flow_nominal(unit="W")=-cpWat*mWat_flow_nominal*
    TApp                     "Nominal cooling capacity"
    annotation (Dialog(group="Heat pump"));
  parameter Real TConCoo_nominal(unit="K")=TLooMax
    "Nominal temperature of the cooled fluid in cooling mode"
    annotation (Dialog(group="Heat pump"));
  parameter Real TEvaCoo_nominal(unit="K")=TLooMax + TApp
    "Nominal temperature of the heated fluid in cooling mode"
    annotation (Dialog(group="Heat pump"));

  parameter Real samplePeriod(unit="s")=7200
    "Sample period of district loop pump speed"
    annotation (Dialog(tab="Controls", group="Indicators"));
  parameter Real TAppSet(unit="K")=2
    "Dry cooler approch setpoint"
    annotation (Dialog(tab="Controls", group="Dry cooler"));
  parameter Real TApp(unit="K")=4
    "Approach temperature for checking if the dry cooler should be enabled"
    annotation (Dialog(tab="Controls", group="Dry cooler"));
  parameter Real minFanSpe=0.1
    "Minimum dry cooler fan speed"
    annotation (Dialog(tab="Controls", group="Dry cooler"));
  parameter Buildings.Controls.OBC.CDL.Types.SimpleController fanConTyp=
      Buildings.Controls.OBC.CDL.Types.SimpleController.PI
    "Type of dry cooler fan controller"
    annotation (Dialog(tab="Controls", group="Dry cooler"));
  parameter Real kFan=1 "Gain of controller"
    annotation (Dialog(tab="Controls", group="Dry cooler"));
  parameter Real TiFan=0.5 "Time constant of integrator block"
    annotation (Dialog(tab="Controls", group="Dry cooler",
      enable=fanConTyp == Buildings.Controls.OBC.CDL.Types.SimpleController.PI
          or fanConTyp == Buildings.Controls.OBC.CDL.Types.SimpleController.PID));
  parameter Real TdFan=0.1 "Time constant of derivative block"
    annotation (Dialog(tab="Controls", group="Dry cooler",
      enable=fanConTyp == Buildings.Controls.OBC.CDL.Types.SimpleController.PD
          or fanConTyp == Buildings.Controls.OBC.CDL.Types.SimpleController.PID));
  parameter Real TCooSet(unit="K")=TLooMin
    "Heat pump tracking temperature setpoint in cooling mode"
    annotation (Dialog(tab="Controls", group="Heat pump"));
  parameter Real THeaSet(unit="K")=TLooMax
    "Heat pump tracking temperature setpoint in heating mode"
    annotation (Dialog(tab="Controls", group="Heat pump"));
  parameter Real TConInMin(unit="K")=TLooMax - TApp - TAppSet
    "Minimum condenser inlet temperature"
    annotation (Dialog(tab="Controls", group="Heat pump"));
  parameter Real TEvaInMax(unit="K")=TLooMin + TApp + TAppSet
    "Maximum evaporator inlet temperature"
    annotation (Dialog(tab="Controls", group="Heat pump"));
  parameter Real offTim(unit="s")=12*3600
     "Heat pump off time due to the low compressor speed"
    annotation (Dialog(tab="Controls", group="Heat pump"));
  parameter Real holOnTim(unit="s")=1800
    "Heat pump hold on time"
    annotation (Dialog(tab="Controls", group="Heat pump"));
  parameter Real holOffTim(unit="s")=1800
    "Heat pump hold off time"
    annotation (Dialog(tab="Controls", group="Heat pump"));
  parameter Real minComSpe=0.2
    "Minimum heat pump compressor speed"
    annotation (Dialog(tab="Controls", group="Heat pump"));
  parameter Buildings.Controls.OBC.CDL.Types.SimpleController heaPumConTyp=
      Buildings.Controls.OBC.CDL.Types.SimpleController.PI
    "Heat pump controller type"
    annotation (Dialog(tab="Controls", group="Heat pump"));
  parameter Real kHeaPum=1 "Gain of controller"
    annotation (Dialog(tab="Controls", group="Heat pump"));
  parameter Real TiHeaPum=0.5 "Time constant of integrator block"
    annotation (Dialog(tab="Controls", group="Heat pump",
      enable=heaPumConTyp == Buildings.Controls.OBC.CDL.Types.SimpleController.PI
          or heaPumConTyp == Buildings.Controls.OBC.CDL.Types.SimpleController.PID));
  parameter Real TdHeaPum=0.1 "Time constant of derivative block"
    annotation (Dialog(tab="Controls", group="Heat pump",
      enable=fanConTyp == Buildings.Controls.OBC.CDL.Types.SimpleController.PD
          or fanConTyp == Buildings.Controls.OBC.CDL.Types.SimpleController.PID));
  parameter Buildings.Controls.OBC.CDL.Types.SimpleController thrWayValConTyp=
      Buildings.Controls.OBC.CDL.Types.SimpleController.PI
    "Three-way valve controller type"
    annotation (Dialog(tab="Controls", group="Heat pump"));
  parameter Real kVal=1 "Gain of controller"
    annotation (Dialog(tab="Controls", group="Heat pump"));
  parameter Real TiVal=0.5 "Time constant of integrator block"
    annotation (Dialog(tab="Controls", group="Heat pump",
      enable=thrWayValConTyp == Buildings.Controls.OBC.CDL.Types.SimpleController.PI
          or thrWayValConTyp == Buildings.Controls.OBC.CDL.Types.SimpleController.PID));
  parameter Real TdVal=0.1 "Time constant of derivative block"
    annotation (Dialog(tab="Controls", group="Heat pump",
      enable=thrWayValConTyp == Buildings.Controls.OBC.CDL.Types.SimpleController.PD
          or thrWayValConTyp == Buildings.Controls.OBC.CDL.Types.SimpleController.PID));

  final parameter Real cpWat(
    final quantity="SpecificHeatCapacity",
    final unit="J/(kg.K)")= 4184
    "Water specific heat capacity";
  final parameter Real rhoWat(
    final quantity="Density",
    final unit="kg/m3")=1000
    "Water density";
  final parameter Real cpGly(
    final quantity="SpecificHeatCapacity",
    final unit="J/(kg.K)")= 3620
    "Glycol specific heat capacity at 20 degC";
  final parameter Real rhoGly(
    final quantity="Density",
    final unit="kg/m3")=1044
    "Glycol density at 20 degC";

  Buildings.Controls.OBC.CDL.Interfaces.RealInput uDisPum
    "District loop pump speed"
    annotation (Placement(transformation(extent={{-340,240},{-300,280}}),
        iconTransformation(extent={{-140,70},{-100,110}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput uSolTim
    "Solar time. An output from weather data"
    annotation (Placement(transformation(extent={{-340,210},{-300,250}}),
        iconTransformation(extent={{-140,50},{-100,90}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TMixAve(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC")
    "Average temperature of mixing points after each energy transfer station"
    annotation (Placement(transformation(extent={{-340,120},{-300,160}}),
        iconTransformation(extent={{-140,10},{-100,50}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TDryBul(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC") "Ambient dry bulb temperature"
    annotation (Placement(transformation(extent={{-340,170},{-300,210}}),
        iconTransformation(extent={{-140,-90},{-100,-50}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TWetBul(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC")
    "Ambient wet bulb temperature"
    annotation (Placement(transformation(extent={{-340,90},{-300,130}}),
        iconTransformation(extent={{-140,-110},{-100,-70}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yEleRat
    "Current electricity rate, cent per kWh"
    annotation (Placement(transformation(extent={{300,250},{340,290}}),
        iconTransformation(extent={{100,70},{140,110}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput PFanDryCoo(
    final quantity="Power",
    final unit="W")
    "Electric power consumed by fan"
    annotation (Placement(transformation(extent={{300,210},{340,250}}),
        iconTransformation(extent={{100,50},{140,90}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput PPumDryCoo(
    final quantity="Power",
    final unit="W")
    "Electrical power consumed by dry cool pump"
    annotation (Placement(transformation(extent={{300,180},{340,220}}),
        iconTransformation(extent={{100,30},{140,70}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput PPumHexGly(
    final quantity="Power",
    final unit="W")
    "Electrical power consumed by the glycol pump of HEX"
    annotation (Placement(transformation(extent={{300,150},{340,190}}),
        iconTransformation(extent={{100,10},{140,50}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput PPumHeaPumGly(
    final quantity="Power",
    final unit="W")
    "Electrical power consumed by glycol pump of heat pump"
    annotation (Placement(transformation(extent={{300,120},{340,160}}),
        iconTransformation(extent={{100,-50},{140,-10}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput PCom(
    final quantity="Power",
    final unit="W")
    "Electric power consumed by compressor"
    annotation (Placement(transformation(extent={{300,-50},{340,-10}}),
        iconTransformation(extent={{100,-70},{140,-30}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput PPumHeaPumWat(
    final quantity="Power",
    final unit="W")
    "Electrical power consumed by heat pump waterside pump"
    annotation (Placement(transformation(extent={{300,-160},{340,-120}}),
        iconTransformation(extent={{100,-90},{140,-50}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput PPumCirPum(
    final quantity="Power",
    final unit="W")
    "Electrical power consumed by circulation pump"
    annotation (Placement(transformation(extent={{300,-230},{340,-190}}),
        iconTransformation(extent={{100,-110},{140,-70}})));

  Modelica.Fluid.Interfaces.FluidPort_a port_a(
    redeclare final package Medium = MediumW)
    "Fluid connector for waterflow from the district"
    annotation (Placement(transformation(extent={{-310,-10},{-290,10}}),
      iconTransformation(extent={{-110,-10},{-90,10}})));
  Modelica.Fluid.Interfaces.FluidPort_b port_b(
    redeclare final package Medium = MediumW)
    "Fluid connector for waterflow to the district"
    annotation (Placement(transformation(extent={{290,-10},{310,10}}),
      iconTransformation(extent={{90,-10},{110,10}})));
  Buildings.Fluid.Movers.Preconfigured.FlowControlled_m_flow pumCenPla(
    redeclare final package Medium = MediumW,
    allowFlowReversal=false,
    addPowerToMedium=false,
    use_riseTime=false,
    m_flow_nominal=mWat_flow_nominal,
    dpMax=Modelica.Constants.inf)     "Pump for the whole central plant"
    annotation (Placement(transformation(extent={{-170,-170},{-150,-150}})));
  Buildings.Fluid.Actuators.Valves.TwoWayEqualPercentage valHexByp(
    redeclare final package Medium = MediumW,
    allowFlowReversal=false,
    final m_flow_nominal=mWat_flow_nominal,
    final dpValve_nominal=dpValve_nominal,
    use_strokeTime=false)  "Bypass heat exchanger valve"
    annotation (Placement(transformation(extent={{-70,-170},{-50,-150}})));
  Buildings.Fluid.Actuators.Valves.TwoWayEqualPercentage valHex(
    redeclare final package Medium = MediumW,
    allowFlowReversal=false,
    final m_flow_nominal=mWat_flow_nominal,
    final dpValve_nominal=dpValve_nominal,
    use_strokeTime=false)
    "Heat exchanger valve"
    annotation (Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=90, origin={-100,-100})));
  Buildings.Fluid.HeatExchangers.ConstantEffectiveness hex(
    allowFlowReversal1=false,
    allowFlowReversal2=false,
    redeclare final package Medium1 = MediumG,
    redeclare final package Medium2 = MediumW,
    final m1_flow_nominal=mHexGly_flow_nominal,
    final m2_flow_nominal=mWat_flow_nominal,
    show_T=true,
    final dp1_nominal=dpHex_nominal,
    final dp2_nominal=dpHex_nominal)
    "Economizer"
    annotation (Placement(transformation(extent={{-60,-60},{-80,-40}})));
  Buildings.Fluid.Actuators.Valves.TwoWayEqualPercentage valHeaPum(
    redeclare final package Medium = MediumW,
    allowFlowReversal=false,
    final m_flow_nominal=mWat_flow_nominal,
    final dpValve_nominal=dpValve_nominal,
    use_strokeTime=false)
    "Heat pump water loop valve"
    annotation (Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=90, origin={120,-120})));
  Buildings.Fluid.Movers.Preconfigured.FlowControlled_m_flow pumHeaPumWat(
    redeclare final package Medium = MediumW,
    allowFlowReversal=false,
    final addPowerToMedium=false,
    use_riseTime=false,
    final m_flow_nominal=mWat_flow_nominal,
    dpMax=Modelica.Constants.inf)
    "Pump for heat pump waterside loop"
     annotation (Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=90, origin={120,-80})));
  Buildings.Fluid.HeatExchangers.CoolingTowers.Merkel   dryCoo(
    redeclare final package Medium = MediumG,
    allowFlowReversal=false,
    final m_flow_nominal=mDryCoo_flow_nominal,
    final dp_nominal=dpDryCoo_nominal,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    TWatIn_nominal=273.15 + 30.55,
    TWatOut_nominal=273.15 + 27.55)
    "Dry cooler"
    annotation (Placement(transformation(extent={{40,120},{60,140}})));
  Buildings.Fluid.Movers.Preconfigured.FlowControlled_m_flow pumDryCoo(
    redeclare final package Medium = MediumG,
    allowFlowReversal=false,
    final addPowerToMedium=false,
    use_riseTime=false,
    final m_flow_nominal=mDryCoo_flow_nominal,
    dpMax=Modelica.Constants.inf)
    "Dry cooler pump"
    annotation (Placement(transformation(extent={{-60,120},{-40,140}})));
  Buildings.Fluid.Movers.Preconfigured.FlowControlled_m_flow pumHeaPumGly(
    redeclare final package Medium = MediumG,
    allowFlowReversal=false,
    final addPowerToMedium=false,
    use_riseTime=false,
    final m_flow_nominal=mHpGly_flow_nominal,
    dpMax=Modelica.Constants.inf)
    "Pump for heat pump glycol loop"
    annotation (Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=-90, origin={180,0})));
  Buildings.Fluid.Actuators.Valves.ThreeWayEqualPercentageLinear valHeaPumByp(
    redeclare final package Medium = MediumG,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    use_strokeTime=false,
    final m_flow_nominal=mHpGly_flow_nominal,
    final dpValve_nominal=dpValve_nominal)
    "Heat pump bypass valve"
    annotation (Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=-90, origin={180,60})));
  Buildings.Fluid.Sensors.TemperatureTwoPort entGenTem(redeclare final package
      Medium = MediumW,
    allowFlowReversal=false,
                        final m_flow_nominal=mWat_flow_nominal)
    "Temperature of waterflow entering the generation module"
    annotation (Placement(transformation(extent={{-270,-170},{-250,-150}})));
  Buildings.Fluid.Sensors.TemperatureTwoPort heaPumLea(
    redeclare final package Medium = MediumW,
    allowFlowReversal=false,
    final m_flow_nominal=mWat_flow_nominal)
    "Temperature of waterflow leave heat pump"
    annotation (Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=-90, origin={180,-100})));
  Buildings.Fluid.Sensors.TemperatureTwoPort heaPumGlyIn(
    redeclare final package Medium = MediumG,
    allowFlowReversal=false,
    final m_flow_nominal=mHpGly_flow_nominal)
    "Temperature of glycol entering heat pump"
    annotation (Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=-90, origin={180,30})));
  Buildings.Fluid.Sources.Boundary_pT bou(
    redeclare final package Medium = MediumG,
    nPorts=1)
    "Boundary pressure condition representing the expansion vessel"
    annotation (Placement(transformation(extent={{10,-10},{-10,10}},
        rotation=180, origin={-124,-44})));
  ThermalGridJBA.Networks.Controls.Indicators ind(
    final samplePeriod=samplePeriod)
    "Indicators for district load, electricity rate and season"
    annotation (Placement(transformation(extent={{-260,250},{-240,270}})));
  ThermalGridJBA.Networks.Controls.DryCoolerHex dryCooHexCon(
    final mHexGly_flow_nominal=mHexGly_flow_nominal,
    final mDryCoo_flow_nominal=mDryCoo_flow_nominal,
    final TAppSet=TAppSet,
    final TApp=TApp,
    final minFanSpe=minFanSpe,
    final fanConTyp=fanConTyp,
    final kFan=kFan,
    final TiFan=TiFan,
    final TdFan=TdFan)
     "Control of dry cooler and heat exchanger"
    annotation (Placement(transformation(extent={{-80,200},{-60,220}})));
  ThermalGridJBA.Networks.Controls.HeatPump heaPumCon(
    final mWat_flow_nominal=mWat_flow_nominal,
    final mWat_flow_min=mWat_flow_min,
    final mHpGly_flow_nominal=mHpGly_flow_nominal,
    final TLooMin=TLooMin,
    final TLooMax=TLooMax,
    final TCooSet=TCooSet,
    final THeaSet=THeaSet,
    final TConInMin=TConInMin,
    final TEvaInMax=TEvaInMax,
    final minComSpe=minComSpe,
    final offTim=offTim,
    final holOnTim=holOnTim,
    final holOffTim=holOffTim,
    final heaPumConTyp=heaPumConTyp,
    final kHeaPum=kHeaPum,
    final TiHeaPum=TiHeaPum,
    final TdHeaPum=TdHeaPum,
    final thrWayValConTyp=thrWayValConTyp,
    final kVal=kVal,
    final TiVal=TiVal,
    final TdVal=TdVal)
    "Control of heat pump and the corresponed pumps and valves"
    annotation (Placement(transformation(extent={{-180,160},{-160,180}})));
  Buildings.Fluid.Sensors.TemperatureTwoPort dryCooOut(
    redeclare final package Medium = MediumG,
    allowFlowReversal=false,
    final m_flow_nominal=mDryCoo_flow_nominal)
    "Temperature of dry cooler outlet"
    annotation (Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=0, origin={130,130})));
  Buildings.Fluid.Movers.Preconfigured.FlowControlled_m_flow pumDryCoo1(
    redeclare final package Medium = MediumG,
    allowFlowReversal=false,
    final addPowerToMedium=false,
    use_riseTime=false,
    final m_flow_nominal=mHexGly_flow_nominal,
    dpMax=Modelica.Constants.inf)
    "Dry cooler pump"
    annotation (Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=-90, origin={-20,20})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter gai2(
    final k=mWat_flow_nominal)
    "Convert mass flow rate"
    annotation (Placement(transformation(extent={{-200,10},{-180,30}})));
  Buildings.Fluid.FixedResistances.Junction jun(
    redeclare final package Medium = MediumW,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    portFlowDirection_1=Modelica.Fluid.Types.PortFlowDirection.Entering,
    portFlowDirection_2=Modelica.Fluid.Types.PortFlowDirection.Leaving,
    portFlowDirection_3=Modelica.Fluid.Types.PortFlowDirection.Leaving,
    m_flow_nominal={mWat_flow_nominal,-mWat_flow_nominal,-mWat_flow_nominal},
    dp_nominal={0,0,0})
    annotation (Placement(transformation(extent={{-110,-150},{-90,-170}})));
  Buildings.Fluid.FixedResistances.Junction jun1(
    redeclare final package Medium = MediumW,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    portFlowDirection_1=Modelica.Fluid.Types.PortFlowDirection.Entering,
    portFlowDirection_2=Modelica.Fluid.Types.PortFlowDirection.Leaving,
    portFlowDirection_3=Modelica.Fluid.Types.PortFlowDirection.Entering,
    m_flow_nominal={mWat_flow_nominal,-mWat_flow_nominal,-mWat_flow_nominal},
    dp_nominal={0,0,0})
    annotation (Placement(transformation(extent={{-30,-150},{-10,-170}})));
  Buildings.Fluid.FixedResistances.Junction jun2(
    redeclare final package Medium = MediumW,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    portFlowDirection_1=Modelica.Fluid.Types.PortFlowDirection.Entering,
    portFlowDirection_2=Modelica.Fluid.Types.PortFlowDirection.Leaving,
    portFlowDirection_3=Modelica.Fluid.Types.PortFlowDirection.Leaving,
    m_flow_nominal={mWat_flow_nominal,-mWat_flow_nominal,-mWat_flow_nominal},
    dp_nominal={0,0,0})
    annotation (Placement(transformation(extent={{110,-150},{130,-170}})));
  Buildings.Fluid.FixedResistances.Junction jun3(
    redeclare final package Medium = MediumW,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    portFlowDirection_1=Modelica.Fluid.Types.PortFlowDirection.Entering,
    portFlowDirection_2=Modelica.Fluid.Types.PortFlowDirection.Leaving,
    portFlowDirection_3=Modelica.Fluid.Types.PortFlowDirection.Entering,
    m_flow_nominal={mWat_flow_nominal,-mWat_flow_nominal,-mWat_flow_nominal},
    dp_nominal={0,0,0})
    annotation (Placement(transformation(extent={{170,-150},{190,-170}})));
  Buildings.Fluid.HeatPumps.ModularReversible.Modular heaPum(
    redeclare final package MediumCon = MediumW,
    redeclare final package MediumEva = MediumG,
    use_rev=true,
    allowDifferentDeviceIdentifiers=true,
    use_intSafCtr=true,
    redeclare
      Buildings.Fluid.HeatPumps.ModularReversible.Controls.Safety.Data.Wuellhorst2021
      safCtrPar,
    dTCon_nominal=TApp,
    dpCon_nominal=30000,
    use_conCap=false,
    CCon=3000,
    GConOut=100,
    GConIns=1000,
    dTEva_nominal=TApp,
    dpEva_nominal=30000,
    use_evaCap=false,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    final QHea_flow_nominal=QHeaPumHea_flow_nominal,
    final QCoo_flow_nominal=QHeaPumCoo_flow_nominal,
    redeclare model RefrigerantCycleHeatPumpHeating =
        Buildings.Fluid.HeatPumps.ModularReversible.RefrigerantCycle.ConstantCarnotEffectiveness(
          redeclare Buildings.Fluid.HeatPumps.ModularReversible.RefrigerantCycle.Frosting.NoFrosting
            iceFacCal,
          TAppCon_nominal=0,
          TAppEva_nominal=0),
    redeclare model RefrigerantCycleHeatPumpCooling =
        Buildings.Fluid.Chillers.ModularReversible.RefrigerantCycle.ConstantCarnotEffectiveness(
          redeclare Buildings.Fluid.HeatPumps.ModularReversible.RefrigerantCycle.Frosting.NoFrosting
            iceFacCal,
          TAppCon_nominal=0,
          TAppEva_nominal=0),
    final TConHea_nominal=TConHea_nominal,
    final TEvaHea_nominal=TEvaHea_nominal,
    final TConCoo_nominal=TConCoo_nominal,
    final TEvaCoo_nominal=TEvaCoo_nominal)
    "Reversible heat pump"
    annotation (Placement(transformation(extent={{140,-20},{160,-40}})));

  Buildings.Fluid.Sensors.TemperatureTwoPort leaGenTem(redeclare final package
      Medium = MediumW,
    allowFlowReversal=false,
                        final m_flow_nominal=mWat_flow_nominal)
    "Temperature of waterflow leave the generation module" annotation (
      Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={252,-160})));
  Buildings.Fluid.Delays.DelayFirstOrder delRet(
    redeclare package Medium = MediumG,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    m_flow_nominal=mDryCoo_flow_nominal,
    nPorts=5) "Control volume to mix all returns" annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-110,90})));
  Buildings.Fluid.Delays.DelayFirstOrder delSup(
    redeclare package Medium = MediumG,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    m_flow_nominal=mDryCoo_flow_nominal,
    nPorts=4) "Control volume for all supplies" annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=270,
        origin={210,100})));
equation
  connect(valHex.port_b, hex.port_a2) annotation (Line(
      points={{-100,-90},{-100,-56},{-80,-56}},
      color={0,127,255},
      thickness=0.5));
  connect(valHeaPum.port_b, pumHeaPumWat.port_a) annotation (Line(
      points={{120,-110},{120,-90}},
      color={0,127,255},
      thickness=0.5));
  connect(pumDryCoo.port_b, dryCoo.port_a) annotation (Line(
      points={{-40,130},{40,130}},
      color={0,127,255},
      thickness=0.5));
  connect(port_a, entGenTem.port_a) annotation (Line(
      points={{-300,0},{-280,0},{-280,-160},{-270,-160}},
      color={0,127,255},
      thickness=0.5));
  connect(entGenTem.port_b, pumCenPla.port_a) annotation (Line(
      points={{-250,-160},{-170,-160}},
      color={0,127,255},
      thickness=0.5));
  connect(pumHeaPumGly.port_a, heaPumGlyIn.port_b) annotation (Line(
      points={{180,10},{180,20}},
      color={0,127,255},
      thickness=0.5));
  connect(heaPumGlyIn.port_a, valHeaPumByp.port_2) annotation (Line(
      points={{180,40},{180,50}},
      color={0,127,255},
      thickness=0.5));
  connect(hex.port_b1, bou.ports[1]) annotation (Line(
      points={{-80,-44},{-114,-44}},
      color={0,127,255},
      thickness=0.5));
  connect(uDisPum, ind.uDisPum) annotation (Line(points={{-320,260},{-290,260},
          {-290,264},{-262,264}}, color={0,0,127}));
  connect(uSolTim, ind.uSolTim) annotation (Line(points={{-320,230},{-270,230},
          {-270,256},{-262,256}}, color={0,0,127}));
  connect(ind.yEle, heaPumCon.uEleRat) annotation (Line(points={{-238,261},{-220,
          261},{-220,179},{-182,179}}, color={255,127,0}));
  connect(ind.yEle, dryCooHexCon.uEleRat) annotation (Line(points={{-238,261},{-220,
          261},{-220,219},{-82,219}}, color={255,127,0}));
  connect(ind.ySt, dryCooHexCon.uSt) annotation (Line(points={{-238,266},{-212,266},
          {-212,217},{-82,217}},      color={255,127,0}));
  connect(ind.ySt, heaPumCon.uSt) annotation (Line(points={{-238,266},{-212,266},
          {-212,177},{-182,177}}, color={255,127,0}));
  connect(ind.yGen, dryCooHexCon.uGen) annotation (Line(points={{-238,254},{-228,
          254},{-228,215},{-82,215}},      color={255,127,0}));
  connect(ind.yGen, heaPumCon.uGen) annotation (Line(points={{-238,254},{-228,
          254},{-228,168},{-182,168}}, color={255,127,0}));
  connect(heaPumCon.y1On, dryCooHexCon.u1HeaPum) annotation (Line(points={{-158,
          171},{-120,171},{-120,206},{-82,206}}, color={255,0,255}));
  connect(TMixAve, heaPumCon.TMixAve) annotation (Line(points={{-320,140},{-280,
          140},{-280,174},{-182,174}}, color={0,0,127}));
  connect(heaPumLea.T, heaPumCon.TWatOut) annotation (Line(points={{191,-100},{
          220,-100},{220,-200},{-220,-200},{-220,171},{-182,171}}, color={0,0,
          127}));
  connect(uDisPum, heaPumCon.uDisPum) annotation (Line(points={{-320,260},{-290,
          260},{-290,164},{-182,164}}, color={0,0,127}));
  connect(heaPumGlyIn.T, heaPumCon.TGlyIn) annotation (Line(points={{191,30},{
          226,30},{226,-206},{-226,-206},{-226,161},{-182,161}}, color={0,0,127}));
  connect(TDryBul, dryCooHexCon.TDryBul) annotation (Line(points={{-320,190},{-270,
          190},{-270,209},{-82,209}},      color={0,0,127}));
  connect(entGenTem.T, dryCooHexCon.TGenIn) annotation (Line(points={{-260,-149},
          {-260,212},{-82,212}}, color={0,0,127}));
  connect(dryCoo.port_b, dryCooOut.port_a)
    annotation (Line(points={{60,130},{120,130}}, color={0,127,255},
      thickness=0.5));
  connect(dryCooOut.T, dryCooHexCon.TDryCooOut) annotation (Line(points={{130,141},
          {130,190},{-100,190},{-100,201},{-82,201}},      color={0,0,127}));
  connect(dryCooHexCon.yValHex, valHex.y) annotation (Line(points={{-58,217},{-40,
          217},{-40,150},{-140,150},{-140,-100},{-112,-100}},     color={0,0,
          127}));
  connect(dryCooHexCon.yValHexByp, valHexByp.y) annotation (Line(points={{-58,219},
          {10,219},{10,-120},{-60,-120},{-60,-148}},        color={0,0,127}));
  connect(hex.port_a1, pumDryCoo1.port_b) annotation (Line(
      points={{-60,-44},{-20,-44},{-20,10}},
      color={0,127,255},
      thickness=0.5));
  connect(dryCooHexCon.yDryCoo, dryCoo.y) annotation (Line(points={{-58,202},{20,
          202},{20,138},{38,138}}, color={0,0,127}));
  connect(TWetBul, dryCoo.TAir) annotation (Line(points={{-320,110},{20,110},{20,
          134},{38,134}}, color={0,0,127}));
  connect(heaPumCon.yVal, valHeaPum.y) annotation (Line(points={{-158,165},{80,165},
          {80,-120},{108,-120}}, color={0,0,127}));
  connect(heaPumCon.yValByp, valHeaPumByp.y) annotation (Line(points={{-158,161},
          {234,161},{234,60},{192,60}}, color={0,0,127}));
  connect(dryCooHexCon.yPumHex, pumDryCoo1.m_flow_in) annotation (Line(points={{-58,214},
          {0,214},{0,20},{-8,20}},           color={0,0,127}));
  connect(dryCooHexCon.yPumDryCoo, pumDryCoo.m_flow_in)
    annotation (Line(points={{-58,206},{-50,206},{-50,142}}, color={0,0,127}));
  connect(heaPumCon.yPumGly, pumHeaPumGly.m_flow_in) annotation (Line(points={{-158,
          168},{246,168},{246,0},{192,0}},      color={0,0,127}));
  connect(heaPumCon.yPum, pumHeaPumWat.m_flow_in) annotation (Line(points={{
          -158,163},{86,163},{86,-80},{108,-80}}, color={0,0,127}));
  connect(gai2.y, pumCenPla.m_flow_in) annotation (Line(points={{-178,20},{-160,
          20},{-160,-148}}, color={0,0,127}));
  connect(uDisPum, gai2.u) annotation (Line(points={{-320,260},{-290,260},{-290,
          20},{-202,20}}, color={0,0,127}));
  connect(dryCoo.PFan, PFanDryCoo) annotation (Line(points={{61,138},{100,138},{
          100,230},{320,230}}, color={0,0,127}));
  connect(pumDryCoo.P, PPumDryCoo) annotation (Line(points={{-39,139},{-20,139},
          {-20,200},{320,200}}, color={0,0,127}));
  connect(pumDryCoo1.P, PPumHexGly) annotation (Line(points={{-11,9},{-11,0},{
          104,0},{104,170},{320,170}},  color={0,0,127}));
  connect(pumHeaPumGly.P, PPumHeaPumGly) annotation (Line(points={{189,-11},{
          189,-20},{260,-20},{260,140},{320,140}},
                                               color={0,0,127}));
  connect(pumHeaPumWat.P, PPumHeaPumWat) annotation (Line(points={{111,-69},{111,
          -60},{60,-60},{60,-140},{320,-140}}, color={0,0,127}));
  connect(pumCenPla.P, PPumCirPum) annotation (Line(points={{-149,-151},{-140,-151},
          {-140,-210},{320,-210}}, color={0,0,127}));
  connect(ind.yEleRat, yEleRat) annotation (Line(points={{-238,259},{20,259},{20,
          270},{320,270}}, color={0,0,127}));
  connect(pumCenPla.port_b, jun.port_1)
    annotation (Line(points={{-150,-160},{-110,-160}}, color={0,127,255},
      thickness=0.5));
  connect(jun.port_2, valHexByp.port_a)
    annotation (Line(points={{-90,-160},{-70,-160}}, color={0,127,255},
      thickness=0.5));
  connect(jun.port_3, valHex.port_a)
    annotation (Line(points={{-100,-150},{-100,-110}}, color={0,127,255},
      thickness=0.5));
  connect(valHexByp.port_b, jun1.port_1) annotation (Line(
      points={{-50,-160},{-30,-160}},
      color={0,127,255},
      thickness=0.5));
  connect(hex.port_b2, jun1.port_3) annotation (Line(
      points={{-60,-56},{-20,-56},{-20,-150}},
      color={0,127,255},
      thickness=0.5));
  connect(jun1.port_2, jun2.port_1) annotation (Line(
      points={{-10,-160},{110,-160}},
      color={0,127,255},
      thickness=0.5));
  connect(jun2.port_3, valHeaPum.port_a) annotation (Line(
      points={{120,-150},{120,-130}},
      color={0,127,255},
      thickness=0.5));
  connect(jun2.port_2, jun3.port_1) annotation (Line(
      points={{130,-160},{170,-160}},
      color={0,127,255},
      thickness=0.5));
  connect(jun3.port_3, heaPumLea.port_b) annotation (Line(
      points={{180,-150},{180,-110}},
      color={0,127,255},
      thickness=0.5));
  connect(pumHeaPumWat.port_b, heaPum.port_a1) annotation (Line(
      points={{120,-70},{120,-36},{140,-36}},
      color={0,127,255},
      thickness=0.5));
  connect(heaPum.port_b1, heaPumLea.port_a) annotation (Line(
      points={{160,-36},{180,-36},{180,-90}},
      color={0,127,255},
      thickness=0.5));
  connect(pumHeaPumGly.port_b, heaPum.port_a2) annotation (Line(
      points={{180,-10},{180,-24},{160,-24}},
      color={0,127,255},
      thickness=0.5));
  connect(heaPumCon.y1Mod, heaPum.hea) annotation (Line(points={{-158,179},{96,179},
          {96,-27.9},{138.9,-27.9}}, color={255,0,255}));
  connect(heaPumCon.ySet, heaPum.ySet) annotation (Line(points={{-158,174},{92,174},
          {92,-31.9},{138.9,-31.9}}, color={0,0,127}));
  connect(heaPum.P, PCom)
    annotation (Line(points={{161,-30},{320,-30}}, color={0,0,127}));
  connect(jun3.port_2, leaGenTem.port_a) annotation (Line(
      points={{190,-160},{242,-160}},
      color={0,127,255},
      thickness=0.5));
  connect(leaGenTem.port_b, port_b) annotation (Line(
      points={{262,-160},{280,-160},{280,0},{300,0}},
      color={0,127,255},
      thickness=0.5));
  connect(pumDryCoo.port_a, delRet.ports[1]) annotation (Line(points={{-60,130},
          {-80,130},{-80,88.4},{-100,88.4}},color={0,127,255},
      thickness=0.5));
  connect(hex.port_b1, delRet.ports[2]) annotation (Line(points={{-80,-44},{-80,
          89.2},{-100,89.2}},          color={0,127,255},
      thickness=0.5));
  connect(heaPum.port_b2, delRet.ports[3]) annotation (Line(points={{140,-24},{
          120,-24},{120,90},{-100,90}},
                                   color={0,127,255},
      thickness=0.5));
  connect(delSup.ports[1], delRet.ports[4]) annotation (Line(points={{200,101.5},
          {134,101.5},{134,90.8},{-100,90.8}},
                                           color={0,127,255},
      thickness=0.5));
  connect(valHeaPumByp.port_1, delSup.ports[2]) annotation (Line(points={{180,70},
          {180,100.5},{200,100.5}},        color={0,127,255},
      thickness=0.5));
  connect(pumDryCoo1.port_a, delSup.ports[3]) annotation (Line(points={{-20,30},
          {-20,70},{140,70},{140,99.5},{200,99.5}},
                                  color={0,127,255},
      thickness=0.5));
  connect(dryCooOut.port_b, delSup.ports[4]) annotation (Line(points={{140,130},
          {180,130},{180,98.5},{200,98.5}},                   color={0,127,255},
      thickness=0.5));
  connect(valHeaPumByp.port_3, delRet.ports[5]) annotation (Line(points={{170,60},
          {126,60},{126,91.6},{-100,91.6}},color={0,127,255},
      thickness=0.5));
  connect(heaPumCon.y1Mod, dryCooHexCon.u1HeaPumMod) annotation (Line(points={{-158,
          179},{-116,179},{-116,204},{-82,204}}, color={255,0,255}));
  annotation (defaultComponentName="gen",
  Icon(coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},
            {100,100}}), graphics={
                                Rectangle(
        extent={{-100,-100},{100,100}},
        lineColor={0,0,127},
        fillColor={255,255,255},
        fillPattern=FillPattern.Solid),
       Text(extent={{-100,140},{100,100}},
          textString="%name",
          textColor={0,0,255})}),
                          Diagram(coordinateSystem(preserveAspectRatio=false,
          extent={{-300,-280},{300,280}})));
end Generations;
