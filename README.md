# pdbe-cypher

## Files included in repo:

- pdbe_cypher_queries.cql - cypher queries for PDBe and PDBe-KB. Applications of the graph database to biological questions.
- meta-queries.cql - miscellaneous queries and useful tips and tricks 

## Cypher queries examples for PDBe Neo4j graph database

1) For a UniProt accession, get every predicted ligand binding site with raw scores and confidence levels, together with information on whether a residue is also on a PPI interface and if there are known variants

2) For a UniProt residue, get interactions, ligand binding, FunPDBe annotations, sequence conservation, domains, everything

2b) For a PDB residue, get interactions, ligand binding, FunPDBe annotations, sequence conservation, domains, everything

3) Using a PDB accession, get a list of all UniProt accessions that it could potentially map to, based on UniRef90 clusters

4) Using a UniProt accession, get every small molecule seen to bind to any protein within the same UniRef90 cluster

5) Get a list of all the PDB chain pairs when one chain is assigned to CATH/SCOP domain, and the other has MobiDB disorder annotation

6) Get a list of every residue that has PTM annotation from AKID and add the residue depth values, and the surface accessibility values and sequence conservation

7) List every PDB residue that bind to a list of HET codes (small-molecules)

8) Using a UniProt accession, get a list of all the predicted ligand binding sites within the UniRef90 cluster, and add sequence conservation

9) Using a PDB id and a list of residues, check if those residues are accessible (ASA alone and ASA complex)

10) For a specified PDB_Chain get the UniRef90 cluster, see what other PDB_Chains are at least 90% identical in sequence, get all residues from this cluster that interact with proteins (PISA), map all the interaction sites back to the input PDB_Chain, while retaining the list of interaction partners for each residue

11) Get all residues and the PDB ids where the residue is annotated as catalytic site by M-CSA

11b) Filter this to show only when a small-molecule is seen bound to the catalytic site residues

12) See what other binding pockets containing NAD+ is most similar to my interest NAD+ binding pocket

13) UniProt range on one side, Pfam domain on the other side, list of PDB, chain?

14) Monomeric PDBs with single CATH domain

15) All entities from UniRef90 clusters for PDB entry 6cmo

16) Get sequence conservations for entry 1d5r

# Meta Queries
- Find shortest path between two graph nodes in a Neo4j database.
