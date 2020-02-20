//Cypher PDBe queries for each scenario discussed at the "Mining PDBe and PDBe-KB using a graph database"

//1) For a UniProt accession, get every predicted ligand binding site with raw scores and confidence levels, together with information on whether a residue is also on a PPI interface and if there are known variants
//Get all 3dligandsite and p2rank annotations for a Uniprot residue
MATCH (unp:UniProt {ACCESSION:'P00441'})-[:HAS_UNP_RESIDUE]->(unpRes:UNP_Residue)<-[:MAP_TO_UNIPROT_RESIDUE]-(pdbRes:PDB_Residue)<-[rel:FUNPDBE_ANNOTATION_FOR]-(fg:FunPDBeResidueGroup)-[:FUNPDBE_RESIDUE_GROUP_OF]->(fe:FunPDBeEntry) WHERE fe.DATA_RESOURCE IN ['3dligandsite','p2rank']
WITH DISTINCT unp, unpRes, fe, rel, [(unpRes)-[:INTERACTS_WITH]->(partner) | partner] as partners, [(unp)<-[:IS_VARIANT_IN]-(variant:UNP_Variant) WHERE toInteger(variant.BEGIN)=toInteger(unpRes.ID) | variant ] AS variants
RETURN toInteger(unpRes.ID) AS unpResidueId, fe.DATA_RESOURCE, COLLECT(toFloat(rel.RAW_SCORE)) AS rawScores, COLLECT(toFloat(rel.CONFIDENCE_SCORE)) AS confScores, 
CASE
    WHEN SIZE(partners) > 0
        THEN "ON PPI Interface"
           ELSE "NOT ON PPI Interface"
    END AS ppiFlag,
    variants
    ORDER BY unpResidueId

//2) For a UniProt residue, get interactions, ligand binding, FunPDBe annotations, sequence conservation, domains, everything

//2b) For a PDB residue, get interactions, ligand binding, FunPDBe annotations, sequence conservation, domains, everything

//3) Using a PDB accession, get a list of all UniProt accessions that it could potentially map to, based on UniRef90 clusters
MATCH (entry:Entry {ID:'5la4'})-[:HAS_ENTITY]->(entity:Entity)-[:HAS_UNIPROT]->(uniprot:UniProt)-[:IS_IN_UNIREF90_CLUSTER]->(cluster:UniRef_Reference)<-[:IS_IN_UNIREF90_CLUSTER]-(uniref90:UniProt)
RETURN uniprot.ACCESSION + COLLECT(uniref90.ACCESSION)

//4) Using a UniProt accession, get every small molecule seen to bind to any protein within the same UniRef90 cluster
// Get similar proteins for the protein
MATCH (uniprot:UniProt {ACCESSION:'Q9Y251'})-[:IS_IN_UNIREF90_CLUSTER]->(cluster)<-[:IS_IN_UNIREF90_CLUSTER]-(uniref90:UniProt)
WITH uniref90
// Get all ligand binding PDB residues which has mapping to the uniref90
MATCH (uniref90)<-[rel:HAS_UNIREF90_SEGMENT]-(entity:Entity)-[:HAS_PDB_RESIDUE]->(pdbRes:PDB_Residue)-[:HAS_ARP_CONTACT]-(boundLigand:Bound_Ligand) WHERE toInteger(pdbRes.ID) IN RANGE(toInteger(rel.PDB_START), toInteger(rel.PDB_END))
RETURN COLLECT(DISTINCT boundLigand.AUTH_COMP_ID)

//5) Get a list of all the PDB chain pairs when one chain is assigned to CATH/SCOP domain, and the other has MobiDB disorder annotation
MATCH (e1:Entry)-[:HAS_ENTITY]->(en1:Entity)-[:HAS_PDB_RESIDUE]->(r1:PDB_Residue)-[:IS_IN_SCOP_DOMAIN]->(s:SCOP), (r1)-[bond:HAS_PISA_BOND]-(r2:PDB_Residue)-[:MAP_TO_UNIPROT_RESIDUE]-(u:UNP_Residue)
WHERE u.IDP_REGION = 'Y'
RETURN DISTINCT e1.ID, bond.AUTH_ASYM_ID_1, bond.AUTH_ASYM_ID_2

//6) Get a list of every residue that has PTM annotation from AKID and add the residue depth values, and the surface accessibility values and sequence conservation

//7) List every PDB residue that bind to a list of HET codes (small-molecules)
WITH ['STI','ERY'] AS chemComps
MATCH (c:Chemical_Component) WHERE c.ID IN chemComps
MATCH (c)<-[:IS_A]-(:Entity)-[:IS_AN_INSTANCE_OF]->(boundLigand:Bound_Ligand)-[:HAS_ARP_CONTACT]-(pdbRes:PDB_Residue)-[rel:IS_IN_CHAIN]->(chain:Chain)
WITH DISTINCT c, rel, pdbRes, chain
RETURN c.ID, COLLECT(pdbRes.UNIQID +":" +rel.AUTH_SEQ_ID +":" +pdbRes.CHEM_COMP_ID +":" +chain.AUTH_ASYM_ID)

//8) Using a UniProt accession, get a list of all the predicted ligand binding sites within the UniRef90 cluster, and add sequence conservation

//9) Using a PDB id and a list of residues, check if those residues are accessible (ASA alone and ASA complex)
MATCH (e:Entry)-[:HAS_ENTITY]->(en:Entity)-[:HAS_PDB_RESIDUE]->(p:PDB_Residue)<-[a:FUNPDBE_ANNOTATION_FOR]-(g:FunPDBeResidueGroup)-[:FUNPDBE_RESIDUE_GROUP_OF]->(f:FunPDBeEntry)
WHERE e.ID = '3pxe'
AND en.ID = '1'
AND p.ID IN ['1', '42', '9']
AND f.DATA_RESOURCE = '3Dcomplex'
AND g.LABEL = 'ASA_alone'
AND toFloat(a.RAW_SCORE) > 0
RETURN p

//10) For a specified PDB_Chain get the UniRef90 cluster, see what other PDB_Chains are at least 90% identical in sequence, get all residues from this cluster that interact with proteins (PISA), map all the interaction sites back to the input PDB_Chain, while retaining the list of interaction partners for each residue

//11a) Get all residues and the PDB ids where the residue is annotated as catalytic site by M-CSA
MATCH (n:FunPDBeEntry {DATA_RESOURCE:'M-CSA'})<-[:FUNPDBE_RESIDUE_GROUP_OF]-(:FunPDBeResidueGroup)-[:FUNPDBE_ANNOTATION_FOR]->(r:PDB_Residue)-[i:IS_IN_CHAIN]->(c:Chain) RETURN r.UNIQID, c.STRUCT_ASYM_ID, i.AUTH_SEQ_ID, n.RESOURCE_ENTRY_URL LIMIT 50

//11b) Filter this to show only when a small-molecule is seen bound to the catalytic site residues
MATCH (n:FunPDBeEntry {DATA_RESOURCE:'M-CSA'})<-[:FUNPDBE_RESIDUE_GROUP_OF]-(:FunPDBeResidueGroup)-[:FUNPDBE_ANNOTATION_FOR]->(r:PDB_Residue)-[i:IS_IN_CHAIN]->(c:Chain),(r)<-[:HAS_ARP_CONTACT]-(b:Bound_Ligand)
RETURN DISTINCT r.UNIQID, c.STRUCT_ASYM_ID, i.AUTH_SEQ_ID, n.RESOURCE_ENTRY_URL, b.C_CHEM_COMP_ID 

//12) See what other binding pockets containing NAD+ is most similar to my interest NAD+ binding pocket:
//List of binding pockets with NAD+ with SCOP/CATH annotations
match (b:Bound_Ligand{CHEM_COMP_ID:"NAJ"})-[:HAS_ARP_CONTACT]->(res:PDB_Residue),
(res:PDB_Residue)<-[:HAS_PDB_RESIDUE]-(e:Entity),
(e:Entity)<-[:HAS_ENTITY]-(pdb:Entry)
optional match (res:PDB_Residue)-[:IS_IN_SCOP_DOMAIN]->(scop:SCOP)
optional match (res:PDB_Residue)-[:IS_IN_CATH_DOMAIN]->(cath:CATH)
return distinct pdb.ID, scop.DESCRIPTION, collect(distinct cath.TOPOL)
// pocket is from the PDBID (6oa7) 
match (b2:Bound_Ligand{CHEM_COMP_ID:"NAJ"})-[dis1:HAS_ARP_CONTACT]->(res1:PDB_Residue),
(res1:PDB_Residue)<-[:HAS_PDB_RESIDUE]-(e1:Entity),
(e1:Entity)<-[:HAS_ENTITY]-(pdb1:Entry{ID:"6oa7"})
Return pdb1.ID, collect(dis1)
//and compare with a list of PDBID
match (b2:Bound_Ligand{CHEM_COMP_ID:"NAJ"})-[dis1:HAS_ARP_CONTACT]->(res1:PDB_Residue),
(res1:PDB_Residue)<-[:HAS_PDB_RESIDUE]-(e1:Entity),
(e1:Entity)<-[:HAS_ENTITY]-(pdb1:Entry{ID:"6oa7"})
match (b1:Bound_Ligand{CHEM_COMP_ID:"NAJ"})-[dis2:HAS_ARP_CONTACT]->(res2:PDB_Residue),
(res2:PDB_Residue)<-[:HAS_PDB_RESIDUE]-(e2:Entity),
(e2:Entity)<-[:HAS_ENTITY]-(pdb2:Entry)
where pdb2.ID IN ["5cdu", "5kje", "1n92", "5cdt", "4dxh", "3wgi", "6owp"]
RETURN pdb1.ID, pdb2.ID, 
algo.similarity.euclideanDistance(collect(toFloat(dis1.DISTANCE)), collect(toFloat(dis2.DISTANCE))) as similarity 
order by similarity desc

//13) UniProt range on one side, Pfam domain on the other side, list of PDB, chain?
WITH 'PF00104' AS pfamId, 'Q15596' AS unpAcc, 744 AS unpStart, 750 AS unpEnd
// Get Pfam domain
MATCH (pfam:Pfam {PFAM_ACCESSION:pfamId})
// Get all UniProt residues having mapping to the Pfam as well as mapped PDB residues
MATCH (pfam)<-[:IS_IN_PFAM]-(ur1:UNP_Residue)<-[:MAP_TO_UNIPROT_RESIDUE]-(pr1:PDB_Residue)
// Get UniProt and its residues in the provided range
MATCH (uniprot:UniProt {ACCESSION:unpAcc})-[:HAS_UNP_RESIDUE]->(ur2:UNP_Residue) WHERE toInteger(ur2.ID) IN RANGE(unpStart, unpEnd)
// Get all PDB residues mapped to the uniprot residues
MATCH (ur2)<-[:MAP_TO_UNIPROT_RESIDUE]-(pr2:PDB_Residue)
MATCH (pr1)-[:HAS_PISA_BOND]-(pr2)
MATCH (pr1)-[r1:IS_IN_CHAIN]->(ch1:Chain), (pr2)-[r2:IS_IN_CHAIN]->(ch2:Chain)
RETURN DISTINCT pr1.UNIQID, r1.AUTH_SEQ_ID, pr1.CHEM_COMP_ID, ch1.AUTH_ASYM_ID, pr2.UNIQID, r2.AUTH_SEQ_ID, pr2.CHEM_COMP_ID, ch2.AUTH_ASYM_ID

//14) Monomeric PDBs with single CATH domain
