<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE eagle SYSTEM "eagle.dtd">
<eagle version="7.3.0">
<drawing>
<settings>
<setting alwaysvectorfont="no"/>
<setting verticaltext="up"/>
</settings>
<grid distance="0.1" unitdist="inch" unit="inch" style="lines" multiple="1" display="no" altdistance="0.01" altunitdist="inch" altunit="inch"/>
<layers>
<layer number="1" name="Top" color="4" fill="1" visible="no" active="no"/>
<layer number="16" name="Bottom" color="1" fill="1" visible="no" active="no"/>
<layer number="17" name="Pads" color="2" fill="1" visible="no" active="no"/>
<layer number="18" name="Vias" color="2" fill="1" visible="no" active="no"/>
<layer number="19" name="Unrouted" color="6" fill="1" visible="no" active="no"/>
<layer number="20" name="Dimension" color="15" fill="1" visible="no" active="no"/>
<layer number="21" name="tPlace" color="7" fill="1" visible="no" active="no"/>
<layer number="22" name="bPlace" color="7" fill="1" visible="no" active="no"/>
<layer number="23" name="tOrigins" color="15" fill="1" visible="no" active="no"/>
<layer number="24" name="bOrigins" color="15" fill="1" visible="no" active="no"/>
<layer number="25" name="tNames" color="7" fill="1" visible="no" active="no"/>
<layer number="26" name="bNames" color="7" fill="1" visible="no" active="no"/>
<layer number="27" name="tValues" color="7" fill="1" visible="no" active="no"/>
<layer number="28" name="bValues" color="7" fill="1" visible="no" active="no"/>
<layer number="29" name="tStop" color="7" fill="3" visible="no" active="no"/>
<layer number="30" name="bStop" color="7" fill="6" visible="no" active="no"/>
<layer number="31" name="tCream" color="7" fill="4" visible="no" active="no"/>
<layer number="32" name="bCream" color="7" fill="5" visible="no" active="no"/>
<layer number="33" name="tFinish" color="6" fill="3" visible="no" active="no"/>
<layer number="34" name="bFinish" color="6" fill="6" visible="no" active="no"/>
<layer number="35" name="tGlue" color="7" fill="4" visible="no" active="no"/>
<layer number="36" name="bGlue" color="7" fill="5" visible="no" active="no"/>
<layer number="37" name="tTest" color="7" fill="1" visible="no" active="no"/>
<layer number="38" name="bTest" color="7" fill="1" visible="no" active="no"/>
<layer number="39" name="tKeepout" color="4" fill="11" visible="no" active="no"/>
<layer number="40" name="bKeepout" color="1" fill="11" visible="no" active="no"/>
<layer number="41" name="tRestrict" color="4" fill="10" visible="no" active="no"/>
<layer number="42" name="bRestrict" color="1" fill="10" visible="no" active="no"/>
<layer number="43" name="vRestrict" color="2" fill="10" visible="no" active="no"/>
<layer number="44" name="Drills" color="7" fill="1" visible="no" active="no"/>
<layer number="45" name="Holes" color="7" fill="1" visible="no" active="no"/>
<layer number="46" name="Milling" color="3" fill="1" visible="no" active="no"/>
<layer number="47" name="Measures" color="7" fill="1" visible="no" active="no"/>
<layer number="48" name="Document" color="7" fill="1" visible="no" active="no"/>
<layer number="49" name="Reference" color="7" fill="1" visible="no" active="no"/>
<layer number="51" name="tDocu" color="7" fill="1" visible="no" active="no"/>
<layer number="52" name="bDocu" color="7" fill="1" visible="no" active="no"/>
<layer number="90" name="Modules" color="5" fill="1" visible="yes" active="yes"/>
<layer number="91" name="Nets" color="2" fill="1" visible="yes" active="yes"/>
<layer number="92" name="Busses" color="1" fill="1" visible="yes" active="yes"/>
<layer number="93" name="Pins" color="2" fill="1" visible="no" active="yes"/>
<layer number="94" name="Symbols" color="4" fill="1" visible="yes" active="yes"/>
<layer number="95" name="Names" color="7" fill="1" visible="yes" active="yes"/>
<layer number="96" name="Values" color="7" fill="1" visible="yes" active="yes"/>
<layer number="97" name="Info" color="7" fill="1" visible="yes" active="yes"/>
<layer number="98" name="Guide" color="6" fill="1" visible="yes" active="yes"/>
</layers>
<schematic xreflabel="%F%N/%S.%C%R" xrefpart="/%S.%C%R">
<libraries>
<library name="con-ptr500">
<description>&lt;b&gt;PTR Connectors&lt;/b&gt;&lt;p&gt;
Aug. 2004 / PTR Meßtechnik:&lt;br&gt;
Die Bezeichnung der Serie AK505 wurde geändert.&lt;br&gt;
Es handelt sich hierbei um AK500 in horizontaler Ausführung.&lt;p&gt;
&lt;TABLE BORDER=0 CELLSPACING=1 CELLPADDING=2&gt;
  &lt;TR&gt;
    &lt;TD ALIGN=LEFT&gt;
      &lt;FONT SIZE=4 FACE=ARIAL&gt;&lt;B&gt;Alte Bezeichnung&lt;/B&gt;&lt;/FONT&gt;
    &lt;/TD&gt;
    &lt;TD ALIGN=LEFT&gt;
      &lt;FONT SIZE=4 FACE=ARIAL&gt;&lt;B&gt;Neue Bezeichnung&lt;/B&gt;&lt;/FONT&gt;
    &lt;/TD&gt;
  &lt;/TR&gt;
  &lt;TR&gt;
    &lt;TD ALIGN=LEFT&gt;
      &lt;B&gt;
      &lt;FONT SIZE=3 FACE=ARIAL color="#FF0000"&gt;AK505/2,grau&lt;/FONT&gt;
      &lt;/B&gt;
    &lt;/TD&gt;
    &lt;TD ALIGN=LEFT&gt;
      &lt;B&gt;
      &lt;FONT SIZE=3 FACE=ARIAL color="#0000FF"&gt;AK500/2-5.0-H-GRAU&lt;/FONT&gt;
      &lt;/B&gt;
    &lt;/TD&gt;
  &lt;/TR&gt;
  &lt;TR&gt;
    &lt;TD ALIGN=LEFT&gt;
      &lt;B&gt;
      &lt;FONT SIZE=3 FACE=ARIAL color="#FF0000"&gt;AK505/2DS,grau&lt;/FONT&gt;
      &lt;/B&gt;
    &lt;/TD&gt;
    &lt;TD ALIGN=LEFT&gt;
      &lt;B&gt;
      &lt;FONT SIZE=3 FACE=ARIAL color="#0000FF"&gt;AK500/2DS-5.0-H-GRAU&lt;/FONT&gt;
      &lt;/B&gt;
    &lt;/TD&gt;
  &lt;/TR&gt;
  &lt;TR&gt;
    &lt;TD ALIGN=LEFT&gt;
      &lt;B&gt;
      &lt;FONT SIZE=3 FACE=ARIAL color="#FF0000"&gt;AKZ505/2,grau&lt;/FONT&gt;
      &lt;/B&gt;
    &lt;/TD&gt;
    &lt;TD ALIGN=LEFT&gt;
      &lt;B&gt;
      &lt;FONT SIZE=3 FACE=ARIAL color="#0000FF"&gt;AKZ500/2-5.08-H-GRAU&lt;/FONT&gt;
      &lt;/B&gt;
    &lt;/TD&gt;
  &lt;/TABLE&gt;

&lt;author&gt;Created by librarian@cadsoft.de&lt;/author&gt;</description>
<packages>
<package name="AK300/2">
<description>&lt;b&gt;CONNECTOR&lt;/b&gt;</description>
<wire x1="5.08" y1="6.223" x2="5.08" y2="3.175" width="0.1524" layer="21"/>
<wire x1="5.08" y1="6.223" x2="-5.08" y2="6.223" width="0.1524" layer="21"/>
<wire x1="5.08" y1="6.223" x2="5.588" y2="6.223" width="0.1524" layer="21"/>
<wire x1="5.588" y1="6.223" x2="5.588" y2="1.397" width="0.1524" layer="21"/>
<wire x1="5.588" y1="1.397" x2="5.08" y2="1.651" width="0.1524" layer="21"/>
<wire x1="5.588" y1="-5.461" x2="5.08" y2="-5.207" width="0.1524" layer="21"/>
<wire x1="5.08" y1="-5.207" x2="5.08" y2="-6.223" width="0.1524" layer="21"/>
<wire x1="5.588" y1="-3.81" x2="5.08" y2="-4.064" width="0.1524" layer="21"/>
<wire x1="5.08" y1="-4.064" x2="5.08" y2="-5.207" width="0.1524" layer="21"/>
<wire x1="5.588" y1="-3.81" x2="5.588" y2="-5.461" width="0.1524" layer="21"/>
<wire x1="0.4572" y1="-6.223" x2="0.4572" y2="-4.318" width="0.1524" layer="21"/>
<wire x1="4.5212" y1="0.254" x2="4.5212" y2="-4.318" width="0.1524" layer="21"/>
<wire x1="0.4572" y1="-6.223" x2="4.5212" y2="-6.223" width="0.1524" layer="21"/>
<wire x1="4.5212" y1="-6.223" x2="5.08" y2="-6.223" width="0.1524" layer="21"/>
<wire x1="-0.4826" y1="-6.223" x2="-0.4826" y2="-4.318" width="0.1524" layer="21"/>
<wire x1="-0.4826" y1="-6.223" x2="0.4572" y2="-6.223" width="0.1524" layer="21"/>
<wire x1="-4.5466" y1="0.254" x2="-4.5466" y2="-4.318" width="0.1524" layer="21"/>
<wire x1="-5.08" y1="-6.223" x2="-4.5466" y2="-6.223" width="0.1524" layer="21"/>
<wire x1="-4.5466" y1="-6.223" x2="-0.4826" y2="-6.223" width="0.1524" layer="21"/>
<wire x1="0.4572" y1="-4.318" x2="4.5212" y2="-4.318" width="0.1524" layer="21"/>
<wire x1="0.4572" y1="-4.318" x2="0.4572" y2="0.254" width="0.1524" layer="21"/>
<wire x1="4.5212" y1="-4.318" x2="4.5212" y2="-6.223" width="0.1524" layer="21"/>
<wire x1="-0.4826" y1="-4.318" x2="-4.5466" y2="-4.318" width="0.1524" layer="21"/>
<wire x1="-0.4826" y1="-4.318" x2="-0.4826" y2="0.254" width="0.1524" layer="21"/>
<wire x1="-4.5466" y1="-4.318" x2="-4.5466" y2="-6.223" width="0.1524" layer="21"/>
<wire x1="4.1402" y1="-3.683" x2="4.1402" y2="-0.508" width="0.1524" layer="21"/>
<wire x1="4.1402" y1="-3.683" x2="0.8382" y2="-3.683" width="0.1524" layer="21"/>
<wire x1="0.8382" y1="-3.683" x2="0.8382" y2="-0.508" width="0.1524" layer="21"/>
<wire x1="-0.8636" y1="-3.683" x2="-0.8636" y2="-0.508" width="0.1524" layer="21"/>
<wire x1="-0.8636" y1="-3.683" x2="-4.1656" y2="-3.683" width="0.1524" layer="21"/>
<wire x1="-4.1656" y1="-3.683" x2="-4.1656" y2="-0.508" width="0.1524" layer="21"/>
<wire x1="-4.1656" y1="-0.508" x2="-3.7846" y2="-0.508" width="0.1524" layer="51"/>
<wire x1="-0.8636" y1="-0.508" x2="-1.2446" y2="-0.508" width="0.1524" layer="51"/>
<wire x1="0.8382" y1="-0.508" x2="1.2192" y2="-0.508" width="0.1524" layer="51"/>
<wire x1="4.1402" y1="-0.508" x2="3.7592" y2="-0.508" width="0.1524" layer="51"/>
<wire x1="-5.08" y1="-6.223" x2="-5.08" y2="0.635" width="0.1524" layer="21"/>
<wire x1="-5.08" y1="0.635" x2="-5.08" y2="3.175" width="0.1524" layer="21"/>
<wire x1="5.08" y1="1.651" x2="5.08" y2="0.635" width="0.1524" layer="21"/>
<wire x1="5.08" y1="0.635" x2="5.08" y2="-4.064" width="0.1524" layer="21"/>
<wire x1="-5.08" y1="3.175" x2="5.08" y2="3.175" width="0.1524" layer="21"/>
<wire x1="-5.08" y1="3.175" x2="-5.08" y2="6.223" width="0.1524" layer="21"/>
<wire x1="5.08" y1="3.175" x2="5.08" y2="1.651" width="0.1524" layer="21"/>
<wire x1="0.4572" y1="3.429" x2="0.4572" y2="5.969" width="0.1524" layer="21"/>
<wire x1="0.4572" y1="5.969" x2="4.5212" y2="5.969" width="0.1524" layer="21"/>
<wire x1="4.5212" y1="5.969" x2="4.5212" y2="3.429" width="0.1524" layer="21"/>
<wire x1="4.5212" y1="3.429" x2="0.4572" y2="3.429" width="0.1524" layer="21"/>
<wire x1="-0.4826" y1="3.429" x2="-0.4826" y2="5.969" width="0.1524" layer="21"/>
<wire x1="-0.4826" y1="3.429" x2="-4.5466" y2="3.429" width="0.1524" layer="21"/>
<wire x1="-4.5466" y1="3.429" x2="-4.5466" y2="5.969" width="0.1524" layer="21"/>
<wire x1="-0.4826" y1="5.969" x2="-4.5466" y2="5.969" width="0.1524" layer="21"/>
<wire x1="3.9574" y1="4.0849" x2="4.0131" y2="5.0545" width="0.1524" layer="21" curve="90.564135"/>
<wire x1="1.016" y1="4.1656" x2="4.0038" y2="4.1189" width="0.1524" layer="21" curve="75.530157"/>
<wire x1="0.8636" y1="5.0038" x2="4.0178" y2="5.0586" width="0.1524" layer="21" curve="-100.0232"/>
<wire x1="0.9144" y1="5.0546" x2="1.0581" y2="4.1297" width="0.1524" layer="21" curve="104.208873"/>
<wire x1="0.8636" y1="4.445" x2="3.9116" y2="5.08" width="0.1524" layer="21"/>
<wire x1="0.9906" y1="4.318" x2="4.0386" y2="4.953" width="0.1524" layer="21"/>
<wire x1="-1.0464" y1="4.0849" x2="-0.9907" y2="5.0545" width="0.1524" layer="21" curve="90.564135"/>
<wire x1="-3.9878" y1="4.1656" x2="-1" y2="4.1188" width="0.1524" layer="21" curve="75.528719"/>
<wire x1="-4.1402" y1="5.0038" x2="-0.9858" y2="5.0588" width="0.1524" layer="21" curve="-100.022513"/>
<wire x1="-4.0894" y1="5.0546" x2="-3.9457" y2="4.1297" width="0.1524" layer="21" curve="104.208873"/>
<wire x1="-4.1402" y1="4.445" x2="-1.0922" y2="5.08" width="0.1524" layer="21"/>
<wire x1="-4.0132" y1="4.318" x2="-0.9652" y2="4.953" width="0.1524" layer="21"/>
<wire x1="-4.5466" y1="0.254" x2="-4.1656" y2="0.254" width="0.1524" layer="21"/>
<wire x1="-0.4826" y1="0.254" x2="-0.8636" y2="0.254" width="0.1524" layer="21"/>
<wire x1="-0.8636" y1="0.254" x2="-4.1656" y2="0.254" width="0.1524" layer="51"/>
<wire x1="-5.08" y1="0.635" x2="-4.1656" y2="0.635" width="0.1524" layer="21"/>
<wire x1="-4.1656" y1="0.635" x2="-0.8636" y2="0.635" width="0.1524" layer="51"/>
<wire x1="-0.8636" y1="0.635" x2="0.8382" y2="0.635" width="0.1524" layer="21"/>
<wire x1="5.08" y1="0.635" x2="4.1402" y2="0.635" width="0.1524" layer="21"/>
<wire x1="4.1402" y1="0.635" x2="0.8382" y2="0.635" width="0.1524" layer="51"/>
<wire x1="4.5212" y1="0.254" x2="4.1402" y2="0.254" width="0.1524" layer="21"/>
<wire x1="0.4572" y1="0.254" x2="0.8382" y2="0.254" width="0.1524" layer="21"/>
<wire x1="0.8382" y1="0.254" x2="4.1402" y2="0.254" width="0.1524" layer="51"/>
<pad name="1" x="-2.5146" y="0" drill="1.3208" shape="long" rot="R90"/>
<pad name="2" x="2.4892" y="0" drill="1.3208" shape="long" rot="R90"/>
<text x="-5.08" y="6.731" size="1.778" layer="25" ratio="10">&gt;NAME</text>
<text x="-5.08" y="-8.636" size="1.778" layer="27" ratio="10">&gt;VALUE</text>
<text x="-4.4958" y="1.27" size="1.27" layer="21" ratio="10">1</text>
<text x="0.5842" y="1.27" size="1.27" layer="21" ratio="10">2</text>
<rectangle x1="-3.7846" y1="-2.54" x2="-1.2446" y2="0.254" layer="51"/>
<rectangle x1="1.2192" y1="-2.54" x2="3.7592" y2="0.254" layer="51"/>
</package>
<package name="AK500/3-H">
<description>&lt;b&gt;CONNECTOR&lt;/b&gt;&lt;p&gt;
Aug. 2004 / PTR Meßtechnik:&lt;br&gt;
Die Bezeichnung der Serie AK505 wurde geändert.&lt;br&gt;
Es handelt sich hierbei um AK500 in horizontaler Ausführung.</description>
<wire x1="-7.5946" y1="-7.239" x2="-7.5946" y2="-3.81" width="0.1524" layer="21"/>
<wire x1="7.5946" y1="2.794" x2="-7.5946" y2="2.794" width="0.1524" layer="21"/>
<wire x1="-7.5946" y1="-7.239" x2="-6.8326" y2="-7.239" width="0.1524" layer="21"/>
<wire x1="7.5946" y1="2.794" x2="7.5946" y2="-3.429" width="0.1524" layer="21"/>
<wire x1="-7.5946" y1="-3.429" x2="7.5946" y2="-3.429" width="0.1524" layer="21"/>
<wire x1="-7.5946" y1="-3.429" x2="-7.5946" y2="2.794" width="0.1524" layer="21"/>
<wire x1="7.5946" y1="-3.429" x2="7.5946" y2="-3.81" width="0.1524" layer="21"/>
<wire x1="7.9756" y1="2.794" x2="7.9756" y2="-3.429" width="0.1524" layer="21"/>
<wire x1="7.9756" y1="-3.429" x2="7.5946" y2="-3.429" width="0.1524" layer="21"/>
<wire x1="7.9756" y1="2.794" x2="7.5946" y2="2.794" width="0.1524" layer="21"/>
<wire x1="-2.9718" y1="2.159" x2="-2.9718" y2="-2.794" width="0.1524" layer="21"/>
<wire x1="-7.0358" y1="-2.794" x2="-2.9718" y2="-2.794" width="0.1524" layer="21"/>
<wire x1="-7.0358" y1="-2.794" x2="-7.0358" y2="2.159" width="0.1524" layer="21"/>
<wire x1="-2.9718" y1="2.159" x2="-7.0358" y2="2.159" width="0.1524" layer="21"/>
<wire x1="-2.032" y1="2.159" x2="-2.032" y2="-2.794" width="0.1524" layer="21"/>
<wire x1="-2.032" y1="-2.794" x2="2.032" y2="-2.794" width="0.1524" layer="21"/>
<wire x1="2.032" y1="-2.794" x2="2.032" y2="2.159" width="0.1524" layer="21"/>
<wire x1="2.032" y1="2.159" x2="-2.032" y2="2.159" width="0.1524" layer="21"/>
<wire x1="2.286" y1="-3.048" x2="-2.286" y2="-3.048" width="0.0508" layer="21"/>
<wire x1="2.286" y1="-3.048" x2="2.286" y2="2.413" width="0.0508" layer="21"/>
<wire x1="-2.286" y1="2.413" x2="2.286" y2="2.413" width="0.0508" layer="21"/>
<wire x1="-2.286" y1="2.413" x2="-2.286" y2="-3.048" width="0.0508" layer="21"/>
<wire x1="-2.7178" y1="2.413" x2="-2.7178" y2="-3.048" width="0.0508" layer="21"/>
<wire x1="-7.2898" y1="2.413" x2="-2.7178" y2="2.413" width="0.0508" layer="21"/>
<wire x1="-7.2898" y1="2.413" x2="-7.2898" y2="-3.048" width="0.0508" layer="21"/>
<wire x1="-2.7178" y1="-3.048" x2="-7.2898" y2="-3.048" width="0.0508" layer="21"/>
<wire x1="-7.0358" y1="0" x2="-2.9718" y2="0" width="0.1524" layer="21" curve="-180"/>
<wire x1="-7.0358" y1="-2.413" x2="-6.7818" y2="-2.667" width="0.1524" layer="21" curve="90"/>
<wire x1="-3.2258" y1="-2.667" x2="-2.9718" y2="-2.413" width="0.1524" layer="21" curve="90"/>
<wire x1="-3.2258" y1="-2.667" x2="-6.7818" y2="-2.667" width="0.1524" layer="21"/>
<wire x1="-3.8608" y1="-2.413" x2="-3.6068" y2="-2.667" width="0.1524" layer="21" curve="90"/>
<wire x1="-6.4008" y1="-2.667" x2="-6.1468" y2="-2.413" width="0.1524" layer="21" curve="90"/>
<wire x1="-6.1468" y1="-0.127" x2="-6.1468" y2="-0.762" width="0.1524" layer="51"/>
<wire x1="-6.1468" y1="-0.127" x2="-3.8608" y2="-0.127" width="0.1524" layer="51"/>
<wire x1="-3.8608" y1="-0.127" x2="-3.8608" y2="-0.762" width="0.1524" layer="51"/>
<wire x1="-6.1468" y1="-0.762" x2="-3.8608" y2="-0.762" width="0.1524" layer="51"/>
<wire x1="-6.1468" y1="-0.762" x2="-6.1468" y2="-2.413" width="0.1524" layer="21"/>
<wire x1="-3.8608" y1="-0.762" x2="-3.8608" y2="-2.413" width="0.1524" layer="21"/>
<wire x1="7.5946" y1="-3.81" x2="-7.5946" y2="-3.81" width="0.0508" layer="21"/>
<wire x1="-7.5946" y1="-3.81" x2="-7.5946" y2="-3.429" width="0.1524" layer="21"/>
<wire x1="7.5946" y1="-3.81" x2="7.5946" y2="-7.239" width="0.1524" layer="21"/>
<wire x1="-2.032" y1="0" x2="2.032" y2="0" width="0.1524" layer="21" curve="-180"/>
<wire x1="-1.143" y1="-0.127" x2="1.143" y2="-0.127" width="0.1524" layer="51"/>
<wire x1="-1.143" y1="-0.127" x2="-1.143" y2="-0.762" width="0.1524" layer="51"/>
<wire x1="-1.143" y1="-0.762" x2="1.143" y2="-0.762" width="0.1524" layer="51"/>
<wire x1="-1.143" y1="-0.762" x2="-1.143" y2="-2.413" width="0.1524" layer="21"/>
<wire x1="1.143" y1="-0.762" x2="1.143" y2="-2.413" width="0.1524" layer="21"/>
<wire x1="1.143" y1="-0.127" x2="1.143" y2="-0.762" width="0.1524" layer="51"/>
<wire x1="-1.397" y1="-2.667" x2="-1.143" y2="-2.413" width="0.1524" layer="21" curve="90"/>
<wire x1="1.143" y1="-2.413" x2="1.397" y2="-2.667" width="0.1524" layer="21" curve="90"/>
<wire x1="1.778" y1="-2.667" x2="-1.778" y2="-2.667" width="0.1524" layer="21"/>
<wire x1="1.778" y1="-2.667" x2="2.032" y2="-2.413" width="0.1524" layer="21" curve="90"/>
<wire x1="-2.032" y1="-2.413" x2="-1.778" y2="-2.667" width="0.1524" layer="21" curve="90"/>
<wire x1="-3.2766" y1="-7.366" x2="-3.2766" y2="-7.239" width="0.1524" layer="21"/>
<wire x1="-3.2766" y1="-7.239" x2="-1.7526" y2="-7.239" width="0.1524" layer="21"/>
<wire x1="-6.8326" y1="-7.366" x2="-6.8326" y2="-7.239" width="0.1524" layer="21"/>
<wire x1="-6.8326" y1="-7.239" x2="-5.3086" y2="-7.239" width="0.1524" layer="21"/>
<wire x1="-6.8326" y1="-7.366" x2="-5.3086" y2="-7.366" width="0.1524" layer="21"/>
<wire x1="-5.3086" y1="-7.239" x2="-5.3086" y2="-7.366" width="0.1524" layer="21"/>
<wire x1="-5.3086" y1="-7.239" x2="-4.8006" y2="-7.239" width="0.1524" layer="21"/>
<wire x1="-4.8006" y1="-7.239" x2="-3.2766" y2="-7.239" width="0.1524" layer="21"/>
<wire x1="-4.8006" y1="-7.366" x2="-4.8006" y2="-7.239" width="0.1524" layer="21"/>
<wire x1="-4.8006" y1="-7.366" x2="-3.2766" y2="-7.366" width="0.1524" layer="21"/>
<wire x1="-0.2286" y1="-7.239" x2="-0.2286" y2="-7.366" width="0.1524" layer="21"/>
<wire x1="-0.2286" y1="-7.239" x2="0.2794" y2="-7.239" width="0.1524" layer="21"/>
<wire x1="-1.7526" y1="-7.366" x2="-0.2286" y2="-7.366" width="0.1524" layer="21"/>
<wire x1="0.2794" y1="-7.366" x2="0.2794" y2="-7.239" width="0.1524" layer="21"/>
<wire x1="0.2794" y1="-7.239" x2="1.8034" y2="-7.239" width="0.1524" layer="21"/>
<wire x1="0.2794" y1="-7.366" x2="1.8034" y2="-7.366" width="0.1524" layer="21"/>
<wire x1="1.8034" y1="-7.366" x2="1.8034" y2="-7.239" width="0.1524" layer="21"/>
<wire x1="-1.7526" y1="-7.366" x2="-1.7526" y2="-7.239" width="0.1524" layer="21"/>
<wire x1="-1.7526" y1="-7.239" x2="-0.2286" y2="-7.239" width="0.1524" layer="21"/>
<wire x1="7.0358" y1="2.159" x2="7.0358" y2="-2.794" width="0.1524" layer="21"/>
<wire x1="2.9718" y1="-2.794" x2="7.0358" y2="-2.794" width="0.1524" layer="21"/>
<wire x1="2.9718" y1="-2.794" x2="2.9718" y2="2.159" width="0.1524" layer="21"/>
<wire x1="7.0358" y1="2.159" x2="2.9718" y2="2.159" width="0.1524" layer="21"/>
<wire x1="7.2898" y1="2.413" x2="7.2898" y2="-3.048" width="0.0508" layer="21"/>
<wire x1="2.7178" y1="2.413" x2="7.2898" y2="2.413" width="0.0508" layer="21"/>
<wire x1="2.7178" y1="2.413" x2="2.7178" y2="-3.048" width="0.0508" layer="21"/>
<wire x1="7.2898" y1="-3.048" x2="2.7178" y2="-3.048" width="0.0508" layer="21"/>
<wire x1="2.9718" y1="0" x2="7.0358" y2="0" width="0.1524" layer="21" curve="-180"/>
<wire x1="2.9718" y1="-2.413" x2="3.2258" y2="-2.667" width="0.1524" layer="21" curve="90"/>
<wire x1="6.7818" y1="-2.667" x2="7.0358" y2="-2.413" width="0.1524" layer="21" curve="90"/>
<wire x1="6.7818" y1="-2.667" x2="3.2258" y2="-2.667" width="0.1524" layer="21"/>
<wire x1="6.1468" y1="-2.413" x2="6.4008" y2="-2.667" width="0.1524" layer="21" curve="90"/>
<wire x1="3.6068" y1="-2.667" x2="3.8608" y2="-2.413" width="0.1524" layer="21" curve="90"/>
<wire x1="3.8608" y1="-0.127" x2="3.8608" y2="-0.762" width="0.1524" layer="51"/>
<wire x1="3.8608" y1="-0.127" x2="6.1468" y2="-0.127" width="0.1524" layer="51"/>
<wire x1="6.1468" y1="-0.127" x2="6.1468" y2="-0.762" width="0.1524" layer="51"/>
<wire x1="3.8608" y1="-0.762" x2="6.1468" y2="-0.762" width="0.1524" layer="51"/>
<wire x1="3.8608" y1="-0.762" x2="3.8608" y2="-2.413" width="0.1524" layer="21"/>
<wire x1="6.1468" y1="-0.762" x2="6.1468" y2="-2.413" width="0.1524" layer="21"/>
<wire x1="6.731" y1="-7.366" x2="6.731" y2="-7.239" width="0.1524" layer="21"/>
<wire x1="3.175" y1="-7.366" x2="4.699" y2="-7.366" width="0.1524" layer="21"/>
<wire x1="5.207" y1="-7.366" x2="6.731" y2="-7.366" width="0.1524" layer="21"/>
<wire x1="3.175" y1="-7.239" x2="3.175" y2="-7.366" width="0.1524" layer="21"/>
<wire x1="3.175" y1="-7.239" x2="1.8034" y2="-7.239" width="0.1524" layer="21"/>
<wire x1="3.175" y1="-7.239" x2="4.699" y2="-7.239" width="0.1524" layer="21"/>
<wire x1="4.699" y1="-7.239" x2="4.699" y2="-7.366" width="0.1524" layer="21"/>
<wire x1="4.699" y1="-7.239" x2="5.207" y2="-7.239" width="0.1524" layer="21"/>
<wire x1="5.207" y1="-7.239" x2="5.207" y2="-7.366" width="0.1524" layer="21"/>
<wire x1="5.207" y1="-7.239" x2="6.731" y2="-7.239" width="0.1524" layer="21"/>
<wire x1="7.5946" y1="-7.239" x2="6.731" y2="-7.239" width="0.1524" layer="21"/>
<circle x="-5.0038" y="0" radius="1.397" width="0.1524" layer="51"/>
<circle x="0" y="0" radius="1.397" width="0.1524" layer="51"/>
<circle x="5.0038" y="0" radius="1.397" width="0.1524" layer="51"/>
<pad name="1" x="-5.0038" y="0" drill="1.3208" shape="long" rot="R90"/>
<pad name="2" x="0" y="0" drill="1.3208" shape="long" rot="R90"/>
<pad name="3" x="5.0038" y="0" drill="1.3208" shape="long" rot="R90"/>
<text x="-7.5946" y="3.556" size="1.778" layer="25" ratio="10">&gt;NAME</text>
<text x="-7.5946" y="-9.525" size="1.778" layer="27" ratio="10">&gt;VALUE</text>
<text x="-5.6896" y="-5.715" size="1.27" layer="21" ratio="10">1</text>
<text x="-0.6096" y="-5.715" size="1.27" layer="21" ratio="10">2</text>
<text x="4.318" y="-5.715" size="1.27" layer="21" ratio="10">3</text>
<rectangle x1="-6.1468" y1="-1.524" x2="-3.8608" y2="-0.762" layer="51"/>
<rectangle x1="-1.143" y1="-1.524" x2="1.143" y2="-0.762" layer="51"/>
<rectangle x1="-6.1468" y1="-2.667" x2="-3.8608" y2="-1.524" layer="21"/>
<rectangle x1="-1.143" y1="-2.667" x2="1.143" y2="-1.524" layer="21"/>
<rectangle x1="3.8608" y1="-1.524" x2="6.1468" y2="-0.762" layer="51"/>
<rectangle x1="3.8608" y1="-2.667" x2="6.1468" y2="-1.524" layer="21"/>
</package>
</packages>
<symbols>
<symbol name="KL">
<circle x="1.27" y="0" radius="1.27" width="0.254" layer="94"/>
<text x="-1.27" y="0.889" size="1.778" layer="95" rot="R180">&gt;NAME</text>
<pin name="KL" x="5.08" y="0" visible="off" length="short" direction="pas" rot="R180"/>
</symbol>
<symbol name="KLV">
<circle x="1.27" y="0" radius="1.27" width="0.254" layer="94"/>
<text x="-1.27" y="0.889" size="1.778" layer="95" rot="R180">&gt;NAME</text>
<text x="-3.81" y="-3.683" size="1.778" layer="96">&gt;VALUE</text>
<pin name="KL" x="5.08" y="0" visible="off" length="short" direction="pas" rot="R180"/>
</symbol>
</symbols>
<devicesets>
<deviceset name="AK300/2" prefix="X" uservalue="yes">
<description>&lt;b&gt;CONNECTOR&lt;/b&gt;</description>
<gates>
<gate name="-1" symbol="KL" x="0" y="5.08" addlevel="always"/>
<gate name="-2" symbol="KLV" x="0" y="0" addlevel="always"/>
</gates>
<devices>
<device name="" package="AK300/2">
<connects>
<connect gate="-1" pin="KL" pad="1"/>
<connect gate="-2" pin="KL" pad="2"/>
</connects>
<technologies>
<technology name="">
<attribute name="MF" value="" constant="no"/>
<attribute name="MPN" value="" constant="no"/>
<attribute name="OC_FARNELL" value="unknown" constant="no"/>
<attribute name="OC_NEWARK" value="unknown" constant="no"/>
</technology>
</technologies>
</device>
</devices>
</deviceset>
<deviceset name="AK500/3-H" prefix="X" uservalue="yes">
<description>&lt;b&gt;CONNECTOR&lt;/b&gt;&lt;p&gt;
Aug. 2004 / PTR Meßtechnik:&lt;br&gt;
Die Bezeichnung der Serie AK505 wurde geändert.&lt;br&gt;
Es handelt sich hierbei um AK500 in horizontaler Ausführung.</description>
<gates>
<gate name="-1" symbol="KL" x="0" y="10.16" addlevel="always"/>
<gate name="-2" symbol="KL" x="0" y="5.08" addlevel="always"/>
<gate name="-3" symbol="KLV" x="0" y="0" addlevel="always"/>
</gates>
<devices>
<device name="" package="AK500/3-H">
<connects>
<connect gate="-1" pin="KL" pad="1"/>
<connect gate="-2" pin="KL" pad="2"/>
<connect gate="-3" pin="KL" pad="3"/>
</connects>
<technologies>
<technology name="">
<attribute name="MF" value="" constant="no"/>
<attribute name="MPN" value="" constant="no"/>
<attribute name="OC_FARNELL" value="unknown" constant="no"/>
<attribute name="OC_NEWARK" value="unknown" constant="no"/>
</technology>
</technologies>
</device>
</devices>
</deviceset>
</devicesets>
</library>
</libraries>
<attributes>
</attributes>
<variantdefs>
</variantdefs>
<classes>
<class number="0" name="default" width="0" drill="0">
</class>
</classes>
<parts>
<part name="ENTRADA" library="con-ptr500" deviceset="AK300/2" device="" value="12V"/>
<part name="STPSAIDA" library="con-ptr500" deviceset="AK300/2" device=""/>
<part name="STPENT" library="con-ptr500" deviceset="AK300/2" device=""/>
<part name="BAT" library="con-ptr500" deviceset="AK300/2" device=""/>
<part name="S.TENSAO" library="con-ptr500" deviceset="AK300/2" device=""/>
<part name="SAIDA" library="con-ptr500" deviceset="AK300/2" device="" value="12"/>
<part name="RELE" library="con-ptr500" deviceset="AK500/3-H" device=""/>
</parts>
<sheets>
<sheet>
<plain>
</plain>
<instances>
<instance part="ENTRADA" gate="-1" x="22.86" y="119.38"/>
<instance part="ENTRADA" gate="-2" x="22.86" y="114.3"/>
<instance part="STPSAIDA" gate="-1" x="68.58" y="132.08" rot="R270"/>
<instance part="STPSAIDA" gate="-2" x="63.5" y="132.08" rot="R270"/>
<instance part="STPENT" gate="-1" x="55.88" y="132.08" rot="R270"/>
<instance part="STPENT" gate="-2" x="50.8" y="132.08" rot="R270"/>
<instance part="BAT" gate="-1" x="101.6" y="132.08" rot="R270"/>
<instance part="BAT" gate="-2" x="96.52" y="132.08" rot="R270"/>
<instance part="S.TENSAO" gate="-1" x="119.38" y="111.76" rot="R180"/>
<instance part="S.TENSAO" gate="-2" x="119.38" y="116.84" rot="R180"/>
<instance part="SAIDA" gate="-1" x="22.86" y="106.68"/>
<instance part="SAIDA" gate="-2" x="22.86" y="101.6"/>
<instance part="RELE" gate="-1" x="53.34" y="88.9" rot="R90"/>
<instance part="RELE" gate="-2" x="58.42" y="88.9" rot="R90"/>
<instance part="RELE" gate="-3" x="63.5" y="88.9" rot="R90"/>
</instances>
<busses>
</busses>
<nets>
<net name="N$1" class="0">
<segment>
<pinref part="ENTRADA" gate="-1" pin="KL"/>
<wire x1="27.94" y1="119.38" x2="50.8" y2="119.38" width="0.1524" layer="91"/>
<pinref part="STPENT" gate="-2" pin="KL"/>
<wire x1="50.8" y1="119.38" x2="50.8" y2="127" width="0.1524" layer="91"/>
</segment>
</net>
<net name="N$4" class="0">
<segment>
<pinref part="ENTRADA" gate="-2" pin="KL"/>
<wire x1="27.94" y1="114.3" x2="55.88" y2="114.3" width="0.1524" layer="91"/>
<pinref part="STPENT" gate="-1" pin="KL"/>
<wire x1="55.88" y1="114.3" x2="55.88" y2="127" width="0.1524" layer="91"/>
</segment>
</net>
<net name="N$3" class="0">
<segment>
<pinref part="STPSAIDA" gate="-1" pin="KL"/>
<pinref part="BAT" gate="-2" pin="KL"/>
<wire x1="68.58" y1="127" x2="96.52" y2="127" width="0.1524" layer="91"/>
<wire x1="116.84" y1="111.76" x2="96.52" y2="111.76" width="0.1524" layer="91"/>
<wire x1="96.52" y1="111.76" x2="96.52" y2="127" width="0.1524" layer="91"/>
<junction x="96.52" y="127"/>
<wire x1="96.52" y1="127" x2="96.52" y2="106.68" width="0.1524" layer="91"/>
<wire x1="96.52" y1="106.68" x2="25.4" y2="106.68" width="0.1524" layer="91"/>
</segment>
</net>
<net name="N$11" class="0">
<segment>
<pinref part="STPSAIDA" gate="-2" pin="KL"/>
<wire x1="63.5" y1="127" x2="63.5" y2="121.92" width="0.1524" layer="91"/>
<wire x1="63.5" y1="121.92" x2="101.6" y2="121.92" width="0.1524" layer="91"/>
<pinref part="BAT" gate="-1" pin="KL"/>
<wire x1="101.6" y1="121.92" x2="101.6" y2="127" width="0.1524" layer="91"/>
<wire x1="101.6" y1="127" x2="101.6" y2="93.98" width="0.1524" layer="91"/>
<junction x="101.6" y="127"/>
<pinref part="RELE" gate="-3" pin="KL"/>
<wire x1="101.6" y1="93.98" x2="63.5" y2="93.98" width="0.1524" layer="91"/>
</segment>
</net>
<net name="N$5" class="0">
<segment>
<wire x1="101.6" y1="129.54" x2="101.6" y2="116.84" width="0.1524" layer="91"/>
<wire x1="101.6" y1="116.84" x2="116.84" y2="116.84" width="0.1524" layer="91"/>
</segment>
</net>
<net name="N$7" class="0">
<segment>
<pinref part="SAIDA" gate="-2" pin="KL"/>
<wire x1="27.94" y1="101.6" x2="58.42" y2="101.6" width="0.1524" layer="91"/>
<wire x1="58.42" y1="101.6" x2="58.42" y2="93.98" width="0.1524" layer="91"/>
<wire x1="58.42" y1="91.44" x2="58.42" y2="93.98" width="0.1524" layer="91"/>
</segment>
</net>
<net name="N$8" class="0">
<segment>
<wire x1="53.34" y1="91.44" x2="53.34" y2="119.38" width="0.1524" layer="91"/>
<wire x1="53.34" y1="119.38" x2="25.4" y2="119.38" width="0.1524" layer="91"/>
</segment>
</net>
</nets>
</sheet>
</sheets>
</schematic>
</drawing>
</eagle>
