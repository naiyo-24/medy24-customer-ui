import requests
url = "http://127.0.0.1:8000/graphql"
query = """
    query GetMyB2BOrders($shopId: String!) {
      getB2bOrders(shopId: $shopId) {
        poId
      }
    }
"""
variables = {"shopId": "SHOP-EA0E100E"}
try:
    response = requests.post(url, json={'query': query, 'variables': variables}, timeout=3)
    print(response.status_code)
    print(response.json())
except Exception as e:
    print(f"Error: {e}")
