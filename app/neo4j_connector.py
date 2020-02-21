"""
neo4j_connector.py: Retrieves an instance of Neo4J
"""

from py2neo import Graph
from neobolt.exceptions import ServiceUnavailable
import os

GRAPH_INSTANCE = None

def get_neo4j_instance(neo4j_url, neo4j_username, neo4j_password):

    if neo4j_url is None:
        neo4j_url = os.environ["NEO4J_URL"]

    if neo4j_username is None:
        neo4j_username = os.environ["NEO4J_USERNAME"]

    if neo4j_password is None:
        neo4j_password = os.environ["NEO4J_PASSWORD"]

    GRAPH_INSTANCE = Graph(neo4j_url, username=neo4j_username, password=neo4j_password)

    # check for Neo4J connectivity
    try:
        GRAPH_INSTANCE.run("""MATCH (n) RETURN n LIMIT 1""")
    except ServiceUnavailable as no_service:
        print("Failed to contact Neo4J instance, exiting...")
        exit(1)

    print(f"Connected to Neo4J @ {neo4j_url}")

    
    return GRAPH_INSTANCE
