within ThermalGridJBA.Hubs.Controls.BaseClasses;
partial block ConnectorDeclarationHHW "Lumped declaration for HHW connectors"

  Buildings.Controls.OBC.CDL.Interfaces.BooleanInput uHea
    "Charge request from the heating hot water tank" annotation (Placement(
        transformation(extent={{-140,-40},{-100,0}}),  iconTransformation(
          extent={{-140,-40},{-100,0}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TTopHea(final unit="K",
      displayUnit="degC") "Tank top temperature of the heating hot water tank"
    annotation (Placement(transformation(extent={{-140,-80},{-100,-40}}),
        iconTransformation(extent={{-140,-80},{-100,-40}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TSetHea(final unit="K",
      displayUnit="degC")
    "Tank top set point temperature of the heating hot water tank" annotation (
      Placement(transformation(extent={{-140,-120},{-100,-80}}),
        iconTransformation(extent={{-140,-120},{-100,-80}})));
  Modelica.Blocks.Interfaces.RealOutput TTop(final unit="K", displayUnit="degC")
    "Tank top temperature selected for the supervisory controller"
    annotation (Placement(transformation(extent={{100,-60},{140,-20}}),
                                                                     iconTransformation(extent={{100,-50},
            {120,-30}})));
  Modelica.Blocks.Interfaces.RealOutput TSet(final unit="K", displayUnit="degC")
    "Set point temperature selected for the supervisory controller" annotation
    (Placement(transformation(extent={{100,-100},{140,-60}}),
        iconTransformation(extent={{100,-90},{120,-70}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yDiv(final unit="1")
    "Diversion valve control signal" annotation (Placement(transformation(
          extent={{100,20},{140,60}}), iconTransformation(extent={{100,20},{140,
            60}})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanOutput y "Enable command"
    annotation (Placement(transformation(extent={{100,-20},{140,20}}),
        iconTransformation(extent={{100,-20},{140,20}})));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
        coordinateSystem(preserveAspectRatio=false)));
end ConnectorDeclarationHHW;
