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
  parameter Real TEvaHea_nominal(unit="K")
    "Nominal temperature of evaporator for heat pump design during heating"
    annotation (Dialog(group="Heat pump"));
  parameter Real QHeaPumCoo_flow_nominal(unit="W")=-cpWat*mWat_flow_nominal*TApp
    "Nominal cooling capacity"
    annotation (Dialog(group="Heat pump"));
  parameter Real TConCoo_nominal(unit="K")
    "Nominal temperature of condenser for heat pump design during cooling"
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
    annotation (Placement(transformation(extent={{-580,240},{-540,280}}),
        iconTransformation(extent={{-140,70},{-100,110}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput uSolTim
    "Solar time. An output from weather data"
    annotation (Placement(transformation(extent={{-580,210},{-540,250}}),
        iconTransformation(extent={{-140,40},{-100,80}})));
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
    annotation (Placement(transformation(extent={{540,-50},{580,-10}}),
        iconTransformation(extent={{100,-70},{140,-30}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput PPumHeaPumWat(
    final quantity="Power",
    final unit="W")
    "Electrical power consumed by heat pump waterside pump"
    annotation (Placement(transformation(extent={{540,-160},{580,-120}}),
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
    annotation (Placement(transformation(extent={{-280,-60},{-300,-40}})));
  Buildings.Fluid.Actuators.Valves.TwoWayEqualPercentage valHeaPum(
    redeclare final package Medium = MediumW,
    allowFlowReversal=false,
    final m_flow_nominal=mWat_flow_nominal,
    final dpValve_nominal=dpValve_nominal,
    use_strokeTime=false)
    "Heat pump water loop valve"
    annotation (Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=90, origin={310,-120})));
  Buildings.Fluid.Movers.Preconfigured.FlowControlled_m_flow pumHeaPumWat(
    redeclare final package Medium = MediumW,
    allowFlowReversal=false,
    final addPowerToMedium=false,
    use_riseTime=false,
    final m_flow_nominal=mWat_flow_nominal,
    dpMax=Modelica.Constants.inf) "Pump for heat pump waterside loop"
     annotation (Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=90, origin={310,-80})));
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
        rotation=-90, origin={370,0})));
  Buildings.Fluid.Actuators.Valves.ThreeWayEqualPercentageLinear valHeaPumByp(
    redeclare final package Medium = MediumG,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    use_strokeTime=false,
    final m_flow_nominal=mHpGly_flow_nominal,
    final dpValve_nominal=dpValve_nominal)
    "Heat pump bypass valve"
    annotation (Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=-90, origin={370,60})));
  Buildings.Fluid.Sensors.TemperatureTwoPort entGenTem(redeclare final package
      Medium = MediumW,
    allowFlowReversal=false,
                        final m_flow_nominal=mWat_flow_nominal)
    "Temperature of waterflow entering the generation module"
    annotation (Placement(transformation(extent={{-490,-170},{-470,-150}})));
  Buildings.Fluid.Sensors.TemperatureTwoPort heaPumLea(
    redeclare final package Medium = MediumW,
    allowFlowReversal=false,
    final m_flow_nominal=mWat_flow_nominal)
    "Temperature of waterflow leave heat pump"
    annotation (Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=-90, origin={370,-100})));
  Buildings.Fluid.Sensors.TemperatureTwoPort heaPumGlyIn(
    redeclare final package Medium = MediumG,
    allowFlowReversal=false,
    final m_flow_nominal=mHpGly_flow_nominal)
    "Temperature of glycol entering heat pump"
    annotation (Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=-90, origin={370,30})));
  Buildings.Fluid.Sources.Boundary_pT bou(
    redeclare final package Medium = MediumG,
    nPorts=1)
    "Boundary pressure condition representing the expansion vessel"
    annotation (Placement(transformation(extent={{10,-10},{-10,10}},
        rotation=180, origin={-344,-44})));
  ThermalGridJBA.Networks.Controls.Indicators ind(
    final samplePeriod=samplePeriod)
    "Indicators for district load, electricity rate and season"
    annotation (Placement(transformation(extent={{-480,250},{-460,270}})));
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
    final mWat_flow_min=1.05*mWat_flow_min,
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
    annotation (Placement(transformation(extent={{-180,170},{-160,190}})));
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
        rotation=-90, origin={-260,16})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter gai2(
    final k=mWat_flow_nominal)
    "Convert mass flow rate"
    annotation (Placement(transformation(extent={{-420,10},{-400,30}})));
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
    m_flow_nominal={mWat_flow_nominal,-mWat_flow_nominal,-mWat_flow_nominal},
    dp_nominal={0,0,0})
    annotation (Placement(transformation(extent={{300,-150},{320,-170}})));
  Buildings.Fluid.FixedResistances.Junction jun3(
    redeclare final package Medium = MediumW,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    portFlowDirection_1=Modelica.Fluid.Types.PortFlowDirection.Bidirectional,
    portFlowDirection_2=Modelica.Fluid.Types.PortFlowDirection.Leaving,
    portFlowDirection_3=Modelica.Fluid.Types.PortFlowDirection.Entering,
    m_flow_nominal={mWat_flow_nominal,-mWat_flow_nominal,mWat_flow_nominal},
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
    annotation (Placement(transformation(extent={{330,-20},{350,-40}})));

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
    use_riseTime=true,
    final m_flow_nominal=mBorFieCen_flow_nominal,
    dp_nominal=dpBorFieCen_nominal,
    dpMax=Modelica.Constants.inf) "Pump for borefield center" annotation (
      Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={180,-80})));
  Buildings.Fluid.Movers.Preconfigured.FlowControlled_m_flow pumBorFiePer(
    redeclare final package Medium = MediumW,
    allowFlowReversal=false,
    final addPowerToMedium=false,
    use_riseTime=true,
    final m_flow_nominal=mBorFiePer_flow_nominal,
    dp_nominal=dpBorFiePer_nominal,
    dpMax=Modelica.Constants.inf) "Pump for borefield perimeter" annotation (
      Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-150,-80})));
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
  Buildings.Fluid.Sensors.TemperatureTwoPort leaGenTem(
    redeclare final package Medium = MediumW,
    allowFlowReversal=false,
    final m_flow_nominal=mWat_flow_nominal)
    "Temperature of waterflow leave the generation module" annotation (
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
    annotation (Placement(transformation(extent={{268,-170},{288,-150}})));
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
        origin={-90,-112})));
  Buildings.Fluid.Sensors.TemperatureTwoPort senTemBorCenRet(
    redeclare final package Medium = MediumW,
    allowFlowReversal=false,
    final m_flow_nominal=mBorFieCen_flow_nominal,
    tau=0) "Temperature of return from borefield center" annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=270,
        origin={240,-110})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant fixmeMassFlowRate(k=0.5*
        mWat_flow_nominal) "Mass flow rate signal"
    annotation (Placement(transformation(extent={{-320,-220},{-300,-200}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant fixme1(k=1)
    "Zero output signal until control is implemented"
    annotation (Placement(transformation(extent={{-18,-130},{2,-110}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant fixme2(k=0)
    "Zero output signal until control is implemented"
    annotation (Placement(transformation(extent={{-72,-210},{-52,-190}})));
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
        origin={310,60})));
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
protected
  Buildings.Controls.OBC.CDL.Reals.Add PPumCirAdd
    "Adder for circulation pump power"
    annotation (Placement(transformation(extent={{200,-270},{220,-250}})));
equation
  connect(valHex.port_b, hex.port_a2) annotation (Line(
      points={{-320,-90},{-320,-56},{-300,-56}},
      color={0,127,255},
      thickness=0.5));
  connect(valHeaPum.port_b, pumHeaPumWat.port_a) annotation (Line(
      points={{310,-110},{310,-90}},
      color={0,127,255},
      thickness=0.5));
  connect(pumDryCoo.port_b, dryCoo.port_a) annotation (Line(
      points={{-40,130},{40,130}},
      color={0,127,255},
      thickness=0.5));
  connect(port_a, entGenTem.port_a) annotation (Line(
      points={{-540,-160},{-490,-160}},
      color={0,127,255},
      thickness=0.5));
  connect(entGenTem.port_b, pumCenPlaPri.port_a) annotation (Line(
      points={{-470,-160},{-390,-160}},
      color={0,127,255},
      thickness=0.5));
  connect(pumHeaPumGly.port_a, heaPumGlyIn.port_b) annotation (Line(
      points={{370,10},{370,20}},
      color={0,127,255},
      thickness=0.5));
  connect(heaPumGlyIn.port_a, valHeaPumByp.port_2) annotation (Line(
      points={{370,40},{370,50}},
      color={0,127,255},
      thickness=0.5));
  connect(hex.port_b1, bou.ports[1]) annotation (Line(
      points={{-300,-44},{-334,-44}},
      color={0,127,255},
      thickness=0.5));
  connect(uDisPum, ind.uDisPum) annotation (Line(points={{-560,260},{-530,260},
          {-530,264},{-482,264}}, color={0,0,127}));
  connect(ind.yEle, heaPumCon.uEleRat) annotation (Line(points={{-458,262},{
          -220,262},{-220,189},{-182,189}},
                                       color={255,127,0}));
  connect(ind.yEle, dryCooHexCon.uEleRat) annotation (Line(points={{-458,262},{
          -440,262},{-440,214},{-82,214}},
                                      color={255,127,0}));
  connect(ind.ySt, dryCooHexCon.uSt) annotation (Line(points={{-444,295},{-432,
          295},{-432,212},{-82,212}}, color={255,127,0}));
  connect(ind.ySt, heaPumCon.uSt) annotation (Line(points={{-444,295},{-212,295},
          {-212,187},{-182,187}}, color={255,127,0}));
  connect(ind.ySea, dryCooHexCon.uGen) annotation (Line(points={{-458,257},{
          -448,257},{-448,210},{-82,210}}, color={255,127,0}));
  connect(ind.ySea, heaPumCon.uGen) annotation (Line(points={{-458,257},{-228,
          257},{-228,178},{-182,178}}, color={255,127,0}));
  connect(heaPumCon.y1On, dryCooHexCon.u1HeaPum) annotation (Line(points={{-158,
          181},{-120,181},{-120,204},{-82,204}}, color={255,0,255}));
  connect(TMixAve, heaPumCon.TMixAve) annotation (Line(points={{-560,140},{-520,
          140},{-520,184},{-182,184}}, color={0,0,127}));
  connect(heaPumLea.T, heaPumCon.TWatOut) annotation (Line(points={{381,-100},{
          440,-100},{440,156},{-206,156},{-206,181},{-182,181}},   color={0,0,
          127}));
  connect(uDisPum, heaPumCon.uDisPum) annotation (Line(points={{-560,260},{-530,
          260},{-530,166},{-182,166}}, color={0,0,127}));
  connect(heaPumGlyIn.T, heaPumCon.TGlyIn) annotation (Line(points={{381,30},{
          432,30},{432,152},{-200,152},{-200,175},{-182,175}},   color={0,0,127}));
  connect(TDryBul, dryCooHexCon.TDryBul) annotation (Line(points={{-560,190},{-500,
          190},{-500,206},{-82,206}},      color={0,0,127}));
  connect(entGenTem.T, dryCooHexCon.TGenIn) annotation (Line(points={{-480,-149},
          {-480,208},{-82,208}}, color={0,0,127}));
  connect(dryCoo.port_b, dryCooOut.port_a)
    annotation (Line(points={{60,130},{120,130}}, color={0,127,255},
      thickness=0.5));
  connect(dryCooOut.T, dryCooHexCon.TDryCooOut) annotation (Line(points={{130,141},
          {130,190},{-100,190},{-100,200},{-82,200}},      color={0,0,127}));
  connect(dryCooHexCon.yValHex, valHex.y) annotation (Line(points={{-58,217},{-42,
          217},{-42,158},{-360,158},{-360,-100},{-332,-100}},     color={0,0,
          127}));
  connect(dryCooHexCon.yValHexByp, valHexByp.y) annotation (Line(points={{-58,219},
          {-42,219},{-42,238},{-210,238},{-210,-120},{-280,-120},{-280,-148}},
                                                            color={0,0,127}));
  connect(hex.port_a1, pumDryCoo1.port_b) annotation (Line(
      points={{-280,-44},{-260,-44},{-260,6}},
      color={0,127,255},
      thickness=0.5));
  connect(heaPumCon.yVal, valHeaPum.y) annotation (Line(points={{-158,175},{270,
          175},{270,-120},{298,-120}},
                                 color={0,0,127}));
  connect(heaPumCon.yValByp, valHeaPumByp.y) annotation (Line(points={{-158,171},
          {424,171},{424,60},{382,60}}, color={0,0,127}));
  connect(dryCooHexCon.yPumHex, pumDryCoo1.m_flow_in) annotation (Line(points={{-58,214},
          {0,214},{0,16},{-248,16}},         color={0,0,127}));
  connect(dryCooHexCon.yPumDryCoo, pumDryCoo.m_flow_in)
    annotation (Line(points={{-58,208},{-50,208},{-50,142}}, color={0,0,127}));
  connect(heaPumCon.yPumGly, pumHeaPumGly.m_flow_in) annotation (Line(points={{-158,
          178},{448,178},{448,0},{382,0}},      color={0,0,127}));
  connect(heaPumCon.yPum, pumHeaPumWat.m_flow_in) annotation (Line(points={{-158,
          173},{276,173},{276,-80},{298,-80}},    color={0,0,127}));
  connect(gai2.y, pumCenPlaPri.m_flow_in) annotation (Line(points={{-398,20},{-380,
          20},{-380,-148}}, color={0,0,127}));
  connect(uDisPum, gai2.u) annotation (Line(points={{-560,260},{-530,260},{-530,
          20},{-422,20}}, color={0,0,127}));
  connect(pumDryCoo.P, PPumDryCoo) annotation (Line(points={{-39,139},{-22,139},
          {-22,140},{-20,140},{-20,200},{560,200}},
                                color={0,0,127}));
  connect(pumDryCoo1.P, PPumHexGly) annotation (Line(points={{-251,5},{-251,-8},
          {-240,-8},{-240,144},{480,144},{480,170},{560,170}},
                                        color={0,0,127}));
  connect(pumHeaPumGly.P, PPumHeaPumGly) annotation (Line(points={{379,-11},{379,
          -20},{526,-20},{526,140},{560,140}}, color={0,0,127}));
  connect(pumHeaPumWat.P, PPumHeaPumWat) annotation (Line(points={{301,-69},{301,
          -60},{490,-60},{490,-140},{560,-140}},
                                               color={0,0,127}));
  connect(ind.yEleRat, yEleRat) annotation (Line(points={{-458,260},{260,260},{
          260,270},{560,270}},
                           color={0,0,127}));
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
  connect(hex.port_b2, jun1.port_3) annotation (Line(
      points={{-280,-56},{-240,-56},{-240,-150}},
      color={0,127,255},
      thickness=0.5));
  connect(jun2.port_3, valHeaPum.port_a) annotation (Line(
      points={{310,-150},{310,-130}},
      color={0,127,255},
      thickness=0.5));
  connect(jun2.port_2, jun3.port_1) annotation (Line(
      points={{320,-160},{360,-160}},
      color={0,127,255},
      thickness=0.5));
  connect(jun3.port_3, heaPumLea.port_b) annotation (Line(
      points={{370,-150},{370,-110}},
      color={0,127,255},
      thickness=0.5));
  connect(pumHeaPumWat.port_b, heaPum.port_a1) annotation (Line(
      points={{310,-70},{310,-36},{330,-36}},
      color={0,127,255},
      thickness=0.5));
  connect(heaPum.port_b1, heaPumLea.port_a) annotation (Line(
      points={{350,-36},{370,-36},{370,-90}},
      color={0,127,255},
      thickness=0.5));
  connect(pumHeaPumGly.port_b, heaPum.port_a2) annotation (Line(
      points={{370,-10},{370,-24},{350,-24}},
      color={0,127,255},
      thickness=0.5));
  connect(heaPumCon.y1Mod, heaPum.hea) annotation (Line(points={{-158,187},{96,
          187},{96,-27.9},{328.9,-27.9}},
                                     color={255,0,255}));
  connect(heaPum.P, PCom)
    annotation (Line(points={{351,-30},{560,-30}}, color={0,0,127}));
  connect(heaPumCon.y1Mod, dryCooHexCon.u1HeaPumMod) annotation (Line(points={{-158,
          187},{-116,187},{-116,202},{-82,202}}, color={255,0,255}));
  connect(heaPumCon.yLooHea, dryCooHexCon.uLooHea) annotation (Line(points={{-158,
          189},{-124,189},{-124,218},{-82,218}},      color={255,127,0}));
  connect(dryCooHexCon.TAirDryCooIn, dryCoo.TAir) annotation (Line(points={{-58,204},
          {20,204},{20,134},{38,134}},      color={0,0,127}));
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
  connect(leaGenTem.port_b, port_b) annotation (Line(points={{-490,-240},{-540,
          -240}},                   color={0,127,255},
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
    annotation (Line(points={{250,-160},{268,-160}}, color={0,127,255},
      thickness=0.5));
  connect(senTemMixCen.port_b, jun2.port_1)
    annotation (Line(points={{288,-160},{300,-160}}, color={0,127,255},
      thickness=0.5));
  connect(jun3.port_2, senTemMixHeaPum.port_a)
    annotation (Line(points={{380,-160},{398,-160}}, color={0,127,255},
      thickness=0.5));
  connect(senTemMixHeaPum.port_b, jun8.port_1) annotation (Line(points={{418,-160},
          {430,-160},{430,-240},{80,-240}}, color={0,127,255},
      thickness=0.5));
  connect(jun9.port_2, leaGenTem.port_a)
    annotation (Line(points={{-20,-240},{-470,-240}}, color={0,127,255},
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
          {-150,-90},{-150,-90}}, color={0,127,255},
      thickness=0.5));
  connect(pumBorFiePer.port_b, portBorFiePer_b) annotation (Line(points={{-150,-70},
          {-150,120},{-286,120},{-286,254},{-160,254},{-160,280}}, color={0,127,
          255},
      thickness=0.5));
  connect(senTemBorPerRet.port_b, jun7.port_3)
    annotation (Line(points={{-90,-122},{-90,-150}}, color={0,127,255},
      thickness=0.5));
  connect(senTemBorPerRet.port_a,portBorFiePer_a)  annotation (Line(points={{-90,
          -102},{-90,-38},{-146,-38},{-146,126},{-278,126},{-278,248},{-80,248},
          {-80,280}}, color={0,127,255},
      thickness=0.5));
  connect(jun4.port_3, pumBorFieCen.port_a) annotation (Line(points={{180,-150},
          {180,-90},{180,-90}}, color={0,127,255},
      thickness=0.5));
  connect(pumBorFieCen.port_b, portBorFieCen_b) annotation (Line(points={{180,-70},
          {180,232},{100,232},{100,280}}, color={0,127,255},
      thickness=0.5));
  connect(jun5.port_3, senTemBorCenRet.port_b)
    annotation (Line(points={{240,-150},{240,-120}}, color={0,127,255},
      thickness=0.5));
  connect(senTemBorCenRet.port_a,portBorFieCen_a)  annotation (Line(points={{240,
          -100},{240,-48},{184,-48},{184,238},{180,238},{180,280}}, color={0,127,
          255},
      thickness=0.5));
  connect(fixmeMassFlowRate.y, pumBorFiePer.m_flow_in) annotation (Line(points=
          {{-298,-210},{-170,-210},{-170,-80},{-162,-80}}, color={0,0,127}));
  connect(fixmeMassFlowRate.y, pumBorFieCen.m_flow_in) annotation (Line(points=
          {{-298,-210},{-170,-210},{-170,-100},{120,-100},{120,-80},{168,-80}},
        color={0,0,127}));
  connect(fixmeMassFlowRate.y, pumCenPlaSec.m_flow_in) annotation (Line(points=
          {{-298,-210},{-170,-210},{-170,-100},{120,-100},{120,-148}}, color={0,
          0,127}));
  connect(pumCenPlaPri.P, PPumCirAdd.u1) annotation (Line(points={{-369,-151},{-350,
          -151},{-350,-254},{198,-254}}, color={0,0,127}));
  connect(PPumCirAdd.u2, pumCenPlaSec.P) annotation (Line(points={{198,-266},{140,
          -266},{140,-151},{131,-151}}, color={0,0,127}));
  connect(PPumCirAdd.y, PPumCirPum) annotation (Line(points={{222,-260},{520,-260},
          {520,-210},{560,-210}}, color={0,0,127}));
  connect(pumBorFiePer.P, PPumBorFiePer) annotation (Line(points={{-159,-69},{-159,
          148},{520,148},{520,110},{560,110}}, color={0,0,127}));
  connect(pumBorFieCen.P, PPumBorFieCen) annotation (Line(points={{171,-69},{171,
          140},{516,140},{516,78},{560,78}}, color={0,0,127}));
  connect(fixme1.y, valIsoPriSec.y)
    annotation (Line(points={{4,-120},{30,-120},{30,-148}}, color={0,0,127}));
  connect(fixme2.y, valPriByp.y) annotation (Line(points={{-50,-200},{-22,-200}},
                                  color={0,0,127}));
  connect(TLooMaxMea, heaPumCon.TLooMaxMea) annotation (Line(points={{-560,100},
          {-472,100},{-472,172},{-182,172}}, color={0,0,127}));
  connect(TLooMinMea, heaPumCon.TLooMinMea) annotation (Line(points={{-560,60},
          {-466,60},{-466,169},{-182,169}}, color={0,0,127}));
  connect(heaPum.ySet, heaPumCon.yComSet) annotation (Line(points={{328.9,-31.9},
          {282,-31.9},{282,184},{-158,184},{-158,183}}, color={0,0,127}));
  connect(dryCooOut.port_b, jun12.port_1) annotation (Line(
      points={{140,130},{370,130},{370,110}},
      color={0,127,255},
      thickness=0.5));
  connect(jun12.port_2, valHeaPumByp.port_1) annotation (Line(
      points={{370,90},{370,70}},
      color={0,127,255},
      thickness=0.5));
  connect(heaPum.port_b2, jun15.port_1) annotation (Line(
      points={{330,-24},{310,-24},{310,50}},
      color={0,127,255},
      thickness=0.5));
  connect(jun15.port_3, valHeaPumByp.port_3) annotation (Line(
      points={{320,60},{360,60}},
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
      points={{-300,-44},{-320,-44},{-320,40}},
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
      points={{310,70},{310,90},{-310,90}},
      color={0,127,255},
      thickness=0.5));
  connect(jun16.port_2, pumDryCoo.port_a) annotation (Line(
      points={{-320,100},{-320,130},{-60,130}},
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
