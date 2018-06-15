<?xml version="1.0"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
       version="1.0">

<!--
<xsl:template match="function[@language='R']"> R code </xsl:template>
-->
<!--
 Search in the tags below literate for top-level function
 tags for which the language attribute is "R".
 In that, we extract the documentation segment.
-->
<xsl:template match="/literate">
  <xsl:apply-templates select="function[@language='R']/doc" /> 
</xsl:template>

</xsl:stylesheet>
