within ThermalGridJBA.CentralPlants;
model Generations
  "Cooling and heating generation from the heat pump and heat exchanger"
  package MediumW = Buildings.Media.Water "Water";
  //   package MediumG = Modelica.Media.Incompressible.Examples.Glycol47 "Glycol";
  package MediumA = Buildings.Media.Air "Air";
  package MediumG = Buildings.Media.Antifreeze.PropyleneGlycolWater(property_T=293.15, X_a=0.40) "Glycol";
  parameter Real TLooMin(
    unit="K",
    displayUnit="degC")=283.65
    "Design minimum district loop temperature";
  parameter Real TLooMax(
    unit="K",
    displayUnit="degC")=297.15
    "Design maximum district loop temperature";
  parameter Real TIniPlaHeaSet(
    unit="K",
    displayUnit="degC")=283.65
    "Initial plant heating setpoint temperature";
  parameter Real TIniPlaCooSet(
    unit="K",
    displayUnit="degC")=297.15
    "Initial plant cooling setpoint temperature";
  parameter Real TDisPumUpp(
    unit="K",
    displayUnit="degC")=TIniPlaHeaSet-2
    "Upper bound temperature for district pump control";
  parameter Real TDisPumLow(
    unit="K",
    displayUnit="degC")=TIniPlaCooSet+2
    "Lower bound temperature for district pump control";

  parameter Real mWat_flow_nominal(unit="kg/s")
    "Nominal water mass flow rate";
  parameter Real mFan_flow_nominal(unit="kg/s")=
    mGly_flow_nominal*MediumG.cp_const/Buildings.Utilities.Psychrometrics.Constants.cpAir
    "Design flow rate for dry cooler fan";
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
    "Nominal pressure drop of dry cooler on glycol side"
    annotation (Dialog(group="Dry cooler"));
  parameter Modelica.Units.SI.PressureDifference dpDryCooFan_nominal=200
    "Design pressure drop on air side of dry cooler"
    annotation (Dialog(group="Dry cooler"));
  parameter Real mGly_flow_nominal(unit="kg/s") = mHexGly_flow_nominal +
    mHeaPumGly_flow_nominal "Nominal glycol mass flow rate for dry cooler"
    annotation (Dialog(group="Dry cooler"));

  // Borefield parameters
  parameter Modelica.Units.SI.MassFlowRate mBorFiePer_flow_nominal
    "Mass flow rate for perimeter of borefield"
    annotation (Dialog(group="Borefield"));
  parameter Modelica.Units.SI.MassFlowRate mBorFieCen_flow_nominal
    "Mass flow rate for center of borefield"
    annotation (Dialog(group="Borefield"));
  parameter Real mBorFiePer_flow_minimum(
    final quantity="MassFlowRate",
    final unit="kg/s")
    "Minimum water mass flow rate to the perimeter borefield to get turbulent flow"
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
  parameter Real mHeaPumGly_flow_nominal(unit="kg/s")
    "Nominal glycol mass flow rate for heat pump"
    annotation (Dialog(group="Heat pump"));
  parameter Real QHeaPumHea_flow_nominal(unit="W")
    "Nominal heating capacity"
    annotation (Dialog(group="Heat pump"));
  parameter Real TConHea_nominal(unit="K") = TLooMin + dTHex_nominal
    "Nominal temperature of the heated fluid in heating mode"
    annotation (Dialog(group="Heat pump"));
  parameter Real TEvaHea_nominal(unit="K")
    "Nominal temperature of evaporator for heat pump design during heating"
    annotation (Dialog(group="Heat pump"));
  parameter Real QHeaPumCoo_flow_nominal(unit="W") "Nominal cooling capacity"
    annotation (Dialog(group="Heat pump"));
  parameter Real TConCoo_nominal(unit="K")
    "Nominal temperature of condenser for heat pump design during cooling"
    annotation (Dialog(group="Heat pump"));
  parameter Real TEvaCoo_nominal(unit="K") = TLooMax + dTHex_nominal
    "Nominal temperature of the heated fluid in cooling mode"
    annotation (Dialog(group="Heat pump"));

  // Controls
  parameter Real staDowDel(
    unit="s")=3600
    "Minimum stage down delay, to avoid quickly staging down"
    annotation (Dialog(tab="Controls"));
  parameter Modelica.Units.SI.TemperatureDifference dTOveShoMax(min=0)=2
    "Maximum temperature difference to allow for control over or undershoot. dTOveShoMax >= 0"
    annotation (Dialog(tab="Controls"));
  parameter Real TDryAppSet(unit="K")=2
    "Dry cooler approach setpoint"
    annotation (Dialog(tab="Controls", group="Dry cooler"));
  parameter Real dTHex_nominal(unit="K") = 4
    "Temperature difference for heat exchanger mass flow rates"
    annotation (Dialog(                group="Heat exchanger"));
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
  parameter Real TApp(
    final quantity="TemperatureDifference",
    final unit="K")=2
    "Approach temperature for enabling economizer"
    annotation (Dialog(tab="Controls", group="Economizer"));

  parameter Real TDryBulSum(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC")=297.15
    "Threshold of the dry bulb temperaure in summer below which starts charging borefield"
    annotation (Dialog(tab="Controls", group="Heat pump"));
  parameter Real dTCooCha(
    final min=0,
    final unit="K",
    final quantity="TemperatureDifference")=4
    "Temperature difference to allow subcooling the central borefield. dTCooCha >= 0"
    annotation (Dialog(tab="Controls", group="Heat pump"));
  parameter Real TConInMin(unit="K")
    "Minimum condenser inlet temperature"
    annotation (Dialog(tab="Controls", group="Heat pump"));
  parameter Real TEvaInMax(unit="K")
    "Maximum evaporator inlet temperature"
    annotation (Dialog(tab="Controls", group="Heat pump"));
  parameter Modelica.Units.SI.PressureDifference dpHeaPum_nominal=30000
    "Pressure drop of heat pump evaporator and condenser at nominal mass flow rate";
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
    "Heat pump controller type"
    annotation (Dialog(tab="Controls", group="Heat pump"));
  parameter Real kHeaPum "Gain of controller"
    annotation (Dialog(tab="Controls", group="Heat pump"));
  parameter Real TiHeaPum "Time constant of integrator block"
    annotation (Dialog(tab="Controls", group="Heat pump",
      enable=heaPumConTyp == Buildings.Controls.OBC.CDL.Types.SimpleController.PI
          or heaPumConTyp == Buildings.Controls.OBC.CDL.Types.SimpleController.PID));
  parameter Real TdHeaPum "Time constant of derivative block"
    annotation (Dialog(tab="Controls", group="Heat pump",
      enable=heaPumConTyp == Buildings.Controls.OBC.CDL.Types.SimpleController.PD
          or heaPumConTyp == Buildings.Controls.OBC.CDL.Types.SimpleController.PID));
  parameter Buildings.Controls.OBC.CDL.Types.SimpleController thrWayValConTyp
    "Three-way valve controller type"
    annotation (Dialog(tab="Controls", group="Heat pump"));
  parameter Real kVal "Gain of controller"
    annotation (Dialog(tab="Controls", group="Heat pump"));
  parameter Real TiVal "Time constant of integrator block"
    annotation (Dialog(tab="Controls", group="Heat pump",
      enable=thrWayValConTyp == Buildings.Controls.OBC.CDL.Types.SimpleController.PI
          or thrWayValConTyp == Buildings.Controls.OBC.CDL.Types.SimpleController.PID));
  parameter Real TdVal "Time constant of derivative block"
    annotation (Dialog(tab="Controls", group="Heat pump",
      enable=thrWayValConTyp == Buildings.Controls.OBC.CDL.Types.SimpleController.PD
          or thrWayValConTyp == Buildings.Controls.OBC.CDL.Types.SimpleController.PID));

  parameter Modelica.Units.SI.Time heaPumIsoValStrTim=30
    "Time needed to fully open or close heat pump waterside isolation valve"
    annotation (Dialog(tab="Dynamics", group="Heat pum"));
  parameter Modelica.Units.SI.Time heaPumPumRis=30
    "Time needed to change motor speed between zero and full speed for the heat pump waterside pump"
    annotation (Dialog(tab="Dynamics", group="Heat pum"));
  parameter Modelica.Units.SI.Time heaPumRisTim=30
    "Time needed to change motor speed between zero and full speed for the heat pump compressor"
    annotation (Dialog(tab="Dynamics", group="Heat pum"));

  Buildings.Controls.OBC.CDL.Interfaces.RealInput TPlaOut(
    final unit="K",
    final quantity="ThermodynamicTemperature",
    displayUnit="degC")
    "Central plant outlet water temperature"
    annotation (Placement(transformation(extent={{-580,460},{-540,500}}),
        iconTransformation(extent={{-140,60},{-100,100}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput uDisPum
    "District loop pump speed"
    annotation (Placement(transformation(extent={{-580,292},{-540,332}}),
        iconTransformation(extent={{-140,-80},{-100,-40}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TLooMaxMea(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC")
    "Maximum temperature of mixing points after each energy transfer station"
    annotation (Placement(transformation(extent={{-580,420},{-540,460}}),
        iconTransformation(extent={{-140,20},{-100,60}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TLooMinMea(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC")
    "Minimum temperature of mixing points after each energy transfer station"
    annotation (Placement(transformation(extent={{-580,380},{-540,420}}),
        iconTransformation(extent={{-140,-20},{-100,20}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TDryBul(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC") "Ambient dry bulb temperature"
    annotation (Placement(transformation(extent={{-580,260},{-540,300}}),
        iconTransformation(extent={{-140,-118},{-100,-78}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yEleRat
    "Current electricity rate, dollar per kWh"
    annotation (Placement(transformation(extent={{660,450},{700,490}}),
        iconTransformation(extent={{100,70},{140,110}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput PFanDryCoo(
    final quantity="Power",
    final unit="W")
    "Electrical power consumed by dry cool fan"
    annotation (Placement(transformation(extent={{660,324},{700,364}}),
        iconTransformation(extent={{100,50},{140,90}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput PPumDryCoo(
    final quantity="Power",
    final unit="W") "Electrical power consumed by dry cool pump"
    annotation (Placement(transformation(extent={{660,280},{700,320}}),
        iconTransformation(extent={{100,30},{140,70}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput PPumHexGly(
    final quantity="Power",
    final unit="W")
    "Electrical power consumed by the glycol pump of HEX"
    annotation (Placement(transformation(extent={{660,250},{700,290}}),
        iconTransformation(extent={{100,10},{140,50}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput PPumHeaPumGly(
    final quantity="Power",
    final unit="W")
    "Electrical power consumed by glycol pump of heat pump"
    annotation (Placement(transformation(extent={{660,164},{700,204}}),
        iconTransformation(extent={{100,-10},{140,30}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput PPumBorFiePer(
    final quantity="Power",
    final unit="W")
    "Electrical power consumed by pump for borefield perimeter"
    annotation (Placement(transformation(extent={{660,134},{700,174}}),
        iconTransformation(extent={{100,-30},{140,10}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput PPumBorFieCen(
    final quantity="Power",
    final unit="W")
    "Electrical power consumed by pump for borefield center"
    annotation (Placement(transformation(extent={{660,102},{700,142}}),
        iconTransformation(extent={{100,-50},{140,-10}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput PCom(
    final quantity="Power",
    final unit="W")
    "Electric power consumed by compressor"
    annotation (Placement(transformation(extent={{660,-40},{700,0}}),
        iconTransformation(extent={{100,-150},{140,-110}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput PPumHeaPumWat(
    final quantity="Power",
    final unit="W")
    "Electrical power consumed by heat pump waterside pump"
    annotation (Placement(transformation(extent={{660,0},{700,40}}),
        iconTransformation(extent={{100,-90},{140,-50}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput PPumCirPum(
    final quantity="Power",
    final unit="W") "Electrical power consumed by circulation pumps"
    annotation (Placement(transformation(extent={{660,-230},{700,-190}}),
        iconTransformation(extent={{100,-110},{140,-70}})));

  Modelica.Fluid.Interfaces.FluidPort_a port_a(
    redeclare final package Medium = MediumW)
    "Fluid connector for waterflow from the district"
    annotation (Placement(transformation(extent={{-550,-170},{-530,-150}}),
      iconTransformation(extent={{-110,-170},{-90,-150}})));
  Modelica.Fluid.Interfaces.FluidPort_b port_b(
    redeclare final package Medium = MediumW)
    "Fluid connector for waterflow to the district"
    annotation (Placement(transformation(extent={{-550,-232},{-530,-212}}),
      iconTransformation(extent={{-110,-210},{-90,-190}})));
  ThermalGridJBA.BaseClasses.Pump_m_flow pumCenPlaPri(
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
    allowFlowReversal2=false,
    redeclare final package Medium1 = MediumG,
    redeclare final package Medium2 = MediumW,
    final m1_flow_nominal=mHexGly_flow_nominal,
    final m2_flow_nominal=mWat_flow_nominal,
    show_T=true,
    final dp1_nominal=dpHex_nominal,
    final dp2_nominal=dpHex_nominal,
    eps=0.9)                         "Economizer"
    annotation (Placement(transformation(extent={{-270,-40},{-290,-20}})));
  Buildings.Fluid.Actuators.Valves.TwoWayEqualPercentage valHeaPum(
    redeclare final package Medium = MediumW,
    final m_flow_nominal=mHeaPumWat_flow_nominal,
    final dpValve_nominal=dpValve_nominal,
    use_strokeTime=true,
    final strokeTime=heaPumIsoValStrTim,
    dpFixed_nominal=dpHeaPum_nominal)
    "Heat pump water loop valve"
    annotation (Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=90, origin={310,-130})));
  ThermalGridJBA.BaseClasses.Pump_m_flow pumHeaPumWat(
    redeclare final package Medium = MediumW,
    final addPowerToMedium=false,
    final use_riseTime=true,
    final riseTime=heaPumPumRis,
    final m_flow_nominal=mHeaPumWat_flow_nominal,
    dp_nominal=dpHeaPum_nominal + dpValve_nominal,
    dpMax=Modelica.Constants.inf) "Pump for heat pump waterside loop"
     annotation (Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=90, origin={310,-40})));
  ThermalGridJBA.BaseClasses.Pump_m_flow pumDryCoo(
    redeclare final package Medium = MediumG,
    final addPowerToMedium=false,
    use_riseTime=true,
    riseTime=heaPumPumRis,
    final m_flow_nominal=mGly_flow_nominal,
    dpMax=Modelica.Constants.inf) "Dry cooler pump"
    annotation (Placement(transformation(extent={{388,170},{408,190}})));
  ThermalGridJBA.BaseClasses.Pump_m_flow pumHeaPumGly(
    redeclare final package Medium = MediumG,
    final addPowerToMedium=false,
    final use_riseTime=true,
    final riseTime=heaPumPumRis,
    final m_flow_nominal=mHeaPumGly_flow_nominal,
    dpMax=Modelica.Constants.inf)
    "Pump for heat pump glycol loop"
    annotation (Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=-90, origin={370,10})));
  Buildings.Fluid.Actuators.Valves.ThreeWayEqualPercentageLinear valHeaPumByp(
    redeclare final package Medium = MediumG,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    use_strokeTime=true,
    strokeTime=heaPumIsoValStrTim,
    m_flow_nominal=mHeaPumGly_flow_nominal,
    final dpValve_nominal=dpValve_nominal)
    "Heat pump bypass valve"
    annotation (Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=-90, origin={370,70})));
  Buildings.Fluid.Sensors.TemperatureTwoPort senTemGenEnt(
    redeclare final package Medium = MediumW,
    allowFlowReversal=false,
    final m_flow_nominal=mWat_flow_nominal)
    "Temperature of waterflow entering the generation module"
    annotation (Placement(transformation(extent={{-490,-170},{-470,-150}})));
  Buildings.Fluid.Sensors.TemperatureTwoPort senTemHeaPumLea(
    redeclare final package Medium = MediumW,
    final m_flow_nominal=mHeaPumWat_flow_nominal)
    "Temperature of waterflow leave heat pump" annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={370,-100})));
  Buildings.Fluid.Sensors.TemperatureTwoPort senTemHeaPumGlyIn(
    redeclare final package Medium = MediumG,
    final m_flow_nominal=mHeaPumGly_flow_nominal)
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
    final m_flow_nominal=mGly_flow_nominal) "Temperature of dry cooler outlet"
    annotation (Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=0,
        origin={440,140})));
  ThermalGridJBA.BaseClasses.Pump_m_flow pumHexGly(
    redeclare final package Medium = MediumG,
    final addPowerToMedium=false,
    use_riseTime=true,
    riseTime=heaPumPumRis,
    final m_flow_nominal=mHexGly_flow_nominal,
    dpMax=Modelica.Constants.inf) "Pump economizer heat exchanger glycol side"
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={-240,16})));
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
    use_intSafCtr=false,
    safCtrPar(
      use_antFre=true,
      TAntFre=257.15,
      use_minFlowCtr=false),
    dTCon_nominal=dTHex_nominal,
    mCon_flow_nominal=mHeaPumWat_flow_nominal,
    dpCon_nominal=0,
    use_conCap=false,
    CCon=3000,
    GConOut=100,
    GConIns=1000,
    dTEva_nominal=dTHex_nominal,
    mEva_flow_nominal=mHeaPumGly_flow_nominal,
    dpEva_nominal=dpHeaPum_nominal,
    use_evaCap=false,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    final QHea_flow_nominal=QHeaPumHea_flow_nominal,
    final QCoo_flow_nominal=QHeaPumCoo_flow_nominal,
    redeclare model RefrigerantCycleHeatPumpHeating =
        Buildings.Fluid.HeatPumps.ModularReversible.RefrigerantCycle.ConstantCarnotEffectiveness
        (redeclare
          Buildings.Fluid.HeatPumps.ModularReversible.RefrigerantCycle.Frosting.NoFrosting
          iceFacCal, final use_constAppTem=true),
    redeclare model RefrigerantCycleHeatPumpCooling =
        Buildings.Fluid.Chillers.ModularReversible.RefrigerantCycle.ConstantCarnotEffectiveness
        (redeclare
          Buildings.Fluid.HeatPumps.ModularReversible.RefrigerantCycle.Frosting.NoFrosting
          iceFacCal, final use_constAppTem=true),
    final TConHea_nominal=TConHea_nominal,
    final TEvaHea_nominal=TEvaHea_nominal,
    final TConCoo_nominal=TConCoo_nominal,
    final TEvaCoo_nominal=TEvaCoo_nominal) "Reversible heat pump"
    annotation (Placement(transformation(extent={{330,-10},{350,-30}})));

  ThermalGridJBA.BaseClasses.Pump_m_flow pumCenPlaSec(
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
    annotation (Placement(transformation(extent={{80,-212},{60,-232}})));
  Buildings.Fluid.FixedResistances.Junction jun9(
    redeclare final package Medium = MediumW,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    portFlowDirection_1=Modelica.Fluid.Types.PortFlowDirection.Entering,
    portFlowDirection_2=Modelica.Fluid.Types.PortFlowDirection.Leaving,
    portFlowDirection_3=Modelica.Fluid.Types.PortFlowDirection.Bidirectional,
    m_flow_nominal={mWat_flow_nominal,-mWat_flow_nominal,mWat_flow_nominal},
    dp_nominal={0,0,0})
    annotation (Placement(transformation(extent={{0,-212},{-20,-232}})));
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
        origin={-10,-192})));
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
  ThermalGridJBA.BaseClasses.Pump_m_flow pumBorFieCen(
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
  ThermalGridJBA.BaseClasses.Pump_m_flow pumBorFiePer(
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
    annotation (Placement(transformation(extent={{-160,490},{-140,510}}),
        iconTransformation(extent={{-90,90},{-70,110}})));
  Modelica.Fluid.Interfaces.FluidPort_a portBorFiePer_a(redeclare final package
      Medium = MediumW)
    "Fluid connector for return from perimeter zones of borefield" annotation (
      Placement(transformation(extent={{-100,490},{-80,510}}),
        iconTransformation(extent={{-50,90},{-30,110}})));
  Modelica.Fluid.Interfaces.FluidPort_b portBorFieCen_b(redeclare final package
      Medium = MediumW) "Fluid connector to center zones of borefield"
    annotation (Placement(transformation(extent={{170,490},{190,510}}),
        iconTransformation(extent={{30,90},{50,110}})));
  Modelica.Fluid.Interfaces.FluidPort_a portBorFieCen_a(redeclare final package
      Medium = MediumW)
    "Fluid connector for return from center zones of borefield" annotation (
      Placement(transformation(extent={{230,490},{250,510}}),
        iconTransformation(extent={{70,90},{90,110}})));
  Buildings.Fluid.Sensors.TemperatureTwoPort senTemGenLea(
    redeclare final package Medium = MediumW,
    allowFlowReversal=false,
    final m_flow_nominal=mWat_flow_nominal)
    "Temperature of waterflow leaving the generation module" annotation (
      Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=0,
        origin={-480,-222})));
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
    m_flow_nominal={mGly_flow_nominal,-mHeaPumGly_flow_nominal,-mGly_flow_nominal},
    dp_nominal={0,0,0}) annotation (Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=0,
        origin={370,140})));
  Buildings.Fluid.FixedResistances.Junction jun13(
    redeclare final package Medium = MediumG,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    m_flow_nominal=mGly_flow_nominal*{1,-1,-1},
    dp_nominal={0,0,0}) annotation (Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=0,
        origin={-240,140})));
  Buildings.Fluid.FixedResistances.Junction jun14(
    redeclare final package Medium = MediumG,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    m_flow_nominal=mGly_flow_nominal*{1,-1,1},
    dp_nominal={0,0,0}) annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-320,140})));
  Buildings.Fluid.FixedResistances.Junction jun15(
    redeclare final package Medium = MediumG,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    m_flow_nominal=mHeaPumGly_flow_nominal*{1,-1,-1},
    dp_nominal={0,0,0})
    annotation (Placement(transformation(extent={{10,10},{-10,-10}},
        rotation=-90,
        origin={310,70})));
  Buildings.Fluid.FixedResistances.Junction jun16(
    redeclare final package Medium = MediumG,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    m_flow_nominal={mGly_flow_nominal,-mGly_flow_nominal,mGly_flow_nominal},
    dp_nominal={0,0,0}) annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={310,180})));
  ThermalGridJBA.Networks.Controls.Indicators ind(
    final TIniPlaHeaSet=TIniPlaHeaSet,
    final TIniPlaCooSet=TIniPlaCooSet,
    final TDryBulSum=TDryBulSum,
    final staDowDel=staDowDel) "Load indicator"
    annotation (Placement(transformation(extent={{-482,464},{-462,484}})));
  ThermalGridJBA.Networks.Controls.HeatExchanger hexCon(final
      mHexGly_flow_nominal=mHexGly_flow_nominal,
      final TApp=TApp)
    "Heat exchanger economizer and the associated pump and valves control"
    annotation (Placement(transformation(extent={{-450,430},{-430,450}})));
  ThermalGridJBA.Networks.Controls.DryCooler dryCooCon(
    final TAppSet=TDryAppSet,
    final minFanSpe=minFanSpe,
    final fanConTyp=fanConTyp,
    final kFan=kFan,
    final TiFan=TiFan,
    final TdFan=TdFan,
    final mFan_flow_nominal=mFan_flow_nominal)
    "Dry cooler and the associated pump control"
    annotation (Placement(transformation(extent={{20,388},{40,408}})));
  ThermalGridJBA.Networks.Controls.Borefields borCon(
    final mWat_flow_nominal=mWat_flow_nominal,
    final mBorFiePer_flow_nominal=mBorFiePer_flow_nominal,
    final mBorFieCen_flow_nominal=mBorFieCen_flow_nominal,
    final mBorFiePer_flow_minimum=mBorFiePer_flow_minimum)
    "Borefield pumps and the valves control"
    annotation (Placement(transformation(extent={{-342,420},{-322,440}})));
  ThermalGridJBA.Networks.Controls.HeatPump heaPumCon(
    final mWat_flow_nominal=mHeaPumWat_flow_nominal,
    final mWat_flow_min=mHeaPumWat_flow_min,
    final mHeaPumGly_flow_nominal=mHeaPumGly_flow_nominal,
    final mBorFieCen_flow_nominal=mBorFieCen_flow_nominal,
    final TLooMin=TLooMin,
    final TLooMax=TLooMax,
    final TDryBulSum=TDryBulSum,
    final dTCooCha=dTCooCha,
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
    final del=minHeaPumSpeHol,
    final isoValStrTim=heaPumIsoValStrTim,
    final watPumRis=heaPumPumRis,
    final heaPumRisTim=heaPumRisTim)
    "Heat pump controller"
    annotation (Placement(transformation(extent={{132,312},{152,336}})));
  Buildings.Fluid.Sensors.MassFlowRate senMasFloPla(
    redeclare package Medium = MediumW,
    allowFlowReversal=false)
    "Mass flow rate entering plant"
    annotation (Placement(transformation(extent={{-440,-170},{-420,-150}})));
  Buildings.Fluid.Sensors.MassFlowRate senMasFloHeaPum(
    redeclare package Medium = MediumW)
    "Mass flow rate entering heat pump" annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={310,-102})));
  Buildings.Fluid.Sensors.TemperatureTwoPort senTemHeaPumEnt(
    redeclare final package Medium = MediumW,
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
  Buildings.Fluid.Sensors.TemperatureTwoPort senTemBorCenSup(
    redeclare final package Medium = MediumW,
    allowFlowReversal=false,
    final m_flow_nominal=mBorFieCen_flow_nominal,
    tau=0) "Temperature of supply to borefield center" annotation (Placement(
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
  Buildings.Fluid.Sensors.TemperatureTwoPort senTemDryCooIn(
    redeclare final package Medium = MediumG,
    final m_flow_nominal=mGly_flow_nominal) "Temperature of dry cooler inlet"
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={440,180})));
  Buildings.Fluid.HeatExchangers.ConstantEffectiveness dryCoo(
    redeclare package Medium1 = MediumA,
    redeclare package Medium2 = MediumG,
    final m1_flow_nominal=mFan_flow_nominal,
    final m2_flow_nominal=mGly_flow_nominal,
    show_T=true,
    final dp1_nominal=dpDryCooFan_nominal,
    final dp2_nominal=dpDryCoo_nominal,
    eps=0.9) "Dry cooler"
    annotation (Placement(transformation(extent={{10,-10},{-10,10}},
        rotation=270,
        origin={486,162})));
  Buildings.Fluid.Sources.Boundary_pT      bouAirIn(
    redeclare package Medium = MediumA,
    use_T_in=true,
    nPorts=1) "Inlet air into dry cooler"
    annotation (Placement(transformation(extent={{590,130},{570,150}})));
  Buildings.Fluid.Sources.Boundary_pT bouAirOut(redeclare package Medium =
        MediumA, nPorts=1) "Pressure boundary condition for air"
    annotation (Placement(transformation(extent={{590,170},{570,190}})));

  ThermalGridJBA.BaseClasses.Pump_m_flow fanDryCoo(
    redeclare package Medium = MediumA,
    energyDynamics=Modelica.Fluid.Types.Dynamics.SteadyState,
    final addPowerToMedium=false,
    use_riseTime=true,
    riseTime=heaPumPumRis,
    final m_flow_nominal=mFan_flow_nominal,
    final dp_nominal=dpDryCooFan_nominal,
    dpMax=Modelica.Constants.inf) "Dry cooler fan"
    annotation (Placement(transformation(extent={{520,170},{540,190}})));

  Networks.Controls.ActualOvershot actOveSho(
    final TLooMax=TLooMax,
    final TLooMin=TLooMin,
    final TDisPumUpp=TDisPumUpp,
    final TDisPumLow=TDisPumLow,
    final dTOveShoMax=dTOveShoMax)
    "Actual overshot"
    annotation (Placement(transformation(extent={{-520,424},{-500,444}})));
protected
  Buildings.Controls.OBC.CDL.Reals.Add PPumCirAdd
    "Adder for circulation pump power"
    annotation (Placement(transformation(extent={{240,-260},{260,-240}})));
equation
  connect(port_a,senTemGenEnt. port_a) annotation (Line(
      points={{-540,-160},{-490,-160}},
      color={0,127,255},
      thickness=1));
  connect(pumHeaPumGly.port_a, senTemHeaPumGlyIn.port_b) annotation (Line(
      points={{370,20},{370,30}},
      color={0,127,255},
      thickness=1));
  connect(senTemHeaPumGlyIn.port_a, valHeaPumByp.port_2) annotation (Line(
      points={{370,50},{370,60}},
      color={0,127,255},
      thickness=1));
  connect(hex.port_b1, bou.ports[1]) annotation (Line(
      points={{-290,-24},{-334,-24}},
      color={0,127,255},
      thickness=1));
  connect(hex.port_a1, pumHexGly.port_b) annotation (Line(
      points={{-270,-24},{-240,-24},{-240,6}},
      color={0,127,255},
      thickness=1));
  connect(pumDryCoo.P, PPumDryCoo) annotation (Line(points={{409,189},{418,189},
          {418,300},{680,300}}, color={135,135,135},
      pattern=LinePattern.Dash));
  connect(pumHexGly.P, PPumHexGly) annotation (Line(points={{-231,5},{-231,0},{
          -190,0},{-190,274},{678,274},{678,270},{680,270}},   color={135,135,
          135},
      pattern=LinePattern.Dash));
  connect(pumHeaPumGly.P, PPumHeaPumGly) annotation (Line(points={{379,-1},{379,
          -4},{646,-4},{646,184},{680,184}},   color={135,135,135},
      pattern=LinePattern.Dash));
  connect(pumCenPlaPri.port_b, jun.port_1) annotation (Line(
      points={{-370,-160},{-330,-160}},
      color={0,127,255},
      thickness=1));
  connect(jun.port_2, valHexByp.port_a)
    annotation (Line(points={{-310,-160},{-290,-160}},
                                                     color={0,127,255},
      thickness=1));
  connect(jun.port_3, valHex.port_a)
    annotation (Line(points={{-320,-150},{-320,-110}}, color={0,127,255},
      thickness=1));
  connect(valHexByp.port_b, jun1.port_1) annotation (Line(
      points={{-270,-160},{-250,-160}},
      color={0,127,255},
      thickness=1));
  connect(jun2.port_3, valHeaPum.port_a) annotation (Line(
      points={{310,-150},{310,-150},{310,-150},{310,-140}},
      color={0,127,255},
      thickness=1));
  connect(jun2.port_2, jun3.port_1) annotation (Line(
      points={{320,-160},{336,-160},{336,-160},{360,-160}},
      color={0,127,255},
      thickness=1));
  connect(jun3.port_3, senTemHeaPumLea.port_b) annotation (Line(
      points={{370,-150},{370,-110}},
      color={0,127,255},
      thickness=1));
  connect(pumHeaPumWat.port_b, heaPum.port_a1) annotation (Line(
      points={{310,-30},{310,-26},{330,-26}},
      color={0,127,255},
      thickness=1));
  connect(heaPum.port_b1, senTemHeaPumLea.port_a) annotation (Line(
      points={{350,-26},{370,-26},{370,-90}},
      color={0,127,255},
      thickness=1));
  connect(pumHeaPumGly.port_b, heaPum.port_a2) annotation (Line(
      points={{370,0},{370,-14},{350,-14}},
      color={0,127,255},
      thickness=1));
  connect(heaPum.P, PCom)
    annotation (Line(points={{351,-20},{680,-20}}, color={135,135,135},
      pattern=LinePattern.Dash));
  connect(jun4.port_2,jun5. port_1) annotation (Line(
      points={{190,-160},{230,-160}},
      color={0,127,255},
      thickness=1));
  connect(jun6.port_2,jun7. port_1) annotation (Line(
      points={{-140,-160},{-100,-160}},
      color={0,127,255},
      thickness=1));
  connect(jun10.port_2, valIsoPriSec.port_a)
    annotation (Line(points={{0,-160},{20,-160}}, color={0,127,255},
      thickness=1));
  connect(valIsoPriSec.port_b, jun11.port_1)
    annotation (Line(points={{40,-160},{60,-160}}, color={0,127,255},
      thickness=1));
  connect(jun11.port_2, pumCenPlaSec.port_a)
    annotation (Line(points={{80,-160},{110,-160}}, color={0,127,255},
      thickness=1));
  connect(pumCenPlaSec.port_b, jun4.port_1)
    annotation (Line(points={{130,-160},{170,-160}}, color={0,127,255},
      thickness=1));
  connect(jun8.port_2, jun9.port_1)
    annotation (Line(points={{60,-222},{0,-222}}, color={0,127,255},
      thickness=1));
  connect(senTemGenLea.port_b, port_b) annotation (Line(
      points={{-490,-222},{-540,-222}},
      color={0,127,255},
      thickness=1));
  connect(jun1.port_2, senTemMixHex.port_a)
    annotation (Line(points={{-230,-160},{-202,-160}}, color={0,127,255},
      thickness=1));
  connect(senTemMixHex.port_b, jun6.port_1)
    annotation (Line(points={{-182,-160},{-160,-160}}, color={0,127,255},
      thickness=1));
  connect(jun7.port_2, senTemMixPer.port_a)
    annotation (Line(points={{-80,-160},{-60,-160}}, color={0,127,255},
      thickness=1));
  connect(senTemMixPer.port_b, jun10.port_1)
    annotation (Line(points={{-40,-160},{-20,-160}}, color={0,127,255},
      thickness=1));
  connect(jun5.port_2, senTemMixCen.port_a)
    annotation (Line(points={{250,-160},{270,-160}}, color={0,127,255},
      thickness=1));
  connect(senTemMixCen.port_b, jun2.port_1)
    annotation (Line(points={{290,-160},{300,-160}}, color={0,127,255},
      thickness=1));
  connect(jun3.port_2, senTemMixHeaPum.port_a)
    annotation (Line(points={{380,-160},{398,-160}}, color={0,127,255},
      thickness=1));
  connect(senTemMixHeaPum.port_b, jun8.port_1) annotation (Line(points={{418,-160},
          {430,-160},{430,-222},{80,-222}}, color={0,127,255},
      thickness=1));
  connect(jun9.port_2,senTemGenLea. port_a) annotation (Line(
      points={{-20,-222},{-470,-222}},
      color={0,127,255},
      thickness=1));
  connect(jun10.port_3, valPriByp.port_a)
    annotation (Line(points={{-10,-170},{-10,-182}},
                                                   color={0,127,255},
      thickness=1));
  connect(valPriByp.port_b, jun9.port_3) annotation (Line(points={{-10,-202},{-10,
          -212}},                      color={0,127,255},
      thickness=1));
  connect(jun11.port_3, jun8.port_3)
    annotation (Line(points={{70,-170},{70,-212}}, color={0,127,255},
      thickness=1));
  connect(jun6.port_3, pumBorFiePer.port_a) annotation (Line(points={{-150,-150},
          {-150,-110}},           color={0,127,255},
      thickness=1));
  connect(senTemBorPerRet.port_b, jun7.port_3)
    annotation (Line(points={{-90,-82},{-90,-150}},  color={0,127,255},
      thickness=1));
  connect(senTemBorPerRet.port_a,portBorFiePer_a)  annotation (Line(points={{-90,-62},
          {-90,500}}, color={0,127,255},
      thickness=1));
  connect(jun4.port_3, pumBorFieCen.port_a) annotation (Line(points={{180,-150},
          {180,-120}},          color={0,127,255},
      thickness=1));
  connect(jun5.port_3, senTemBorCenRet.port_b)
    annotation (Line(points={{240,-150},{240,-82}},  color={0,127,255},
      thickness=1));
  connect(senTemBorCenRet.port_a,portBorFieCen_a)  annotation (Line(points={{240,-62},
          {240,500}},                                               color={0,127,
          255},
      thickness=1));
  connect(pumCenPlaPri.P, PPumCirAdd.u1) annotation (Line(points={{-369,-151},{-350,
          -151},{-350,-244},{238,-244}}, color={135,135,135},
      pattern=LinePattern.Dash));
  connect(PPumCirAdd.u2, pumCenPlaSec.P) annotation (Line(points={{238,-256},{140,
          -256},{140,-151},{131,-151}}, color={135,135,135},
      pattern=LinePattern.Dash));
  connect(PPumCirAdd.y, PPumCirPum) annotation (Line(points={{262,-250},{520,
          -250},{520,-210},{680,-210}},
                                  color={135,135,135},
      pattern=LinePattern.Dash));
  connect(pumBorFiePer.P, PPumBorFiePer) annotation (Line(points={{-159,-89},{-159,
          236},{638,236},{638,154},{680,154}}, color={135,135,135},
      pattern=LinePattern.Dash));
  connect(pumBorFieCen.P, PPumBorFieCen) annotation (Line(points={{171,-99},{172,
          -99},{172,-96},{160,-96},{160,122},{680,122}},
                                             color={135,135,135},
      pattern=LinePattern.Dash));
  connect(senTemDryCooOut.port_b, jun12.port_1) annotation (Line(
      points={{430,140},{380,140}},
      color={0,127,255},
      thickness=1));
  connect(jun12.port_3, valHeaPumByp.port_1) annotation (Line(
      points={{370,130},{370,80}},
      color={0,127,255},
      thickness=1));
  connect(heaPum.port_b2, jun15.port_1) annotation (Line(
      points={{330,-14},{310,-14},{310,60}},
      color={0,127,255},
      thickness=1));
  connect(jun15.port_3, valHeaPumByp.port_3) annotation (Line(
      points={{320,70},{360,70}},
      color={0,127,255},
      thickness=1));
  connect(jun12.port_2, jun13.port_1) annotation (Line(
      points={{360,140},{-230,140}},
      color={0,127,255},
      thickness=1));
  connect(jun13.port_3, pumHexGly.port_a) annotation (Line(
      points={{-240,130},{-240,26}},
      color={0,127,255},
      thickness=1));
  connect(hex.port_b1, jun14.port_1) annotation (Line(
      points={{-290,-24},{-320,-24},{-320,130}},
      color={0,127,255},
      thickness=1));
  connect(jun13.port_2, jun14.port_3) annotation (Line(
      points={{-250,140},{-310,140}},
      color={0,127,255},
      thickness=1));
  connect(jun14.port_2, jun16.port_1) annotation (Line(
      points={{-320,150},{-320,180},{300,180}},
      color={0,127,255},
      thickness=1));
  connect(jun15.port_2, jun16.port_3) annotation (Line(
      points={{310,80},{310,170}},
      color={0,127,255},
      thickness=1));
  connect(jun16.port_2, pumDryCoo.port_a) annotation (Line(
      points={{320,180},{388,180}},
      color={0,127,255},
      thickness=1));
  connect(ind.ySt, hexCon.uSt) annotation (Line(points={{-460,474},{-456,474},{-456,
          446},{-452,446}}, color={255,127,0}));
  connect(ind.yEle, hexCon.uEleRat) annotation (Line(points={{-460,471},{-460,470},
          {-454,470},{-454,450},{-452,450},{-452,449}},
                                  color={255,127,0}));
  connect(ind.ySea, hexCon.uSea) annotation (Line(points={{-460,466},{-458,466},
          {-458,444},{-452,444},{-452,443}},
                                  color={255,127,0}));
  connect(TDryBul, hexCon.TDryBul) annotation (Line(points={{-560,280},{-532,280},
          {-532,392},{-460,392},{-460,432},{-452,432}},
                                  color={0,0,127}));
  connect(senTemGenEnt.T, hexCon.TPlaIn) annotation (Line(points={{-480,-149},{-480,
          436},{-452,436}},      color={0,0,127}));
  connect(TDryBul, dryCooCon.TDryBul) annotation (Line(points={{-560,280},{14,
          280},{14,388},{18,388}},     color={0,0,127}));
  connect(ind.ySt, borCon.uSt) annotation (Line(points={{-460,474},{-362,474},{-362,
          437},{-344,437}}, color={255,127,0}));
  connect(ind.yEle, borCon.uEleRat) annotation (Line(points={{-460,471},{-358,471},
          {-358,439},{-344,439}}, color={255,127,0}));
  connect(ind.ySea, borCon.uSea) annotation (Line(points={{-460,466},{-370,466},
          {-370,435},{-344,435}}, color={255,127,0}));
  connect(ind.ySt, heaPumCon.uSt) annotation (Line(points={{-460,474},{86,474},
          {86,334},{130,334}},    color={255,127,0}));
  connect(ind.yEle, heaPumCon.uEleRat) annotation (Line(points={{-460,471},{90,
          471},{90,336},{130,336}},    color={255,127,0}));
  connect(ind.ySea, heaPumCon.uSea) annotation (Line(points={{-460,466},{-372,
          466},{-372,332},{130,332}},                   color={255,127,0}));
  connect(uDisPum, borCon.uDisPum) annotation (Line(points={{-560,312},{-376,
          312},{-376,431},{-344,431}},                  color={0,0,127}));
  connect(senTemGenEnt.T, heaPumCon.TPlaIn) annotation (Line(points={{-480,-149},
          {-480,308},{84,308},{84,328},{130,328}},      color={0,0,127}));
  connect(senTemHeaPumLea.T, heaPumCon.THeaPumOut) annotation (Line(points={{381,
          -100},{616,-100},{616,286},{92,286},{92,320},{130,320}},        color
        ={0,0,127}));
  connect(senTemGenEnt.port_b, senMasFloPla.port_a) annotation (Line(
      points={{-470,-160},{-440,-160}},
      color={0,127,255},
      thickness=1));
  connect(senMasFloPla.port_b, pumCenPlaPri.port_a) annotation (Line(
      points={{-420,-160},{-390,-160}},
      color={0,127,255},
      thickness=1));
  connect(valHeaPum.port_b, senMasFloHeaPum.port_a) annotation (Line(
      points={{310,-120},{310,-112}},
      color={0,127,255},
      thickness=1));
  connect(senMasFloPla.m_flow, heaPumCon.mPla_flow) annotation (Line(points={{-430,
          -149},{-430,270},{96,270},{96,318},{130,318}},      color={0,0,127}));
  connect(senMasFloHeaPum.m_flow, heaPumCon.mHeaPum_flow) annotation (Line(
        points={{299,-102},{274,-102},{274,276},{100,276},{100,316},{130,316}},
        color={0,0,127}));
  connect(senTemHeaPumGlyIn.T, heaPumCon.TGlyIn) annotation (Line(points={{381,40},
          {622,40},{622,270},{104,270},{104,314},{130,314}},        color={0,0,
          127}));
  connect(uDisPum, heaPumCon.uDisPum) annotation (Line(points={{-560,312},{130,
          312}},                                             color={0,0,127}));
  connect(hexCon.yValHexByp, valHexByp.y) annotation (Line(points={{-428,444},{
          -410,444},{-410,-120},{-280,-120},{-280,-148}},
                                                     color={0,0,127}));
  connect(hexCon.yValHex, valHex.y) annotation (Line(points={{-428,440},{-404,440},
          {-404,-100},{-332,-100}}, color={0,0,127}));
  connect(hexCon.yPumHex, pumHexGly.m_flow_in) annotation (Line(points={{-428,
          436},{-416,436},{-416,260},{-208,260},{-208,16},{-228,16}},
                                                                    color={0,0,
          127}));
  connect(dryCooCon.mSetPumDryCoo_flow, pumDryCoo.m_flow_in) annotation (Line(
        points={{42,404},{48,404},{48,252},{398,252},{398,192}}, color={0,0,127}));
  connect(borCon.yValPriByp, valPriByp.y) annotation (Line(points={{-320,438},{-176,
          438},{-176,-192},{-22,-192}}, color={0,0,127}));
  connect(borCon.yValIso, valIsoPriSec.y) annotation (Line(points={{-320,435},{
          -288,435},{-288,242},{30,242},{30,-148}},
                                                 color={0,0,127}));
  connect(borCon.yPumPerBor, pumBorFiePer.m_flow_in) annotation (Line(points={{-320,
          430},{-172,430},{-172,-100},{-162,-100}},
                                                  color={0,0,127}));
  connect(borCon.yPumPri, pumCenPlaPri.m_flow_in) annotation (Line(points={{-320,
          427},{-294,427},{-294,348},{-380,348},{-380,-148}},   color={0,0,127}));
  connect(borCon.yPumCenBor, pumBorFieCen.m_flow_in) annotation (Line(points={{-320,
          424},{-300,424},{-300,246},{152,246},{152,-110},{168,-110}},
                                                                     color={0,0,
          127}));
  connect(borCon.yPumSec, pumCenPlaSec.m_flow_in) annotation (Line(points={{-320,
          421},{-306,421},{-306,256},{120,256},{120,-148}},   color={0,0,127}));
  connect(heaPumCon.y1Mod, heaPum.hea) annotation (Line(points={{154,333},{292,
          333},{292,-17.9},{328.9,-17.9}},
                                      color={255,0,255}));
  connect(heaPumCon.yComSet, heaPum.ySet) annotation (Line(points={{154,331},{
          286,331},{286,-21.9},{328.9,-21.9}},
                                           color={0,0,127}));
  connect(heaPumCon.yPumGly, pumHeaPumGly.m_flow_in) annotation (Line(points={{154,323},
          {630,323},{630,10},{382,10}},    color={0,0,127}));
  connect(heaPumCon.yVal, valHeaPum.y) annotation (Line(points={{154,320},{266,
          320},{266,-130},{298,-130}},
                                  color={0,0,127}));
  connect(heaPumCon.yValByp, valHeaPumByp.y) annotation (Line(points={{154,317},
          {608,317},{608,70},{382,70}}, color={0,0,127}));
  connect(heaPumCon.yPum, pumHeaPumWat.m_flow_in) annotation (Line(points={{154,314},
          {258,314},{258,-40},{298,-40}},      color={0,0,127}));
  connect(TPlaOut, ind.TPlaOut)
    annotation (Line(points={{-560,480},{-484,480}}, color={0,0,127}));
  connect(heaPumCon.y1On, dryCooCon.u1HeaPum) annotation (Line(points={{154,328},
          {164,328},{164,364},{-2,364},{-2,404},{18,404}},       color={255,0,
          255}));
  connect(senTemDryCooOut.T, dryCooCon.TDryCooOut) annotation (Line(points={{440,151},
          {440,158},{458,158},{458,416},{8,416},{8,391},{18,391}},
                                                                color={0,0,127}));
  connect(ind.yEleRat, yEleRat) annotation (Line(points={{-460,469},{680,469},{
          680,470}},           color={0,0,127}));
  connect(heaPumCon.y1On, borCon.u1HeaPum) annotation (Line(points={{154,328},{
          162,328},{162,372},{-348,372},{-348,420},{-344,420},{-344,421}},
                                                                color={255,0,
          255}));
  connect(senMasFloHeaPum.m_flow, borCon.mHeaPum_flow) annotation (Line(points={{299,
          -102},{274,-102},{274,348},{-354,348},{-354,422},{-344,422},{-344,423}},
        color={0,0,127}));
  connect(pumHeaPumWat.P, PPumHeaPumWat) annotation (Line(points={{301,-29},{
          301,-6},{652,-6},{652,20},{680,20}},     color={135,135,135},
      pattern=LinePattern.Dash));
  connect(senMasFloHeaPum.port_b,senTemHeaPumEnt. port_a) annotation (Line(
      points={{310,-92},{310,-80}},
      color={0,127,255},
      thickness=1));
  connect(senTemHeaPumEnt.port_b, pumHeaPumWat.port_a) annotation (Line(
      points={{310,-60},{310,-50}},
      color={0,127,255},
      thickness=1));
  connect(senTemHeaPumEnt.T, heaPumCon.THeaPumIn) annotation (Line(points={{299,-70},
          {278,-70},{278,282},{88,282},{88,322},{130,322}},           color={0,
          0,127}));
  connect(pumBorFiePer.port_b, senTemBorPerSup.port_a) annotation (Line(
      points={{-150,-90},{-150,-80}},
      color={0,127,255},
      thickness=1));
  connect(senTemBorPerSup.port_b, portBorFiePer_b) annotation (Line(
      points={{-150,-60},{-150,500}},
      color={0,127,255},
      thickness=1));
  connect(pumBorFieCen.port_b, senTemBorCenSup.port_a) annotation (Line(
      points={{180,-100},{180,-82}},
      color={0,127,255},
      thickness=1));
  connect(senTemBorCenSup.port_b, portBorFieCen_b) annotation (Line(
      points={{180,-62},{180,500}},
      color={0,127,255},
      thickness=1));
  connect(valHex.port_b, senTemEcoEnt.port_a) annotation (Line(
      points={{-320,-90},{-320,-80}},
      color={0,127,255},
      thickness=1));
  connect(senTemEcoEnt.port_b, hex.port_a2) annotation (Line(
      points={{-320,-60},{-320,-36},{-290,-36}},
      color={0,127,255},
      thickness=1));
  connect(hex.port_b2, senTemEcoLea.port_a) annotation (Line(
      points={{-270,-36},{-240,-36},{-240,-62}},
      color={0,127,255},
      thickness=1));
  connect(senTemEcoLea.port_b, jun1.port_3) annotation (Line(
      points={{-240,-82},{-240,-150}},
      color={0,127,255},
      thickness=1));
  connect(pumDryCoo.port_b, senTemDryCooIn.port_a)
    annotation (Line(points={{408,180},{430,180}}, color={0,127,255},
      thickness=1));
  connect(senTemDryCooIn.T, dryCooCon.TDyrCooIn)
    annotation (Line(points={{440,191},{440,414},{12,414},{12,395},{18,395}},
                                                        color={0,0,127}));
  connect(hexCon.on, dryCooCon.u1Eco) annotation (Line(points={{-428,448},{-2,
          448},{-2,407},{18,407}},                       color={255,0,255}));
  connect(heaPumCon.yPumGly, dryCooCon.mDryCooLoa_flow[1]) annotation (Line(
        points={{154,323},{168,323},{168,376},{2,376},{2,397.5},{18,397.5}},
                              color={0,0,127}));
  connect(hexCon.yPumHex, dryCooCon.mDryCooLoa_flow[2]) annotation (Line(points={{-428,
          436},{-432,436},{-432,318},{-6,318},{-6,398.5},{18,398.5}},
        color={0,0,127}));
  connect(senTemDryCooIn.port_b, dryCoo.port_a2) annotation (Line(
      points={{450,180},{480,180},{480,172}},
      color={0,127,255},
      thickness=1));
  connect(dryCoo.port_b2, senTemDryCooOut.port_a) annotation (Line(
      points={{480,152},{480,140},{450,140}},
      color={0,127,255},
      thickness=1));
  connect(dryCoo.port_a1, bouAirIn.ports[1]) annotation (Line(
      points={{492,152},{492,140},{570,140}},
      color={0,127,255},
      thickness=1));

  connect(bouAirIn.T_in, TDryBul) annotation (Line(points={{592,144},{600,144},
          {600,280},{-560,280}},
                            color={0,0,127}));
  connect(bouAirOut.ports[1], fanDryCoo.port_b) annotation (Line(
      points={{570,180},{540,180}},
      color={0,127,255},
      thickness=1));
  connect(fanDryCoo.port_a, dryCoo.port_b1) annotation (Line(
      points={{520,180},{492,180},{492,172}},
      color={0,127,255},
      thickness=1));
  connect(fanDryCoo.m_flow_in, dryCooCon.mSetFanDryCoo_flow) annotation (Line(
        points={{530,192},{530,262},{46,262},{46,398},{42,398}},
                                                               color={0,0,127}));
  connect(fanDryCoo.P, PFanDryCoo) annotation (Line(points={{541,189},{554,189},
          {554,344},{680,344}},
                           color={135,135,135},
      pattern=LinePattern.Dash));
  connect(ind.TActPlaCooSet, heaPumCon.TActPlaCooSet) annotation (Line(points={{-460,
          477},{94,477},{94,324},{130,324}},      color={0,0,127}));
  connect(TDryBul, heaPumCon.TDryBul) annotation (Line(points={{-560,280},{80,
          280},{80,330},{130,330}},
                               color={0,0,127}));
  connect(heaPumCon.y1SumCooBor, borCon.u1SumCooBor) annotation (Line(points={{154,335},
          {156,335},{156,356},{-352,356},{-352,433},{-344,433}},          color
        ={255,0,255}));
  connect(TDryBul, ind.TDryBul) annotation (Line(points={{-560,280},{-532,280},{
          -532,474},{-484,474}}, color={0,0,127}));
  connect(TLooMaxMea, actOveSho.TMixMax) annotation (Line(points={{-560,440},{-522,
          440}},                     color={0,0,127}));
  connect(TLooMinMea, actOveSho.TMixMin) annotation (Line(points={{-560,400},{-528,
          400},{-528,428},{-522,428}},
                                    color={0,0,127}));
  connect(actOveSho.dTActHeaOveSho, ind.dTActHeaOveSho) annotation (Line(points={{-498,
          428},{-490,428},{-490,468},{-484,468}},
        color={0,0,127}));
  connect(ind.TActPlaHeaSet, heaPumCon.TActPlaHeaSet) annotation (Line(points={{-460,
          483},{110,483},{110,326},{130,326}},      color={0,0,127}));
  connect(actOveSho.dTActCooOveSho, ind.dTActCooOveSho) annotation (Line(points={{-498,
          440},{-492,440},{-492,470},{-484,470}},
        color={0,0,127}));
  connect(borCon.TMixMea, senTemMixPer.T) annotation (Line(points={{-344,425},{-380,
          425},{-380,364},{-50,364},{-50,-149}},
        color={0,0,127}));
  connect(ind.TActPlaHeaSet, borCon.TActPlaHeaSet) annotation (Line(points={{-460,
          483},{-388,483},{-388,430},{-366,430},{-366,429},{-344,429}},
                                                       color={0,0,127}));
  connect(ind.TActPlaCooSet, borCon.TActPlaCooSet) annotation (Line(points={{-460,
          477},{-392,477},{-392,426},{-344,426},{-344,427}},      color={0,0,
          127}));
  connect(borCon.u1HeaPumMod, heaPumCon.y1Mod) annotation (Line(points={{-344,
          419},{-350,419},{-350,360},{160,360},{160,333},{154,333}}, color={255,
          0,255}));
  annotation (defaultComponentName="gen",
  Icon(coordinateSystem(preserveAspectRatio=false, extent={{-100,-220},{100,100}}),
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
          extent={{-540,-280},{660,500}})),
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
