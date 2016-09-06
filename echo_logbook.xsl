<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template match="/">
  <html>
  <body>
    <h2>Survey Data for <xsl:value-of select="/echo_logbook/survey/@SurveyName"/>, <xsl:value-of select="/echo_logbook/survey/@Voyage"/></h2>
    <table border="1">
      <tr bgcolor="#9acd32">
		<th>Filename</th>
		<th>Snapshot</th>
        <th>Stratum</th>
		<th>Transect</th>
        <th>Comment</th>
        <th>Start Time</th>
		<th>End Time</th>
      </tr>
      <xsl:for-each select="/echo_logbook/survey/line">
		<xsl:variable name="st" select="@StartTime"/>
		<xsl:variable name="et" select="@EndTime"/>
        <tr>
          <td><xsl:value-of select="@Filename"/></td>
          <td><xsl:value-of select="@Snapshot"/></td>
		  <td><xsl:value-of select="@Stratum"/></td>
		  <td><xsl:value-of select="@Transect"/></td>
          <td><xsl:value-of select="@Comment"/></td>
		  <td><xsl:value-of select="concat(substring($st,9,2),':',substring($st,11,2),':',substring($st,13,2),' ',substring($st,7,2),'/',substring($st,5,2),'/',substring($st,1,4))"/></td><!-- 20151222173429 -->
		  <td><xsl:value-of select="concat(substring($et,9,2),':',substring($et,11,2),':',substring($et,13,2),' ',substring($et,7,2),'/',substring($et,5,2),'/',substring($et,1,4))"/></td><!-- 20151222173429 -->
        </tr>
      </xsl:for-each>
    </table>
  </body>
  </html>
</xsl:template>

</xsl:stylesheet>