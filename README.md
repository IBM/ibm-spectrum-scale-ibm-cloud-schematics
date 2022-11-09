# IBM Spectrum Scale Solution

Repository for the Scale Solution Tile implementation files.

# Deployment with Schematics CLI on IBM Cloud

Follow the steps below to provision an IBM Spectrum Scale cluster using IBM Cloud CLI.

```
$ cp sample/configs/hpc_workspace_config.json config.json
$ ibmcloud iam api-key-create my-api-key --file ~/.ibm-api-key.json -d "my api key"
$ cat ~/.ibm-api-key.json | jq -r ."apikey"
# copy your apikey
$ vim config.json
# paste your apikey and set all the required input parameters to create spectrum scale cluster
```
Also need to generate github token if you use private Github repository.

# Deployment Process:

```
$ ibmcloud schematics workspace new -f config.json --github-token xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
$ ibmcloud schematics workspace list | grep <workspace name provided in config.json>
Name                     ID                                       Description     Version           Status     Frozen
hpcc-scale-test      us-east.workspace.hpcc-scale-test.3172ff2f               Terraform v1.0.11    INACTIVE         False   
                                  
OK
$ ibmcloud schematics plan --id us-east.workspace.hpcc-scale-test.3172ff2f 
                 
Activity ID   4a606ec27712d879159464a0f8d33f1e                    
OK

$ ibmcloud schematics apply --id us-east.workspace.hpcc-scale-test.3172ff2f 
Do you really want to perform this action? [y/N]> y

Activity ID 0f69588331523aab748361fbb854e6d0

OK
$ ibmcloud schematics logs --id us-east.workspace.hpcc-scale-test.3172ff2f 

 2022/04/20 05:11:57 Terraform apply | Apply complete! Resources: 40 added, 0 changed, 0 destroyed.
 2022/04/20 05:11:57 Terraform apply | 
 2022/04/20 05:11:57 Terraform apply | Outputs:
 2022/04/20 05:11:57 Terraform apply | 
 2022/04/20 05:11:57 Terraform apply | shematics_controller_ip = [
 2022/04/20 05:11:57 Terraform apply |   "169.63.173.216",
 2022/04/20 05:11:57 Terraform apply | ]
 2022/04/20 05:11:57 Terraform apply | ssh_command = "ssh -J ubuntu@161.156.200.102 vpcuser@10.241.1.4"
 2022/04/20 05:11:57 Terraform apply | ]
 2022/04/20 05:11:57 Command finished successfully.
 2022/04/20 05:12:04 Done with the workspace action
 
OK
$ ssh -J ubuntu@<bastion node ip> vpcuser@<Ip of bootstrap/storage/compute nodes>

$ ibmcloud schematics destroy --id us-east.workspace.hpcc-scale-test.3172ff2f
Do you really want to perform this action? [y/N]> y
                 
Activity ID   facd6ab01ae28d368b38198598d5e37c   
                 
OK
```
# Deployment with Schematics UI on IBM Cloud

1. Go to <https://cloud.ibm.com/schematics/workspaces> and click on create a workspace.
2. Further with Schematics workspace creation page, specify the github repo URL and provide the SSH token to access private Github repo. Select Terraform version as 1.0 and click next.
3. Update the workspace details with the name/resource group information. Also choose in which region the workspace needs to be created and click save.
4. Go to Schematic Workspace Settings, under variable section, click on "burger icons" to update the following parameters:
    - Provide the region and vpc_availability_zones details, where the scale cluster resources need to be provisioned.
    - Update bastion_key_pair/compute_cluster_key_pair/storage_cluster_key_pair with your ibm cloud SSH key name such as "scale-ssh-key" created from a specific region in IBM Cloud.
    - If required update the resource_prefix to the required naming convention.
    - Fetch the public ip address of the device and update the same on remote_cidr_blocks.
    - IBM Customer number(Bring your licence) needs to be provided for entitlement check.
    - Update the total_storage_cluster_instances and total_compute_cluster_instances count as per your requirement.
    - Update compute_cluster_gui_username, compute_cluster_gui_password, storage_cluster_gui_username, storage_cluster_gui_password. 
    
   Note: If IBM Customer number is not provide cluster creation will fail
5. Click on "Generate Plan" and ensure there are no errors and fix the errors if there are any
6. After "Generate Plan" gives no errors, click on "Apply Plan" to create resources.
7. Check the "Jobs" section on the left hand side to view the resource creation progress.
8. See the Log if the "Apply Plan" activity is successful and copy the output SSH command to your laptop terminal to SSH to either bootstrap/storage/compute nodes.
9. If device gets connected to any other different network i.e(Wi-Fi/LAN/Mobile Hotspot) from usual connection. Update the public ip address on Bastion security group to SSH to nodes 

# Spectrum Scale Storage Node and GPFS Setup
* The Spectrum Scale storage and compute nodes are configured as a GPFS cluster (owningCluster) which owns and serves the file system to be mounted. 
* AccessingCluster, i.e., the compute cluster is the cluster that accesses owningCluster, and is also configured as a GPFS cluster. 
* The file system mountpoint on owningCluster(storage gpfs Cluster) is specified in the variable storage_cluster_filesystem_mountpoint. Default value = "/gpfs/fs1"
* The file system mountpoint on accessingCluster(compute gpfs Cluster) is specified in the variable compute_cluster_filesystem_mountpoint. Default value = "/gpfs/fs1"

### Steps to validate Cluster setups
###### 1. To validate the storage node is setup and exported correctly
* Login to the storage node using SSH (ssh -J ubuntu@bastion_ip root@any storage_ip)
* The below command is to export the actual path from where we could run all the respective commands to validate the setup
```
# sudo su
# export PATH=$PATH:/usr/lpp/mmfs/bin
```
* The command below shows the status of the cluster

```
# mmgetstate -a 
Node number  Node name                 GPFS state  
----------------------------------------------------
           1  spectrum-scale-storage-2  active
           2  spectrum-scale-storage-3  active
           3  spectrum-scale-storage-1  active
```

* The command below shows the complete information about GPFS cluster/IP address/Admin node/Designation
```
# mmlscluster

GPFS cluster information
========================
  GPFS cluster name:         spectrum-scale.storage
  GPFS cluster id:           9876153676758860235
  GPFS UID domain:           spectrum-scale.storage
  Remote shell command:      /usr/bin/ssh
  Remote file copy command:  /usr/bin/scp
  Repository type:           CCR

 Node  Daemon node name                        IP address  Admin node name                         Designation
---------------------------------------------------------------------------------------------------------------
   1   spectrum-scale-storage-2.strgscale.com  10.241.1.7  spectrum-scale-storage-2.strgscale.com  quorum-manager-perfmon
   2   spectrum-scale-storage-3.strgscale.com  10.241.1.8  spectrum-scale-storage-3.strgscale.com  quorum-manager-perfmon
   3   spectrum-scale-storage-1.strgscale.com  10.241.1.9  spectrum-scale-storage-1.strgscale.com  quorum-perfmon


```

* The command below shows the details about the file system
```
# mmlsfs all 

File system attributes for /dev/fs1:
====================================
flag                value                    description
------------------- ------------------------ -----------------------------------
 -f                 8192                     Minimum fragment (subblock) size in bytes
 -i                 4096                     Inode size in bytes
 -I                 32768                    Indirect block size in bytes
 -m                 2                        Default number of metadata replicas
 -M                 3                        Maximum number of metadata replicas
 -r                 2                        Default number of data replicas
 -R                 3                        Maximum number of data replicas
 -j                 scatter                  Block allocation type
 -D                 nfs4                     File locking semantics in effect
 -k                 all                      ACL semantics in effect
 -n                 32                       Estimated number of nodes that will mount file system
 -B                 4194304                  Block size
 -Q                 none                     Quotas accounting enabled
                    none                     Quotas enforced
                    none                     Default quotas enabled
 --perfileset-quota no                       Per-fileset quota enforcement
 --filesetdf        no                       Fileset df enabled?
 -V                 28.00 (5.1.4.0)          File system version
 --create-time      Fri Sep  2 11:31:17 2022 File system creation time
 -z                 no                       Is DMAPI enabled?
 -L                 33554432                 Logfile size
 -E                 yes                      Exact mtime mount option
 -S                 relatime                 Suppress atime mount option
 -K                 whenpossible             Strict replica allocation option
 --fastea           yes                      Fast external attributes enabled?
 --encryption       no                       Encryption enabled?
 --inode-limit      97676288                 Maximum number of inodes
 --log-replicas     0                        Number of log replicas
 --is4KAligned      yes                      is4KAligned?
 --rapid-repair     yes                      rapidRepair enabled?
 --write-cache-threshold 0                   HAWC Threshold (max 65536)
 --subblocks-per-full-block 512              Number of subblocks per full block
 -P                 system                   Disk storage pools in file system
 --file-audit-log   no                       File Audit Logging enabled?
 --maintenance-mode no                       Maintenance Mode enabled?
 --flush-on-close   no                       flush cache on file close enabled?
 --auto-inode-limit no                       Increase maximum number of inodes per inode space automatically?
 -d                 nsd_10_241_1_10_nvme0n1;nsd_10_241_1_10_nvme1n1;nsd_10_241_1_10_nvme2n1;nsd_10_241_1_10_nvme3n1;nsd_10_241_1_10_nvme4n1;nsd_10_241_1_10_nvme5n1;nsd_10_241_1_10_nvme6n1;
 -d                 nsd_10_241_1_10_nvme7n1;nsd_10_241_1_7_nvme0n1;nsd_10_241_1_7_nvme1n1;nsd_10_241_1_7_nvme2n1;nsd_10_241_1_7_nvme3n1;nsd_10_241_1_7_nvme4n1;nsd_10_241_1_7_nvme5n1;
 -d                 nsd_10_241_1_7_nvme6n1;nsd_10_241_1_7_nvme7n1;nsd_10_241_1_8_nvme0n1;nsd_10_241_1_8_nvme1n1;nsd_10_241_1_8_nvme2n1;nsd_10_241_1_8_nvme3n1;nsd_10_241_1_8_nvme4n1;
 -d                 nsd_10_241_1_8_nvme5n1;nsd_10_241_1_8_nvme6n1;nsd_10_241_1_8_nvme7n1;nsd_10_241_1_9_nvme0n1;nsd_10_241_1_9_nvme1n1;nsd_10_241_1_9_nvme2n1;nsd_10_241_1_9_nvme3n1;
 -d                 nsd_10_241_1_9_nvme4n1;nsd_10_241_1_9_nvme5n1;nsd_10_241_1_9_nvme6n1;nsd_10_241_1_9_nvme7n1  Disks in file system
 -A                 yes                      Automatic mount option
 -o                 none                     Additional mount options
 -T                 /gpfs/fs1                Default mount point
 --mount-priority   0                        Mount priority
```
* The command below shows about the filesystem mounted to all the compute and storage nodes 

```
# mmlsmount all -L
File system fs1 is mounted on 6 nodes:
  10.241.1.8      spectrum-scale-storage-3.strgscale spectrum-scale.storage    
  10.241.1.9      spectrum-scale-storage-1.strgscale spectrum-scale.storage    
  10.241.1.7      spectrum-scale-storage-2.strgscale spectrum-scale.storage    
  10.241.0.5      spectrum-scale-compute-3.compscale spectrum-scale.compute    
  10.241.0.7      spectrum-scale-compute-1.compscale spectrum-scale.compute    
  10.241.0.6      spectrum-scale-compute-2.compscale spectrum-scale.compute 
```
* The command below shows the information about the NSD servers and Disk name

```
# mmlsnsd -a  

 File system   Disk name       NSD servers                                    
------------------------------------------------------------------------------
 fs1           nsd_10_241_1_7_vdb spectrum-scale-storage-2.strgscale.com 
 fs1           nsd_10_241_1_7_vdc spectrum-scale-storage-2.strgscale.com 
 fs1           nsd_10_241_1_8_vdb spectrum-scale-storage-3.strgscale.com 
 fs1           nsd_10_241_1_8_vdc spectrum-scale-storage-3.strgscale.com 
 fs1           nsd_10_241_1_9_vdb spectrum-scale-storage-1.strgscale.com 
 fs1           nsd_10_241_1_9_vdc spectrum-scale-storage-1.strgscale.com 
```

* The command below shows the heath status of the cluster

```
# mmhealth cluster show

Component           Total         Failed       Degraded        Healthy          Other
-------------------------------------------------------------------------------------
NODE                    3              0              0              2              1
GPFS                    3              0              0              2              1
NETWORK                 3              0              0              3              0
FILESYSTEM              1              0              0              1              0
DISK                    6              0              0              6              0
FILESYSMGR              1              0              0              1              0
GUI                     1              0              0              1              0
PERFMON                 3              0              0              3              0
THRESHOLD               3              0              0              3              0

```

* The command below shows the status of the individual nodes

```
# mmhealth node show 

Node name:      spectrum-scale-storage-3.strgscale.com
Node status:    HEALTHY
Status Change:  2 hours ago

Component      Status        Status Change     Reasons & Notices
----------------------------------------------------------------
FILESYSMGR     HEALTHY       2 hours ago       -
GPFS           HEALTHY       2 hours ago       -
NETWORK        HEALTHY       2 hours ago       -
FILESYSTEM     HEALTHY       2 hours ago       -
DISK           HEALTHY       2 hours ago       -
PERFMON        HEALTHY       2 hours ago       -
THRESHOLD      HEALTHY       2 hours ago       -
```
* The command below showcase the feasibility to check the status of node from another node from same cluster i.e(Storage-storage/compute-compute)

```
# mmhealth node show -N 10.241.1.9

Node name:      spectrum-scale-storage-1.strgscale.com
Node status:    HEALTHY
Status Change:  2 hours ago

Component      Status        Status Change     Reasons & Notices
----------------------------------------------------------------
GPFS           HEALTHY       2 hours ago       -
NETWORK        HEALTHY       2 hours ago       -
FILESYSTEM     HEALTHY       2 hours ago       -
DISK           HEALTHY       2 hours ago       -
PERFMON        HEALTHY       2 hours ago       -
THRESHOLD      HEALTHY       2 hours ago       -

```
* The command below show how to access other node from one node in the same cluster
```
# ssh root@10.241.1.9
###########################################################################################
# You have logged in to Instance storage virtual server.                                  #
#   - Instance storage is temporary storage that's available only while your virtual      #
#     server is running.                                                                  #
#   - Data on the drive is unrecoverable after instance shutdown, disruptive maintenance, #
#     or hardware failure.                                                                #
#                                                                                         #
# Refer: https://cloud.ibm.com/docs/vpc?topic=vpc-instance-storage                        #
###########################################################################################
Activate the web console with: systemctl enable --now cockpit.socket

This system is not registered to Red Hat Insights. See https://cloud.redhat.com/
To register this system, run: insights-client --register

Last login: Thu Apr 21 11:49:39 2022 from 10.241.1.5
```

* The command below showcase the autorization between storage and compute cluster

```
# mmauth show
Cluster name:        spectrum-scale.compute
Cipher list:         AUTHONLY
SHA digest:          1645130b96b8518d98b420a80c078638384a3a58a08c100c63e0de9f34501641
File system access:  fs1       (rw, root allowed)

Cluster name:        spectrum-scale.storage (this cluster)
Cipher list:         AUTHONLY
SHA digest:          173bb739f290dab735ce250c1d954d6da1d912aa8b650d5b3fca49ac2e9475fd
File system access:  (all rw)
```

* The command below shows the complete configurations of the cluster

```
# mmlsconfig

Configuration data for cluster spectrum-scale.storage:
------------------------------------------------------
clusterName spectrum-scale.storage
clusterId 14139934390600460176
autoload yes
profile storagesncparams
dmapiFileHandleSize 32
minReleaseLevel 5.1.4.0
tscCmdAllowRemoteConnections no
ccrEnabled yes
cipherList AUTHONLY
sdrNotifyAuthEnabled yes
numaMemoryInterleave yes
ignorePrefetchLUNCount yes
workerThreads 1024
restripeOnDiskFailure yes
unmountOnDiskFail meta
readReplicaPolicy local
nsdSmallThreadRatio 16
nsdThreadsPerQueue 16
nsdbufspace 70
maxFilesToCache 128K
maxStatCache 128K
maxblocksize 16M
maxMBpS 24000
maxReceiverThreads 128
maxTcpConnsPerNodeConn 2
nsdMaxWorkerThreads 1024
nsdMinWorkerThreads 1024
idleSocketTimeout 0
minMissedPingTimeout 60
failureDetectionTime 60
[storagenodegrp]
pagepool 32G
[common]
tscCmdPortRange 60000-61000
adminMode central

File systems in cluster spectrum-scale.storage:
-----------------------------------------------
/dev/fs1

```

Note: The above specified commands can be tried from both compute/storage nodes. The output would be the same, respective of nodes accessed from 

### Replication for IBM Spectrum Scale Persistent
1. IBM Spectrum Scale replication provides high availability at the storage level by having two consistent replicas of the file system; each available for recovery when the other one fails. 
2. The two replicas are kept in-sync by using logical replication-based mirroring that does not require specific support from the underlying disk subsystem.
3. The data and metadata replication features of GPFS are used to maintain a secondary copy of each file system block, relying on the concept of disk failure groups to control the physical placement of the individual copies.

### Steps to validate Replication from Compute and Storage Nodes

* The command below shows the default value of data replica and metadata replicas

```
# mmlsfs all -r

File system attributes for spectrum-scale.storage:/dev/fs1:
===========================================================
flag        value          description
------------------- ------------------------ -----------------------------------
 -r         2            Default number of data replicas
 
# mmlsfs all -m
File system attributes for /dev/fs1:
====================================
flag                value                    description
------------------- ------------------------ -----------------------------------
 -m                 2                        Default number of metadata replicas 
```
* The command below shows the maximum value of data replica and metadata replica that is supported

```
# mmlsfs all -R

File system attributes for spectrum-scale.storage:/dev/fs1:
===========================================================
flag        value          description
------------------- ------------------------ -----------------------------------
 -R         3            Maximum number of data replicas
 
# mmlsfs all -M
File system attributes for /dev/fs1:
====================================
flag                value                    description
------------------- ------------------------ -----------------------------------
 -M                 3                        Maximum number of metadata replicas 
```
* The command below shows the complete block size of the attached disk to cluster using bare metal nodes

```
# mmlsfs fs1 -B

flag                value                    description
------------------- ------------------------ -----------------------------------
 -B                 4194304                  Block size

```

### Steps to Validate Cluster Information Setup from Bootstrap  

* The command below shows the complete storage/compute cluster information

```
# sudo su
# mmcloudworkflows cluster info
 
Spectrum Scale Storage Cluster
|-------------------------------------------|---------------|--------|-----|
|                Instance Id                |   Private IP  | Quorum | GUI |
|-------------------------------------------|---------------|--------|-----|
| 0787_46b70435-ca51-42ed-9953-5723a14329a3 |   10.241.1.9  |   Y    |     |
| 0787_45bf9f53-e480-4e0e-af49-c48a2f5a792e |   10.241.1.7  |   Y    |  Y  |
| 0787_b201c97f-744f-4bf1-8e46-abd175f1cec1 |   10.241.1.8  |   Y    |     |
|-------------------------------------------|---------------|--------|-----|
 
Admin Node: 10.241.1.7
 
Spectrum Scale Compute Cluster
|-------------------------------------------|---------------|--------|-----|
|                Instance Id                |   Private IP  | Quorum | GUI |
|-------------------------------------------|---------------|--------|-----|
| 0787_5d168e74-f278-4fd7-9d59-ee1ac8cb0002 |   10.241.0.7  |   Y    |     |
| 0787_0f8d00e2-4210-4ddd-8c00-427b3bdd9229 |   10.241.0.6  |   Y    |     |
| 0787_cb3a9b6d-d882-4d60-9630-644222756da8 |   10.241.0.5  |   Y    |  Y  |
|-------------------------------------------|---------------|--------|-----|
 
Admin Node: 10.241.0.5

```

* The command below shows how to destroy the storage and compute nodes part of scale cluster

```
# mmcloudworkflows cluster destroy ibmcloud
2022-04-21 14:13:14,594 - INFO - Logging in to file: /var/adm/ras/ibm_cloud_workflow_logs/mm_cloud_workflow_teardown.log_2022-Apr-21_14-13-14

    =======================================================================
    |                          ! Danger Zone !                            |
    ======================================================================|
    |  This workflow, will result in teardown of IBM Spectrum Scale       |
    |  cluster and resources. However, it will not destroy VPC, Bastion   |
    |  Host resources and the s3 bucket.                                  |
    |                                                                     |
    |  Notes:                                                             |
    |  1. Ensure to STOP all your applications before proceeding further. |
    |  2. All IBM Scale Scale instances must be in either 'running',      |
    |     'pending', 'stopping' or 'stopped' state.                       |
    =======================================================================
        
Do you want to continue teardown [y/N]: y
2022-04-21 14:13:33,844 - INFO - Proceeding for tear down ..
2022-04-21 14:13:33,844 - INFO - Obtaining necessary permissions to destroy cluster resources
2022-04-21 14:13:34,695 - INFO - Proceeding to destroy the IBM Spectrum Scale cluster
2022-04-21 14:13:34,695 - INFO - This may take a few minutes to complete.

```
**Note:** 
* For the best user experience with Spectrum scale cluster destruction process, always log into Bootstrap node first and run the above destroy command. Wait a while for the resources related to storage and compute to be deleted.
* Once the above specified command is ran successful, login to IBM Cloud account and access schematics to destroy the resources from the workspace.

### Steps to access storage and compute GUI

* The command below shows need to be ran from local machine to access GUI for storage and compute cluster to monitor resources

```
# eval `ssh-agent`
# ssh-add -k <path_of_region_specific_key>
# ssh -A -L 22443:<GUI_node_IP>:443 -N ubuntu@<bastion_host_IP>
```
**Note:**
* Provide the IP address of the GUI node for compute/storage 
* To fetch the IP, you can login to bootstrap node and run one of the above specified command i.e (mmcloudworkflows cluster info). Block with "Y" shows where the GUI has been installed


<!-- BEGIN_TF_DOCS -->
#### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_http"></a> [http](#requirement_http) | 3.0.1 |
| <a name="requirement_ibm"></a> [ibm](#requirement_ibm) | 1.44.2 |

#### Inputs

| Name | Description | Type |
|------|-------------|------|
| <a name="input_bastion_key_pair"></a> [bastion_key_pair](#input_bastion_key_pair) | Name of the SSH key configured in your IBM Cloud account that is used to establish a connection to the Bastion and Bootstrap nodes. Make Ensure that the SSH key is present in the same resource group and region where the cluster is being provisioned. If you do not have an SSH key in your IBM Cloud account, create one by using the [SSH keys](https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys) instructions. | `string` |
| <a name="input_compute_cluster_gui_password"></a> [compute_cluster_gui_password](#input_compute_cluster_gui_password) | Password that is used for logging in to the compute cluster through the GUI. The password should contain a minimum of eight characters.  For a strong password, use a combination of uppercase and lowercase letters, one number and a special character. Make sure that the password doesn't contain the username. | `string` |
| <a name="input_compute_cluster_gui_username"></a> [compute_cluster_gui_username](#input_compute_cluster_gui_username) | GUI username to perform system management and monitoring tasks on the compute cluster. The Username should be at least 4 characters, (any combination of lowercase and uppercase letters). | `string` |
| <a name="input_compute_cluster_key_pair"></a> [compute_cluster_key_pair](#input_compute_cluster_key_pair) | Name of the SSH key configured in your IBM Cloud account that is used to establish a connection to the Compute cluster nodes. Make sure that the SSH key is present in the same resource group and region where the cluster is provisioned. The solution supports only one ssh key that can be attached to compute nodes. If you do not have an SSH key in your IBM Cloud account, create one by using the [SSH keys](https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys) instructions. | `string` |
| <a name="input_remote_cidr_blocks"></a> [remote_cidr_blocks](#input_remote_cidr_blocks) | Comma-separated list of IP addresses that can be access the Spectrum Scale cluster Bastion node through SSH. For the purpose of security, provide the public IP address(es) assigned to the device(s) authorized to establish SSH connections. (Example : ["169.45.117.34"])  To fetch the IP address of the device, use [https://ipv4.icanhazip.com/](https://ipv4.icanhazip.com/). | `list(string)` |
| <a name="input_storage_cluster_gui_password"></a> [storage_cluster_gui_password](#input_storage_cluster_gui_password) | Password that is used for logging in to the storage cluster through the GUI. The password should contain a minimum of 8 characters. For a strong password, use a combination of uppercase and lowercase letters, one number, and a special character. Make sure that the password doesn't contain the username. | `string` |
| <a name="input_storage_cluster_gui_username"></a> [storage_cluster_gui_username](#input_storage_cluster_gui_username) | GUI username to perform system management and monitoring tasks on the storage cluster. Note: Username should be at least 4 characters, (any combination of lowercase and uppercase letters). | `string` |
| <a name="input_storage_cluster_key_pair"></a> [storage_cluster_key_pair](#input_storage_cluster_key_pair) | Name of the SSH key configured in your IBM Cloud account that is used to establish a connection to the Storage cluster nodes. Make sure that the SSH key is present in the same resource group and region where the cluster is provisioned. The solution supports only one SSH key that can be attached to the storage nodes. If you do not have an SSH key in your IBM Cloud account, create one by using the [SSH keys](https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys) instructions. | `string` |
| <a name="input_vpc_availability_zones"></a> [vpc_availability_zones](#input_vpc_availability_zones) | IBM Cloud availability zone names within the selected region where the Spectrum Scale cluster should be deployed.For the current release, the solution supports only a single availability zone.For more information, see [Region and data center locations for resource deployment](https://cloud.ibm.com/docs/overview?topic=overview-locations). | `list(string)` |
| <a name="input_vpc_region"></a> [vpc_region](#input_vpc_region) | Name of the IBM Cloud region where the resources need to be provisioned.(Examples: us-east, us-south, etc.) For more information, see [Region and data center locations for resource deployment](https://cloud.ibm.com/docs/overview?topic=overview-locations). | `string` |
| <a name="input_TF_PARALLELISM"></a> [TF_PARALLELISM](#input_TF_PARALLELISM) | Limit the number of concurrent operation. | `string` |
| <a name="input_TF_VERSION"></a> [TF_VERSION](#input_TF_VERSION) | The version of the Terraform engine that's used in the Schematics workspace. | `string` |
| <a name="input_bastion_osimage_name"></a> [bastion_osimage_name](#input_bastion_osimage_name) | Name of the image that will be used to provision the Bastion node for the Spectrum Scale cluster. Only Ubuntu stock image of any version available to the IBM Cloud account in the specific region are supported. | `string` |
| <a name="input_bastion_vsi_profile"></a> [bastion_vsi_profile](#input_bastion_vsi_profile) | The virtual server instance profile type name to be used to create the Bastion node. For more information, see [Instance Profiles](https://cloud.ibm.com/docs/vpc?topic=vpc-profiles). | `string` |
| <a name="input_bootstrap_osimage_name"></a> [bootstrap_osimage_name](#input_bootstrap_osimage_name) | Name of the custom image that you would like to use to create the Bootstrap node for the Spectrum Scale cluster. The solution supports only the default custom image that has been provided. | `string` |
| <a name="input_bootstrap_vsi_profile"></a> [bootstrap_vsi_profile](#input_bootstrap_vsi_profile) | The virtual server instance profile type name to be used to create the Bootstrap node. For more information, see [Instance Profiles](https://cloud.ibm.com/docs/vpc?topic=vpc-profiles&interface=ui). | `string` |
| <a name="input_compute_cluster_filesystem_mountpoint"></a> [compute_cluster_filesystem_mountpoint](#input_compute_cluster_filesystem_mountpoint) | Compute cluster (accessing Cluster) file system mount point. The accessingCluster is the cluster that accesses the owningCluster. For more information, see [Mounting a remote GPFS file system](https://www.ibm.com/docs/en/spectrum-scale/5.1.4?topic=system-mounting-remote-gpfs-file). | `string` |
| <a name="input_compute_vsi_osimage_name"></a> [compute_vsi_osimage_name](#input_compute_vsi_osimage_name) | Name of the image that you would like to use to create the compute cluster nodes for the IBM Spectrum Scale cluster. The solution supports both stock and custom images that use RHEL7.9 and 8.4 versions that have the appropriate Spectrum Scale functionality. If you'd like, you can follow the instructions for [Planning for custom images](https://cloud.ibm.com/docs/vpc?topic=vpc-planning-custom-images)to create your own custom image. | `string` |
| <a name="input_compute_vsi_profile"></a> [compute_vsi_profile](#input_compute_vsi_profile) | The virtual server instance profile type name to be used to create the compute cluster nodes. For more information, see [Instance Profiles](https://cloud.ibm.com/docs/vpc?topic=vpc-profiles&interface=ui). | `string` |
| <a name="input_filesystem_block_size"></a> [filesystem_block_size](#input_filesystem_block_size) | File system [block size](https://www.ibm.com/docs/en/spectrum-scale/5.1.4?topic=considerations-block-size). Spectrum Scale supported block sizes (in bytes) include: 256K, 512K, 1M, 2M, 4M, 8M, 16M. | `string` |
| <a name="input_ibm_customer_number"></a> [ibm_customer_number](#input_ibm_customer_number) | The IBM Customer Number (ICN) that is used for the Bring Your Own License (BYOL) entitlement check. Note: An ICN is not required if the storage_type selected is evaluation. For more information on how to find your ICN, see [What is my IBM Customer Number (ICN)?](https://www.ibm.com/support/pages/what-my-ibm-customer-number-icn). | `string` |
| <a name="input_resource_group"></a> [resource_group](#input_resource_group) | Resource group name from your IBM Cloud account where the VPC resources should be deployed. For more information, see[Managing resource groups](https://cloud.ibm.com/docs/account?topic=account-rgs&interface=ui). | `string` |
| <a name="input_resource_prefix"></a> [resource_prefix](#input_resource_prefix) | Prefix that is used to name the IBM Cloud resources that are provisioned to build the Spectrum Scale cluster. Make sure that the prefix is unique since you cannot create multiple resources with the same name. The maximum length of supported characters is 64. | `string` |
| <a name="input_storage_bare_metal_osimage_name"></a> [storage_bare_metal_osimage_name](#input_storage_bare_metal_osimage_name) | Name of the image that you would like to use to create the storage cluster nodes for the Spectrum Scale cluster. The solution supports only a RHEL 8.4 stock image. | `string` |
| <a name="input_storage_bare_metal_server_profile"></a> [storage_bare_metal_server_profile](#input_storage_bare_metal_server_profile) | Specify the bare metal server profile type name to be used to create the bare metal storage nodes. For more information, see [bare metal server profiles](https://cloud.ibm.com/docs/vpc?topic=vpc-bare-metal-servers-profile&interface=ui). | `string` |
| <a name="input_storage_cluster_filesystem_mountpoint"></a> [storage_cluster_filesystem_mountpoint](#input_storage_cluster_filesystem_mountpoint) | Spectrum Scale storage cluster (owningCluster) file system mount point. The owningCluster is the cluster that owns and serves the file system to be mounted. For information, see[Mounting a remote GPFS file system](https://www.ibm.com/docs/en/spectrum-scale/5.1.4?topic=system-mounting-remote-gpfs-file). | `string` |
| <a name="input_storage_type"></a> [storage_type](#input_storage_type) | Select the Spectrum Scale file system deployment method. Note: The Spectrum Scale scratch and evaluation type deploys the Spectrum Scale file system on virtual server instances, and the persistent type deploys the Spectrum Scale file system on bare metal servers. The persistent Spectrum Scale storage feature is a beta feature that is available for prototyping and testing purposes. There are no warranties, SLAs, or support provided for persistent storage and it is not intended for production use. | `string` |
| <a name="input_storage_vsi_osimage_name"></a> [storage_vsi_osimage_name](#input_storage_vsi_osimage_name) | Name of the image that you would like to use to create the storage cluster nodes for the IBM Spectrum Scale cluster. The solution supports both stock and custom images that use RHEL8.4 version and that have the appropriate Spectrum Scale functionality. If you'd like, you can follow the instructions for [Planning for custom images](https://cloud.ibm.com/docs/vpc?topic=vpc-planning-custom-images) create your own custom image. | `string` |
| <a name="input_storage_vsi_profile"></a> [storage_vsi_profile](#input_storage_vsi_profile) | Specify the virtual server instance profile type name to be used to create the Storage nodes. For more information, see [Instance Profiles](https://cloud.ibm.com/docs/vpc?topic=vpc-profiles). | `string` |
| <a name="input_total_compute_cluster_instances"></a> [total_compute_cluster_instances](#input_total_compute_cluster_instances) | Total number of compute cluster instances that you need to provision. A minimum of three nodes and a maximum of 64 nodes are supported. | `number` |
| <a name="input_total_storage_cluster_instances"></a> [total_storage_cluster_instances](#input_total_storage_cluster_instances) | Total number of storage cluster instances that you need to provision. A minimum of three nodes and a maximum of 18 nodes are supported if the storage type selected is scratch. A minimum of three nodes and a maximum of 10 nodes are supported if the storage type selected is persistent. | `number` |
| <a name="input_vpc_cidr_block"></a> [vpc_cidr_block](#input_vpc_cidr_block) | IBM Cloud VPC address prefixes that are needed for VPC creation. Since the solution supports only a single availability zone, provide one CIDR address prefix for VPC creation. For more information, see [Bring your own subnet](https://cloud.ibm.com/docs/vpc?topic=vpc-configuring-address-prefixes). | `list(string)` |
| <a name="input_vpc_compute_cluster_dns_domain"></a> [vpc_compute_cluster_dns_domain](#input_vpc_compute_cluster_dns_domain) | IBM Cloud DNS Services domain name to be used for the compute cluster. | `string` |
| <a name="input_vpc_compute_cluster_private_subnets_cidr_blocks"></a> [vpc_compute_cluster_private_subnets_cidr_blocks](#input_vpc_compute_cluster_private_subnets_cidr_blocks) | The CIDR block that's required for the creation of the compute cluster private subnet. Modify the CIDR block if it has already been reserved or used for other applications within the VPC or conflicts with anyon-premises CIDR blocks when using a hybrid environment. Provide only one CIDR block for the creation of the compute subnet. | `list(string)` |
| <a name="input_vpc_storage_cluster_dns_domain"></a> [vpc_storage_cluster_dns_domain](#input_vpc_storage_cluster_dns_domain) | IBM Cloud DNS Services domain name to be used for the storage cluster. | `string` |
| <a name="input_vpc_storage_cluster_private_subnets_cidr_blocks"></a> [vpc_storage_cluster_private_subnets_cidr_blocks](#input_vpc_storage_cluster_private_subnets_cidr_blocks) | The CIDR block that's required for the creation of the storage cluster private subnet. Modify the CIDR block if it has already been reserved or used for other applications within the VPC or conflicts with any on-premises CIDR blocks when using a hybrid environment. Provide only one CIDR block for the creation of the storage subnet. | `list(string)` |

#### Outputs

| Name | Description |
|------|-------------|
| <a name="output_schematics_controller_ip"></a> [schematics_controller_ip](#output_schematics_controller_ip) | IP that has been used by the schematics side to ssh for bastion node to push the user input data file to create storage and compute cluster. |
| <a name="output_ssh_command"></a> [ssh_command](#output_ssh_command) | SSH command that can be used to login to bootstrap node to destroy the cluster. Use the same command to ssh to any of storage/compute node but update the respective ip of the nodes in place of bootstrap node ip.(Examples: ssh -J <ubuntu@bastionip> <vpcuser@ip of storage/compute node>) |
| <a name="output_trusted_profile_id"></a> [trusted_profile_id](#output_trusted_profile_id) | IBM Cloud Trusted Profile ID. |
| <a name="output_vpc_compute_cluster_dns_service_id"></a> [vpc_compute_cluster_dns_service_id](#output_vpc_compute_cluster_dns_service_id) | IBM Cloud DNS compute cluster resource instance server ID. |
| <a name="output_vpc_compute_cluster_dns_zone_id"></a> [vpc_compute_cluster_dns_zone_id](#output_vpc_compute_cluster_dns_zone_id) | IBM Cloud DNS compute cluster zone ID. |
| <a name="output_vpc_compute_cluster_private_subnets"></a> [vpc_compute_cluster_private_subnets](#output_vpc_compute_cluster_private_subnets) | List of IDs of compute cluster private subnets. |
| <a name="output_vpc_custom_resolver_id"></a> [vpc_custom_resolver_id](#output_vpc_custom_resolver_id) | IBM Cloud DNS custom resolver ID. |
| <a name="output_vpc_id"></a> [vpc_id](#output_vpc_id) | The ID of the VPC. |
| <a name="output_vpc_storage_cluster_dns_service_id"></a> [vpc_storage_cluster_dns_service_id](#output_vpc_storage_cluster_dns_service_id) | IBM Cloud DNS storage cluster resource instance server ID. |
| <a name="output_vpc_storage_cluster_dns_zone_id"></a> [vpc_storage_cluster_dns_zone_id](#output_vpc_storage_cluster_dns_zone_id) | IBM Cloud DNS storage cluster zone ID. |
| <a name="output_vpc_storage_cluster_private_subnets"></a> [vpc_storage_cluster_private_subnets](#output_vpc_storage_cluster_private_subnets) | List of IDs of storage cluster private subnets. |
<!-- END_TF_DOCS -->
