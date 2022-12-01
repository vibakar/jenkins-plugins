#!/bin/bash -e

environments__list=("mgmt_pre" "mgmt_prd")
environments__list__names=("MGMT-PRE" "MGMT-PRD")

mgmt_pre__actions_list=("enable_autopilot" "cleanup_pvc" "upgrade_vault")
mgmt_pre__actions_list__names=("Enable autopilot" "Cleanup PVC" "Upgrade Vault")

###
mgmt_pre__name="MGMT-PRE"
mgmt_pre__regions_list=("euwe1" "euwe2")
mgmt_pre__regions_list__names=("EUWE1 (Secondary)" "EUWE2 (Primary)")
 
mgmt_pre__euwe1__auth_plugin="True"
mgmt_pre__euwe1__http_proxy="http://k8sproxy-ctu-euwe1.mgmt-pre.oncp.group:8118"
mgmt_pre__euwe1__https_proxy="http://k8sproxy-ctu-euwe1.mgmt-pre.oncp.group:8118"
mgmt_pre__euwe1__no_proxy="googleapis.com"
mgmt_pre__euwe1__project="mgmt-ctu-pre-4195"
mgmt_pre__euwe1__cluster="mgmt-ctu-pre-01-kcl-01-euwe1"
mgmt_pre__euwe1__gcpregion="europe-west1"
mgmt_pre__euwe1__pod_name="hcv1-vault-0"
 
mgmt_pre__euwe2__auth_plugin="True"
mgmt_pre__euwe2__http_proxy="http://k8sproxy-ctu-euwe2.mgmt-pre.oncp.group:8118"
mgmt_pre__euwe2__https_proxy="http://k8sproxy-ctu-euwe2.mgmt-pre.oncp.group:8118"
mgmt_pre__euwe2__no_proxy="googleapis.com"
mgmt_pre__euwe2__project="mgmt-ctu-pre-4195"
mgmt_pre__euwe2__cluster="mgmt-ctu-pre-01-kcl-01-euwe2"
mgmt_pre__euwe2__gcpregion="europe-west2"
mgmt_pre__euwe2__pod_name="hcv2-vault-0"
###
mgmt_prd__name="MGMT-PRD"
mgmt_prd__regions_list=("euwe1prd" "euwe2prd" "euwe1nprd" "euwe2nprd")
mgmt_prd__regions_list__names=("EUWE1-Prod (Secondary)" "EUWE2-Prod (Primary)" "EUWE1-NonProd (Secondary)" "EUWE2-NonProd (Primary)")
 
mgmt_prd__euwe1prd__auth_plugin="True"
mgmt_prd__euwe1prd__http_proxy="http://k8sproxy-ctu-euwe1.mgmt-prd.oncp.io:8118"
mgmt_prd__euwe1prd__https_proxy="http://k8sproxy-ctu-euwe1.mgmt-prd.oncp.io:8118"
mgmt_prd__euwe1prd__no_proxy="googleapis.com"
mgmt_prd__euwe1prd__project="mgmt-ctu-prd-240c"
mgmt_prd__euwe1prd__cluster="mgmt-ctu-prd-01-kcl-02-euwe1"
mgmt_prd__euwe1prd__gcpregion="europe-west1"
mgmt_prd__euwe1prd__pod_name=""

mgmt_prd__euwe2prd__auth_plugin="True"
mgmt_prd__euwe2prd__http_proxy="http://k8sproxy-ctu-euwe2.mgmt-prd.oncp.io:8118"
mgmt_prd__euwe2prd__https_proxy="http://k8sproxy-ctu-euwe2.mgmt-prd.oncp.io:8118"
mgmt_prd__euwe2prd__no_proxy="googleapis.com"
mgmt_prd__euwe2prd__project="mgmt-ctu-prd-240c"
mgmt_prd__euwe2prd__cluster="mgmt-ctu-prd-01-kcl-02-euwe2"
mgmt_prd__euwe2prd__gcpregion="europe-west2"
mgmt_prd__euwe2prd__pod_name=""

mgmt_prd__euwe1nprd__auth_plugin="True"
mgmt_prd__euwe1nprd__http_proxy="http://k8sproxy-ctu-euwe1.mgmt-nonprd.oncp.io:8118"
mgmt_prd__euwe1nprd__https_proxy="http://k8sproxy-ctu-euwe1.mgmt-nonprd.oncp.io:8118"
mgmt_prd__euwe1nprd__no_proxy="googleapis.com"
mgmt_prd__euwe1nprd__project="mgmt-ctu-prd-240c"
mgmt_prd__euwe1nprd__cluster="mgmt-ctu-prd-01-kcl-01-euwe1"
mgmt_prd__euwe1nprd__gcpregion="europe-west1"
mgmt_prd__euwe1nprd__pod_name=""

mgmt_prd__euwe2nprd__auth_plugin="True"
mgmt_prd__euwe2nprd__http_proxy="http://k8sproxy-ctu-euwe2.mgmt-nonprd.oncp.io:8118"
mgmt_prd__euwe2nprd__https_proxy="http://k8sproxy-ctu-euwe2.mgmt-nonprd.oncp.io:8118"
mgmt_prd__euwe2nprd__no_proxy="googleapis.com"
mgmt_prd__euwe2nprd__project="mgmt-ctu-prd-240c"
mgmt_prd__euwe2nprd__cluster="mgmt-ctu-prd-01-kcl-01-euwe2"
mgmt_prd__euwe2nprd__gcpregion="europe-west2"
mgmt_prd__euwe2nprd__pod_name=""

###

function print_action() {
    local text="ACTION: ${1}"
    local separator=$(printf '%*s' ${#text} '')

    echo -e "${text}"
    echo -e "${separator// /=}"
}

function print_info() {
    local text="\e[94mINFO:\e[0m ${1}"
    echo -e "${text}"
}

function select_environment() {
    local idx
    local return=$1
    local environment_input
    
    echo -e
    print_action "Please select an environment from the list below."

    for ((idx=0; idx<${#environments__list__names[@]}; ++idx)); do
        echo "$idx" "${environments__list__names[idx]}"
    done
    echo -e "$idx Exit program"

    read environment_input
    if [[ ${environment_input} == $idx ]]; then echo -e "Goodbye" && return 1; fi
    if [[ ${environment_input} > ${#environments__list__names[@]} ]] || [[ -z ${environment_input} ]]; then print_info "Selection unknown." && return 1; fi
    eval $return="${environments__list[${environment_input}]}"
}

function select_region() {
    local idx
    local return=$1
    local region_input

    echo -e
    print_info "${environment} selected."
    print_action "Please select a KCL Cluster region."

    declare -n regions_list="${environment}__regions_list"
    declare -n regions_list__names="${environment}__regions_list__names"

    for ((idx=0; idx<${#regions_list__names[@]}; ++idx)); do
        echo "$idx" "${regions_list__names[idx]}"
    done
    echo -e "$idx Exit program"

    read region_input

    if [[ ${region_input} == $idx ]]; then echo -e "Goodbye" && return 1; fi
    if [[ ${region_input} > ${#regions_list__names[@]} ]] || [[ -z ${region_input} ]]; then print_info "Selection unknown." && return 1; fi
    eval $return="${regions_list[${region_input}]}"
}

function configure_gcp() {
    echo -e
    print_info "${region} selected."
    print_info "Executing the gcp configuration steps."

    declare -n gcp_auth_plugin="${environment}__${region}__auth_plugin"
    declare -n gcp_http_proxy="${environment}__${region}__http_proxy"
    declare -n gcp_https_proxy="${environment}__${region}__https_proxy"
    declare -n gcp_no_proxy="${environment}__${region}__no_proxy"
    declare -n gcp_project="${environment}__${region}__project"
    declare -n gcp_cluster="${environment}__${region}__cluster"
    declare -n gcp_region="${environment}__${region}__gcpregion"

    export USE_GKE_GCLOUD_AUTH_PLUGIN=${gcp_auth_plugin}
    export http_proxy=${gcp_http_proxy}
    export https_proxy=${gcp_https_proxy}
    export no_proxy=${gcp_no_proxy}

    gcloud config set project ${gcp_project}
    gcloud container clusters get-credentials ${gcp_cluster} --region=${gcp_region}
    # print_action "Please login using your Google Identity."
    # gcloud auth login

    print_info "Setting kubectl context to Namespace ns-kcl-mgmt-ctu-hcv."
    kubectl config set-context --current --namespace=ns-kcl-mgmt-ctu-hcv
}

function mgmt_pre_actions_menu() {
    local further_command

    echo -e
    print_action "Please select an action from the list below."

    for ((idx=0; idx<${#mgmt_pre__actions_list__names[@]}; ++idx)); do
        echo "$idx" "${mgmt_pre__actions_list__names[idx]}"
    done
    echo -e "$idx Exit program"

    read further_command
    if [[ ${further_command} == $idx ]]; then echo -e "Goodbye" && return 1; fi
    if [[ ${further_command} > ${#mgmt_pre__actions_list__names[@]} ]] || [[ -z ${further_command} ]]; then print_info "Selection unknown." && return 1; fi
    ${mgmt_pre__actions_list[${further_command}]}
}

function enable_autopilot() {
    local vault_username

    declare -n pod_name="${environment}__${region}__pod_name"

    echo -e
    print_info "${pod_name} selected."
    print_action "Please provide your vault credentials."
    echo -e "Type your username and press enter:"
    read vault_username

    kubectl exec ${pod_name} -- vault login -method=ldap username=${vault_username}
    kubectl exec ${pod_name} -- vault operator raft autopilot set-config -cleanup-dead-servers=true -dead-server-last-contact-threshold=24h -last-contact-threshold=1m -max-trailing-logs=100 -min-quorum=3 -server-stabilization-time=10s
    kubectl exec ${pod_name} -- vault operator raft autopilot get-config
    kubectl exec ${pod_name} -- vault operator raft list-peers
}

function cleanup_pvc() {
    local pvc_names

    echo -e
    print_info "Getting pods and pvc info."
    kubectl get pods
    kubectl get pvc
    echo -e
    print_action "Type the pvc names you want to delete (separated by space) then press enter."
    read pvc_names
    kubectl delete pvc ${pvc_names}
}

function upgrade_vault() {
    local upgrade_input_1
    local upgrade_input_2

    echo -e
    echo -e "==========================================================================="
    echo -e "\e[1;91mWARNING:\e[0m This option should only be used in MNGT PRE!!!!"
    echo -e "This will delete the 4 STANDBY PODS, please DELETE the LEADER POD manually."
    echo -e "You will only be able to run this with GCP Role: roles/container.admin."
    echo -e "==========================================================================="
    echo -e
    print_action "Do you want to upgrade Vault?"
    echo -e "0 No"
    echo -e "1 Yes"
    read upgrade_input_1

    if [[ -z ${upgrade_input_1} ]]; then print_info "Selection unknown." && return 1; fi
    if [[ "${upgrade_input_1}" == "1" ]]; then
        echo -e
        print_action "Please confirm if you will like to upgrade Vault."
        echo -e [y/N]
        read upgrade_input_2

        if [[ -z ${upgrade_input_2} ]]; then print_info "Selection unknown." && return 1; fi
        case ${upgrade_input_2} in 
            "y"|"Y")
                for i in $(kubectl get pods --selector="vault-active=false" -o jsonpath="{.items[*].metadata.name}"); do 
                    echo -e "\e[1;91mWARNING:\e[0m Pod $i will be deleted."
                    kubectl delete po ${i}
                    print_info "Pausing for 35 seconds to allow pod ${i} to recreate."
                    sleep 35
                    print_info "Gathering logs, last 15 entries for pod ${i}."
                    kubectl logs $i | tail -n 15
                done
                ;;
            *)
                echo -e "Goodbye" && return 0
                ;;
        esac
    elif [[ "${upgrade_input_1}" == "0" ]]; then
        echo -e "Goodbye" && return 0
    else
        print_info "Selection unknown." && return 1;
    fi
}

select_environment environment
if [[ $? != 0 ]]; then return; fi 
select_region region
if [[ $? != 0 ]]; then return; fi 
configure_gcp
if [[ $? != 0 ]]; then return; fi 

if [[ ${environment} == "mgmt_pre" ]]; then 
    mgmt_pre_actions_menu
fi

return 0
