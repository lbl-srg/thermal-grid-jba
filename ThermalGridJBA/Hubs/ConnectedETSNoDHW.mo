within ThermalGridJBA.Hubs;
model ConnectedETSNoDHW "Load connected to the network via ETS"
  extends ThermalGridJBA.Hubs.BaseClasses.PartialConnectedETS(
    redeclare Buildings.DHC.ETS.Combined.ChillerBorefield ets(
      QChiWat_flow_nominal=QCoo_flow_nominal,
      QHeaWat_flow_nominal=QHea_flow_nominal,
      dp1Hex_nominal=40E3,
      dp2Hex_nominal=40E3,
      QHex_flow_nominal=-QCoo_flow_nominal,
      T_a1Hex_nominal=284.15,
      T_b1Hex_nominal=279.15,
      T_a2Hex_nominal=277.15,
      T_b2Hex_nominal=282.15,
      QWSE_flow_nominal=QCoo_flow_nominal,
      dpCon_nominal=40E3,
      dpEva_nominal=40E3,
      datChi=datChi));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput dHHeaWat_flow(final unit="W")
    "Heating water distributed energy flow rate"
    annotation (Placement(transformation(extent={{300,-160},{340,-120}}),
      iconTransformation(extent={{-20,-20},{20,20}},
        rotation=-90,
        origin={-40,-120})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput dHChiWat_flow(final unit="W")
    "Chilled water distributed energy flow rate"
    annotation (Placement(transformation(extent={{300,-120},{340,-80}}),
      iconTransformation(extent={{-20,-20},{20,20}},
        rotation=-90,
        origin={-20,-120})));
equation

  connect(ets.dHChiWat_flow, dHChiWat_flow)
    annotation (Line(points={{28,-90},{28,-100},{320,-100}}, color={0,0,127}));
  connect(dHHeaWat_flow, ets.dHHeaWat_flow) annotation (Line(points={{320,-140},
          {280,-140},{280,-106},{24,-106},{24,-90}}, color={0,0,127}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
        coordinateSystem(preserveAspectRatio=false)),
        defaultComponentName = "bui");
end ConnectedETSNoDHW;
