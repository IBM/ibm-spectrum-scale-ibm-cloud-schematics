# **CHANGELOG**

## **2.5.1**
### BUG FIXES
- Updated SGKLM images.

## **2.5.0**
### ENHANCEMENTS
- Enabling AFM feature : Enabling AFM feature allows you to connect IBM Storage Scale filesets to Cloud Object Storage (COS).
- Enabling Encryption with IBM Key Protect : You can now encrypt the Storage Scale cluster file systems using IBM Key Protect. To enable encryption, specify the scale_encryption_xxx deployment values when setting up your workspace. For detailed instructions on enabling encryption and configuring these deployment values, refer to the Enabling Encryption documentation.

## **2.4.0**
### ENHANCEMENTS
- Enabling colocation feature : Enabling colocation designates the subset of Storage server as protocol nodes. If disabled, the protocol nodes are created on a dedicated virtual server irrespective of storage type.
- Enabling boot drive encryption feature for Bare Metal : Enable the boot drive encryption feature for IBM Bare Metal servers on VPC to use the local disk drive for boot. Boot drive encryption encrypts the drive by using LUKS and leverages the local Trusted Platform Module (TPM) for key management.
- Updated Storage Scale software version : The Storage Scale version that is used for the configuration of the compute and storage clusters is updated from version 5.1.9.2 to 5.2.0.1.

## **2.3.2**
### ENHANCEMENTS
- Introducing a single CES hostname that is mapped to all the CES IP addresses to distribute the workload.
- LDAP user integration with password-based authentication.
- Minor encryption, NFS, and security fixes.

## **2.3.1**
### ENHANCEMENTS
- Updated Storage Scale software version: The Storage Scale version used for configuration of the compute and storage clusters has been updated from version 5.1.9.0 to 5.1.9.2
- Updated RHEL stock image versionfor storage node from ibm-redhat-8-8-minimal-amd64-2 to ibm-redhat-8-8-minimal-amd64-3
- Updated RHEL stock image version for compute node from ibm-redhat-7-9-minimal-amd64-11 to ibm-redhat-7-9-minimal-amd64-12

## **2.3.0**
### ENHANCEMENTS
- Enabling CES Feature: You can now enable CES feature to enable access to data stored in Storage Scale. By providing non-zero value to total_protocol_cluster_instances variable.
- User Management: LDAP is an optional component for CES, allowing users to either use an existing LDAP server or set up a new LDAP node specifically for the CES cluster. By setting up the ldap_basedns deployment value to the required domain name during the deployment, the LDAP feature is integrated along with the Scale CES.
- Updated RHEL stock image version: The RHEL stock image version was updated from RHEL 8.6 to RHEL 8.8.
- Updated Storage Scale software version: The Storage Scale version used for configuration of the compute and storage clusters has been updated from version 5.1.8.1 to 5.1.9.0

## **2.2.1**
### ENHANCEMENTS
- Encryption with GKLM: You can now encrypt your Storage Scale cluster file system by using the IBM Security® Guardium® Key Lifecycle Manager (GKLM).
- Parallel vNIC (Virtual Network Interface Controller): Create a secondary vNIC for higher VSI profiles to separate the data and storage traffic across different vNICs for higher bandwidth and better performance.
- Sapphire Rapids-based virtual server instance profile support: The solution now supports deployment of compute nodes on virtual server instance profiles that make use of 4th Generation Intel® Xeon® Scalable processors (code named Sapphire Rapids). Those profiles can be used only with the RHEL 8.8 custom image.

## **2.1.1**
### ENHANCEMENTS
- Support for persistent storage type based on IBM Spectrum Scale deployment on bare metal servers (GA).

## **2.1.0**
### ENHANCEMENTS
- Support for evaluation storage type based on IBM Spectrum Scale developer edition

## **2.0.0**
### ENHANCEMENTS
- Support for persistent storage type based on IBM Spectrum Scale deployment on bare metal servers (beta)

## **1.0.1**
### **BUG FIXES**
- Trusted Profile policy name update 
- Fixed http fetch IP issue

## **1.0.0**
- Initial Release