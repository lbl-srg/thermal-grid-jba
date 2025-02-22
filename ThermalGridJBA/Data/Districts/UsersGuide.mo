within ThermalGridJBA.Data.Districts;
package UsersGuide "User's Guide"
  extends Modelica.Icons.Information;
  annotation (preferredView="info",
  Documentation(info="<html>
<p>
This data record package provide pre-configured district parameterisations.
The 17 in-scope buildings of the site are grouped at four levels:
</p>
<table><thead>
  <tr>
    <th>Grouping</th>
    <th>Record</th>
    <th>Load profile name</th>
    <th>Remarks</th>
  </tr></thead>
<tbody>
  <tr>
    <td>Individuals</td>
    <td>not implemented yet</td>
    <td>\"B0000\"</td>
    <td>Each individual building</td>
  </tr>
  <tr>
    <td>14 hubs</td>
    <td>not implemented yet</td>
    <td>\"H00\"</td>
    <td>Corresponds to the grouping in MILP</td>
  </tr>
  <tr>
    <td>5 clusters</td>
    <td><a href=\"modelica://ThermalGridJBA.Data.Districts.FiveHubs\">ThermalGridJBA.Data.Districts.FiveHubs</a></td>
    <td>\"CX\"</td>
    <td>Five is an empirical limit of ETS in one model.<br>The buildings are grouped by vicinity.</td>
  </tr>
  <tr>
    <td>All combined</td>
    <td><a href=\"modelica://ThermalGridJBA.Data.Districts.SingleHub\">ThermalGridJBA.Data.Districts.SingleHub</a></td>
    <td>\"All\"</td>
    <td>All building load profiles combined.</td>
  </tr>
</tbody>
</table>
<p>
The figure below illustrates how the buildings are grouped.
</p>
<p align=\"center\">
<img alt=\"image\" src=\"modelica://ThermalGridJBA/Resources/Images/Networks/building-grouping.png\"/>
</p>
</html>"));

end UsersGuide;
