---
title: Accessing Workspace Files with Shared Clusters (UC) in Databricks
date: 2023-10-18 16:30:00 +0100
categories: [Databricks]
tags: [databricks, spark, unity-catalog, ]
---

## The issue

If you are trying to access workspace files or files located in a repository folder (as described [here](https://learn.microsoft.com/en-us/azure/databricks/files/workspace-interact)) from a shared cluster in Databricks, you might run into the following error:

`java.lang.SecurityException: User does not have permission SELECT on any file.`

The underlying problem has to do with the [restrictions](https://docs.databricks.com/en/clusters/configure.html#shared-access-mode-limitations) you are facing when using shared clusters in Databricks.

If you want to access Unity Catalog with a cluster the only two options regarding `Access Mode` currently are `Shared` or `Single User` though. If the latter is out of the question as it often happens in projects that i am participating in, then you will not be able to access workspace files from the only cluster option that is left.

## The solution

One way of dealing with this problem is to use [Databricks Python SDK](https://databricks-sdk-py.readthedocs.io/en/latest/).

### (1) Install the SDK on your Cluster

First you need to install the SDK on your current cluster. There are many ways to install libraries on your cluster, the easiest one is to add this line of code in a notebook cell of its own:

```python
%pip install databricks-sdk --upgrade
```

### (2) Initialize, Connect & Authenticate

Then you need to connect to your workspace and authenticate. In my example i am assuming that you have a PAT stored in a secret scope called `keyvault` and the secret name is `databrickspat`. You can also provide a token in the code, but that is __never__ recommended.

```python
from databricks.sdk import WorkspaceClient

w = WorkspaceClient(
    host  = spark.conf.get("spark.databricks.workspaceUrl"),
    token = dbutils.secrets.get(scope="keyvault", key="databrickspat")
)
```

### (3) Interact with Workspace Files

```python
# List DBFS with dbutils
w.dbutils.fs.ls("/")
 
# ...or with 'dbfs'
for file_ in w.dbfs.list("/"):
    print(file_)
    
# List workspace files of a user
for file_ in w.workspace.list("/Users/<username>", recursive=True):
    print(file_.path)
    
# List repository files of a user
for file_ in w.workspace.list("/Repos/<username>/<repo>"):
    print(file_.path)
 
# Get contents of a yaml file stored in Repos/...    
for line in w.workspace.download(path="/Repos/<username>/<repo>/.../catalog.yml"):
    print(line.decode("UTF-8").replace("\n", ""))

# Upload a (text) file to repos
import base64
from databricks.sdk.service import workspace

path = "/Repos/<username>/<repo>/.../test.yml"
w.workspace.import_(content=base64.b64encode(("This is the file's content").encode()).decode(),
    format=workspace.ImportFormat.AUTO,
    overwrite=True,
    path=path
)
```

List files in DBFS:
![List DBFS](/assets/img/dbfs.png)

List files in User/Workspace:
![List User Files](/assets/img/user.png)

Show contents of a yaml file saved in user's repository folder:
![Download File](/assets/img/yaml.png)
