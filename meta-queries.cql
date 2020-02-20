
// Meta-queries
// Navigating the PDBe-KB Graph the lazy way...

// How are FunSites related to ligand interactions. I could walk through the schema, or...
// NB. Variable length queries can explode, so need to be restrictive..
MATCH (fr:FunPDBeEntry {DATA_RESOURCE:"cath-funsites"})
WITH fr LIMIT 1 MATCH (bl:Bound_Ligand), p = ((fr)-[*1..3]-(bl))
RETURN p LIMIT 1
