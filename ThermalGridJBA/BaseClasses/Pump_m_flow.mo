within ThermalGridJBA.BaseClasses;
model Pump_m_flow "Pump with prescribed mass flow rate"
  extends Buildings.Fluid.Movers.FlowControlled_m_flow(
    per(
      pressure(
        V_flow=m_flow_nominal/rho_default*{0, 1, 2},
        dp=if rho_default < 500
           then dp_nominal*{1.12, 1, 0}
  else dp_nominal*{1.14, 1, 0.42}),
    powerOrEfficiencyIsHydraulic=false,
    etaHydMet = Buildings.Fluid.Movers.BaseClasses.Types.HydraulicEfficiencyMethod.Efficiency_VolumeFlowRate,
    etaMotMet = Buildings.Fluid.Movers.BaseClasses.Types.MotorEfficiencyMethod.Efficiency_VolumeFlowRate,
    efficiency(
        V_flow={0},
        eta={0.7})),
    final nominalValuesDefineDefaultPressureCurve=true,
    final inputType=Buildings.Fluid.Types.InputType.Continuous,
    final init=Modelica.Blocks.Types.Init.InitialOutput,
    addPowerToMedium=false,
    energyDynamics=Modelica.Fluid.Types.Dynamics.SteadyState,
    use_riseTime=false);
  annotation (
    Icon(
      graphics={
        Ellipse(
          extent={{-58,58},{58,-58}},
          lineColor={0,0,0},
          fillPattern=FillPattern.Sphere,
          fillColor={0,0,0}),
        Polygon(
          points={{-2,52},{-2,-48},{52,2},{-2,52}},
          lineColor={0,0,0},
          pattern=LinePattern.None,
          fillPattern=FillPattern.HorizontalCylinder,
          fillColor={255,255,255})}),
    Documentation(
      info="<html>
<p>
This is a steady-state model of a pump with ideally controlled
mass flow rate as input signal, and no heat added to the medium.
</p>
<p>
The model sets a constant efficiency, as opposed to using the efficiency based on the Euler method.
The reason is that in these system model, we use one pump to represent
an array of parallel pumps, and hence, if in an array of parallel pumps one pump would be
on and one off, this single pump would operate with a control signal of <i>0.5</i> times the design
mass flow rate.
If the Euler method were used, it would yield a very small efficiency.
</p>
</html>", revisions="<html>
<ul>
<li>
December 12, 2023, by Ettore Zanetti:<br/>
Changed to preconfigured pump model,
This is for
<a href=\"https://github.com/lbl-srg/modelica-buildings/issues/3431\">issue 3431</a>.
</li>
<li>
July 31, 2020, by Antoine Gautier:<br/>
First implementation.
</li>
</ul>
</html>"));
end Pump_m_flow;
