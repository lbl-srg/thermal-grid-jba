within ThermalGridJBA.Requirements;
block DistrictLoop "Requirements for district loop"

  parameter Boolean verifyRequirements = true
    "Set to false to disable requirement verification";

  Modelica.Blocks.Interfaces.RealInput TLoo[:](
     each final unit="K",
     each displayUnit="degC") "Loop water temperatures"
    annotation (Placement(transformation(extent={{-140,40},{-100,80}})));
  Modelica.Blocks.Interfaces.RealInput RDisPip(each final unit="Pa/m")
    "Pressure drop per meter pipe in district pipe"
    annotation (Placement(transformation(extent={{-140,-20},{-100,20}})));
  Modelica.Blocks.Interfaces.RealInput RSerLin[:](
    each final unit="Pa/m")
    "Pressure drop per meter pipe in service line"
    annotation (Placement(transformation(extent={{-140,-80},{-100,-40}})));

  Buildings_Requirements.WithinBand     disLooTem[:](
    each name="District loop",
    each text=
        "O-401: The water that is served to each service line must be between 10.5◦C and 24◦C.",
    each u_max(
      each final unit="K",
      each displayUnit="degC") = 297.15,
    each u_min(
      each final unit="K",
      each displayUnit="degC") = 283.65) if verifyRequirements
    "Test whether loop temperatures are within an upper and lower band"
    annotation (Placement(transformation(extent={{0,60},{20,80}})));
  Buildings_Requirements.GreaterEqual disPipPreDro(
    name="District loop",
    text="The pressure drop in the district loop and the service line must be no bigger than
    125Pa/m at full load.")
    if verifyRequirements
    "Pressure drop distribution pipe and service lines"
    annotation (Placement(transformation(extent={{0,-12},{20,8}})));
  Buildings_Requirements.GreaterEqual serLinPreDro[:](
    each name="District loop",
    each text="The pressure drop in the district loop and the service line must be no bigger than
    125Pa/m at full load.")
    if verifyRequirements
    "Pressure drop distribution pipe and service lines"
    annotation (Placement(transformation(extent={{0,-60},{20,-40}})));
  Modelica.Blocks.Sources.Constant RMax(
    k(unit="Pa/m") = 125)
    "Maximum pressure drop per meter pipe"
    annotation (Placement(transformation(extent={{-80,20},{-60,40}})));
  Modelica.Blocks.Sources.Constant RMaxSerLin[:](
    each k(each unit="Pa/m") = 125)
    "Maximum pressure drop per meter pipe"
    annotation (Placement(transformation(extent={{-80,-40},{-60,-20}})));
equation
  connect(pipPreDro.u_min, RDisPip)
    annotation (Line(points={{-41,0},{-120,0}}, color={0,0,127}));
  connect(RMaxSerLin.y, serLinPreDro.u_max) annotation (Line(points={{-59,-30},
          {-30,-30},{-30,-44},{-1,-44}}, color={0,0,127}));
  connect(RSerLin, serLinPreDro.u_min) annotation (Line(points={{-120,-60},{-30,
          -60},{-30,-48},{-1,-48}}, color={0,0,127}));
  connect(RMax.y, disPipPreDro.u_max) annotation (Line(points={{-59,30},{-30,30},
          {-30,4},{-1,4}}, color={0,0,127}));
  connect(RDisPip, disPipPreDro.u_min)
    annotation (Line(points={{-120,0},{-1,0}}, color={0,0,127}));
  connect(TLoo, disLooTem.u) annotation (Line(points={{-120,60},{-62,60},{-62,
          74},{-1,74}}, color={0,0,127}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
        coordinateSystem(preserveAspectRatio=false)));
end DistrictLoop;
