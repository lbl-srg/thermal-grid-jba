within ThermalGridJBA.Hubs.Controls;
block TwoTankCommand
  "Joint command for the two-status and the three-status tanks"
  extends Modelica.Blocks.Icons.Block;
  Buildings.Controls.OBC.CDL.Interfaces.BooleanInput u2
    "Two-status tank command: true = charge; false = no action" annotation (
      Placement(transformation(extent={{-140,40},{-100,80}}),
        iconTransformation(extent={{-140,40},{-100,80}})));
  Buildings.Controls.OBC.CDL.Interfaces.IntegerInput u3
    "Three-status tank command: 1 = no action; 2 = slow charge; 3 = fast charge"
    annotation (Placement(transformation(extent={{-140,-80},{-100,-40}}),
        iconTransformation(extent={{-140,-80},{-100,-40}})));
  Buildings.Controls.OBC.CDL.Interfaces.IntegerOutput y annotation (Placement(
        transformation(extent={{100,-20},{140,20}}), iconTransformation(extent={
            {100,-20},{140,20}})));
equation
  if u3 == 3 then
    y = 4; // HHW tank fast charge
  elseif u2 then
    y = 3; // DHW tank charge
  elseif u3 == 2 then
    y = 2; // HHW tank slow charge
  else
    y = 1; // no action
  end if;
  annotation(defaultComponentName="twoTanCom");
end TwoTankCommand;
