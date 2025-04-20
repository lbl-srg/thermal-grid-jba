within ThermalGridJBA.CentralPlants;
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
  parameter Real TPlaHeaSet(
    unit="K",
    displayUnit="degC")=283.65
    "Design plant heating setpoint temperature";
  parameter Real TPlaCooSet(
    unit="K",
    displayUnit="degC")=297.15
    "Design plant cooling setpoint temperature";

  parameter Real mWat_flow_nominal(unit="kg/s")
    "Nominal water mass flow rate";
  parameter Modelica.Units.SI.PressureDifference dpValve_nominal(
    displayUnit="Pa")=6000
    "Nominal pressure drop of fully open 2-way valve";
  // Heat exchanger parameters
  parameter Modelica.Units.SI.PressureDifference dpHex_nominal(displayUnit="Pa")=10000
    "Pressure difference across heat exchanger"
    annotation (Dialog(group="Heat exchanger"));
  parameter Real mHexGly_flow_nominal(unit="kg/s")
    "Nominal glycol mass flow rate for heat exchanger"
    annotation (Dialog(group="Heat exchanger"));
  // Heat exchanger parameters
  parameter Modelica.Units.SI.PressureDifference dpDryCoo_nominal(
    displayUnit="Pa")=10000
    "Nominal pressure drop of dry cooler"
    annotation (Dialog(group="Dry cooler"));
  parameter Real mDryCoo_flow_nominal(unit="kg/s")=mHexGly_flow_nominal +
    mHpGly_flow_nominal
    "Nominal glycol mass flow rate for dry cooler"
    annotation (Dialog(group="Dry cooler"));

  // Borefield parameters
  parameter Modelica.Units.SI.MassFlowRate mBorFiePer_flow_nominal
    "Mass flow rate for perimeter of borefield"
    annotation (Dialog(group="Borefield"));
  parameter Modelica.Units.SI.MassFlowRate mBorFieCen_flow_nominal
    "Mass flow rate for center of borefield"
    annotation (Dialog(group="Borefield"));
  parameter Modelica.Units.SI.PressureDifference dpBorFiePer_nominal(
    displayUnit="Pa")
    "Nominal pressure drop of perimeter zones of borefield"
    annotation (Dialog(group="Borefield"));
  parameter Modelica.Units.SI.PressureDifference dpBorFieCen_nominal(
    displayUnit="Pa")=10000
    "Nominal pressure drop of center zones of borefield"
    annotation (Dialog(group="Borefield"));

  // Heat pump parameters
  parameter Real mHeaPumWat_flow_nominal(unit="kg/s")
    "Heat pump nominal water mass flow rate"
    annotation (Dialog(group="Heat pump"));
  parameter Real mHeaPumWat_flow_min(unit="kg/s")
    "Heat pump minimum water mass flow rate"
    annotation (Dialog(group="Heat pump"));
  parameter Real mHpGly_flow_nominal(unit="kg/s")
    "Nominal glycol mass flow rate for heat pump"
    annotation (Dialog(group="Heat pump"));
  parameter Real QHeaPumHea_flow_nominal(unit="W")=cpWat*mHeaPumWat_flow*TApp
    "Nominal heating capacity"
    annotation (Dialog(group="Heat pump"));
  parameter Real TConHea_nominal(unit="K")=TLooMin + TApp
    "Nominal temperature of the heated fluid in heating mode"
    annotation (Dialog(group="Heat pump"));
  parameter Real TEvaHea_nominal(unit="K")
    "Nominal temperature of evaporator for heat pump design during heating"
    annotation (Dialog(group="Heat pump"));
  parameter Real QHeaPumCoo_flow_nominal(unit="W")=-cpWat*mHeaPumWat_flow*TApp
    "Nominal cooling capacity"
    annotation (Dialog(group="Heat pump"));
  parameter Real TConCoo_nominal(unit="K")
    "Nominal temperature of condenser for heat pump design during cooling"
    annotation (Dialog(group="Heat pump"));
  parameter Real TEvaCoo_nominal(unit="K")=TLooMax + TApp
    "Nominal temperature of the heated fluid in cooling mode"
    annotation (Dialog(group="Heat pump"));

  parameter Real staDowDel(
    unit="s")=3600
    "Minimum stage down delay, to avoid quickly staging down"
    annotation (Dialog(tab="Controls"));
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
//   parameter Real TCooSet(unit="K")=TLooMin
//     "Heat pump tracking temperature setpoint in cooling mode"
//     annotation (Dialog(tab="Controls", group="Heat pump"));
//   parameter Real THeaSet(unit="K")=TLooMax
//     "Heat pump tracking temperature setpoint in heating mode"
//     annotation (Dialog(tab="Controls", group="Heat pump"));
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
  parameter Real minHeaPumSpeHol=120
    "Threshold time for checking if the compressor has been in the minimum speed"
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

  Buildings.Controls.OBC.CDL.Interfaces.RealInput TPlaOut(
    final unit="K",
    final quantity="ThermodynamicTemperature",
    displayUnit="degC")
    "Central plant outlet water temperature"
    annotation (Placement(transformation(extent={{-580,240},{-540,280}}),
        iconTransformation(extent={{-140,60},{-100,100}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput uDisPum
    "District loop pump speed"
    annotation (Placement(transformation(extent={{-580,200},{-540,240}}),
        iconTransformation(extent={{-140,30},{-100,70}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TMixAve(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC")
    "Average temperature of mixing points after each energy transfer station"
    annotation (Placement(transformation(extent={{-580,120},{-540,160}}),
        iconTransformation(extent={{-140,-62},{-100,-22}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TLooMaxMea(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC")
    "Maximum temperature of mixing points after each energy transfer station"
    annotation (Placement(transformation(extent={{-580,80},{-540,120}}),
        iconTransformation(extent={{-140,-102},{-100,-62}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TLooMinMea(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC")
    "Minimum temperature of mixing points after each energy transfer station"
    annotation (Placement(transformation(extent={{-580,40},{-540,80}}),
        iconTransformation(extent={{-140,-142},{-100,-102}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TDryBul(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC") "Ambient dry bulb temperature"
    annotation (Placement(transformation(extent={{-580,170},{-540,210}}),
        iconTransformation(extent={{-140,-2},{-100,38}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yEleRat
    "Current electricity rate, cent per kWh"
    annotation (Placement(transformation(extent={{540,250},{580,290}}),
        iconTransformation(extent={{100,70},{140,110}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput PPumDryCoo(
    final quantity="Power",
    final unit="W")
    "Electrical power consumed by dry cool pump"
    annotation (Placement(transformation(extent={{540,180},{580,220}}),
        iconTransformation(extent={{100,30},{140,70}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput PPumHexGly(
    final quantity="Power",
    final unit="W")
    "Electrical power consumed by the glycol pump of HEX"
    annotation (Placement(transformation(extent={{540,150},{580,190}}),
        iconTransformation(extent={{100,10},{140,50}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput PPumHeaPumGly(
    final quantity="Power",
    final unit="W")
    "Electrical power consumed by glycol pump of heat pump"
    annotation (Placement(transformation(extent={{540,120},{580,160}}),
        iconTransformation(extent={{100,-10},{140,30}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput PPumBorFiePer(
    final quantity="Power",
    final unit="W")
    "Electrical power consumed by pump for borefield perimeter"
    annotation (Placement(transformation(extent={{540,90},{580,130}}),
        iconTransformation(extent={{100,-30},{140,10}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput PPumBorFieCen(
    final quantity="Power",
    final unit="W")
    "Electrical power consumed by pump for borefield center"
    annotation (Placement(transformation(extent={{540,58},{580,98}}),
        iconTransformation(extent={{100,-50},{140,-10}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput PCom(
    final quantity="Power",
    final unit="W")
    "Electric power consumed by compressor"
    annotation (Placement(transformation(extent={{540,-44},{580,-4}}),
        iconTransformation(extent={{100,-70},{140,-30}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput PPumHeaPumWat(
    final quantity="Power",
    final unit="W")
    "Electrical power consumed by heat pump waterside pump"
    annotation (Placement(transformation(extent={{540,-70},{580,-30}}),
        iconTransformation(extent={{100,-90},{140,-50}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput PPumCirPum(
    final quantity="Power",
    final unit="W") "Electrical power consumed by circulation pumps"
    annotation (Placement(transformation(extent={{540,-230},{580,-190}}),
        iconTransformation(extent={{100,-110},{140,-70}})));

  Modelica.Fluid.Interfaces.FluidPort_a port_a(
    redeclare final package Medium = MediumW)
    "Fluid connector for waterflow from the district"
    annotation (Placement(transformation(extent={{-550,-170},{-530,-150}}),
      iconTransformation(extent={{-110,-170},{-90,-150}})));
  Modelica.Fluid.Interfaces.FluidPort_b port_b(
    redeclare final package Medium = MediumW)
    "Fluid connector for waterflow to the district"
    annotation (Placement(transformation(extent={{-550,-250},{-530,-230}}),
      iconTransformation(extent={{-110,-210},{-90,-190}})));
  Buildings.Fluid.Movers.Preconfigured.FlowControlled_m_flow pumCenPlaPri(
    redeclare final package Medium = MediumW,
    allowFlowReversal=false,
    addPowerToMedium=false,
    use_riseTime=false,
    m_flow_nominal=mWat_flow_nominal,
    dpMax=Modelica.Constants.inf)
    "Pump for the primary loop of the central plant"
    annotation (Placement(transformation(extent={{-390,-170},{-370,-150}})));
  Buildings.Fluid.Actuators.Valves.TwoWayEqualPercentage valHexByp(
    redeclare final package Medium = MediumW,
    allowFlowReversal=false,
    final m_flow_nominal=mWat_flow_nominal,
    final dpValve_nominal=dpValve_nominal,
    use_strokeTime=false) "Bypass heat exchanger valve"
    annotation (Placement(transformation(extent={{-290,-170},{-270,-150}})));
  Buildings.Fluid.Actuators.Valves.TwoWayEqualPercentage valHex(
    redeclare final package Medium = MediumW,
    allowFlowReversal=false,
    final m_flow_nominal=mWat_flow_nominal,
    final dpValve_nominal=dpValve_nominal,
    use_strokeTime=false)
    "Heat exchanger valve"
    annotation (Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=90, origin={-320,-100})));
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
    annotation (Placement(transformation(extent={{-280,-40},{-300,-20}})));
  Buildings.Fluid.Actuators.Valves.TwoWayEqualPercentage valHeaPum(
    redeclare final package Medium = MediumW,
    allowFlowReversal=false,
    final m_flow_nominal=mHeaPumWat_flow_nominal,
    final dpValve_nominal=dpValve_nominal,
    use_strokeTime=false)
    "Heat pump water loop valve"
    annotation (Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=90, origin={310,-130})));
  Buildings.Fluid.Movers.Preconfigured.FlowControlled_m_flow pumHeaPumWat(
    redeclare final package Medium = MediumW,
    allowFlowReversal=false,
    final addPowerToMedium=false,
    use_riseTime=false,
    final m_flow_nominal=mHeaPumWat_flow_nominal,
    dpMax=Modelica.Constants.inf) "Pump for heat pump waterside loop"
     annotation (Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=90, origin={310,-40})));
  Buildings.Fluid.HeatExchangers.CoolingTowers.FixedApproach
                                                        dryCoo(
    redeclare final package Medium = MediumG,
    allowFlowReversal=false,
    final m_flow_nominal=mDryCoo_flow_nominal,
    final show_T=true,
    final dp_nominal=dpDryCoo_nominal,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    final TApp=0)
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
        rotation=-90, origin={370,10})));
  Buildings.Fluid.Actuators.Valves.ThreeWayEqualPercentageLinear valHeaPumByp(
    redeclare final package Medium = MediumG,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    use_strokeTime=false,
    final m_flow_nominal=mHpGly_flow_nominal,
    final dpValve_nominal=dpValve_nominal)
    "Heat pump bypass valve"
    annotation (Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=-90, origin={370,70})));
  Buildings.Fluid.Sensors.TemperatureTwoPort senTemEntGen(
    redeclare final package Medium = MediumW,
    allowFlowReversal=false,
    final m_flow_nominal=mWat_flow_nominal)
    "Temperature of waterflow entering the generation module"
    annotation (Placement(transformation(extent={{-490,-170},{-470,-150}})));
  Buildings.Fluid.Sensors.TemperatureTwoPort senTemHeaPumLea(
    redeclare final package Medium = MediumW,
    allowFlowReversal=false,
    final m_flow_nominal=mHeaPumWat_flow_nominal)
    "Temperature of waterflow leave heat pump" annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={370,-72})));
  Buildings.Fluid.Sensors.TemperatureTwoPort senTemHeaPumGlyIn(
    redeclare final package Medium = MediumG,
    allowFlowReversal=false,
    final m_flow_nominal=mHpGly_flow_nominal)
    "Temperature of glycol entering heat pump" annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={370,40})));
  Buildings.Fluid.Sources.Boundary_pT bou(
    redeclare final package Medium = MediumG,
    nPorts=1)
    "Boundary pressure condition representing the expansion vessel"
    annotation (Placement(transformation(extent={{10,-10},{-10,10}},
        rotation=180, origin={-344,-24})));
  Buildings.Fluid.Sensors.TemperatureTwoPort senTemDryCooOut(
    redeclare final package Medium = MediumG,
    allowFlowReversal=false,
    final m_flow_nominal=mDryCoo_flow_nominal)
    "Temperature of dry cooler outlet" annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={130,130})));
  Buildings.Fluid.Movers.Preconfigured.FlowControlled_m_flow pumDryCoo1(
    redeclare final package Medium = MediumG,
    allowFlowReversal=false,
    final addPowerToMedium=false,
    use_riseTime=false,
    final m_flow_nominal=mHexGly_flow_nominal,
    dpMax=Modelica.Constants.inf)
    "Dry cooler pump"
    annotation (Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=-90, origin={-260,16})));
  Buildings.Fluid.FixedResistances.Junction jun(
    redeclare final package Medium = MediumW,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    portFlowDirection_1=Modelica.Fluid.Types.PortFlowDirection.Entering,
    portFlowDirection_2=Modelica.Fluid.Types.PortFlowDirection.Leaving,
    portFlowDirection_3=Modelica.Fluid.Types.PortFlowDirection.Leaving,
    m_flow_nominal={mWat_flow_nominal,-mWat_flow_nominal,-mWat_flow_nominal},
    dp_nominal={0,0,0})
    annotation (Placement(transformation(extent={{-330,-150},{-310,-170}})));
  Buildings.Fluid.FixedResistances.Junction jun1(
    redeclare final package Medium = MediumW,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    portFlowDirection_1=Modelica.Fluid.Types.PortFlowDirection.Entering,
    portFlowDirection_2=Modelica.Fluid.Types.PortFlowDirection.Leaving,
    portFlowDirection_3=Modelica.Fluid.Types.PortFlowDirection.Entering,
    m_flow_nominal={mWat_flow_nominal,-mWat_flow_nominal,mWat_flow_nominal},
    dp_nominal={0,0,0})
    annotation (Placement(transformation(extent={{-250,-150},{-230,-170}})));
  Buildings.Fluid.FixedResistances.Junction jun2(
    redeclare final package Medium = MediumW,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    portFlowDirection_1=Modelica.Fluid.Types.PortFlowDirection.Entering,
    portFlowDirection_2=Modelica.Fluid.Types.PortFlowDirection.Bidirectional,
    portFlowDirection_3=Modelica.Fluid.Types.PortFlowDirection.Leaving,
    m_flow_nominal={mWat_flow_nominal,-mWat_flow_nominal,-
        mHeaPumWat_flow_nominal},
    dp_nominal={0,0,0})
    annotation (Placement(transformation(extent={{300,-150},{320,-170}})));
  Buildings.Fluid.FixedResistances.Junction jun3(
    redeclare final package Medium = MediumW,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    portFlowDirection_1=Modelica.Fluid.Types.PortFlowDirection.Bidirectional,
    portFlowDirection_2=Modelica.Fluid.Types.PortFlowDirection.Leaving,
    portFlowDirection_3=Modelica.Fluid.Types.PortFlowDirection.Entering,
    m_flow_nominal={mWat_flow_nominal,-mWat_flow_nominal,
        mHeaPumWat_flow_nominal},
    dp_nominal={0,0,0})
    annotation (Placement(transformation(extent={{360,-150},{380,-170}})));
  Buildings.Fluid.HeatPumps.ModularReversible.Modular heaPum(
    show_T=true,
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
    allowFlowReversalEva=false,
    allowFlowReversalCon=false,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    final QHea_flow_nominal=QHeaPumHea_flow_nominal,
    final QCoo_flow_nominal=QHeaPumCoo_flow_nominal,
    redeclare model RefrigerantCycleHeatPumpHeating =
        Buildings.Fluid.HeatPumps.ModularReversible.RefrigerantCycle.ConstantCarnotEffectiveness
        (redeclare
          Buildings.Fluid.HeatPumps.ModularReversible.RefrigerantCycle.Frosting.NoFrosting
          iceFacCal),
    redeclare model RefrigerantCycleHeatPumpCooling =
        Buildings.Fluid.Chillers.ModularReversible.RefrigerantCycle.ConstantCarnotEffectiveness
        (redeclare
          Buildings.Fluid.HeatPumps.ModularReversible.RefrigerantCycle.Frosting.NoFrosting
          iceFacCal),
    final TConHea_nominal=TConHea_nominal,
    final TEvaHea_nominal=TEvaHea_nominal,
    final TConCoo_nominal=TConCoo_nominal,
    final TEvaCoo_nominal=TEvaCoo_nominal)
    "Reversible heat pump"
    annotation (Placement(transformation(extent={{330,-10},{350,-30}})));

  Buildings.Fluid.Movers.Preconfigured.FlowControlled_m_flow pumCenPlaSec(
    redeclare final package Medium = MediumW,
    allowFlowReversal=false,
    addPowerToMedium=false,
    use_riseTime=false,
    m_flow_nominal=mWat_flow_nominal,
    dpMax=Modelica.Constants.inf) "Pump for secondary loop of central plant"
    annotation (Placement(transformation(extent={{110,-170},{130,-150}})));
  Buildings.Fluid.FixedResistances.Junction jun4(
    redeclare final package Medium = MediumW,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    portFlowDirection_1=Modelica.Fluid.Types.PortFlowDirection.Entering,
    portFlowDirection_2=Modelica.Fluid.Types.PortFlowDirection.Bidirectional,
    portFlowDirection_3=Modelica.Fluid.Types.PortFlowDirection.Leaving,
    m_flow_nominal={mWat_flow_nominal,-mWat_flow_nominal,-mWat_flow_nominal},
    dp_nominal={0,0,0})
    annotation (Placement(transformation(extent={{170,-150},{190,-170}})));
  Buildings.Fluid.FixedResistances.Junction jun5(
    redeclare final package Medium = MediumW,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    portFlowDirection_1=Modelica.Fluid.Types.PortFlowDirection.Bidirectional,
    portFlowDirection_2=Modelica.Fluid.Types.PortFlowDirection.Leaving,
    portFlowDirection_3=Modelica.Fluid.Types.PortFlowDirection.Entering,
    m_flow_nominal={mWat_flow_nominal,-mWat_flow_nominal,mWat_flow_nominal},
    dp_nominal={0,0,0})
    annotation (Placement(transformation(extent={{230,-150},{250,-170}})));
  Buildings.Fluid.FixedResistances.Junction jun6(
    redeclare final package Medium = MediumW,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    portFlowDirection_1=Modelica.Fluid.Types.PortFlowDirection.Entering,
    portFlowDirection_2=Modelica.Fluid.Types.PortFlowDirection.Bidirectional,
    portFlowDirection_3=Modelica.Fluid.Types.PortFlowDirection.Leaving,
    m_flow_nominal={mWat_flow_nominal,-mWat_flow_nominal,-mWat_flow_nominal},
    dp_nominal={0,0,0})
    annotation (Placement(transformation(extent={{-160,-150},{-140,-170}})));
  Buildings.Fluid.FixedResistances.Junction jun7(
    redeclare final package Medium = MediumW,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    portFlowDirection_1=Modelica.Fluid.Types.PortFlowDirection.Bidirectional,
    portFlowDirection_2=Modelica.Fluid.Types.PortFlowDirection.Leaving,
    portFlowDirection_3=Modelica.Fluid.Types.PortFlowDirection.Entering,
    m_flow_nominal={mWat_flow_nominal,-mWat_flow_nominal,mWat_flow_nominal},
    dp_nominal={0,0,0})
    annotation (Placement(transformation(extent={{-100,-150},{-80,-170}})));
  Buildings.Fluid.FixedResistances.Junction jun8(
    redeclare final package Medium = MediumW,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    portFlowDirection_1=Modelica.Fluid.Types.PortFlowDirection.Entering,
    portFlowDirection_2=Modelica.Fluid.Types.PortFlowDirection.Leaving,
    portFlowDirection_3=Modelica.Fluid.Types.PortFlowDirection.Bidirectional,
    m_flow_nominal={mWat_flow_nominal,-mWat_flow_nominal,-mWat_flow_nominal},
    dp_nominal={0,0,0})
    annotation (Placement(transformation(extent={{80,-230},{60,-250}})));
  Buildings.Fluid.FixedResistances.Junction jun9(
    redeclare final package Medium = MediumW,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    portFlowDirection_1=Modelica.Fluid.Types.PortFlowDirection.Entering,
    portFlowDirection_2=Modelica.Fluid.Types.PortFlowDirection.Leaving,
    portFlowDirection_3=Modelica.Fluid.Types.PortFlowDirection.Bidirectional,
    m_flow_nominal={mWat_flow_nominal,-mWat_flow_nominal,mWat_flow_nominal},
    dp_nominal={0,0,0})
    annotation (Placement(transformation(extent={{0,-230},{-20,-250}})));
  Buildings.Fluid.FixedResistances.Junction jun10(
    redeclare final package Medium = MediumW,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    portFlowDirection_1=Modelica.Fluid.Types.PortFlowDirection.Entering,
    portFlowDirection_2=Modelica.Fluid.Types.PortFlowDirection.Leaving,
    portFlowDirection_3=Modelica.Fluid.Types.PortFlowDirection.Bidirectional,
    m_flow_nominal={mWat_flow_nominal,-mWat_flow_nominal,-mWat_flow_nominal},
    dp_nominal={0,0,0})
    annotation (Placement(transformation(extent={{-20,-170},{0,-150}})));
  Buildings.Fluid.FixedResistances.Junction jun11(
    redeclare final package Medium = MediumW,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    portFlowDirection_1=Modelica.Fluid.Types.PortFlowDirection.Entering,
    portFlowDirection_2=Modelica.Fluid.Types.PortFlowDirection.Leaving,
    portFlowDirection_3=Modelica.Fluid.Types.PortFlowDirection.Bidirectional,
    m_flow_nominal={mWat_flow_nominal,-mWat_flow_nominal,-mWat_flow_nominal},
    dp_nominal={0,0,0})
    annotation (Placement(transformation(extent={{60,-170},{80,-150}})));
  Buildings.Fluid.Actuators.Valves.TwoWayEqualPercentage valPriByp(
    redeclare final package Medium = MediumW,
    final allowFlowReversal=true,
    final m_flow_nominal=mWat_flow_nominal,
    final dpValve_nominal=dpValve_nominal,
    use_strokeTime=false) "Bypass valve to decouple primary and secondary loop"
    annotation (Placement(transformation(
        extent={{-10,10},{10,-10}},
        rotation=270,
        origin={-10,-200})));
  Buildings.Fluid.Actuators.Valves.TwoWayEqualPercentage valIsoPriSec(
    redeclare final package Medium = MediumW,
    allowFlowReversal=false,
    final m_flow_nominal=mWat_flow_nominal,
    final dpValve_nominal=dpValve_nominal,
    use_strokeTime=false)
    "Isolation valve to decouple primary and secondary loop" annotation (
      Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={30,-160})));
  Buildings.Fluid.Movers.Preconfigured.FlowControlled_m_flow pumBorFieCen(
    redeclare final package Medium = MediumW,
    allowFlowReversal=false,
    final addPowerToMedium=false,
    use_riseTime=false,
    final m_flow_nominal=mBorFieCen_flow_nominal,
    dp_nominal=dpBorFieCen_nominal,
    dpMax=Modelica.Constants.inf) "Pump for borefield center" annotation (
      Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={180,-110})));
  Buildings.Fluid.Movers.Preconfigured.FlowControlled_m_flow pumBorFiePer(
    redeclare final package Medium = MediumW,
    allowFlowReversal=false,
    final addPowerToMedium=false,
    use_riseTime=false,
    final m_flow_nominal=mBorFiePer_flow_nominal,
    dp_nominal=dpBorFiePer_nominal,
    dpMax=Modelica.Constants.inf) "Pump for borefield perimeter" annotation (
      Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-150,-100})));
  Modelica.Fluid.Interfaces.FluidPort_b portBorFiePer_b(redeclare final package
      Medium = MediumW) "Fluid connector to perimeter zones of borefield"
    annotation (Placement(transformation(extent={{-170,270},{-150,290}}),
        iconTransformation(extent={{-90,90},{-70,110}})));
  Modelica.Fluid.Interfaces.FluidPort_a portBorFiePer_a(redeclare final package
      Medium = MediumW)
    "Fluid connector for return from perimeter zones of borefield" annotation (
      Placement(transformation(extent={{-90,270},{-70,290}}),
        iconTransformation(extent={{-50,90},{-30,110}})));
  Modelica.Fluid.Interfaces.FluidPort_b portBorFieCen_b(redeclare final package
      Medium = MediumW) "Fluid connector to center zones of borefield"
    annotation (Placement(transformation(extent={{90,270},{110,290}}),
        iconTransformation(extent={{30,90},{50,110}})));
  Modelica.Fluid.Interfaces.FluidPort_a portBorFieCen_a(redeclare final package
      Medium = MediumW)
    "Fluid connector for return from center zones of borefield" annotation (
      Placement(transformation(extent={{170,270},{190,290}}),
        iconTransformation(extent={{70,90},{90,110}})));
  Buildings.Fluid.Sensors.TemperatureTwoPort senTemLeaGen(
    redeclare final package Medium = MediumW,
    allowFlowReversal=false,
    final m_flow_nominal=mWat_flow_nominal)
    "Temperature of waterflow leaving the generation module" annotation (
      Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=0,
        origin={-480,-240})));
  Buildings.Fluid.Sensors.TemperatureTwoPort senTemMixHex(
    redeclare final package Medium = MediumW,
    allowFlowReversal=false,
    final m_flow_nominal=mWat_flow_nominal,
    tau=0) "Temperature after heat exchanger mixing"
    annotation (Placement(transformation(extent={{-202,-170},{-182,-150}})));
  Buildings.Fluid.Sensors.TemperatureTwoPort senTemMixPer(
    redeclare final package Medium = MediumW,
    allowFlowReversal=false,
    final m_flow_nominal=mWat_flow_nominal,
    tau=0) "Temperature after perimeter borefield return mixing"
    annotation (Placement(transformation(extent={{-60,-170},{-40,-150}})));
  Buildings.Fluid.Sensors.TemperatureTwoPort senTemMixCen(
    redeclare final package Medium = MediumW,
    allowFlowReversal=false,
    final m_flow_nominal=mWat_flow_nominal,
    tau=0) "Temperature after center borefield return mixing"
    annotation (Placement(transformation(extent={{270,-170},{290,-150}})));
  Buildings.Fluid.Sensors.TemperatureTwoPort senTemMixHeaPum(
    redeclare final package Medium = MediumW,
    allowFlowReversal=false,
    final m_flow_nominal=mWat_flow_nominal,
    tau=0) "Temperature after heat pump return mixing"
    annotation (Placement(transformation(extent={{398,-170},{418,-150}})));
  Buildings.Fluid.Sensors.TemperatureTwoPort senTemBorPerRet(
    redeclare final package Medium = MediumW,
    allowFlowReversal=false,
    final m_flow_nominal=mBorFiePer_flow_nominal,
    tau=0) "Temperature of return from borefield perimeter" annotation (
      Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=270,
        origin={-90,-72})));
  Buildings.Fluid.Sensors.TemperatureTwoPort senTemBorCenRet(
    redeclare final package Medium = MediumW,
    allowFlowReversal=false,
    final m_flow_nominal=mBorFieCen_flow_nominal,
    tau=0) "Temperature of return from borefield center" annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=270,
        origin={240,-72})));
  Buildings.Fluid.FixedResistances.Junction jun12(
    redeclare final package Medium = MediumG,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    portFlowDirection_1=Modelica.Fluid.Types.PortFlowDirection.Entering,
    portFlowDirection_2=Modelica.Fluid.Types.PortFlowDirection.Leaving,
    portFlowDirection_3=Modelica.Fluid.Types.PortFlowDirection.Leaving,
    m_flow_nominal={mDryCoo_flow_nominal,-mHpGly_flow_nominal,-
        mDryCoo_flow_nominal},
    dp_nominal={0,0,0})
    annotation (Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={370,100})));
  Buildings.Fluid.FixedResistances.Junction jun13(
    redeclare final package Medium = MediumG,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    portFlowDirection_1=Modelica.Fluid.Types.PortFlowDirection.Entering,
    portFlowDirection_2=Modelica.Fluid.Types.PortFlowDirection.Leaving,
    portFlowDirection_3=Modelica.Fluid.Types.PortFlowDirection.Leaving,
    m_flow_nominal={mDryCoo_flow_nominal,-mDryCoo_flow_nominal,-
        mHexGly_flow_nominal},
    dp_nominal={0,0,0})
    annotation (Placement(transformation(extent={{10,-10},{-10,10}},
        rotation=0,
        origin={-260,50})));
  Buildings.Fluid.FixedResistances.Junction jun14(
    redeclare final package Medium = MediumG,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    portFlowDirection_1=Modelica.Fluid.Types.PortFlowDirection.Entering,
    portFlowDirection_2=Modelica.Fluid.Types.PortFlowDirection.Leaving,
    portFlowDirection_3=Modelica.Fluid.Types.PortFlowDirection.Entering,
    m_flow_nominal={mHexGly_flow_nominal,-mDryCoo_flow_nominal,
        mDryCoo_flow_nominal},
    dp_nominal={0,0,0})
    annotation (Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-320,50})));
  Buildings.Fluid.FixedResistances.Junction jun15(
    redeclare final package Medium = MediumG,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    portFlowDirection_1=Modelica.Fluid.Types.PortFlowDirection.Entering,
    portFlowDirection_2=Modelica.Fluid.Types.PortFlowDirection.Leaving,
    portFlowDirection_3=Modelica.Fluid.Types.PortFlowDirection.Leaving,
    m_flow_nominal={mHpGly_flow_nominal,-mHpGly_flow_nominal,-
        mHpGly_flow_nominal},
    dp_nominal={0,0,0})
    annotation (Placement(transformation(extent={{10,10},{-10,-10}},
        rotation=-90,
        origin={310,70})));
  Buildings.Fluid.FixedResistances.Junction jun16(
    redeclare final package Medium = MediumG,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    portFlowDirection_1=Modelica.Fluid.Types.PortFlowDirection.Entering,
    portFlowDirection_2=Modelica.Fluid.Types.PortFlowDirection.Leaving,
    portFlowDirection_3=Modelica.Fluid.Types.PortFlowDirection.Entering,
    m_flow_nominal={mDryCoo_flow_nominal,-mDryCoo_flow_nominal,
        mDryCoo_flow_nominal},
    dp_nominal={0,0,0})
    annotation (Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-320,90})));
  ThermalGridJBA.Networks.Controls.Indicators ind(
    final TPlaHeaSet=TPlaHeaSet,
    final TPlaCooSet=TPlaCooSet,
    final staDowDel=staDowDel)
    annotation (Placement(transformation(extent={{-520,250},{-500,270}})));
  ThermalGridJBA.Networks.Controls.HeatExchanger hexCon(
    final mHexGly_flow_nominal=mHexGly_flow_nominal,
    final TApp=TApp)
    "Heat exchanger economizer and the associated pump and valves control"
    annotation (Placement(transformation(extent={{-460,220},{-440,240}})));
  ThermalGridJBA.Networks.Controls.DryCooler dryCooCon(
    final mDryCoo_flow_nominal=mDryCoo_flow_nominal,
    final TAppSet=TAppSet,
    final TApp=TApp,
    final minFanSpe=minFanSpe,
    final fanConTyp=fanConTyp,
    final kFan=kFan,
    final TiFan=TiFan,
    final TdFan=TdFan)
    "Dry cooler and the associated pump control"
    annotation (Placement(transformation(extent={{-380,220},{-360,240}})));
  ThermalGridJBA.Networks.Controls.Borefields borCon(
    final mWat_flow_nominal=mWat_flow_nominal,
    final mBorFiePer_flow_nominal=mBorFiePer_flow_nominal,
    final mBorFieCen_flow_nominal=mBorFieCen_flow_nominal)
    "Borefield pumps and the valves control"
    annotation (Placement(transformation(extent={{-240,220},{-220,240}})));
  ThermalGridJBA.Networks.Controls.HeatPump heaPumCon(
    final mWat_flow_nominal=mWat_flow_nominal,
    final mWat_flow_min=mHeaPumWat_flow_min,
    final mHpGly_flow_nominal=mHpGly_flow_nominal,
    final mBorFieCen_flow_nominal=mBorFieCen_flow_nominal,
    final TLooMin=TLooMin,
    final TLooMax=TLooMax,
    final TPlaCooSet=TPlaCooSet,
    final TPlaHeaSet=TPlaHeaSet,
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
    final TdVal=TdVal,
    final del=minHeaPumSpeHol)
    annotation (Placement(transformation(extent={{-120,216},{-100,240}})));
  Buildings.Fluid.Sensors.MassFlowRate senMasFloPla(redeclare each package
      Medium = MediumW, each allowFlowReversal=false)
    "Mass flow rate entering plant"
    annotation (Placement(transformation(extent={{-440,-170},{-420,-150}})));
  Buildings.Fluid.Sensors.MassFlowRate senMasFloHeaPum(redeclare each package
      Medium = MediumW, each allowFlowReversal=false)
    "Mass flow rate entering heat pump" annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={310,-102})));
  Buildings.Fluid.Sensors.TemperatureTwoPort senTemheaPumEnt(
    redeclare final package Medium = MediumW,
    allowFlowReversal=false,
    final m_flow_nominal=mHeaPumWat_flow_nominal,
    tau=0) "Temperature entering into heat pump" annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={310,-70})));
  Buildings.Fluid.Sensors.TemperatureTwoPort senTemBorPerSup(
    redeclare final package Medium = MediumW,
    allowFlowReversal=false,
    final m_flow_nominal=mBorFiePer_flow_nominal,
    tau=0) "Temperature of supply to borefield perimeter" annotation (Placement(
        transformation(
        extent={{10,-10},{-10,10}},
        rotation=270,
        origin={-150,-70})));
  Buildings.Fluid.Sensors.TemperatureTwoPort senTemBorCenRet1(
    redeclare final package Medium = MediumW,
    allowFlowReversal=false,
    final m_flow_nominal=mBorFieCen_flow_nominal,
    tau=0) "Temperature of return from borefield center" annotation (Placement(
        transformation(
        extent={{10,-10},{-10,10}},
        rotation=270,
        origin={180,-72})));
  Buildings.Fluid.Sensors.TemperatureTwoPort senTemEcoLea(
    redeclare final package Medium = MediumW,
    allowFlowReversal=false,
    final m_flow_nominal=mWat_flow_nominal,
    tau=0) "Temperature of return from economizer" annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=270,
        origin={-240,-72})));
  Buildings.Fluid.Sensors.TemperatureTwoPort senTemEcoEnt(
    redeclare final package Medium = MediumW,
    allowFlowReversal=false,
    final m_flow_nominal=mWat_flow_nominal,
    tau=0) "Temperature of supply to economizer" annotation (Placement(
        transformation(
        extent={{10,-10},{-10,10}},
        rotation=270,
        origin={-320,-70})));
protected
  Buildings.Controls.OBC.CDL.Reals.Add PPumCirAdd
    "Adder for circulation pump power"
    annotation (Placement(transformation(extent={{200,-270},{220,-250}})));
equation
  connect(pumDryCoo.port_b, dryCoo.port_a) annotation (Line(
      points={{-40,130},{40,130}},
      color={0,127,255},
      thickness=0.5));
  connect(port_a, senTemEntGen.port_a) annotation (Line(
      points={{-540,-160},{-490,-160}},
      color={0,127,255},
      thickness=0.5));
  connect(pumHeaPumGly.port_a, senTemHeaPumGlyIn.port_b) annotation (Line(
      points={{370,20},{370,30}},
      color={0,127,255},
      thickness=0.5));
  connect(senTemHeaPumGlyIn.port_a, valHeaPumByp.port_2) annotation (Line(
      points={{370,50},{370,60}},
      color={0,127,255},
      thickness=0.5));
  connect(hex.port_b1, bou.ports[1]) annotation (Line(
      points={{-300,-24},{-334,-24}},
      color={0,127,255},
      thickness=0.5));
  connect(dryCoo.port_b, senTemDryCooOut.port_a) annotation (Line(
      points={{60,130},{120,130}},
      color={0,127,255},
      thickness=0.5));
  connect(hex.port_a1, pumDryCoo1.port_b) annotation (Line(
      points={{-280,-24},{-260,-24},{-260,6}},
      color={0,127,255},
      thickness=0.5));
  connect(pumDryCoo.P, PPumDryCoo) annotation (Line(points={{-39,139},{-22,139},
          {-22,140},{-20,140},{-20,200},{560,200}},
                                color={0,0,127}));
  connect(pumDryCoo1.P, PPumHexGly) annotation (Line(points={{-251,5},{-251,-8},
          {-240,-8},{-240,144},{480,144},{480,170},{560,170}},
                                        color={0,0,127}));
  connect(pumHeaPumGly.P, PPumHeaPumGly) annotation (Line(points={{379,-1},{379,
          -12},{526,-12},{526,140},{560,140}}, color={0,0,127}));
  connect(pumCenPlaPri.port_b, jun.port_1) annotation (Line(
      points={{-370,-160},{-330,-160}},
      color={0,127,255},
      thickness=0.5));
  connect(jun.port_2, valHexByp.port_a)
    annotation (Line(points={{-310,-160},{-290,-160}},
                                                     color={0,127,255},
      thickness=0.5));
  connect(jun.port_3, valHex.port_a)
    annotation (Line(points={{-320,-150},{-320,-110}}, color={0,127,255},
      thickness=0.5));
  connect(valHexByp.port_b, jun1.port_1) annotation (Line(
      points={{-270,-160},{-250,-160}},
      color={0,127,255},
      thickness=0.5));
  connect(jun2.port_3, valHeaPum.port_a) annotation (Line(
      points={{310,-150},{310,-140}},
      color={0,127,255},
      thickness=0.5));
  connect(jun2.port_2, jun3.port_1) annotation (Line(
      points={{320,-160},{360,-160}},
      color={0,127,255},
      thickness=0.5));
  connect(jun3.port_3, senTemHeaPumLea.port_b) annotation (Line(
      points={{370,-150},{370,-82}},
      color={0,127,255},
      thickness=0.5));
  connect(pumHeaPumWat.port_b, heaPum.port_a1) annotation (Line(
      points={{310,-30},{310,-26},{330,-26}},
      color={0,127,255},
      thickness=0.5));
  connect(heaPum.port_b1, senTemHeaPumLea.port_a) annotation (Line(
      points={{350,-26},{370,-26},{370,-62}},
      color={0,127,255},
      thickness=0.5));
  connect(pumHeaPumGly.port_b, heaPum.port_a2) annotation (Line(
      points={{370,0},{370,-14},{350,-14}},
      color={0,127,255},
      thickness=0.5));
  connect(heaPum.P, PCom)
    annotation (Line(points={{351,-20},{456,-20},{456,-24},{560,-24}},
                                                   color={0,0,127}));
  connect(jun4.port_2,jun5. port_1) annotation (Line(
      points={{190,-160},{230,-160}},
      color={0,127,255},
      thickness=0.5));
  connect(jun6.port_2,jun7. port_1) annotation (Line(
      points={{-140,-160},{-100,-160}},
      color={0,127,255},
      thickness=0.5));
  connect(jun10.port_2, valIsoPriSec.port_a)
    annotation (Line(points={{0,-160},{20,-160}}, color={0,127,255},
      thickness=0.5));
  connect(valIsoPriSec.port_b, jun11.port_1)
    annotation (Line(points={{40,-160},{60,-160}}, color={0,127,255},
      thickness=0.5));
  connect(jun11.port_2, pumCenPlaSec.port_a)
    annotation (Line(points={{80,-160},{110,-160}}, color={0,127,255},
      thickness=0.5));
  connect(pumCenPlaSec.port_b, jun4.port_1)
    annotation (Line(points={{130,-160},{170,-160}}, color={0,127,255},
      thickness=0.5));
  connect(jun8.port_2, jun9.port_1)
    annotation (Line(points={{60,-240},{0,-240}}, color={0,127,255},
      thickness=0.5));
  connect(senTemLeaGen.port_b, port_b) annotation (Line(
      points={{-490,-240},{-540,-240}},
      color={0,127,255},
      thickness=0.5));
  connect(jun1.port_2, senTemMixHex.port_a)
    annotation (Line(points={{-230,-160},{-202,-160}}, color={0,127,255},
      thickness=0.5));
  connect(senTemMixHex.port_b, jun6.port_1)
    annotation (Line(points={{-182,-160},{-160,-160}}, color={0,127,255},
      thickness=0.5));
  connect(jun7.port_2, senTemMixPer.port_a)
    annotation (Line(points={{-80,-160},{-60,-160}}, color={0,127,255},
      thickness=0.5));
  connect(senTemMixPer.port_b, jun10.port_1)
    annotation (Line(points={{-40,-160},{-20,-160}}, color={0,127,255},
      thickness=0.5));
  connect(jun5.port_2, senTemMixCen.port_a)
    annotation (Line(points={{250,-160},{270,-160}}, color={0,127,255},
      thickness=0.5));
  connect(senTemMixCen.port_b, jun2.port_1)
    annotation (Line(points={{290,-160},{300,-160}}, color={0,127,255},
      thickness=0.5));
  connect(jun3.port_2, senTemMixHeaPum.port_a)
    annotation (Line(points={{380,-160},{398,-160}}, color={0,127,255},
      thickness=0.5));
  connect(senTemMixHeaPum.port_b, jun8.port_1) annotation (Line(points={{418,-160},
          {430,-160},{430,-240},{80,-240}}, color={0,127,255},
      thickness=0.5));
  connect(jun9.port_2, senTemLeaGen.port_a) annotation (Line(
      points={{-20,-240},{-470,-240}},
      color={0,127,255},
      thickness=0.5));
  connect(jun10.port_3, valPriByp.port_a)
    annotation (Line(points={{-10,-170},{-10,-190}},
                                                   color={0,127,255},
      thickness=0.5));
  connect(valPriByp.port_b, jun9.port_3) annotation (Line(points={{-10,-210},{
          -10,-230}},                  color={0,127,255},
      thickness=0.5));
  connect(jun11.port_3, jun8.port_3)
    annotation (Line(points={{70,-170},{70,-230}}, color={0,127,255},
      thickness=0.5));
  connect(jun6.port_3, pumBorFiePer.port_a) annotation (Line(points={{-150,-150},
          {-150,-110}},           color={0,127,255},
      thickness=0.5));
  connect(senTemBorPerRet.port_b, jun7.port_3)
    annotation (Line(points={{-90,-82},{-90,-150}},  color={0,127,255},
      thickness=0.5));
  connect(senTemBorPerRet.port_a,portBorFiePer_a)  annotation (Line(points={{-90,-62},
          {-90,-38},{-146,-38},{-146,126},{-280,126},{-280,260},{-80,260},{-80,
          280}},      color={0,127,255},
      thickness=0.5));
  connect(jun4.port_3, pumBorFieCen.port_a) annotation (Line(points={{180,-150},
          {180,-120}},          color={0,127,255},
      thickness=0.5));
  connect(jun5.port_3, senTemBorCenRet.port_b)
    annotation (Line(points={{240,-150},{240,-82}},  color={0,127,255},
      thickness=0.5));
  connect(senTemBorCenRet.port_a,portBorFieCen_a)  annotation (Line(points={{240,-62},
          {240,-48},{184,-48},{184,268},{180,268},{180,280}},       color={0,127,
          255},
      thickness=0.5));
  connect(pumCenPlaPri.P, PPumCirAdd.u1) annotation (Line(points={{-369,-151},{-350,
          -151},{-350,-254},{198,-254}}, color={0,0,127}));
  connect(PPumCirAdd.u2, pumCenPlaSec.P) annotation (Line(points={{198,-266},{140,
          -266},{140,-151},{131,-151}}, color={0,0,127}));
  connect(PPumCirAdd.y, PPumCirPum) annotation (Line(points={{222,-260},{520,-260},
          {520,-210},{560,-210}}, color={0,0,127}));
  connect(pumBorFiePer.P, PPumBorFiePer) annotation (Line(points={{-159,-89},{
          -159,-86},{-168,-86},{-168,148},{520,148},{520,110},{560,110}},
                                               color={0,0,127}));
  connect(pumBorFieCen.P, PPumBorFieCen) annotation (Line(points={{171,-99},{
          171,-88},{156,-88},{156,140},{516,140},{516,78},{560,78}},
                                             color={0,0,127}));
  connect(senTemDryCooOut.port_b, jun12.port_1) annotation (Line(
      points={{140,130},{370,130},{370,110}},
      color={0,127,255},
      thickness=0.5));
  connect(jun12.port_2, valHeaPumByp.port_1) annotation (Line(
      points={{370,90},{370,80}},
      color={0,127,255},
      thickness=0.5));
  connect(heaPum.port_b2, jun15.port_1) annotation (Line(
      points={{330,-14},{310,-14},{310,60}},
      color={0,127,255},
      thickness=0.5));
  connect(jun15.port_3, valHeaPumByp.port_3) annotation (Line(
      points={{320,70},{360,70}},
      color={0,127,255},
      thickness=0.5));
  connect(jun12.port_3, jun13.port_1) annotation (Line(
      points={{360,100},{80,100},{80,50},{-250,50}},
      color={0,127,255},
      thickness=0.5));
  connect(jun13.port_3, pumDryCoo1.port_a) annotation (Line(
      points={{-260,40},{-260,26}},
      color={0,127,255},
      thickness=0.5));
  connect(hex.port_b1, jun14.port_1) annotation (Line(
      points={{-300,-24},{-320,-24},{-320,40}},
      color={0,127,255},
      thickness=0.5));
  connect(jun13.port_2, jun14.port_3) annotation (Line(
      points={{-270,50},{-310,50}},
      color={0,127,255},
      thickness=0.5));
  connect(jun14.port_2, jun16.port_1) annotation (Line(
      points={{-320,60},{-320,80}},
      color={0,127,255},
      thickness=0.5));
  connect(jun15.port_2, jun16.port_3) annotation (Line(
      points={{310,80},{310,90},{-310,90}},
      color={0,127,255},
      thickness=0.5));
  connect(jun16.port_2, pumDryCoo.port_a) annotation (Line(
      points={{-320,100},{-320,130},{-60,130}},
      color={0,127,255},
      thickness=0.5));
  connect(ind.ySt, hexCon.uSt) annotation (Line(points={{-498,265},{-480,265},{-480,
          236},{-462,236}}, color={255,127,0}));
  connect(ind.yEle, hexCon.uEleRat) annotation (Line(points={{-498,259},{-476,259},
          {-476,239},{-462,239}}, color={255,127,0}));
  connect(ind.ySea, hexCon.uSea) annotation (Line(points={{-498,252},{-484,252},
          {-484,233},{-462,233}}, color={255,127,0}));
  connect(TDryBul, hexCon.TDryBul) annotation (Line(points={{-560,190},{-486,190},
          {-486,222},{-462,222}}, color={0,0,127}));
  connect(senTemEntGen.T, hexCon.TPlaIn) annotation (Line(points={{-480,-149},{
          -480,226},{-462,226}}, color={0,0,127}));
  connect(ind.ySt, dryCooCon.uSt) annotation (Line(points={{-498,265},{-400,265},
          {-400,237},{-382,237}}, color={255,127,0}));
  connect(ind.yEle, dryCooCon.uEleRat) annotation (Line(points={{-498,259},{-396,
          259},{-396,239},{-382,239}}, color={255,127,0}));
  connect(ind.ySea, dryCooCon.uSea) annotation (Line(points={{-498,252},{-404,252},
          {-404,235},{-382,235}}, color={255,127,0}));
  connect(TDryBul, dryCooCon.TDryBul) annotation (Line(points={{-560,190},{-400,
          190},{-400,230},{-382,230}}, color={0,0,127}));
  connect(ind.ySt, borCon.uSt) annotation (Line(points={{-498,265},{-260,265},{-260,
          236},{-242,236}}, color={255,127,0}));
  connect(ind.yEle, borCon.uEleRat) annotation (Line(points={{-498,259},{-256,259},
          {-256,239},{-242,239}}, color={255,127,0}));
  connect(ind.ySea, borCon.uSea) annotation (Line(points={{-498,252},{-264,252},
          {-264,233},{-242,233}}, color={255,127,0}));
  connect(ind.ySt, heaPumCon.uSt) annotation (Line(points={{-498,265},{-140,265},
          {-140,237},{-122,237}}, color={255,127,0}));
  connect(ind.yEle, heaPumCon.uEleRat) annotation (Line(points={{-498,259},{-136,
          259},{-136,239},{-122,239}}, color={255,127,0}));
  connect(ind.ySea, heaPumCon.uSea) annotation (Line(points={{-498,252},{-360,252},
          {-360,254},{-144,254},{-144,235},{-122,235}}, color={255,127,0}));
  connect(senTemEntGen.T, dryCooCon.TPlaIn) annotation (Line(points={{-480,-149},
          {-480,196},{-404,196},{-404,232},{-382,232}}, color={0,0,127}));
  connect(uDisPum, borCon.uDisPum) annotation (Line(points={{-560,220},{-520,
          220},{-520,200},{-260,200},{-260,228},{-242,228}},
                                                        color={0,0,127}));
  connect(senTemEntGen.T, heaPumCon.TPlaIn) annotation (Line(points={{-480,-149},
          {-480,196},{-160,196},{-160,232},{-122,232}}, color={0,0,127}));
  connect(senTemHeaPumLea.T, heaPumCon.THeaPumOut) annotation (Line(points={{
          381,-72},{420,-72},{420,186},{-150,186},{-150,227},{-122,227}}, color
        ={0,0,127}));
  connect(senTemEntGen.port_b, senMasFloPla.port_a) annotation (Line(
      points={{-470,-160},{-440,-160}},
      color={0,127,255},
      thickness=0.5));
  connect(senMasFloPla.port_b, pumCenPlaPri.port_a) annotation (Line(
      points={{-420,-160},{-390,-160}},
      color={0,127,255},
      thickness=0.5));
  connect(valHeaPum.port_b, senMasFloHeaPum.port_a) annotation (Line(
      points={{310,-120},{310,-112}},
      color={0,127,255},
      thickness=0.5));
  connect(senMasFloPla.m_flow, heaPumCon.mPla_flow) annotation (Line(points={{-430,
          -149},{-430,170},{-144,170},{-144,224},{-122,224}}, color={0,0,127}));
  connect(senMasFloHeaPum.m_flow, heaPumCon.mHeaPum_flow) annotation (Line(
        points={{299,-102},{274,-102},{274,176},{-138,176},{-138,222},{-122,222}},
        color={0,0,127}));
  connect(senTemHeaPumGlyIn.T, heaPumCon.TGlyIn) annotation (Line(points={{381,
          40},{412,40},{412,170},{-132,170},{-132,219},{-122,219}}, color={0,0,
          127}));
  connect(uDisPum, heaPumCon.uDisPum) annotation (Line(points={{-560,220},{-520,
          220},{-520,200},{-128,200},{-128,217},{-122,217}}, color={0,0,127}));
  connect(hexCon.yValHexByp, valHexByp.y) annotation (Line(points={{-438,234},{-410,
          234},{-410,-120},{-280,-120},{-280,-148}}, color={0,0,127}));
  connect(hexCon.yValHex, valHex.y) annotation (Line(points={{-438,230},{-416,230},
          {-416,-100},{-332,-100}}, color={0,0,127}));
  connect(hexCon.yPumHex, pumDryCoo1.m_flow_in) annotation (Line(points={{-438,226},
          {-422,226},{-422,32},{-234,32},{-234,16},{-248,16}}, color={0,0,127}));
  connect(dryCooCon.TAirDryCooIn, dryCoo.TAir) annotation (Line(points={{-358,236},
          {-294,236},{-294,110},{20,110},{20,134},{38,134}}, color={0,0,127}));
  connect(dryCooCon.yPumDryCoo, pumDryCoo.m_flow_in) annotation (Line(points={{-358,
          230},{-300,230},{-300,160},{-50,160},{-50,142}}, color={0,0,127}));
  connect(borCon.yValPriByp, valPriByp.y) annotation (Line(points={{-218,238},{-174,
          238},{-174,-200},{-22,-200}}, color={0,0,127}));
  connect(borCon.yValIso, valIsoPriSec.y) annotation (Line(points={{-218,235},{-180,
          235},{-180,-140},{30,-140},{30,-148}}, color={0,0,127}));
  connect(borCon.yPumPerBor, pumBorFiePer.m_flow_in) annotation (Line(points={{-218,
          230},{-186,230},{-186,-100},{-162,-100}},
                                                  color={0,0,127}));
  connect(borCon.yPumPri, pumCenPlaPri.m_flow_in) annotation (Line(points={{-218,
          227},{-192,227},{-192,-140},{-380,-140},{-380,-148}}, color={0,0,127}));
  connect(borCon.yPumCenBor, pumBorFieCen.m_flow_in) annotation (Line(points={{-218,
          224},{-198,224},{-198,-42},{150,-42},{150,-110},{168,-110}},
                                                                     color={0,0,
          127}));
  connect(borCon.yPumSec, pumCenPlaSec.m_flow_in) annotation (Line(points={{-218,
          221},{-204,221},{-204,-136},{120,-136},{120,-148}}, color={0,0,127}));
  connect(heaPumCon.y1Mod, heaPum.hea) annotation (Line(points={{-98,238},{292,
          238},{292,-17.9},{328.9,-17.9}},
                                      color={255,0,255}));
  connect(heaPumCon.yComSet, heaPum.ySet) annotation (Line(points={{-98,235},{
          286,235},{286,-21.9},{328.9,-21.9}},
                                           color={0,0,127}));
  connect(heaPumCon.yPumGly, pumHeaPumGly.m_flow_in) annotation (Line(points={{-98,227},
          {440,227},{440,10},{382,10}},    color={0,0,127}));
  connect(heaPumCon.yVal, valHeaPum.y) annotation (Line(points={{-98,224},{266,224},
          {266,-130},{298,-130}}, color={0,0,127}));
  connect(heaPumCon.yValByp, valHeaPumByp.y) annotation (Line(points={{-98,221},
          {400,221},{400,70},{382,70}}, color={0,0,127}));
  connect(heaPumCon.yPum, pumHeaPumWat.m_flow_in) annotation (Line(points={{-98,218},
          {258,218},{258,-40},{298,-40}},      color={0,0,127}));
  connect(TPlaOut, ind.TPlaOut)
    annotation (Line(points={{-560,260},{-522,260}}, color={0,0,127}));
  connect(heaPumCon.y1On, dryCooCon.u1HeaPum) annotation (Line(points={{-98,232},
          {-80,232},{-80,204},{-396,204},{-396,227},{-382,227}}, color={255,0,
          255}));
  connect(heaPumCon.y1Mod, dryCooCon.u1HeaPumMod) annotation (Line(points={{-98,
          238},{-76,238},{-76,192},{-392,192},{-392,225},{-382,225}}, color={
          255,0,255}));
  connect(senTemDryCooOut.T, dryCooCon.TDryCooOut) annotation (Line(points={{
          130,141},{130,166},{-388,166},{-388,222},{-382,222}}, color={0,0,127}));
  connect(ind.yEleRat, yEleRat) annotation (Line(points={{-498,257},{500,257},{
          500,270},{560,270}}, color={0,0,127}));
  connect(heaPumCon.y1On, borCon.u1HeaPum) annotation (Line(points={{-98,232},{
          -80,232},{-80,204},{-256,204},{-256,224},{-242,224}}, color={255,0,
          255}));
  connect(senMasFloHeaPum.m_flow, borCon.mHeaPum_flow) annotation (Line(points=
          {{299,-102},{274,-102},{274,176},{-252,176},{-252,222},{-242,222}},
        color={0,0,127}));
  connect(pumHeaPumWat.P, PPumHeaPumWat) annotation (Line(points={{301,-29},{
          301,-24},{292,-24},{292,-50},{560,-50}}, color={0,0,127}));
  connect(senMasFloHeaPum.port_b, senTemheaPumEnt.port_a) annotation (Line(
      points={{310,-92},{310,-80}},
      color={0,127,255},
      thickness=0.5));
  connect(senTemheaPumEnt.port_b, pumHeaPumWat.port_a) annotation (Line(
      points={{310,-60},{310,-50}},
      color={0,127,255},
      thickness=0.5));
  connect(senTemheaPumEnt.T, heaPumCon.THeaPumIn) annotation (Line(points={{299,
          -70},{280,-70},{280,180},{-156,180},{-156,229},{-122,229}}, color={0,
          0,127}));
  connect(pumBorFiePer.port_b, senTemBorPerSup.port_a) annotation (Line(
      points={{-150,-90},{-150,-80}},
      color={0,127,255},
      thickness=0.5));
  connect(senTemBorPerSup.port_b, portBorFiePer_b) annotation (Line(
      points={{-150,-60},{-150,120},{-286,120},{-286,270},{-160,270},{-160,280}},
      color={0,127,255},
      thickness=0.5));
  connect(pumBorFieCen.port_b, senTemBorCenRet1.port_a) annotation (Line(
      points={{180,-100},{180,-82}},
      color={0,127,255},
      thickness=0.5));
  connect(senTemBorCenRet1.port_b, portBorFieCen_b) annotation (Line(
      points={{180,-62},{180,260},{100,260},{100,280}},
      color={0,127,255},
      thickness=0.5));
  connect(valHex.port_b, senTemEcoEnt.port_a) annotation (Line(
      points={{-320,-90},{-320,-80}},
      color={0,127,255},
      thickness=0.5));
  connect(senTemEcoEnt.port_b, hex.port_a2) annotation (Line(
      points={{-320,-60},{-320,-36},{-300,-36}},
      color={0,127,255},
      thickness=0.5));
  connect(hex.port_b2, senTemEcoLea.port_a) annotation (Line(
      points={{-280,-36},{-240,-36},{-240,-62}},
      color={0,127,255},
      thickness=0.5));
  connect(senTemEcoLea.port_b, jun1.port_3) annotation (Line(
      points={{-240,-82},{-240,-150}},
      color={0,127,255},
      thickness=0.5));
  annotation (defaultComponentName="gen",
  Icon(coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},{100,100}}),
                         graphics={
                                Rectangle(
        extent={{-100,-220},{100,100}},
        lineColor={0,0,127},
        fillColor={255,255,255},
        fillPattern=FillPattern.Solid),
       Text(extent={{-90,-216},{110,-256}},
          textString="%name",
          textColor={0,0,255})}),
   Diagram(coordinateSystem(preserveAspectRatio=false,
          extent={{-540,-280},{540,280}})),
    Documentation(revisions="<html>
<ul>
<li>
March 31, 2025, by Michael Wetter:<br/>
Increased minimum flow rate for heat pump, as it was set to <i>10&perc;</i>, but the
heat pump safety control goes to a minimum flow rate error when the water flow rate
gets below <i>10%</i> of the design water flow rate.<br/>
This is for
<a href=\\\"https://github.com/lbl-srg/thermal-grid-jba/issues/13\\\">issue 13</a>.
</li>
</ul>
</html>"));
end Generations;
