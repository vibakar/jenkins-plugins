#!/bin/bash
echo " Enter the GCP Environment:"
echo "1 MGMT-PRE"
echo "2 MGMT-PRD"
echo -n "ACTION: Please enter your choice: "
while :
do
  read environment
  case $environment in
  "1")
    echo "NOTE: MGMT-PRE SELECTED "
    echo "============================================"
    echo "ACTION: Select KCL Cluster Region: "
    echo "1 EUWE1(Secondary)"
    echo "2 EUWE2(Primary)"
    while :
    do
      read region
      case $region in 
    "1")
      echo "You selected region EUWE$region."
      export USE_GKE_GCLOUD_AUTH_PLUGIN=True
      export http_proxy=http://k8sproxy-ctu-euwe1.mgmt-pre.oncp.group:8118
      export https_proxy=http://k8sproxy-ctu-euwe1.mgmt-pre.oncp.group:8118
      export no_proxy=googleapis.com
      gcloud config set project mgmt-ctu-pre-4195
      gcloud container clusters get-credentials mgmt-ctu-pre-01-kcl-01-euwe1 --region=europe-west1
      echo "ACTION: Please login using your Google Identity:"
      #gcloud auth login
      echo "Setting kubectl context to Namespace ns-kcl-mgmt-ctu-hcv: "
      kubectl config set-context --current --namespace=ns-kcl-mgmt-ctu-hcv
      break ;;
    "2")
      echo "NOTE: You selected region EUWE$region."
      export USE_GKE_GCLOUD_AUTH_PLUGIN=True
      export http_proxy=http://k8sproxy-ctu-euwe2.mgmt-pre.oncp.group:8118
      export https_proxy=http://k8sproxy-ctu-euwe2.mgmt-pre.oncp.group:8118
      export no_proxy=googleapis.com
      gcloud config set project mgmt-ctu-pre-4195
      gcloud container clusters get-credentials mgmt-ctu-pre-01-kcl-01-euwe2 --region=europe-west2
      echo "ACTION: Please login using your Google Identity:"
      #gcloud auth login
      echo "NOTE: Setting kubectl context to Namespace ns-kcl-mgmt-ctu-hcv: "
      kubectl config set-context --current --namespace=ns-kcl-mgmt-ctu-hcv
      break ;;
      esac
    done
    echo "============================================="
    echo "WARNING: This option should only be used in MNGT PRE!!!! This will delete the 4 STANDBY PODS, please DELETE the LEADER POD manually. You will only be able to run this with GCP Role: roles/container.admin"
    echo "============================================="
    echo "ACTION: **** Upgrade Vault ? **** "
    echo "1 Yes"
    echo "2 No"
    echo "ACTION: Please confirm if you will like to upgrade Vault: "
    while :
    do
      read upgradedecision
      case $upgradedecision in 
    "1")
      for i in $( kubectl get pods  --selector="vault-active=false" -o jsonpath="{.items[*].metadata.name}" ) ; 
        do 
        echo "WARNING: Pod $i will be deleted."; 
        kubectl delete po $i ;
        echo "NOTE: Pausing for 35 seconds to allow pod $i to recreate.";
        sleep 35;
        echo "INFO: GATHERING LOGS - last 15 entries for pod $i."
        kubectl logs $i | tail -n 15;
        done
      break ;;
    "2")
      echo "NOTE: EXITING SCRIPT."
      break 
      esac
    done
    break
    ;;
  "2")
    echo -n "NOTE: MGMT-PRD Selected"
    echo "============================================"
    echo "ACTION: Select KCL Cluster Region: "
    echo "1 EUWE1-Prod(Secondary)"
    echo "2 EUWE2-Prod(Primary)"
    echo "3 EUWE1-NonProd(Secondary)"
    echo "4 EUWE2-NonProd(Primary)"
    while :
    do
      read region
      case $region in 
    "1")
      echo "You selected region EUWE$region-Prod."
      export USE_GKE_GCLOUD_AUTH_PLUGIN=True
      export http_proxy=http://k8sproxy-ctu-euwe1.mgmt-prd.oncp.io:8118
      export https_proxy=http://k8sproxy-ctu-euwe1.mgmt-prd.oncp.io:8118
      export no_proxy=googleapis.com
      gcloud config set project mgmt-ctu-prd-240c
      gcloud container clusters get-credentials mgmt-ctu-prd-01-kcl-02-euwe1 --region=europe-west1
      echo "ACTION: Please login using your Google Identity:"
      #gcloud auth login
      echo "Setting kubectl context to Namespace ns-kcl-mgmt-ctu-hcv: "
      kubectl config set-context --current --namespace=ns-kcl-mgmt-ctu-hcv
      break ;;
    "2")
      echo "NOTE: You selected region EUWE$region-Prod."
      export USE_GKE_GCLOUD_AUTH_PLUGIN=True
      export http_proxy=http://k8sproxy-ctu-euwe2.mgmt-prd.oncp.io:8118
      export https_proxy=http://k8sproxy-ctu-euwe2.mgmt-prd.oncp.io:8118
      export no_proxy=googleapis.com
      gcloud config set project mgmt-ctu-prd-240c
      gcloud container clusters get-credentials mgmt-ctu-prd-01-kcl-02-euwe2 --region=europe-west2
      echo "ACTION: Please login using your Google Identity:"
      #gcloud auth login
      echo "NOTE: Setting kubectl context to Namespace ns-kcl-mgmt-ctu-hcv: "
      kubectl config set-context --current --namespace=ns-kcl-mgmt-ctu-hcv
      break ;;
    "3")
      echo "NOTE: You selected region EUWE1-NonProd."
      export USE_GKE_GCLOUD_AUTH_PLUGIN=True
      export http_proxy=http://k8sproxy-ctu-euwe1.mgmt-nonprd.oncp.io:8118
      export https_proxy=http://k8sproxy-ctu-euwe1.mgmt-nonprd.oncp.io:8118
      export no_proxy=googleapis.com
      gcloud config set project mgmt-ctu-prd-240c
      gcloud container clusters get-credentials mgmt-ctu-prd-01-kcl-01-euwe1 --region=europe-west1
      echo "ACTION: Please login using your Google Identity:"
      #gcloud auth login
      echo "NOTE: Setting kubectl context to Namespace ns-kcl-mgmt-ctu-hcv: "
      kubectl config set-context --current --namespace=ns-kcl-mgmt-ctu-hcv
      break ;;
    "4")
      echo "NOTE: You selected region EUWE1-NonProd."
      export USE_GKE_GCLOUD_AUTH_PLUGIN=True
      export http_proxy=http://k8sproxy-ctu-euwe2.mgmt-nonprd.oncp.io:8118
      export https_proxy=http://k8sproxy-ctu-euwe2.mgmt-nonprd.oncp.io:8118
      export no_proxy=googleapis.com
      gcloud config set project mgmt-ctu-prd-240c
      gcloud container clusters get-credentials mgmt-ctu-prd-01-kcl-01-euwe2 --region=europe-west2
      echo "ACTION: Please login using your Google Identity:"
      #gcloud auth login
      echo "NOTE: Setting kubectl context to Namespace ns-kcl-mgmt-ctu-hcv: "
      kubectl config set-context --current --namespace=ns-kcl-mgmt-ctu-hcv
      break ;;
      esac
    done
    break
    ;;

  *)
    echo -n "unknown"
    ;;
  esac
done
