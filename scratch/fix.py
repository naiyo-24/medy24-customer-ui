import re

queries_path = '../medy_backend_new/graphql_api/queries.py'
with open(queries_path, 'r') as f:
    queries_content = f.read()

queries_content = queries_content.replace(
    'DistributorUser.is_active == True',
    'DistributorUser.is_accepting_orders == True'
)

with open(queries_path, 'w') as f:
    f.write(queries_content)

print("Fixed is_active to is_accepting_orders")
