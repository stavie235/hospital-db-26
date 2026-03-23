# hospital-db-26

just reviewed  install.sql exceot απο τις βαρδιες και τα φαρμακα κ ολα τα εμπλεκομενα 
https://app.diagrams.net/#G1yI_30mXudaJQPMzchIIUsxKzp7gwZI5u#%7B%22pageId%22%3A%22H0l7PjpYrFNg5VEylbUn%22%7D [er-diagram-hospital-latest-2(2).drawio](https://github.com/user-attachments/files/26183173/er-diagram-hospital-latest-2.2.drawio)
<mxfile host="app.diagrams.net" agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36" version="29.6.3">
  <diagram name="Σελίδα-1" id="H0l7PjpYrFNg5VEylbUn">
    <mxGraphModel grid="1" page="0" gridSize="10" guides="1" tooltips="1" connect="1" arrows="1" fold="1" pageScale="1" pageWidth="6000" pageHeight="4800" math="0" shadow="0">
      <root>
        <mxCell id="0" />
        <mxCell id="1" parent="0" />
        <mxCell id="e_Staff" parent="1" style="shape=rectangle;whiteSpace=wrap;html=1;strokeWidth=2;fontSize=35;fontStyle=1;verticalAlign=middle;fillColor=#dae8fc;strokeColor=#6c8ebf;" value="Staff Member&amp;nbsp;" vertex="1">
          <mxGeometry height="80" width="250" x="2400" y="115" as="geometry" />
        </mxCell>
        <mxCell id="a_100" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;fontStyle=4;fillColor=#fff2cc;strokeColor=#d6b656;" value="&lt;u&gt;staff_id&lt;/u&gt;" vertex="1">
          <mxGeometry height="80" width="250" x="2080" y="220" as="geometry" />
        </mxCell>
        <mxCell id="ae_101" edge="1" parent="1" source="e_Staff" style="endArrow=none;html=1;arcSize=20;fontSize=35;" target="a_100">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_102" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="amka" vertex="1">
          <mxGeometry height="80" width="250" x="2810" y="-120" as="geometry" />
        </mxCell>
        <mxCell id="ae_103" edge="1" parent="1" source="e_Staff" style="endArrow=none;html=1;arcSize=20;fontSize=35;" target="a_102">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_104" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="first_name" vertex="1">
          <mxGeometry height="80" width="250" x="2840" y="-10" as="geometry" />
        </mxCell>
        <mxCell id="ae_105" edge="1" parent="1" source="e_Staff" style="endArrow=none;html=1;arcSize=20;fontSize=35;" target="a_104">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_106" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="last_name" vertex="1">
          <mxGeometry height="80" width="250" x="2860" y="80" as="geometry" />
        </mxCell>
        <mxCell id="ae_107" edge="1" parent="1" source="e_Staff" style="endArrow=none;html=1;arcSize=20;fontSize=35;" target="a_106">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_108" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="age" vertex="1">
          <mxGeometry height="80" width="250" x="2740" y="230" as="geometry" />
        </mxCell>
        <mxCell id="ae_109" edge="1" parent="1" source="e_Staff" style="endArrow=none;html=1;arcSize=20;fontSize=35;" target="a_108">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_110" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="email" vertex="1">
          <mxGeometry height="80" width="250" x="2650" y="-330" as="geometry" />
        </mxCell>
        <mxCell id="ae_111" edge="1" parent="1" source="e_Staff" style="endArrow=none;html=1;arcSize=20;fontSize=35;" target="a_110">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_112" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="phone" vertex="1">
          <mxGeometry height="80" width="250" x="2330" y="-380" as="geometry" />
        </mxCell>
        <mxCell id="ae_113" edge="1" parent="1" source="e_Staff" style="endArrow=none;html=1;arcSize=20;fontSize=35;" target="a_112">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_114" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="hiring_date" vertex="1">
          <mxGeometry height="80" width="250" x="2175" y="-270" as="geometry" />
        </mxCell>
        <mxCell id="ae_115" edge="1" parent="1" source="e_Staff" style="endArrow=none;html=1;arcSize=20;fontSize=35;" target="a_114">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_116" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="staff_type" vertex="1">
          <mxGeometry height="80" width="250" x="2050" y="-100" as="geometry" />
        </mxCell>
        <mxCell id="ae_117" edge="1" parent="1" source="e_Staff" style="endArrow=none;html=1;arcSize=20;fontSize=35;" target="a_116">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_118" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="photo_url" vertex="1">
          <mxGeometry height="80" width="250" x="2280" y="-160" as="geometry" />
        </mxCell>
        <mxCell id="ae_119" edge="1" parent="1" source="e_Staff" style="endArrow=none;html=1;arcSize=20;fontSize=35;" target="a_118">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_120" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="description" vertex="1">
          <mxGeometry height="80" width="250" x="2560" y="-190" as="geometry" />
        </mxCell>
        <mxCell id="ae_121" edge="1" parent="1" source="e_Staff" style="endArrow=none;html=1;arcSize=20;fontSize=35;" target="a_120">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="e_Doctor" parent="1" style="shape=rectangle;whiteSpace=wrap;html=1;fillColor=#DAE8FC;strokeColor=#6C8EBF;strokeWidth=2;fontSize=35;fontStyle=1;verticalAlign=middle;" value="Doctor" vertex="1">
          <mxGeometry height="80" width="250" x="1100" y="615" as="geometry" />
        </mxCell>
        <mxCell id="a_122" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fillColor=#FFF2CC;strokeColor=#D6B656;fontSize=35;fontStyle=4;" value="&lt;u&gt;staff_id&lt;/u&gt;" vertex="1">
          <mxGeometry height="80" width="250" x="1340" y="400" as="geometry" />
        </mxCell>
        <mxCell id="ae_123" edge="1" parent="1" source="e_Doctor" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_122">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_124" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="license_number" vertex="1">
          <mxGeometry height="80" width="290" x="860" y="905" as="geometry" />
        </mxCell>
        <mxCell id="ae_125" edge="1" parent="1" source="e_Doctor" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_124">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_126" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="specialty" vertex="1">
          <mxGeometry height="80" width="250" x="860" y="790" as="geometry" />
        </mxCell>
        <mxCell id="ae_127" edge="1" parent="1" source="e_Doctor" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_126">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_128" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="rank" vertex="1">
          <mxGeometry height="80" width="250" x="733" y="680" as="geometry" />
        </mxCell>
        <mxCell id="ae_129" edge="1" parent="1" source="e_Doctor" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_128">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_130" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="supervisor_id" vertex="1">
          <mxGeometry height="80" width="250" x="560" y="570" as="geometry" />
        </mxCell>
        <mxCell id="ae_131" edge="1" parent="1" source="e_Doctor" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_130">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="e_Nurse" parent="1" style="shape=rectangle;whiteSpace=wrap;html=1;fillColor=#DAE8FC;strokeColor=#6C8EBF;strokeWidth=2;fontSize=35;fontStyle=1;verticalAlign=middle;" value="Nurse" vertex="1">
          <mxGeometry height="80" width="250" x="2490" y="830" as="geometry" />
        </mxCell>
        <mxCell id="a_132" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fillColor=#FFF2CC;strokeColor=#D6B656;fontSize=35;fontStyle=4;" value="&lt;u&gt;staff_id&lt;/u&gt;" vertex="1">
          <mxGeometry height="80" width="250" x="2730" y="580" as="geometry" />
        </mxCell>
        <mxCell id="ae_133" edge="1" parent="1" source="e_Nurse" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_132">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_134" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="rank" vertex="1">
          <mxGeometry height="80" width="250" x="2050" y="600" as="geometry" />
        </mxCell>
        <mxCell id="ae_135" edge="1" parent="1" source="e_Nurse" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_134">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_136" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="department_id" vertex="1">
          <mxGeometry height="80" width="250" x="2000" y="450" as="geometry" />
        </mxCell>
        <mxCell id="ae_137" edge="1" parent="1" source="e_Nurse" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_136">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="e_Administrative" parent="1" style="shape=rectangle;whiteSpace=wrap;html=1;fillColor=#DAE8FC;strokeColor=#6C8EBF;strokeWidth=2;fontSize=35;fontStyle=1;verticalAlign=middle;" value="Administrative" vertex="1">
          <mxGeometry height="80" width="250" x="3690" y="615" as="geometry" />
        </mxCell>
        <mxCell id="a_138" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fillColor=#FFF2CC;strokeColor=#D6B656;fontSize=35;fontStyle=4;" value="&lt;u&gt;staff_id&lt;/u&gt;" vertex="1">
          <mxGeometry height="80" width="250" x="3646" y="470" as="geometry" />
        </mxCell>
        <mxCell id="ae_139" edge="1" parent="1" source="e_Administrative" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_138">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_140" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="role" vertex="1">
          <mxGeometry height="80" width="250" x="3320" y="695" as="geometry" />
        </mxCell>
        <mxCell id="ae_141" edge="1" parent="1" source="e_Administrative" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_140">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_142" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="office_location" vertex="1">
          <mxGeometry height="80" width="250" x="3592" y="732" as="geometry" />
        </mxCell>
        <mxCell id="ae_143" edge="1" parent="1" source="e_Administrative" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_142">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_144" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="department_id" vertex="1">
          <mxGeometry height="80" width="250" x="3700" y="830" as="geometry" />
        </mxCell>
        <mxCell id="ae_145" edge="1" parent="1" source="e_Administrative" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_144">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="e_Department" parent="1" style="shape=rectangle;whiteSpace=wrap;html=1;fillColor=#DAE8FC;strokeColor=#6C8EBF;strokeWidth=2;fontSize=35;fontStyle=1;verticalAlign=middle;" value="Department" vertex="1">
          <mxGeometry height="80" width="250" x="3690" y="1265" as="geometry" />
        </mxCell>
        <mxCell id="a_146" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fillColor=#FFF2CC;strokeColor=#D6B656;fontSize=35;fontStyle=4;" value="&lt;u&gt;department_id&lt;/u&gt;" vertex="1">
          <mxGeometry height="80" width="250" x="4465" y="1010" as="geometry" />
        </mxCell>
        <mxCell id="ae_147" edge="1" parent="1" source="e_Department" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_146">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_148" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="name" vertex="1">
          <mxGeometry height="80" width="250" x="4060" y="1170" as="geometry" />
        </mxCell>
        <mxCell id="ae_149" edge="1" parent="1" source="e_Department" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_148">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_150" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="description" vertex="1">
          <mxGeometry height="80" width="250" x="3420" y="910" as="geometry" />
        </mxCell>
        <mxCell id="ae_151" edge="1" parent="1" source="e_Department" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_150">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_152" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="num_beds" vertex="1">
          <mxGeometry height="80" width="250" x="3990" y="1540" as="geometry" />
        </mxCell>
        <mxCell id="ae_153" edge="1" parent="1" source="e_Department" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_152">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_154" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="floor_building" vertex="1">
          <mxGeometry height="80" width="250" x="3596" y="1382" as="geometry" />
        </mxCell>
        <mxCell id="ae_155" edge="1" parent="1" source="e_Department" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_154">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_156" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="director_id" vertex="1">
          <mxGeometry height="80" width="250" x="3320" y="1316" as="geometry" />
        </mxCell>
        <mxCell id="ae_157" edge="1" parent="1" source="e_Department" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_156">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_158" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="photo_url" vertex="1">
          <mxGeometry height="80" width="250" x="3592" y="1030" as="geometry" />
        </mxCell>
        <mxCell id="ae_159" edge="1" parent="1" source="e_Department" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_158">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="e_Bed" parent="1" style="shape=rectangle;whiteSpace=wrap;html=1;fillColor=#DAE8FC;strokeColor=#6C8EBF;strokeWidth=2;fontSize=35;fontStyle=1;verticalAlign=middle;double=1;" value="Bed" vertex="1">
          <mxGeometry height="80" width="250" x="4715" y="1265" as="geometry" />
        </mxCell>
        <mxCell id="a_160" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fillColor=#FFF2CC;strokeColor=#D6B656;fontSize=35;fontStyle=4;" value="&lt;u&gt;bed_id&lt;/u&gt;" vertex="1">
          <mxGeometry height="80" width="250" x="4761" y="1140" as="geometry" />
        </mxCell>
        <mxCell id="ae_161" edge="1" parent="1" source="e_Bed" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_160">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_162" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="bed_number" vertex="1">
          <mxGeometry height="80" width="250" x="5050" y="1500" as="geometry" />
        </mxCell>
        <mxCell id="ae_163" edge="1" parent="1" source="e_Bed" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_162">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_164" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="bed_type" vertex="1">
          <mxGeometry height="80" width="250" x="4740" y="1580" as="geometry" />
        </mxCell>
        <mxCell id="ae_165" edge="1" parent="1" source="e_Bed" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_164">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_166" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="status" vertex="1">
          <mxGeometry height="80" width="250" x="4540" y="1450" as="geometry" />
        </mxCell>
        <mxCell id="ae_167" edge="1" parent="1" source="e_Bed" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_166">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_168" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="department_id" vertex="1">
          <mxGeometry height="80" width="250" x="4813" y="1420" as="geometry" />
        </mxCell>
        <mxCell id="ae_169" edge="1" parent="1" source="e_Bed" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_168">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="e_ProcedureRoom" parent="1" style="shape=rectangle;whiteSpace=wrap;html=1;fillColor=#DAE8FC;strokeColor=#6C8EBF;strokeWidth=2;fontSize=35;fontStyle=1;verticalAlign=middle;" value="Procedure Room" vertex="1">
          <mxGeometry height="80" width="250" x="4680" y="2665" as="geometry" />
        </mxCell>
        <mxCell id="a_170" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;fontStyle=4;fillColor=#fff2cc;strokeColor=#d6b656;" value="&lt;u&gt;room_id&lt;/u&gt;" vertex="1">
          <mxGeometry height="80" width="250" x="4813" y="2520" as="geometry" />
        </mxCell>
        <mxCell id="ae_171" edge="1" parent="1" source="e_ProcedureRoom" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_170">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_172" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="room_name" vertex="1">
          <mxGeometry height="80" width="250" x="4820" y="2816" as="geometry" />
        </mxCell>
        <mxCell id="ae_173" edge="1" parent="1" source="e_ProcedureRoom" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_172">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_174" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="room_type" vertex="1">
          <mxGeometry height="80" width="250" x="4680" y="2958" as="geometry" />
        </mxCell>
        <mxCell id="ae_175" edge="1" parent="1" source="e_ProcedureRoom" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_174">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_176" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="description" vertex="1">
          <mxGeometry height="80" width="250" x="4480" y="2840" as="geometry" />
        </mxCell>
        <mxCell id="ae_177" edge="1" parent="1" source="e_ProcedureRoom" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_176">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_178" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="photo_url" vertex="1">
          <mxGeometry height="80" width="250" x="4950" y="2920" as="geometry" />
        </mxCell>
        <mxCell id="ae_179" edge="1" parent="1" source="e_ProcedureRoom" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_178">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="e_Shift" parent="1" style="shape=rectangle;whiteSpace=wrap;html=1;fillColor=#DAE8FC;strokeColor=#6C8EBF;strokeWidth=2;fontSize=35;fontStyle=1;verticalAlign=middle;" value="Shift" vertex="1">
          <mxGeometry height="80" width="250" x="4915" y="815" as="geometry" />
        </mxCell>
        <mxCell id="a_180" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fillColor=#FFF2CC;strokeColor=#D6B656;fontSize=35;fontStyle=4;" value="&lt;u&gt;shift_id&lt;/u&gt;" vertex="1">
          <mxGeometry height="80" width="250" x="5011" y="670" as="geometry" />
        </mxCell>
        <mxCell id="ae_181" edge="1" parent="1" source="e_Shift" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_180">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_182" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="department_id" vertex="1">
          <mxGeometry height="80" width="250" x="5076" y="932" as="geometry" />
        </mxCell>
        <mxCell id="ae_183" edge="1" parent="1" source="e_Shift" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_182">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_184" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="shift_date" vertex="1">
          <mxGeometry height="80" width="250" x="4812" y="932" as="geometry" />
        </mxCell>
        <mxCell id="ae_185" edge="1" parent="1" source="e_Shift" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_184">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_186" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fillColor=#FFF2CC;strokeColor=#D6B656;fontSize=35;" value="shift_type" vertex="1">
          <mxGeometry height="80" width="250" x="5360" y="905" as="geometry" />
        </mxCell>
        <mxCell id="ae_187" edge="1" parent="1" source="e_Shift" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_186">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="e_Patient" parent="1" style="shape=rectangle;whiteSpace=wrap;html=1;fillColor=#DAE8FC;strokeColor=#6C8EBF;strokeWidth=2;fontSize=35;fontStyle=1;verticalAlign=middle;" value="Patient" vertex="1">
          <mxGeometry height="80" width="250" x="720" y="1530" as="geometry" />
        </mxCell>
        <mxCell id="a_188" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fillColor=#FFF2CC;strokeColor=#D6B656;fontSize=35;fontStyle=4;" value="&lt;u&gt;patient_id&lt;/u&gt;" vertex="1">
          <mxGeometry height="80" width="250" x="803" y="1200" as="geometry" />
        </mxCell>
        <mxCell id="ae_189" edge="1" parent="1" source="e_Patient" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_188">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_190" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="amka" vertex="1">
          <mxGeometry height="80" width="250" x="-390" y="1440" as="geometry" />
        </mxCell>
        <mxCell id="ae_191" edge="1" parent="1" source="e_Patient" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_190">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_192" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="first_name" vertex="1">
          <mxGeometry height="80" width="250" x="-580" y="1550" as="geometry" />
        </mxCell>
        <mxCell id="ae_193" edge="1" parent="1" source="e_Patient" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_192">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_194" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="last_name" vertex="1">
          <mxGeometry height="80" width="250" x="-280" y="1900" as="geometry" />
        </mxCell>
        <mxCell id="ae_195" edge="1" parent="1" source="e_Patient" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_194">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_196" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="father_name" vertex="1">
          <mxGeometry height="80" width="250" x="-450" y="1785" as="geometry" />
        </mxCell>
        <mxCell id="ae_197" edge="1" parent="1" source="e_Patient" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_196">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_198" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="age" vertex="1">
          <mxGeometry height="80" width="250" x="-440" y="1670" as="geometry" />
        </mxCell>
        <mxCell id="ae_199" edge="1" parent="1" source="e_Patient" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_198">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_200" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="gender" vertex="1">
          <mxGeometry height="80" width="250" x="-320" y="1550" as="geometry" />
        </mxCell>
        <mxCell id="ae_201" edge="1" parent="1" source="e_Patient" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_200">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_202" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="weight" vertex="1">
          <mxGeometry height="80" width="250" x="380" y="1710" as="geometry" />
        </mxCell>
        <mxCell id="ae_203" edge="1" parent="1" source="e_Patient" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_202">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_204" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="height" vertex="1">
          <mxGeometry height="80" width="250" y="1840" as="geometry" />
        </mxCell>
        <mxCell id="ae_205" edge="1" parent="1" source="e_Patient" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_204">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_206" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="address" vertex="1">
          <mxGeometry height="80" width="250" x="120" y="1700" as="geometry" />
        </mxCell>
        <mxCell id="ae_207" edge="1" parent="1" source="e_Patient" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_206">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_208" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="phone" vertex="1">
          <mxGeometry height="80" width="250" x="270" y="1820" as="geometry" />
        </mxCell>
        <mxCell id="ae_209" edge="1" parent="1" source="e_Patient" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_208">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_210" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="email" vertex="1">
          <mxGeometry height="80" width="250" x="-47" y="1590" as="geometry" />
        </mxCell>
        <mxCell id="ae_211" edge="1" parent="1" source="e_Patient" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_210">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_212" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="profession" vertex="1">
          <mxGeometry height="80" width="250" x="220" y="1565" as="geometry" />
        </mxCell>
        <mxCell id="ae_213" edge="1" parent="1" source="e_Patient" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_212">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_214" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="nationality" vertex="1">
          <mxGeometry height="80" width="250" x="-180" y="1700" as="geometry" />
        </mxCell>
        <mxCell id="ae_215" edge="1" parent="1" source="e_Patient" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_214">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_216" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="insurance_provider" vertex="1">
          <mxGeometry height="80" width="340" x="-10" y="1450" as="geometry" />
        </mxCell>
        <mxCell id="ae_217" edge="1" parent="1" source="e_Patient" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_216">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_218" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="photo_url" vertex="1">
          <mxGeometry height="80" width="250" x="-630" y="1926" as="geometry" />
        </mxCell>
        <mxCell id="ae_219" edge="1" parent="1" source="e_Patient" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_218">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="e_EmergencyContact" parent="1" style="shape=rectangle;whiteSpace=wrap;html=1;fillColor=#DAE8FC;strokeColor=#6C8EBF;strokeWidth=2;fontSize=35;fontStyle=1;verticalAlign=middle;double=1;" value="Emergency Contact" vertex="1">
          <mxGeometry height="80" width="250" x="70" y="1065" as="geometry" />
        </mxCell>
        <mxCell id="a_220" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fillColor=#FFF2CC;strokeColor=#D6B656;fontSize=35;fontStyle=4;" value="&lt;u&gt;contact_id&lt;/u&gt;" vertex="1">
          <mxGeometry height="80" width="250" x="480" y="980" as="geometry" />
        </mxCell>
        <mxCell id="ae_221" edge="1" parent="1" source="e_EmergencyContact" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_220">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_222" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="patient_id" vertex="1">
          <mxGeometry height="80" width="250" x="-250" y="890" as="geometry" />
        </mxCell>
        <mxCell id="ae_223" edge="1" parent="1" source="e_EmergencyContact" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_222">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_224" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="full_name" vertex="1">
          <mxGeometry height="80" width="250" x="-200" y="1200" as="geometry" />
        </mxCell>
        <mxCell id="ae_225" edge="1" parent="1" source="e_EmergencyContact" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_224">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_226" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="phone" vertex="1">
          <mxGeometry height="80" width="250" x="-200" y="1020" as="geometry" />
        </mxCell>
        <mxCell id="ae_227" edge="1" parent="1" source="e_EmergencyContact" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_226">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_228" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="relationship" vertex="1">
          <mxGeometry height="80" width="250" x="-30" y="830" as="geometry" />
        </mxCell>
        <mxCell id="ae_229" edge="1" parent="1" source="e_EmergencyContact" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_228">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="e_Hospitalization" parent="1" style="shape=rectangle;whiteSpace=wrap;html=1;fillColor=#DAE8FC;strokeColor=#6C8EBF;strokeWidth=2;fontSize=35;fontStyle=1;verticalAlign=middle;" value="Hospitalization" vertex="1">
          <mxGeometry height="80" width="250" x="2380" y="1865" as="geometry" />
        </mxCell>
        <mxCell id="a_230" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;fontStyle=4;fillColor=#fff2cc;strokeColor=#d6b656;" value="&lt;u&gt;hospitalization_id&lt;/u&gt;" vertex="1">
          <mxGeometry height="80" width="250" x="2480" y="1510" as="geometry" />
        </mxCell>
        <mxCell id="ae_231" edge="1" parent="1" source="e_Hospitalization" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_230">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_232" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="patient_id" vertex="1">
          <mxGeometry height="80" width="250" x="2580" y="1670" as="geometry" />
        </mxCell>
        <mxCell id="ae_233" edge="1" parent="1" source="e_Hospitalization" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_232">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_234" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="bed_id" vertex="1">
          <mxGeometry height="80" width="250" x="2940" y="1790" as="geometry" />
        </mxCell>
        <mxCell id="ae_235" edge="1" parent="1" source="e_Hospitalization" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_234">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_236" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="department_id" vertex="1">
          <mxGeometry height="80" width="250" x="2680" y="1926" as="geometry" />
        </mxCell>
        <mxCell id="ae_237" edge="1" parent="1" source="e_Hospitalization" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_236">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_238" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="ken_code" vertex="1">
          <mxGeometry height="80" width="250" x="2650" y="2060" as="geometry" />
        </mxCell>
        <mxCell id="ae_239" edge="1" parent="1" source="e_Hospitalization" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_238">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_240" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="admission_date" vertex="1">
          <mxGeometry height="80" width="250" x="2130" y="2120" as="geometry" />
        </mxCell>
        <mxCell id="ae_241" edge="1" parent="1" source="e_Hospitalization" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_240">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_242" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="discharge_date" vertex="1">
          <mxGeometry height="80" width="250" x="1980" y="1885" as="geometry" />
        </mxCell>
        <mxCell id="ae_243" edge="1" parent="1" source="e_Hospitalization" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_242">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_244" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="admission_diagnosis" vertex="1">
          <mxGeometry height="80" width="250" x="1980" y="2030" as="geometry" />
        </mxCell>
        <mxCell id="ae_245" edge="1" parent="1" source="e_Hospitalization" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_244">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_246" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="icd10_code" vertex="1">
          <mxGeometry height="80" width="250" x="1925" y="1725" as="geometry" />
        </mxCell>
        <mxCell id="ae_247" edge="1" parent="1" source="e_Hospitalization" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_246">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_248" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="discharge_desc" vertex="1">
          <mxGeometry height="80" width="250" x="2230" y="1470" as="geometry" />
        </mxCell>
        <mxCell id="ae_249" edge="1" parent="1" source="e_Hospitalization" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_248">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_250" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="total_cost" vertex="1">
          <mxGeometry height="80" width="250" x="2330" y="1660" as="geometry" />
        </mxCell>
        <mxCell id="ae_251" edge="1" parent="1" source="e_Hospitalization" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_250">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="e_KEN" parent="1" style="shape=rectangle;whiteSpace=wrap;html=1;fillColor=#DAE8FC;strokeColor=#6C8EBF;strokeWidth=2;fontSize=35;fontStyle=1;verticalAlign=middle;" value="KEN" vertex="1">
          <mxGeometry height="80" width="250" x="3915" y="1865" as="geometry" />
        </mxCell>
        <mxCell id="a_252" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fillColor=#FFF2CC;strokeColor=#D6B656;fontSize=35;fontStyle=4;" value="&lt;u&gt;ken_code&lt;/u&gt;" vertex="1">
          <mxGeometry height="80" width="250" x="4011" y="1720" as="geometry" />
        </mxCell>
        <mxCell id="ae_253" edge="1" parent="1" source="e_KEN" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_252">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_254" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="description" vertex="1">
          <mxGeometry height="80" width="250" x="4084" y="1982" as="geometry" />
        </mxCell>
        <mxCell id="ae_255" edge="1" parent="1" source="e_KEN" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_254">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_256" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="base_cost" vertex="1">
          <mxGeometry height="80" width="250" x="3816" y="1982" as="geometry" />
        </mxCell>
        <mxCell id="ae_257" edge="1" parent="1" source="e_KEN" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_256">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_258" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="alos_days" vertex="1">
          <mxGeometry height="80" width="250" x="3740" y="1750" as="geometry" />
        </mxCell>
        <mxCell id="ae_259" edge="1" parent="1" source="e_KEN" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_258">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="e_TriageRecord" parent="1" style="shape=rectangle;whiteSpace=wrap;html=1;strokeWidth=2;fontSize=35;fontStyle=1;verticalAlign=middle;fillColor=#dae8fc;strokeColor=#6c8ebf;" value="Triage Record" vertex="1">
          <mxGeometry height="80" width="250" x="390" y="2265" as="geometry" />
        </mxCell>
        <mxCell id="a_260" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fillColor=#FFF2CC;strokeColor=#D6B656;fontSize=35;fontStyle=4;" value="&lt;u&gt;triage_id&lt;/u&gt;" vertex="1">
          <mxGeometry height="80" width="250" x="840" y="2160" as="geometry" />
        </mxCell>
        <mxCell id="ae_261" edge="1" parent="1" source="e_TriageRecord" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_260">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_262" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="patient_id" vertex="1">
          <mxGeometry height="80" width="250" x="449" y="2413" as="geometry" />
        </mxCell>
        <mxCell id="ae_263" edge="1" parent="1" source="e_TriageRecord" style="endArrow=none;html=1;arcSize=20;fontSize=35;" target="a_262">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_264" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="nurse_id" vertex="1">
          <mxGeometry height="80" width="250" x="-47" y="2476" as="geometry" />
        </mxCell>
        <mxCell id="ae_265" edge="1" parent="1" source="e_TriageRecord" style="endArrow=none;html=1;arcSize=20;fontSize=35;" target="a_264">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_266" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="hospitalization_id" vertex="1">
          <mxGeometry height="80" width="250" x="-30" y="2262" as="geometry" />
        </mxCell>
        <mxCell id="ae_267" edge="1" parent="1" source="e_TriageRecord" style="endArrow=none;html=1;arcSize=20;fontSize=35;" target="a_266">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_268" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="arrival_time" vertex="1">
          <mxGeometry height="80" width="250" x="260" y="2500" as="geometry" />
        </mxCell>
        <mxCell id="ae_269" edge="1" parent="1" source="e_TriageRecord" style="endArrow=none;html=1;arcSize=20;fontSize=35;" target="a_268">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_270" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="symptoms" vertex="1">
          <mxGeometry height="80" width="250" x="180" y="2377" as="geometry" />
        </mxCell>
        <mxCell id="ae_271" edge="1" parent="1" source="e_TriageRecord" style="endArrow=none;html=1;arcSize=20;fontSize=35;" target="a_270">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_272" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="urgency_level" vertex="1">
          <mxGeometry height="80" width="250" x="89" y="2140" as="geometry" />
        </mxCell>
        <mxCell id="ae_273" edge="1" parent="1" source="e_TriageRecord" style="endArrow=none;html=1;arcSize=20;fontSize=35;" target="a_272">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_274" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="outcome" vertex="1">
          <mxGeometry height="80" width="250" x="-120" y="2365" as="geometry" />
        </mxCell>
        <mxCell id="ae_275" edge="1" parent="1" source="e_TriageRecord" style="endArrow=none;html=1;arcSize=20;fontSize=35;" target="a_274">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="e_Evaluation" parent="1" style="shape=rectangle;whiteSpace=wrap;html=1;fillColor=#DAE8FC;strokeColor=#6C8EBF;strokeWidth=2;fontSize=35;fontStyle=1;verticalAlign=middle;" value="Evaluation" vertex="1">
          <mxGeometry height="80" width="250" x="3600" y="2365" as="geometry" />
        </mxCell>
        <mxCell id="a_276" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fillColor=#FFF2CC;strokeColor=#D6B656;fontSize=35;fontStyle=4;" value="&lt;u&gt;evaluation_id&lt;/u&gt;" vertex="1">
          <mxGeometry height="80" width="250" x="3648" y="2240" as="geometry" />
        </mxCell>
        <mxCell id="ae_277" edge="1" parent="1" source="e_Evaluation" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_276">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_278" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="hospitalization_id" vertex="1">
          <mxGeometry height="80" width="250" x="3920" y="2240" as="geometry" />
        </mxCell>
        <mxCell id="ae_279" edge="1" parent="1" source="e_Evaluation" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_278">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_280" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="medical_care" vertex="1">
          <mxGeometry height="80" width="250" x="3960" y="2358" as="geometry" />
        </mxCell>
        <mxCell id="ae_281" edge="1" parent="1" source="e_Evaluation" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_280">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_282" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="nursing_care" vertex="1">
          <mxGeometry height="80" width="250" x="3842" y="2484" as="geometry" />
        </mxCell>
        <mxCell id="ae_283" edge="1" parent="1" source="e_Evaluation" style="endArrow=none;html=1;arcSize=20;fontSize=35;" target="a_282">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_284" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="cleanliness" vertex="1">
          <mxGeometry height="80" width="250" x="3707" y="2610" as="geometry" />
        </mxCell>
        <mxCell id="ae_285" edge="1" parent="1" source="e_Evaluation" style="endArrow=none;html=1;arcSize=20;fontSize=35;" target="a_284">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_286" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="food" vertex="1">
          <mxGeometry height="80" width="250" x="3457" y="2537" as="geometry" />
        </mxCell>
        <mxCell id="ae_287" edge="1" parent="1" source="e_Evaluation" style="endArrow=none;html=1;arcSize=20;fontSize=35;" target="a_286">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_288" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="overall" vertex="1">
          <mxGeometry height="80" width="250" x="3310" y="2404" as="geometry" />
        </mxCell>
        <mxCell id="ae_289" edge="1" parent="1" source="e_Evaluation" style="endArrow=none;html=1;arcSize=20;fontSize=35;" target="a_288">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_290" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="comments" vertex="1">
          <mxGeometry height="80" width="250" x="3388" y="2140" as="geometry" />
        </mxCell>
        <mxCell id="ae_291" edge="1" parent="1" source="e_Evaluation" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_290">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_292" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="evaluation_date" vertex="1">
          <mxGeometry height="80" width="250" x="3651" y="2110" as="geometry" />
        </mxCell>
        <mxCell id="ae_293" edge="1" parent="1" source="e_Evaluation" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_292">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="e_LaboratoryTest" parent="1" style="shape=rectangle;whiteSpace=wrap;html=1;fillColor=#DAE8FC;strokeColor=#6C8EBF;strokeWidth=2;fontSize=35;fontStyle=1;verticalAlign=middle;" value="Laboratory Test" vertex="1">
          <mxGeometry height="80" width="250" x="1290" y="2580" as="geometry" />
        </mxCell>
        <mxCell id="a_294" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fillColor=#FFF2CC;strokeColor=#D6B656;fontSize=35;fontStyle=4;" value="&lt;u&gt;test_id&lt;/u&gt;" vertex="1">
          <mxGeometry height="62" width="250" x="1400" y="2422" as="geometry" />
        </mxCell>
        <mxCell id="ae_295" edge="1" parent="1" source="e_LaboratoryTest" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_294">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_296" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="hospitalization_id" vertex="1">
          <mxGeometry height="62" width="330" x="1210" y="2909" as="geometry" />
        </mxCell>
        <mxCell id="ae_297" edge="1" parent="1" source="e_LaboratoryTest" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_296">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_298" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="ordered_by" vertex="1">
          <mxGeometry height="60" width="250" x="1706" y="2580" as="geometry" />
        </mxCell>
        <mxCell id="ae_299" edge="1" parent="1" source="e_LaboratoryTest" style="endArrow=none;html=1;arcSize=20;fontSize=35;" target="a_298">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_300" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="test_code" vertex="1">
          <mxGeometry height="57" width="250" x="1550" y="2710" as="geometry" />
        </mxCell>
        <mxCell id="ae_301" edge="1" parent="1" source="e_LaboratoryTest" style="endArrow=none;html=1;arcSize=20;fontSize=35;" target="a_300">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_302" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="test_type" vertex="1">
          <mxGeometry height="55" width="250" x="1330" y="2810" as="geometry" />
        </mxCell>
        <mxCell id="ae_303" edge="1" parent="1" source="e_LaboratoryTest" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_302">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_304" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="test_date" vertex="1">
          <mxGeometry height="62" width="250" x="1080" y="2767" as="geometry" />
        </mxCell>
        <mxCell id="ae_305" edge="1" parent="1" source="e_LaboratoryTest" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_304">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_306" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="result_text" vertex="1">
          <mxGeometry height="60" width="250" x="1000" y="2675" as="geometry" />
        </mxCell>
        <mxCell id="ae_307" edge="1" parent="1" source="e_LaboratoryTest" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_306">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_308" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="result_numeric" vertex="1">
          <mxGeometry height="52" width="250" x="960" y="2580" as="geometry" />
        </mxCell>
        <mxCell id="ae_309" edge="1" parent="1" source="e_LaboratoryTest" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_308">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_310" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="measurement_unit" vertex="1">
          <mxGeometry height="80" width="316" x="983" y="2457" as="geometry" />
        </mxCell>
        <mxCell id="ae_311" edge="1" parent="1" source="e_LaboratoryTest" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_310">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_312" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="cost" vertex="1">
          <mxGeometry height="42" width="250" x="1740" y="2476" as="geometry" />
        </mxCell>
        <mxCell id="ae_313" edge="1" parent="1" source="e_LaboratoryTest" style="endArrow=none;html=1;arcSize=20;fontSize=35;" target="a_312">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="e_ProcedureCatalog" parent="1" style="shape=rectangle;whiteSpace=wrap;html=1;fillColor=#DAE8FC;strokeColor=#6C8EBF;strokeWidth=2;fontSize=35;fontStyle=1;verticalAlign=middle;" value="Procedure Catalog" vertex="1">
          <mxGeometry height="80" width="250" x="4170" y="3165" as="geometry" />
        </mxCell>
        <mxCell id="a_314" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fillColor=#FFF2CC;strokeColor=#D6B656;fontSize=35;fontStyle=4;" value="&lt;u&gt;procedure_code&lt;/u&gt;" vertex="1">
          <mxGeometry height="80" width="250" x="4120" y="3020" as="geometry" />
        </mxCell>
        <mxCell id="ae_315" edge="1" parent="1" source="e_ProcedureCatalog" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_314">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_316" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="name" vertex="1">
          <mxGeometry height="80" width="250" x="4419" y="3324" as="geometry" />
        </mxCell>
        <mxCell id="ae_317" edge="1" parent="1" source="e_ProcedureCatalog" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_316">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_318" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="category" vertex="1">
          <mxGeometry height="80" width="250" x="4205" y="3370" as="geometry" />
        </mxCell>
        <mxCell id="ae_319" edge="1" parent="1" source="e_ProcedureCatalog" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_318">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_320" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="default_cost" vertex="1">
          <mxGeometry height="80" width="250" x="3957" y="3300" as="geometry" />
        </mxCell>
        <mxCell id="ae_321" edge="1" parent="1" source="e_ProcedureCatalog" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_320">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_322" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="description" vertex="1">
          <mxGeometry height="80" width="250" x="4440" y="3450" as="geometry" />
        </mxCell>
        <mxCell id="ae_323" edge="1" parent="1" source="e_ProcedureCatalog" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_322">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="e_MedicalProcedure" parent="1" style="shape=rectangle;whiteSpace=wrap;html=1;fillColor=#DAE8FC;strokeColor=#6C8EBF;strokeWidth=2;fontSize=35;fontStyle=1;verticalAlign=middle;" value="Medical Procedure" vertex="1">
          <mxGeometry height="80" width="250" x="3050" y="2920" as="geometry" />
        </mxCell>
        <mxCell id="a_324" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fillColor=#FFF2CC;strokeColor=#D6B656;fontSize=35;fontStyle=4;" value="&lt;u&gt;procedure_id&lt;/u&gt;" vertex="1">
          <mxGeometry height="80" width="250" x="3090" y="2680" as="geometry" />
        </mxCell>
        <mxCell id="ae_325" edge="1" parent="1" source="e_MedicalProcedure" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_324">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_326" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="procedure_code" vertex="1">
          <mxGeometry height="80" width="250" x="3310" y="3340" as="geometry" />
        </mxCell>
        <mxCell id="ae_327" edge="1" parent="1" source="e_MedicalProcedure" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_326">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_328" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="hospitalization_id" vertex="1">
          <mxGeometry height="80" width="320" x="3210" y="3065" as="geometry" />
        </mxCell>
        <mxCell id="ae_329" edge="1" parent="1" source="e_MedicalProcedure" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_328">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_330" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="room_id" vertex="1">
          <mxGeometry height="80" width="250" x="3110" y="3202" as="geometry" />
        </mxCell>
        <mxCell id="ae_331" edge="1" parent="1" source="e_MedicalProcedure" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_330">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_332" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="primary_surgeon_id" vertex="1">
          <mxGeometry height="80" width="370" x="2790" y="3430" as="geometry" />
        </mxCell>
        <mxCell id="ae_333" edge="1" parent="1" source="e_MedicalProcedure" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_332">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_334" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="start_time" vertex="1">
          <mxGeometry height="80" width="250" x="2690" y="3010" as="geometry" />
        </mxCell>
        <mxCell id="ae_335" edge="1" parent="1" source="e_MedicalProcedure" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_334">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_336" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="end_time" vertex="1">
          <mxGeometry height="80" width="250" x="2877" y="3260" as="geometry" />
        </mxCell>
        <mxCell id="ae_337" edge="1" parent="1" source="e_MedicalProcedure" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_336">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_338" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="actual_cost" vertex="1">
          <mxGeometry height="80" width="250" x="2670" y="3190" as="geometry" />
        </mxCell>
        <mxCell id="ae_339" edge="1" parent="1" source="e_MedicalProcedure" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_338">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="e_Prescription" parent="1" style="shape=rectangle;whiteSpace=wrap;html=1;fillColor=#DAE8FC;strokeColor=#6C8EBF;strokeWidth=2;fontSize=35;fontStyle=1;verticalAlign=middle;" value="Prescription" vertex="1">
          <mxGeometry height="80" width="250" x="1720" y="2940" as="geometry" />
        </mxCell>
        <mxCell id="a_340" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;fontStyle=4;fillColor=#fff2cc;strokeColor=#d6b656;" value="&lt;u&gt;prescription_id&lt;/u&gt;" vertex="1">
          <mxGeometry height="80" width="250" x="2090" y="2797.5" as="geometry" />
        </mxCell>
        <mxCell id="ae_341" edge="1" parent="1" source="e_Prescription" style="endArrow=none;html=1;arcSize=20;fontSize=35;" target="a_340">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_342" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="hospitalization_id" vertex="1">
          <mxGeometry height="80" width="300" x="2150" y="2930" as="geometry" />
        </mxCell>
        <mxCell id="ae_343" edge="1" parent="1" source="e_Prescription" style="endArrow=none;html=1;arcSize=20;fontSize=35;" target="a_342">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_344" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="doctor_id" vertex="1">
          <mxGeometry height="80" width="250" x="2050" y="3046" as="geometry" />
        </mxCell>
        <mxCell id="ae_345" edge="1" parent="1" source="e_Prescription" style="endArrow=none;html=1;arcSize=20;fontSize=35;" target="a_344">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_346" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="patient_id" vertex="1">
          <mxGeometry height="80" width="250" x="1870" y="3202" as="geometry" />
        </mxCell>
        <mxCell id="ae_347" edge="1" parent="1" source="e_Prescription" style="endArrow=none;html=1;arcSize=20;fontSize=35;" target="a_346">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_348" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="drug_id" vertex="1">
          <mxGeometry height="80" width="250" x="2193" y="3165" as="geometry" />
        </mxCell>
        <mxCell id="ae_349" edge="1" parent="1" source="e_Prescription" style="endArrow=none;html=1;arcSize=20;fontSize=35;" target="a_348">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_350" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="dosage" vertex="1">
          <mxGeometry height="80" width="250" x="1770" y="3310" as="geometry" />
        </mxCell>
        <mxCell id="ae_351" edge="1" parent="1" source="e_Prescription" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_350">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_352" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="frequency" vertex="1">
          <mxGeometry height="80" width="250" x="1580" y="3210" as="geometry" />
        </mxCell>
        <mxCell id="ae_353" edge="1" parent="1" source="e_Prescription" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_352">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_354" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="start_date" vertex="1">
          <mxGeometry height="80" width="250" x="2080" y="3324" as="geometry" />
        </mxCell>
        <mxCell id="ae_355" edge="1" parent="1" source="e_Prescription" style="endArrow=none;html=1;arcSize=20;fontSize=35;" target="a_354">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_356" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="end_date" vertex="1">
          <mxGeometry height="80" width="250" x="2160" y="3450" as="geometry" />
        </mxCell>
        <mxCell id="ae_357" edge="1" parent="1" source="e_Prescription" style="endArrow=none;html=1;arcSize=20;fontSize=35;" target="a_356">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="e_Drug" parent="1" style="shape=rectangle;whiteSpace=wrap;html=1;fillColor=#DAE8FC;strokeColor=#6C8EBF;strokeWidth=2;fontSize=35;fontStyle=1;verticalAlign=middle;" value="Drug" vertex="1">
          <mxGeometry height="80" width="250" x="1370" y="3470" as="geometry" />
        </mxCell>
        <mxCell id="a_358" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fillColor=#FFF2CC;strokeColor=#D6B656;fontSize=35;fontStyle=4;" value="&lt;u&gt;drug_id&lt;/u&gt;" vertex="1">
          <mxGeometry height="80" width="250" x="1070" y="3420" as="geometry" />
        </mxCell>
        <mxCell id="ae_359" edge="1" parent="1" source="e_Drug" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_358">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_360" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="drug_name" vertex="1">
          <mxGeometry height="80" width="250" x="1456" y="3650" as="geometry" />
        </mxCell>
        <mxCell id="ae_361" edge="1" parent="1" source="e_Drug" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_360">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_362" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="ema_code" vertex="1">
          <mxGeometry height="80" width="250" x="1160" y="3690" as="geometry" />
        </mxCell>
        <mxCell id="ae_363" edge="1" parent="1" source="e_Drug" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_362">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_364" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="description" vertex="1">
          <mxGeometry height="80" width="250" x="1310" y="3760" as="geometry" />
        </mxCell>
        <mxCell id="ae_365" edge="1" parent="1" source="e_Drug" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_364">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="e_ActiveSubstance" parent="1" style="shape=rectangle;whiteSpace=wrap;html=1;fillColor=#DAE8FC;strokeColor=#6C8EBF;strokeWidth=2;fontSize=35;fontStyle=1;verticalAlign=middle;" value="Active Substance" vertex="1">
          <mxGeometry height="80" width="250" x="880" y="2932" as="geometry" />
        </mxCell>
        <mxCell id="a_366" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fillColor=#FFF2CC;strokeColor=#D6B656;fontSize=35;fontStyle=4;" value="&lt;u&gt;substance_id&lt;/u&gt;" vertex="1">
          <mxGeometry height="80" width="250" x="840" y="3100" as="geometry" />
        </mxCell>
        <mxCell id="ae_367" edge="1" parent="1" source="e_ActiveSubstance" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_366">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="a_368" parent="1" style="shape=ellipse;perimeter=ellipsePerimeter;whiteSpace=wrap;html=1;fontSize=35;" value="substance_name" vertex="1">
          <mxGeometry height="80" width="250" x="553" y="2990" as="geometry" />
        </mxCell>
        <mxCell id="ae_369" edge="1" parent="1" source="e_ActiveSubstance" style="endArrow=none;html=1;strokeColor=#B3B3B3;arcSize=20;fontSize=35;" target="a_368">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="isa_e372" edge="1" parent="1" source="IpbID4TjgTse4RfUTD4G-2" style="endArrow=none;html=1;strokeWidth=3;strokeColor=#82B366;arcSize=20;fontSize=35;" target="e_Doctor">
          <mxGeometry relative="1" as="geometry">
            <mxPoint x="2492.3027663934427" y="511.531762295082" as="sourcePoint" />
          </mxGeometry>
        </mxCell>
        <mxCell id="isa_e373" edge="1" parent="1" source="IpbID4TjgTse4RfUTD4G-2" style="endArrow=none;html=1;strokeWidth=3;strokeColor=#82B366;arcSize=20;fontSize=35;" target="e_Nurse">
          <mxGeometry relative="1" as="geometry">
            <mxPoint x="2540.2968036529683" y="576.8036529680362" as="sourcePoint" />
          </mxGeometry>
        </mxCell>
        <mxCell id="isa_e374" edge="1" parent="1" source="IpbID4TjgTse4RfUTD4G-2" style="endArrow=none;html=1;strokeWidth=3;strokeColor=#82B366;arcSize=20;fontSize=35;" target="e_Administrative">
          <mxGeometry relative="1" as="geometry">
            <mxPoint x="2607.4877031650985" y="511.8167236954662" as="sourcePoint" />
          </mxGeometry>
        </mxCell>
        <mxCell id="r_Supervises" parent="1" style="shape=rhombus;perimeter=rhombusPerimeter;whiteSpace=wrap;html=1;fillColor=#E1D5E7;strokeColor=#9673A6;strokeWidth=2;fontStyle=1;fontSize=35;" value="Supervises" vertex="1">
          <mxGeometry height="80" width="250" x="880" y="480" as="geometry" />
        </mxCell>
        <mxCell id="ed_376" edge="1" parent="1" source="r_Supervises" style="endArrow=none;html=1;strokeColor=#666666;;fontSize=35;fontStyle=1;fontColor=#CC6600;arcSize=20;" target="e_Doctor" value="1">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="ed_377" edge="1" parent="1" source="r_Supervises" style="endArrow=none;html=1;strokeColor=#666666;;fontSize=35;fontStyle=1;fontColor=#CC6600;arcSize=20;" target="e_Doctor" value="N">
          <mxGeometry relative="1" as="geometry">
            <Array as="points">
              <mxPoint x="1000" y="620" />
            </Array>
          </mxGeometry>
        </mxCell>
        <mxCell id="r_BelongsTo" parent="1" style="shape=rhombus;perimeter=rhombusPerimeter;whiteSpace=wrap;html=1;fillColor=#E1D5E7;strokeColor=#9673A6;strokeWidth=2;fontStyle=1;fontSize=35;" value="Belongs To" vertex="1">
          <mxGeometry height="180" width="250" x="2140" y="940" as="geometry" />
        </mxCell>
        <mxCell id="ed_379" edge="1" parent="1" source="r_BelongsTo" style="endArrow=none;html=1;strokeColor=#666666;;fontSize=35;fontStyle=1;fontColor=#CC6600;arcSize=20;" target="e_Department" value="M">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="r_AssignedTo" parent="1" style="shape=rhombus;perimeter=rhombusPerimeter;whiteSpace=wrap;html=1;fillColor=#E1D5E7;strokeColor=#9673A6;strokeWidth=2;fontStyle=1;fontSize=35;" value="Assigned To" vertex="1">
          <mxGeometry height="80" width="250" x="3100" y="930" as="geometry" />
        </mxCell>
        <mxCell id="ed_380" edge="1" parent="1" style="shape=link;endArrow=none;html=1;strokeColor=#333333;strokeWidth=4;;fontSize=35;fontStyle=1;fontColor=#CC6600;arcSize=20;" target="e_Nurse" value="N">
          <mxGeometry relative="1" as="geometry">
            <Array as="points">
              <mxPoint x="3170" y="950" />
            </Array>
            <mxPoint x="3170" y="960" as="sourcePoint" />
          </mxGeometry>
        </mxCell>
        <mxCell id="ed_381" edge="1" parent="1" source="r_AssignedTo" style="endArrow=none;html=1;strokeColor=#666666;;fontSize=35;fontStyle=1;fontColor=#CC6600;arcSize=20;" target="e_Department" value="1">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="r_WorksIn" parent="1" style="shape=rhombus;perimeter=rhombusPerimeter;whiteSpace=wrap;html=1;fillColor=#E1D5E7;strokeColor=#9673A6;strokeWidth=2;fontStyle=1;fontSize=35;" value="Works In" vertex="1">
          <mxGeometry height="80" width="250" x="3940" y="905" as="geometry" />
        </mxCell>
        <mxCell id="ed_382" edge="1" parent="1" source="r_WorksIn" style="shape=link;endArrow=none;html=1;strokeColor=#333333;strokeWidth=4;;fontSize=35;fontStyle=1;fontColor=#CC6600;arcSize=20;" target="e_Administrative" value="N">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="ed_383" edge="1" parent="1" source="r_WorksIn" style="endArrow=none;html=1;strokeColor=#666666;;fontSize=35;fontStyle=1;fontColor=#CC6600;arcSize=20;" target="e_Department" value="1">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="r_Directs" parent="1" style="shape=rhombus;perimeter=rhombusPerimeter;whiteSpace=wrap;html=1;fillColor=#E1D5E7;strokeColor=#9673A6;strokeWidth=2;fontStyle=1;fontSize=35;" value="Directs" vertex="1">
          <mxGeometry height="80" width="250" x="2920" y="985" as="geometry" />
        </mxCell>
        <mxCell id="ed_384" edge="1" parent="1" source="r_Directs" style="shape=link;endArrow=none;html=1;strokeColor=#333333;strokeWidth=4;;fontSize=35;fontStyle=1;fontColor=#CC6600;arcSize=20;" target="e_Department" value="1">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="ed_385" edge="1" parent="1" source="r_Directs" style="endArrow=none;html=1;strokeColor=#666666;;fontSize=35;fontStyle=1;fontColor=#CC6600;arcSize=20;" target="e_Doctor" value="1">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="r_Contains" parent="1" style="shape=rhombus;perimeter=rhombusPerimeter;whiteSpace=wrap;html=1;fillColor=#E1D5E7;strokeColor=#9673A6;strokeWidth=2;fontStyle=1;fontSize=35;double=1;" value="Contains" vertex="1">
          <mxGeometry height="80" width="250" x="4240" y="1260" as="geometry" />
        </mxCell>
        <mxCell id="ed_386" edge="1" parent="1" source="r_Contains" style="shape=link;endArrow=none;html=1;strokeColor=#333333;strokeWidth=4;;fontSize=35;fontStyle=1;fontColor=#CC6600;arcSize=20;" target="e_Department" value="1">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="ed_387" edge="1" parent="1" source="r_Contains" style="shape=link;endArrow=none;html=1;strokeColor=#333333;strokeWidth=4;;fontSize=35;fontStyle=1;fontColor=#CC6600;arcSize=20;" target="e_Bed" value="N">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="r_Has" parent="1" style="shape=rhombus;perimeter=rhombusPerimeter;whiteSpace=wrap;html=1;fillColor=#E1D5E7;strokeColor=#9673A6;strokeWidth=2;fontStyle=1;fontSize=35;double=1;" value="Has" vertex="1">
          <mxGeometry height="80" width="250" x="340" y="1310" as="geometry" />
        </mxCell>
        <mxCell id="ed_388" edge="1" parent="1" source="r_Has" style="endArrow=none;html=1;strokeColor=#666666;;fontSize=35;fontStyle=1;fontColor=#CC6600;arcSize=20;" target="e_Patient" value="1">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="ed_389" edge="1" parent="1" source="r_Has" style="shape=link;endArrow=none;html=1;strokeColor=#333333;strokeWidth=4;;fontSize=35;fontStyle=1;fontColor=#CC6600;arcSize=20;" target="e_EmergencyContact" value="N">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="r_Admitted" parent="1" style="shape=rhombus;perimeter=rhombusPerimeter;whiteSpace=wrap;html=1;fillColor=#E1D5E7;strokeColor=#9673A6;strokeWidth=2;fontStyle=1;fontSize=35;" value="Admitted" vertex="1">
          <mxGeometry height="130" width="250" x="1390" y="1700" as="geometry" />
        </mxCell>
        <mxCell id="ed_390" edge="1" parent="1" source="r_Admitted" style="endArrow=none;html=1;strokeColor=#666666;;fontSize=35;fontStyle=1;fontColor=#CC6600;arcSize=20;" target="e_Patient" value="1">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="ed_391" edge="1" parent="1" source="r_Admitted" style="shape=link;endArrow=none;html=1;strokeColor=#333333;strokeWidth=4;;fontSize=35;fontStyle=1;fontColor=#CC6600;arcSize=20;" target="e_Hospitalization" value="N">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="r_Uses" parent="1" style="shape=rhombus;perimeter=rhombusPerimeter;whiteSpace=wrap;html=1;fillColor=#E1D5E7;strokeColor=#9673A6;strokeWidth=2;fontStyle=1;fontSize=35;" value="Uses" vertex="1">
          <mxGeometry height="80" width="250" x="3620" y="1610" as="geometry" />
        </mxCell>
        <mxCell id="ed_392" edge="1" parent="1" source="r_Uses" style="shape=link;endArrow=none;html=1;strokeColor=#333333;strokeWidth=4;;fontSize=35;fontStyle=1;fontColor=#CC6600;arcSize=20;" target="e_Hospitalization" value="N">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="ed_393" edge="1" parent="1" source="r_Uses" style="endArrow=none;html=1;strokeColor=#666666;;fontSize=35;fontStyle=1;fontColor=#CC6600;arcSize=20;" target="e_Bed" value="1">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="r_InDept" parent="1" style="shape=rhombus;perimeter=rhombusPerimeter;whiteSpace=wrap;html=1;fillColor=#E1D5E7;strokeColor=#9673A6;strokeWidth=2;fontStyle=1;fontSize=35;" value="In Dept" vertex="1">
          <mxGeometry height="80" width="250" x="3090" y="1510" as="geometry" />
        </mxCell>
        <mxCell id="ed_394" edge="1" parent="1" source="r_InDept" style="shape=link;endArrow=none;html=1;strokeColor=#333333;strokeWidth=4;;fontSize=35;fontStyle=1;fontColor=#CC6600;arcSize=20;" target="e_Hospitalization" value="N">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="ed_395" edge="1" parent="1" source="r_InDept" style="endArrow=none;html=1;strokeColor=#666666;;fontSize=35;fontStyle=1;fontColor=#CC6600;arcSize=20;" target="e_Department" value="1">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="r_Classified" parent="1" style="shape=rhombus;perimeter=rhombusPerimeter;whiteSpace=wrap;html=1;fillColor=#E1D5E7;strokeColor=#9673A6;strokeWidth=2;fontStyle=1;fontSize=35;" value="Classified" vertex="1">
          <mxGeometry height="80" width="250" x="3190" y="1860" as="geometry" />
        </mxCell>
        <mxCell id="ed_396" edge="1" parent="1" source="r_Classified" style="shape=link;endArrow=none;html=1;strokeColor=#333333;strokeWidth=4;;fontSize=35;fontStyle=1;fontColor=#CC6600;arcSize=20;" target="e_Hospitalization" value="N">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="ed_397" edge="1" parent="1" source="r_Classified" style="endArrow=none;html=1;strokeColor=#666666;;fontSize=35;fontStyle=1;fontColor=#CC6600;arcSize=20;" target="e_KEN" value="1">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="r_Tested" parent="1" style="shape=rhombus;perimeter=rhombusPerimeter;whiteSpace=wrap;html=1;fillColor=#E1D5E7;strokeColor=#9673A6;strokeWidth=2;fontStyle=1;fontSize=35;" value="Tested" vertex="1">
          <mxGeometry height="80" width="250" x="1940" y="2230" as="geometry" />
        </mxCell>
        <mxCell id="ed_398" edge="1" parent="1" source="r_Tested" style="endArrow=none;html=1;strokeColor=#666666;;fontSize=35;fontStyle=1;fontColor=#CC6600;arcSize=20;" target="e_Hospitalization" value="1">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="ed_399" edge="1" parent="1" source="r_Tested" style="endArrow=none;html=1;strokeColor=#333333;strokeWidth=4;;fontSize=35;fontStyle=1;fontColor=#CC6600;arcSize=20;" target="e_LaboratoryTest" value="N">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="r_Involves" parent="1" style="shape=rhombus;perimeter=rhombusPerimeter;whiteSpace=wrap;html=1;fillColor=#E1D5E7;strokeColor=#9673A6;strokeWidth=2;fontStyle=1;fontSize=35;" value="Involves" vertex="1">
          <mxGeometry height="80" width="250" x="2740" y="2360" as="geometry" />
        </mxCell>
        <mxCell id="ed_400" edge="1" parent="1" source="r_Involves" style="endArrow=none;html=1;strokeColor=#666666;;fontSize=35;fontStyle=1;fontColor=#CC6600;arcSize=20;" target="e_Hospitalization" value="1">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="ed_401" edge="1" parent="1" source="r_Involves" style="shape=link;endArrow=none;html=1;strokeColor=#333333;strokeWidth=4;;fontSize=35;fontStyle=1;fontColor=#CC6600;arcSize=20;" target="e_MedicalProcedure" value="N">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="r_HasRx" parent="1" style="shape=rhombus;perimeter=rhombusPerimeter;whiteSpace=wrap;html=1;fillColor=#E1D5E7;strokeColor=#9673A6;strokeWidth=2;fontStyle=1;fontSize=35;" value="Has Rx" vertex="1">
          <mxGeometry height="80" width="250" x="2090" y="2485" as="geometry" />
        </mxCell>
        <mxCell id="ed_402" edge="1" parent="1" source="r_HasRx" style="endArrow=none;html=1;strokeColor=#666666;;fontSize=35;fontStyle=1;fontColor=#CC6600;arcSize=20;" target="e_Hospitalization" value="1">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="ed_403" edge="1" parent="1" source="r_HasRx" style="shape=link;endArrow=none;html=1;strokeColor=#333333;strokeWidth=4;;fontSize=35;fontStyle=1;fontColor=#CC6600;arcSize=20;" target="e_Prescription" value="N">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="r_Triaged" parent="1" style="shape=rhombus;perimeter=rhombusPerimeter;whiteSpace=wrap;html=1;fillColor=#E1D5E7;strokeColor=#9673A6;strokeWidth=2;fontStyle=1;fontSize=35;" value="Triaged" vertex="1">
          <mxGeometry height="130" width="250" x="1390" y="2253" as="geometry" />
        </mxCell>
        <mxCell id="ed_404" edge="1" parent="1" source="r_Triaged" style="shape=link;endArrow=none;html=1;strokeColor=#333333;strokeWidth=4;;fontSize=35;fontStyle=1;fontColor=#CC6600;arcSize=20;" target="e_TriageRecord" value="1">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="ed_405" edge="1" parent="1" source="r_Triaged" style="endArrow=none;html=1;strokeColor=#666666;;fontSize=35;fontStyle=1;fontColor=#CC6600;arcSize=20;" target="e_Hospitalization" value="1">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="r_Evaluated" parent="1" style="shape=rhombus;perimeter=rhombusPerimeter;whiteSpace=wrap;html=1;fillColor=#E1D5E7;strokeColor=#9673A6;strokeWidth=2;fontStyle=1;fontSize=35;" value="Evaluated" vertex="1">
          <mxGeometry height="80" width="250" x="3040" y="2110" as="geometry" />
        </mxCell>
        <mxCell id="ed_406" edge="1" parent="1" source="r_Evaluated" style="shape=link;endArrow=none;html=1;strokeColor=#333333;strokeWidth=4;;fontSize=35;fontStyle=1;fontColor=#CC6600;arcSize=20;" target="e_Evaluation" value="1">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="ed_407" edge="1" parent="1" source="r_Evaluated" style="endArrow=none;html=1;strokeColor=#666666;;fontSize=35;fontStyle=1;fontColor=#CC6600;arcSize=20;" target="e_Hospitalization" value="1">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="r_OrderedBy" parent="1" style="shape=rhombus;perimeter=rhombusPerimeter;whiteSpace=wrap;html=1;fillColor=#E1D5E7;strokeColor=#9673A6;strokeWidth=2;fontStyle=1;fontSize=35;" value="Ordered By" vertex="1">
          <mxGeometry height="168" width="250" x="1174" y="1404" as="geometry" />
        </mxCell>
        <mxCell id="ed_408" edge="1" parent="1" source="r_OrderedBy" style="shape=link;endArrow=none;html=1;strokeColor=#333333;strokeWidth=4;;fontSize=35;fontStyle=1;fontColor=#CC6600;arcSize=20;" target="e_LaboratoryTest" value="N">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="ed_409" edge="1" parent="1" source="r_OrderedBy" style="endArrow=none;html=1;strokeColor=#666666;;fontSize=35;fontStyle=1;fontColor=#CC6600;arcSize=20;" target="e_Doctor" value="1">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="r_TypeOf" parent="1" style="shape=rhombus;perimeter=rhombusPerimeter;whiteSpace=wrap;html=1;fillColor=#E1D5E7;strokeColor=#9673A6;strokeWidth=2;fontStyle=1;fontSize=35;" value="Type Of" vertex="1">
          <mxGeometry height="80" width="250" x="3640" y="3010" as="geometry" />
        </mxCell>
        <mxCell id="ed_411" edge="1" parent="1" source="r_TypeOf" style="endArrow=none;html=1;strokeColor=#666666;;fontSize=35;fontStyle=1;fontColor=#CC6600;arcSize=20;" target="e_ProcedureCatalog" value="1">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="r_InRoom" parent="1" style="shape=rhombus;perimeter=rhombusPerimeter;whiteSpace=wrap;html=1;fillColor=#E1D5E7;strokeColor=#9673A6;strokeWidth=2;fontStyle=1;fontSize=35;" value="In Room" vertex="1">
          <mxGeometry height="80" width="250" x="3890" y="2760" as="geometry" />
        </mxCell>
        <mxCell id="r_Surgeon" parent="1" style="shape=rhombus;perimeter=rhombusPerimeter;whiteSpace=wrap;html=1;fillColor=#E1D5E7;strokeColor=#9673A6;strokeWidth=2;fontStyle=1;fontSize=35;" value="Surgeon" vertex="1">
          <mxGeometry height="80" width="250" x="1943" y="1520" as="geometry" />
        </mxCell>
        <mxCell id="ed_414" edge="1" parent="1" source="r_Surgeon" style="shape=link;endArrow=none;html=1;strokeColor=#333333;strokeWidth=4;;fontSize=35;fontStyle=1;fontColor=#CC6600;arcSize=20;" target="e_MedicalProcedure" value="N">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="ed_415" edge="1" parent="1" source="r_Surgeon" style="endArrow=none;html=1;strokeColor=#666666;;fontSize=35;fontStyle=1;fontColor=#CC6600;arcSize=20;" target="e_Doctor" value="1">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="r_AssistedBy" parent="1" style="shape=rhombus;perimeter=rhombusPerimeter;whiteSpace=wrap;html=1;fillColor=#E1D5E7;strokeColor=#9673A6;strokeWidth=2;fontStyle=1;fontSize=35;" value="Assisted By" vertex="1">
          <mxGeometry height="80" width="250" x="2700" y="1350" as="geometry" />
        </mxCell>
        <mxCell id="ed_416" edge="1" parent="1" source="r_AssistedBy" style="endArrow=none;html=1;strokeColor=#666666;;fontSize=35;fontStyle=1;fontColor=#CC6600;arcSize=20;" target="e_MedicalProcedure" value="N">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="ed_417" edge="1" parent="1" source="r_AssistedBy" style="endArrow=none;html=1;strokeColor=#666666;;fontSize=35;fontStyle=1;fontColor=#CC6600;arcSize=20;" target="e_Staff" value="M">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="r_WrittenBy" parent="1" style="shape=rhombus;perimeter=rhombusPerimeter;whiteSpace=wrap;html=1;fillColor=#E1D5E7;strokeColor=#9673A6;strokeWidth=2;fontStyle=1;fontSize=35;" value="Written By" vertex="1">
          <mxGeometry height="130" width="250" x="1520" y="1932" as="geometry" />
        </mxCell>
        <mxCell id="ed_418" edge="1" parent="1" source="r_WrittenBy" style="shape=link;endArrow=none;html=1;strokeColor=#333333;strokeWidth=4;;fontSize=35;fontStyle=1;fontColor=#CC6600;arcSize=20;" target="e_Prescription" value="N">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="ed_419" edge="1" parent="1" source="r_WrittenBy" style="endArrow=none;html=1;strokeColor=#666666;;fontSize=35;fontStyle=1;fontColor=#CC6600;arcSize=20;" target="e_Doctor" value="1">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="r_RxFor" parent="1" style="shape=rhombus;perimeter=rhombusPerimeter;whiteSpace=wrap;html=1;fillColor=#E1D5E7;strokeColor=#9673A6;strokeWidth=2;fontStyle=1;fontSize=35;" value="Rx For" vertex="1">
          <mxGeometry height="80" width="250" x="930" y="2020" as="geometry" />
        </mxCell>
        <mxCell id="ed_420" edge="1" parent="1" source="r_RxFor" style="endArrow=none;html=1;strokeColor=#666666;;fontSize=35;fontStyle=1;fontColor=#CC6600;arcSize=20;" target="e_Prescription" value="N">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="ed_421" edge="1" parent="1" source="r_RxFor" style="endArrow=none;html=1;strokeColor=#666666;;fontSize=35;fontStyle=1;fontColor=#CC6600;arcSize=20;" target="e_Patient" value="1">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="r_OfDrug" parent="1" style="shape=rhombus;perimeter=rhombusPerimeter;whiteSpace=wrap;html=1;fillColor=#E1D5E7;strokeColor=#9673A6;strokeWidth=2;fontStyle=1;fontSize=35;" value="Of Drug" vertex="1">
          <mxGeometry height="80" width="250" x="1770" y="3470" as="geometry" />
        </mxCell>
        <mxCell id="ed_422" edge="1" parent="1" source="r_OfDrug" style="shape=link;endArrow=none;html=1;strokeColor=#333333;strokeWidth=4;;fontSize=35;fontStyle=1;fontColor=#CC6600;arcSize=20;" target="e_Prescription" value="N">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="ed_423" edge="1" parent="1" source="r_OfDrug" style="endArrow=none;html=1;strokeColor=#666666;;fontSize=35;fontStyle=1;fontColor=#CC6600;arcSize=20;" target="e_Drug" value="1">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="r_DrugContains" parent="1" style="shape=rhombus;perimeter=rhombusPerimeter;whiteSpace=wrap;html=1;fillColor=#E1D5E7;strokeColor=#9673A6;strokeWidth=2;fontStyle=1;fontSize=35;" value="DrugContains" vertex="1">
          <mxGeometry height="80" width="250" x="1174" y="3122" as="geometry" />
        </mxCell>
        <mxCell id="ed_425" edge="1" parent="1" source="r_DrugContains" style="endArrow=none;html=1;strokeColor=#666666;;fontSize=35;fontStyle=1;fontColor=#CC6600;arcSize=20;" target="e_ActiveSubstance" value="M">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="r_AllergicTo" parent="1" style="shape=rhombus;perimeter=rhombusPerimeter;whiteSpace=wrap;html=1;fillColor=#E1D5E7;strokeColor=#9673A6;strokeWidth=2;fontStyle=1;fontSize=35;" value="Allergic To" vertex="1">
          <mxGeometry height="80" width="250" x="700" y="2709" as="geometry" />
        </mxCell>
        <mxCell id="ed_426" edge="1" parent="1" source="r_AllergicTo" style="endArrow=none;html=1;strokeColor=#666666;;fontSize=35;fontStyle=1;fontColor=#CC6600;arcSize=20;" target="e_Patient" value="N">
          <mxGeometry relative="1" as="geometry">
            <Array as="points">
              <mxPoint x="790" y="2100" />
              <mxPoint x="800" y="1860" />
            </Array>
          </mxGeometry>
        </mxCell>
        <mxCell id="ed_427" edge="1" parent="1" source="r_AllergicTo" style="endArrow=none;html=1;strokeColor=#666666;;fontSize=35;fontStyle=1;fontColor=#CC6600;arcSize=20;" target="e_ActiveSubstance" value="M">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="r_ShiftFor" parent="1" style="shape=rhombus;perimeter=rhombusPerimeter;whiteSpace=wrap;html=1;fillColor=#E1D5E7;strokeColor=#9673A6;strokeWidth=2;fontStyle=1;fontSize=35;" value="Shift For" vertex="1">
          <mxGeometry height="80" width="250" x="4420" y="760" as="geometry" />
        </mxCell>
        <mxCell id="ed_428" edge="1" parent="1" source="r_ShiftFor" style="shape=link;endArrow=none;html=1;strokeColor=#333333;strokeWidth=4;;fontSize=35;fontStyle=1;fontColor=#CC6600;arcSize=20;" target="e_Shift" value="1">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="r_OnDuty" parent="1" style="shape=rhombus;perimeter=rhombusPerimeter;whiteSpace=wrap;html=1;fillColor=#E1D5E7;strokeColor=#9673A6;strokeWidth=2;fontStyle=1;fontSize=35;" value="On Duty" vertex="1">
          <mxGeometry height="80" width="250" x="3710" y="288" as="geometry" />
        </mxCell>
        <mxCell id="ed_431" edge="1" parent="1" source="r_OnDuty" style="endArrow=none;html=1;strokeColor=#666666;;fontSize=35;fontStyle=1;fontColor=#CC6600;arcSize=20;" target="e_Staff" value="M">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="r_RecordOf" parent="1" style="shape=rhombus;perimeter=rhombusPerimeter;whiteSpace=wrap;html=1;fillColor=#E1D5E7;strokeColor=#9673A6;strokeWidth=2;fontStyle=1;fontSize=35;" value="Record Of" vertex="1">
          <mxGeometry height="80" width="250" x="490" y="1910" as="geometry" />
        </mxCell>
        <mxCell id="ed_432" edge="1" parent="1" source="r_RecordOf" style="shape=link;endArrow=none;html=1;strokeColor=#333333;strokeWidth=4;;fontSize=35;fontStyle=1;fontColor=#CC6600;arcSize=20;" target="e_TriageRecord" value="N">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="r_TriagedBy" parent="1" style="shape=rhombus;perimeter=rhombusPerimeter;whiteSpace=wrap;html=1;fillColor=#E1D5E7;strokeColor=#9673A6;strokeWidth=2;fontStyle=1;fontSize=35;" value="Triaged By" vertex="1">
          <mxGeometry height="120" width="250" x="1580" y="1410" as="geometry" />
        </mxCell>
        <mxCell id="ed_434" edge="1" parent="1" source="r_TriagedBy" style="shape=link;endArrow=none;html=1;strokeColor=#333333;strokeWidth=4;;fontSize=35;fontStyle=1;fontColor=#CC6600;arcSize=20;" target="e_TriageRecord" value="N">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="ed_435" edge="1" parent="1" source="r_TriagedBy" style="endArrow=none;html=1;strokeColor=#666666;;fontSize=35;fontStyle=1;fontColor=#CC6600;arcSize=20;" target="e_Nurse" value="1">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="IpbID4TjgTse4RfUTD4G-2" parent="1" style="shape=rhombus;perimeter=rhombusPerimeter;whiteSpace=wrap;html=1;fillColor=#E1D5E7;strokeColor=#9673A6;strokeWidth=2;fontStyle=1;fontSize=35;" value="ISA" vertex="1">
          <mxGeometry height="180" width="250" x="2320" y="400" as="geometry" />
        </mxCell>
        <mxCell id="IpbID4TjgTse4RfUTD4G-3" edge="1" parent="1" source="e_Staff" style="shape=link;html=1;rounded=0;" target="IpbID4TjgTse4RfUTD4G-2" value="">
          <mxGeometry relative="1" width="100" as="geometry">
            <mxPoint x="2880" y="380" as="sourcePoint" />
            <mxPoint x="2980" y="380" as="targetPoint" />
          </mxGeometry>
        </mxCell>
        <mxCell id="8FO7XHq_h0duGJFMV3aA-2" edge="1" parent="1" source="e_Doctor" style="shape=link;endArrow=none;html=1;strokeColor=#333333;strokeWidth=4;;fontSize=35;fontStyle=1;fontColor=#CC6600;arcSize=20;" target="r_BelongsTo" value="N">
          <mxGeometry relative="1" as="geometry">
            <mxPoint x="1600" y="780" as="sourcePoint" />
            <mxPoint x="2267" y="878" as="targetPoint" />
          </mxGeometry>
        </mxCell>
        <mxCell id="8FO7XHq_h0duGJFMV3aA-4" edge="1" parent="1" source="e_Department" style="shape=link;endArrow=none;html=1;strokeColor=#333333;strokeWidth=4;;fontSize=35;fontStyle=1;fontColor=#CC6600;arcSize=20;" target="r_ShiftFor" value="N">
          <mxGeometry relative="1" x="-0.0522" y="-1" as="geometry">
            <mxPoint y="1" as="offset" />
            <mxPoint x="4190" y="1050" as="sourcePoint" />
            <mxPoint x="4419" y="1053" as="targetPoint" />
          </mxGeometry>
        </mxCell>
        <mxCell id="8FO7XHq_h0duGJFMV3aA-6" edge="1" parent="1" source="r_OnDuty" style="shape=link;endArrow=none;html=1;strokeColor=#333333;strokeWidth=4;;fontSize=35;fontStyle=1;fontColor=#CC6600;arcSize=20;exitX=1;exitY=1;exitDx=0;exitDy=0;" target="e_Shift" value="N">
          <mxGeometry relative="1" x="-0.0522" y="-1" as="geometry">
            <mxPoint y="1" as="offset" />
            <mxPoint x="4140" y="828" as="sourcePoint" />
            <mxPoint x="4772" y="390" as="targetPoint" />
          </mxGeometry>
        </mxCell>
        <mxCell id="8FO7XHq_h0duGJFMV3aA-9" edge="1" parent="1" source="e_Patient" style="shape=link;endArrow=none;html=1;strokeColor=#333333;strokeWidth=4;;fontSize=35;fontStyle=1;fontColor=#CC6600;arcSize=20;exitX=0.5;exitY=1;exitDx=0;exitDy=0;" target="r_RecordOf" value="1">
          <mxGeometry relative="1" as="geometry">
            <mxPoint x="790" y="1750" as="sourcePoint" />
            <mxPoint x="1636" y="2055" as="targetPoint" />
          </mxGeometry>
        </mxCell>
        <mxCell id="8FO7XHq_h0duGJFMV3aA-12" edge="1" parent="1" source="e_MedicalProcedure" style="shape=link;endArrow=none;html=1;strokeColor=#333333;strokeWidth=4;;fontSize=35;fontStyle=1;fontColor=#CC6600;arcSize=20;" target="r_InRoom" value="N">
          <mxGeometry relative="1" as="geometry">
            <Array as="points" />
            <mxPoint x="3470" y="2790" as="sourcePoint" />
            <mxPoint x="3666" y="3220" as="targetPoint" />
          </mxGeometry>
        </mxCell>
        <mxCell id="8FO7XHq_h0duGJFMV3aA-14" edge="1" parent="1" source="r_InRoom" style="endArrow=none;html=1;strokeColor=#666666;;fontSize=35;fontStyle=1;fontColor=#CC6600;arcSize=20;" target="e_ProcedureRoom" value="1">
          <mxGeometry relative="1" as="geometry">
            <mxPoint x="4240" y="2600" as="sourcePoint" />
            <mxPoint x="4580" y="2699" as="targetPoint" />
          </mxGeometry>
        </mxCell>
        <mxCell id="8FO7XHq_h0duGJFMV3aA-15" edge="1" parent="1" source="e_MedicalProcedure" style="shape=link;endArrow=none;html=1;strokeColor=#333333;strokeWidth=4;;fontSize=35;fontStyle=1;fontColor=#CC6600;arcSize=20;" target="r_TypeOf" value="N">
          <mxGeometry relative="1" as="geometry">
            <Array as="points" />
            <mxPoint x="3400" y="3070" as="sourcePoint" />
            <mxPoint x="4103" y="2990" as="targetPoint" />
          </mxGeometry>
        </mxCell>
        <mxCell id="8FO7XHq_h0duGJFMV3aA-17" edge="1" parent="1" source="e_Drug" style="shape=link;endArrow=none;html=1;strokeColor=#333333;strokeWidth=4;;fontSize=35;fontStyle=1;fontColor=#CC6600;arcSize=20;exitX=0.5;exitY=0;exitDx=0;exitDy=0;" target="r_DrugContains" value="N">
          <mxGeometry relative="1" as="geometry">
            <mxPoint x="1390" y="3616" as="sourcePoint" />
            <mxPoint x="1348" y="3165" as="targetPoint" />
          </mxGeometry>
        </mxCell>
      </root>
    </mxGraphModel>
  </diagram>
</mxfile>
