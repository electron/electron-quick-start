<?xml version="1.0"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
       version="1.0">

<!--
 Search in the tags below literate for top-level function
 tags for which the language attribute is "R".
 In that, we extract the documentation segment.
-->
<xsl:template match="arg">
 <xsl:value-of select="." /> 
  <xsl:if test="[@defaultValue]">
    <xsl:text> = value</xsl:text>
  </xsl:if>
</xsl:template> 
<xsl:template match="/Rhelp">
  <xsl:apply-templates select="usage" /> 
</xsl:template>

</xsl:stylesheet>
