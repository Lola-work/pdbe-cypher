
import neo4j_connector as neo4j_connector
import argparse

graph = None

def get_ligands(accession):

    # Query for getting bound ligands
    query = """
    MATCH (u:UniProt {ACCESSION:$acc})-[:HAS_UNP_RESIDUE]->(ur:UNP_Residue)-[:BOUNDED_BY]->(c:Chemical_Component)
    RETURN COLLECT(DISTINCT c.ID)
    """

    results = graph.run(query, { "acc": accession })

    print(f"List of interacting ligands with {accession}: {results.next()[0]}")


if __name__ == "__main__":

    parser = argparse.ArgumentParser("Neo4J Python connector")

    parser.add_argument("--neo4j_url", help="Neo4J URL: In the format bolt://<hostname>:<port>. Example: bolt://3.5.1.111:7687")
    parser.add_argument("--neo4j_username", help="Neo4J username")
    parser.add_argument("--neo4j_password", help="Neo4J password")
    parser.add_argument("--uniprot_accession", help="A UniProt accession", required=True)

    args = parser.parse_args()

    graph = neo4j_connector.get_neo4j_instance(args.neo4j_url, args.neo4j_username, args.neo4j_password)

    get_ligands(args.uniprot_accession)
    

    